import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

/// Real in-memory Drift coverage for the Flashcard List read/mutation paths
/// (`docs/wireframes/06-flashcard-list.md`,
/// `docs/contracts/repository-contracts/flashcard-repository.md`).
void main() {
  late AppDatabase db;
  late FolderDao folderDao;
  late FlashcardRepositoryImpl repo;
  late FolderRepositoryImpl folderRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    folderDao = FolderDao(db);
    repo = FlashcardRepositoryImpl(FlashcardDao(db), folderDao);
    folderRepo = FolderRepositoryImpl(folderDao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<Deck> seedDeck() async {
    final Folder folder =
        (await folderRepo.createRootFolder(name: 'Korean') as Ok<Folder>).value;
    return (await folderRepo.createDeck(
              parentFolderId: folder.id,
              name: 'N5',
              targetLanguage: TargetLanguage.korean,
            )
            as Ok<Deck>)
        .value;
  }

  Future<void> addCard(
    DeckId deckId,
    String id,
    String front,
    String back,
    int order, {
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) async {
    final int now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            exampleSentence: Value<String?>(exampleSentence),
            pronunciation: Value<String?>(pronunciation),
            hint: Value<String?>(hint),
            sortOrder: Value<int>(order),
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (final String tag in tags) {
      await db
          .into(db.flashcardTags)
          .insert(FlashcardTagsCompanion.insert(flashcardId: id, tag: tag));
    }
  }

  Future<void> setProgress(
    FlashcardId flashcardId, {
    required int boxNumber,
    required int dueAt,
    required bool isSuspended,
    required int reviewCount,
    required int lapseCount,
    int? buriedUntil,
    int? lastStudiedAt,
  }) async {
    await (db.update(db.flashcardProgress)..where(
          (FlashcardProgress row) => row.flashcardId.equals(flashcardId),
        ))
        .write(
          FlashcardProgressCompanion(
            boxNumber: Value<int>(boxNumber),
            dueAt: Value<int?>(dueAt),
            buriedUntil: Value<int?>(buriedUntil),
            isSuspended: Value<bool>(isSuspended),
            reviewCount: Value<int>(reviewCount),
            lapseCount: Value<int>(lapseCount),
            lastStudiedAt: Value<int?>(lastStudiedAt),
          ),
        );
  }

  Future<FlashcardListDetail> load(DeckId deckId, {String? search}) async {
    final Result<FlashcardListDetail> result = await repo
        .watchFlashcardList(deckId, searchTerm: search)
        .first;
    return (result as Ok<FlashcardListDetail>).value;
  }

  group('watchFlashcardList', () {
    test('loaded — returns deck, breadcrumb, ordered cards, total', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', '안녕하세요', 'Hello', 0);
      await addCard(deck.id, 'c2', '감사합니다', 'Thank you', 1);

      final FlashcardListDetail detail = await load(deck.id);

      expect(detail.deck.name, 'N5');
      expect(detail.totalCount, 2);
      expect(detail.cards.map((c) => c.front), <String>['안녕하세요', '감사합니다']);
      // Breadcrumb is the folder chain (Library root segment is added in UI).
      expect(detail.breadcrumb.single.name, 'Korean');
    });

    test('empty deck — zero cards, totalCount 0', () async {
      final Deck deck = await seedDeck();

      final FlashcardListDetail detail = await load(deck.id);

      expect(detail.cards, isEmpty);
      expect(detail.totalCount, 0);
    });

    test(
      'search no-results keeps totalCount > 0 (distinct from empty deck)',
      () async {
        final Deck deck = await seedDeck();
        await addCard(deck.id, 'c1', '안녕하세요', 'Hello', 0);

        final FlashcardListDetail detail = await load(deck.id, search: 'zzz');

        expect(detail.cards, isEmpty);
        expect(detail.totalCount, 1);
      },
    );

    test('search matches front/back substring', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', '안녕하세요', 'Hello', 0);
      await addCard(deck.id, 'c2', '감사합니다', 'Thank you', 1);

      final FlashcardListDetail detail = await load(deck.id, search: 'thank');

      expect(detail.cards.single.front, '감사합니다');
      expect(detail.totalCount, 2);
    });

    test('search matches pronunciation and hint content', () async {
      final Deck deck = await seedDeck();
      await addCard(
        deck.id,
        'c1',
        '안녕하세요',
        'Hello',
        0,
        pronunciation: 'annyeonghaseyo',
      );
      await addCard(
        deck.id,
        'c2',
        '연구자',
        'Researcher',
        1,
        hint: 'research + person',
      );

      final FlashcardListDetail pronunciationDetail = await load(
        deck.id,
        search: 'annyeong',
      );
      final FlashcardListDetail hintDetail = await load(
        deck.id,
        search: 'person',
      );

      expect(pronunciationDetail.cards.single.front, '안녕하세요');
      expect(hintDetail.cards.single.front, '연구자');
    });

    test('unknown deck id surfaces a NotFoundFailure', () async {
      final Result<FlashcardListDetail> result = await repo
          .watchFlashcardList('missing')
          .first;

      expect(result, isA<Err<FlashcardListDetail>>());
      expect(
        (result as Err<FlashcardListDetail>).failure,
        isA<NotFoundFailure>(),
      );
    });
  });

  group('createFlashcard', () {
    test('creates a card with trimmed text and seeds progress', () async {
      final Deck deck = await seedDeck();

      final Result<Flashcard> result = await repo.createFlashcard(
        deckId: deck.id,
        front: '  안녕하세요  ',
        back: '  Hello  ',
        exampleSentence: '  Example sentence  ',
        pronunciation: '  annyeonghaseyo  ',
        hint: '  Greeting root  ',
        tags: <String>['topik ii', 'noun', 'noun'],
      );

      expect(result, isA<Ok<Flashcard>>());
      final Flashcard created = (result as Ok<Flashcard>).value;
      expect(created.front, '안녕하세요');
      expect(created.back, 'Hello');
      expect(created.exampleSentence, 'Example sentence');
      expect(created.pronunciation, 'annyeonghaseyo');
      expect(created.hint, 'Greeting root');
      expect(created.sortOrder, 0);

      final List<FlashcardTagRow> tagRows = await db
          .select(db.flashcardTags)
          .get();
      expect(tagRows.map((row) => row.tag), <String>['topik ii', 'noun']);

      final List<FlashcardProgressRow> progressRows = await db
          .select(db.flashcardProgress)
          .get();
      expect(progressRows, hasLength(1));
      expect(progressRows.single.flashcardId, created.id);
      expect(progressRows.single.dueAt, isA<int>());
    });

    test('unknown deck returns NotFoundFailure and inserts nothing', () async {
      final Result<Flashcard> result = await repo.createFlashcard(
        deckId: 'missing',
        front: 'Hello',
        back: 'World',
        tags: <String>['tag'],
      );

      expect(result, isA<Err<Flashcard>>());
      expect((result as Err<Flashcard>).failure, isA<NotFoundFailure>());
      expect(await db.select(db.flashcards).get(), isEmpty);
      expect(await db.select(db.flashcardProgress).get(), isEmpty);
    });
  });

  group('commitDeckImport', () {
    test('commits valid rows and seeds progress in one transaction', () async {
      final Deck deck = await seedDeck();

      final Result<int> result = await repo.commitDeckImport(
        deckId: deck.id,
        rows: const <DeckImportPreviewRow>[
          DeckImportPreviewRow(lineNumber: 2, front: 'Hello', back: 'World'),
          DeckImportPreviewRow(
            lineNumber: 3,
            front: 'Goodbye',
            back: 'Farewell',
          ),
        ],
      );

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 2);

      final List<FlashcardRow> flashcardRows = await db
          .select(db.flashcards)
          .get();
      expect(flashcardRows, hasLength(2));
      expect(flashcardRows.map((row) => row.front), <String>[
        'Hello',
        'Goodbye',
      ]);
      expect(flashcardRows.map((row) => row.sortOrder), <int>[0, 1]);

      final List<FlashcardProgressRow> progressRows = await db
          .select(db.flashcardProgress)
          .get();
      expect(progressRows, hasLength(2));
      expect(progressRows.every((row) => row.dueAt != null), isTrue);
    });

    test(
      'rolls back the whole transaction when a later row fails validation',
      () async {
        final Deck deck = await seedDeck();

        final Result<int> result = await repo.commitDeckImport(
          deckId: deck.id,
          rows: const <DeckImportPreviewRow>[
            DeckImportPreviewRow(lineNumber: 2, front: 'Hello', back: 'World'),
            DeckImportPreviewRow(lineNumber: 3, front: '   ', back: 'Ignored'),
          ],
        );

        expect(result, isA<Err<int>>());
        expect((result as Err<int>).failure, isA<ValidationFailure>());
        expect(await db.select(db.flashcards).get(), isEmpty);
        expect(await db.select(db.flashcardProgress).get(), isEmpty);
      },
    );
  });

  group('getFlashcardDetail', () {
    test('returns deck, breadcrumb, tags, and progress snapshot', () async {
      final Deck deck = await seedDeck();
      final Result<Flashcard> createdResult = await repo.createFlashcard(
        deckId: deck.id,
        front: '안녕하세요',
        back: 'Hello',
        exampleSentence: 'Example sentence',
        pronunciation: 'annyeonghaseyo',
        hint: 'Greeting root',
        tags: <String>['noun', 'greeting'],
      );
      final Flashcard created = (createdResult as Ok<Flashcard>).value;
      await setProgress(
        created.id,
        boxNumber: 4,
        dueAt: DateTime.utc(2026, 1, 2).millisecondsSinceEpoch,
        isSuspended: true,
        reviewCount: 7,
        lapseCount: 2,
        buriedUntil: DateTime.utc(2026, 1, 3).millisecondsSinceEpoch,
        lastStudiedAt: DateTime.utc(2026, 1, 1).millisecondsSinceEpoch,
      );

      final Result<FlashcardDetail> result = await repo.getFlashcardDetail(
        flashcardId: created.id,
      );

      expect(result, isA<Ok<FlashcardDetail>>());
      final FlashcardDetail detail = (result as Ok<FlashcardDetail>).value;
      expect(detail.deck.id, deck.id);
      expect(detail.breadcrumb.single.name, 'Korean');
      expect(detail.flashcard.front, '안녕하세요');
      expect(detail.flashcard.back, 'Hello');
      expect(detail.tags, unorderedEquals(<String>['noun', 'greeting']));
      expect(detail.progress, isA<FlashcardProgressSnapshot>());
      expect(detail.progress!.boxNumber, 4);
      expect(detail.progress!.isSuspended, isTrue);
      expect(detail.progress!.reviewCount, 7);
      expect(detail.progress!.lapseCount, 2);
    });

    test('unknown card id surfaces a NotFoundFailure', () async {
      final Result<FlashcardDetail> result = await repo.getFlashcardDetail(
        flashcardId: 'missing',
      );

      expect(result, isA<Err<FlashcardDetail>>());
      expect((result as Err<FlashcardDetail>).failure, isA<NotFoundFailure>());
    });
  });

  group('updateFlashcard', () {
    test('replaces tags and resets progress when asked', () async {
      final Deck deck = await seedDeck();
      final Result<Flashcard> createdResult = await repo.createFlashcard(
        deckId: deck.id,
        front: '안녕하세요',
        back: 'Hello',
        exampleSentence: 'Example sentence',
        pronunciation: 'annyeonghaseyo',
        hint: 'Greeting root',
        tags: <String>['noun', 'greeting'],
      );
      final Flashcard created = (createdResult as Ok<Flashcard>).value;
      await setProgress(
        created.id,
        boxNumber: 4,
        dueAt: DateTime.utc(2026, 1, 2).millisecondsSinceEpoch,
        isSuspended: true,
        reviewCount: 7,
        lapseCount: 2,
        buriedUntil: DateTime.utc(2026, 1, 3).millisecondsSinceEpoch,
        lastStudiedAt: DateTime.utc(2026, 1, 1).millisecondsSinceEpoch,
      );

      final Result<Flashcard> result = await repo.updateFlashcard(
        flashcardId: created.id,
        front: '  안녕  ',
        back: '  Hello there  ',
        exampleSentence: '  Example sentence  ',
        pronunciation: '  annyeonghaseyo  ',
        hint: '  Greeting root  ',
        tags: <String>['verb', 'noun', 'verb'],
        progressPolicy: FlashcardProgressEditPolicy.resetProgress,
      );

      expect(result, isA<Ok<Flashcard>>());
      final Flashcard updated = (result as Ok<Flashcard>).value;
      expect(updated.front, '안녕');
      expect(updated.back, 'Hello there');

      final Result<FlashcardDetail> detailResult = await repo
          .getFlashcardDetail(flashcardId: created.id);
      final FlashcardDetail detail =
          (detailResult as Ok<FlashcardDetail>).value;
      expect(detail.tags, unorderedEquals(<String>['verb', 'noun']));
      expect(detail.progress!.boxNumber, 1);
      expect(detail.progress!.reviewCount, 0);
      expect(detail.progress!.lapseCount, 0);
      expect(detail.progress!.isSuspended, isFalse);
      expect(detail.progress!.buriedUntil, equals(null));
    });
  });

  group('deleteFlashcard', () {
    test('removes the card; list refreshes without it', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', 'A', 'a', 0);
      await addCard(deck.id, 'c2', 'B', 'b', 1);

      final Result<void> result = await repo.deleteFlashcard(flashcardId: 'c1');

      expect(result, isA<Ok<void>>());
      final FlashcardListDetail detail = await load(deck.id);
      expect(detail.totalCount, 1);
      expect(detail.cards.single.id, 'c2');
    });

    test('unknown card id surfaces a NotFoundFailure', () async {
      final Result<void> result = await repo.deleteFlashcard(
        flashcardId: 'missing',
      );

      expect((result as Err<void>).failure, isA<NotFoundFailure>());
    });
  });

  group('reorderFlashcards', () {
    test('persists sort_order by list position', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', 'A', 'a', 0);
      await addCard(deck.id, 'c2', 'B', 'b', 1);
      await addCard(deck.id, 'c3', 'C', 'c', 2);

      final Result<void> result = await repo.reorderFlashcards(
        deckId: deck.id,
        orderedIds: <String>['c3', 'c1', 'c2'],
      );

      expect(result, isA<Ok<void>>());
      final FlashcardListDetail detail = await load(deck.id);
      expect(detail.cards.map((c) => c.id), <String>['c3', 'c1', 'c2']);
    });
  });

  group('deleteDeck (FolderRepository)', () {
    test('cascades cards and makes the list NotFound', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', 'A', 'a', 0);

      final Result<void> result = await folderRepo.deleteDeck(deckId: deck.id);

      expect(result, isA<Ok<void>>());
      final Result<FlashcardListDetail> after = await repo
          .watchFlashcardList(deck.id)
          .first;
      expect(
        (after as Err<FlashcardListDetail>).failure,
        isA<NotFoundFailure>(),
      );
    });
  });
}
