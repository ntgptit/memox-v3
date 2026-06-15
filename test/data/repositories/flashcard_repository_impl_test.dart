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
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
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
    bool withProgress = false,
    int? dueAt,
    int? buriedUntil,
    bool isSuspended = false,
    int reviewCount = 0,
    int lapseCount = 0,
    int? lastStudiedAt,
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
    if (withProgress) {
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: id,
              dueAt: Value<int?>(dueAt),
              buriedUntil: Value<int?>(buriedUntil),
              isSuspended: Value<bool>(isSuspended),
              reviewCount: Value<int>(reviewCount),
              lapseCount: Value<int>(lapseCount),
              lastStudiedAt: Value<int?>(lastStudiedAt),
            ),
          );
    }
    final Set<String> seenTags = <String>{};
    for (final String tag in tags) {
      final String normalizedTag = TagValidator.storageValue(tag);
      if (normalizedTag.isEmpty || !seenTags.add(normalizedTag)) {
        continue;
      }
      await db
          .into(db.flashcardTags)
          .insert(
            FlashcardTagsCompanion.insert(flashcardId: id, tag: normalizedTag),
          );
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

  Future<FlashcardListDetail> load(
    DeckId deckId, {
    String? search,
    FlashcardStatusFilter statusFilter = FlashcardStatusFilter.all,
    List<String> selectedTags = const <String>[],
    DateTime? now,
  }) async {
    final Result<FlashcardListDetail> result = await repo
        .watchFlashcardList(
          deckId,
          searchTerm: search,
          statusFilter: statusFilter,
          selectedTags: selectedTags,
          now: now,
        )
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

    test('statusFilter all matches the default list order', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', '안녕하세요', 'Hello', 0);
      await addCard(deck.id, 'c2', '감사합니다', 'Thank you', 1);

      final FlashcardListDetail defaultDetail = await load(deck.id);
      final FlashcardListDetail allDetail = await load(
        deck.id,
        statusFilter: FlashcardStatusFilter.all,
      );

      expect(allDetail.cards.map((c) => c.id), <String>['c1', 'c2']);
      expect(
        allDetail.cards.map((c) => c.id),
        defaultDetail.cards.map((c) => c.id),
      );
      expect(allDetail.totalCount, 2);
    });

    test(
      'active filters exclude suspended and currently buried cards and keep expired-buried cards',
      () async {
        final Deck deck = await seedDeck();
        final DateTime now = DateTime.utc(2026, 1, 15, 12);
        await addCard(deck.id, 'active', 'Active', 'Card', 0);
        await addCard(
          deck.id,
          'suspended',
          'Suspended',
          'Card',
          1,
          withProgress: true,
          dueAt: now.millisecondsSinceEpoch - 1000,
          isSuspended: true,
        );
        await addCard(
          deck.id,
          'buried',
          'Buried',
          'Card',
          2,
          withProgress: true,
          dueAt: now.millisecondsSinceEpoch - 1000,
          buriedUntil: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        );
        await addCard(
          deck.id,
          'expired',
          'Expired',
          'Card',
          3,
          withProgress: true,
          dueAt: now.millisecondsSinceEpoch + 1000,
          buriedUntil: now
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
        );

        final FlashcardListDetail detail = await load(
          deck.id,
          statusFilter: FlashcardStatusFilter.active,
          now: now,
        );

        expect(detail.cards.map((c) => c.id), <String>['active', 'expired']);
        expect(detail.totalCount, 4);
      },
    );

    test(
      'due filters include past-due and due-now cards and exclude future-due, suspended, and buried cards',
      () async {
        final Deck deck = await seedDeck();
        final Folder otherFolder =
            (await folderRepo.createRootFolder(name: 'Other') as Ok<Folder>)
                .value;
        final Deck otherDeck =
            (await folderRepo.createDeck(
                      parentFolderId: otherFolder.id,
                      name: 'Other deck',
                      targetLanguage: TargetLanguage.korean,
                    )
                    as Ok<Deck>)
                .value;
        final DateTime now = DateTime.utc(2026, 1, 15, 12);
        await addCard(
          deck.id,
          'past',
          'Past due',
          'Alpha',
          0,
          withProgress: true,
          dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        );
        await addCard(
          deck.id,
          'now',
          'Due now',
          'Beta',
          1,
          withProgress: true,
          dueAt: now.millisecondsSinceEpoch,
        );
        await addCard(
          deck.id,
          'future',
          'Future due',
          'Gamma',
          2,
          withProgress: true,
          dueAt: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        );
        await addCard(
          deck.id,
          'suspended',
          'Suspended due',
          'Delta',
          3,
          withProgress: true,
          dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
          isSuspended: true,
        );
        await addCard(
          deck.id,
          'buried',
          'Buried due',
          'Epsilon',
          4,
          withProgress: true,
          dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
          buriedUntil: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        );
        await addCard(
          deck.id,
          'expired',
          'Expired buried due',
          'Zeta',
          5,
          withProgress: true,
          dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
          buriedUntil: now
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
        );
        await addCard(
          otherDeck.id,
          'other',
          'Other deck due',
          'Eta',
          0,
          withProgress: true,
          dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        );

        final FlashcardListDetail detail = await load(
          deck.id,
          statusFilter: FlashcardStatusFilter.due,
          now: now,
        );

        expect(detail.cards.map((c) => c.id), <String>[
          'past',
          'now',
          'expired',
        ]);
        expect(detail.totalCount, 6);
      },
    );

    test('due filters compose with search term', () async {
      final Deck deck = await seedDeck();
      final DateTime now = DateTime.utc(2026, 1, 15, 12);
      await addCard(
        deck.id,
        'past',
        'Alpha past due',
        'Alpha',
        0,
        withProgress: true,
        dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await addCard(
        deck.id,
        'now',
        'Beta due now',
        'Beta',
        1,
        withProgress: true,
        dueAt: now.millisecondsSinceEpoch,
      );

      final FlashcardListDetail detail = await load(
        deck.id,
        search: 'beta',
        statusFilter: FlashcardStatusFilter.due,
        now: now,
      );

      expect(detail.cards.map((c) => c.id), <String>['now']);
      expect(detail.totalCount, 2);
    });

    test('suspended filter returns only suspended cards', () async {
      final Deck deck = await seedDeck();
      final DateTime now = DateTime.utc(2026, 1, 15, 12);
      await addCard(
        deck.id,
        's1',
        'Suspended one',
        'Card',
        0,
        withProgress: true,
        dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        isSuspended: true,
      );
      await addCard(
        deck.id,
        's2',
        'Suspended two',
        'Card',
        1,
        withProgress: true,
        dueAt: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        buriedUntil: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        isSuspended: true,
      );
      await addCard(
        deck.id,
        'active',
        'Active',
        'Card',
        2,
        withProgress: true,
        dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      );

      final FlashcardListDetail detail = await load(
        deck.id,
        statusFilter: FlashcardStatusFilter.suspended,
        now: now,
      );

      expect(detail.cards.map((c) => c.id), <String>['s1', 's2']);
      expect(detail.totalCount, 3);
    });

    test('buried filter returns only currently buried cards', () async {
      final Deck deck = await seedDeck();
      final DateTime now = DateTime.utc(2026, 1, 15, 12);
      await addCard(
        deck.id,
        'buried1',
        'Buried one',
        'Card',
        0,
        withProgress: true,
        dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        buriedUntil: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await addCard(
        deck.id,
        'buried2',
        'Buried two',
        'Card',
        1,
        withProgress: true,
        dueAt: now.millisecondsSinceEpoch,
        buriedUntil: now.add(const Duration(days: 2)).millisecondsSinceEpoch,
        isSuspended: true,
      );
      await addCard(
        deck.id,
        'expired',
        'Expired buried',
        'Card',
        2,
        withProgress: true,
        dueAt: now.millisecondsSinceEpoch,
        buriedUntil: now
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch,
      );

      final FlashcardListDetail detail = await load(
        deck.id,
        statusFilter: FlashcardStatusFilter.buried,
        now: now,
      );

      expect(detail.cards.map((c) => c.id), <String>['buried1', 'buried2']);
      expect(detail.totalCount, 3);
    });

    test('empty selected tags returns all cards', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', 'One', 'Alpha', 0, tags: <String>['weak']);
      await addCard(deck.id, 'c2', 'Two', 'Beta', 1, tags: <String>['grammar']);

      final FlashcardListDetail detail = await load(
        deck.id,
        selectedTags: const <String>[],
      );

      expect(detail.cards.map((c) => c.id), <String>['c1', 'c2']);
      expect(detail.totalCount, 2);
    });

    test('single normalized tag filter stays deck-scoped', () async {
      final Deck deck = await seedDeck();
      final Folder otherFolder =
          (await folderRepo.createRootFolder(name: 'Other') as Ok<Folder>)
              .value;
      final Deck otherDeck =
          (await folderRepo.createDeck(
                    parentFolderId: otherFolder.id,
                    name: 'Other deck',
                    targetLanguage: TargetLanguage.korean,
                  )
                  as Ok<Deck>)
              .value;
      await addCard(deck.id, 'c1', 'One', 'Alpha', 0, tags: <String>['weak']);
      await addCard(deck.id, 'c3', 'Three', 'Gamma', 1, tags: <String>['WEAK']);
      await addCard(
        otherDeck.id,
        'c2',
        'Two',
        'Beta',
        0,
        tags: <String>['WEAK'],
      );

      final FlashcardListDetail detail = await load(
        deck.id,
        selectedTags: <String>['#WEAK'],
      );

      expect(detail.cards.map((c) => c.id), <String>['c1', 'c3']);
      expect(detail.totalCount, 2);
    });

    test('multiple selected tags use AND semantics', () async {
      final Deck deck = await seedDeck();
      await addCard(
        deck.id,
        'both',
        'Both tags',
        'Alpha',
        0,
        tags: <String>['weak', 'grammar'],
      );
      await addCard(
        deck.id,
        'one',
        'One tag',
        'Beta',
        1,
        tags: <String>['weak'],
      );
      await addCard(
        deck.id,
        'other',
        'Other tag',
        'Gamma',
        2,
        tags: <String>['grammar'],
      );

      final FlashcardListDetail detail = await load(
        deck.id,
        selectedTags: <String>['grammar', 'weak'],
      );

      expect(detail.cards.map((c) => c.id), <String>['both']);
      expect(detail.totalCount, 3);
    });

    test('tag filter composes with search term and status filter', () async {
      final Deck deck = await seedDeck();
      final DateTime now = DateTime.utc(2026, 1, 15, 12);
      await addCard(
        deck.id,
        'match',
        'Beta weak due',
        'Alpha',
        0,
        tags: <String>['weak', 'grammar'],
        withProgress: true,
        dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await addCard(
        deck.id,
        'wrongTag',
        'Beta other due',
        'Beta',
        1,
        tags: <String>['other'],
        withProgress: true,
        dueAt: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await addCard(
        deck.id,
        'wrongStatus',
        'Beta weak future',
        'Gamma',
        2,
        tags: <String>['weak'],
        withProgress: true,
        dueAt: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );

      final FlashcardListDetail detail = await load(
        deck.id,
        search: 'beta',
        statusFilter: FlashcardStatusFilter.due,
        selectedTags: <String>['WEAK'],
        now: now,
      );

      expect(detail.cards.map((c) => c.id), <String>['match']);
      expect(detail.totalCount, 3);
    });

    test('tag no-results keeps totalCount consistent', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', 'One', 'Alpha', 0, tags: <String>['weak']);
      await addCard(deck.id, 'c2', 'Two', 'Beta', 1, tags: <String>['grammar']);

      final FlashcardListDetail detail = await load(
        deck.id,
        selectedTags: <String>['missing'],
      );

      expect(detail.cards, isEmpty);
      expect(detail.totalCount, 2);
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
      // Brand-new card: due_at stays NULL (never scheduled) so it counts as NEW.
      expect(progressRows.single.dueAt, null);
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

  group('existingByFrontBackPairs', () {
    test(
      'matches normalized front/back pairs only within the target deck',
      () async {
        final Deck deck = await seedDeck();
        final Folder otherFolder =
            (await folderRepo.createRootFolder(name: 'Other') as Ok<Folder>)
                .value;
        final Deck otherDeck =
            (await folderRepo.createDeck(
                      parentFolderId: otherFolder.id,
                      name: 'Other deck',
                      targetLanguage: TargetLanguage.korean,
                    )
                    as Ok<Deck>)
                .value;

        await addCard(deck.id, 'c1', 'Hello', 'World', 0);
        await addCard(otherDeck.id, 'c2', 'Hello', 'World', 0);

        final Result<List<Flashcard>> result = await repo
            .existingByFrontBackPairs(deck.id, <({String front, String back})>[
              (front: ' hello ', back: ' world '),
              (front: 'missing', back: 'card'),
            ]);

        expect(result, isA<Ok<List<Flashcard>>>());
        final Ok<List<Flashcard>> okResult = result as Ok<List<Flashcard>>;
        expect(okResult.value, hasLength(1));
        expect(okResult.value.single.id, 'c1');
      },
    );

    test('returns NotFoundFailure for a missing deck id', () async {
      final Result<List<Flashcard>> result = await repo
          .existingByFrontBackPairs('missing', <({String front, String back})>[
            (front: 'Hello', back: 'World'),
          ]);

      expect(result, isA<Err<List<Flashcard>>>());
      expect((result as Err<List<Flashcard>>).failure, isA<NotFoundFailure>());
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
      // Imported cards are also brand-new: due_at stays NULL until first study.
      expect(progressRows.every((row) => row.dueAt == null), isTrue);
    });

    test(
      'rejects duplicate rows inside the commit input before writing anything',
      () async {
        final Deck deck = await seedDeck();

        final Result<int> result = await repo.commitDeckImport(
          deckId: deck.id,
          rows: const <DeckImportPreviewRow>[
            DeckImportPreviewRow(lineNumber: 2, front: 'Hello', back: 'World'),
            DeckImportPreviewRow(
              lineNumber: 3,
              front: ' hello ',
              back: ' world ',
            ),
          ],
        );

        expect(result, isA<Err<int>>());
        expect(
          (result as Err<int>).failure,
          isA<ValidationFailure>().having(
            (ValidationFailure failure) => failure.code,
            'code',
            ValidationCode.duplicate,
          ),
        );
        expect(await db.select(db.flashcards).get(), isEmpty);
        expect(await db.select(db.flashcardProgress).get(), isEmpty);
      },
    );

    test(
      'rejects rows duplicated against existing flashcards in the same deck',
      () async {
        final Deck deck = await seedDeck();
        await addCard(deck.id, 'existing', 'Hello', 'World', 0);

        final Result<int> result = await repo.commitDeckImport(
          deckId: deck.id,
          rows: const <DeckImportPreviewRow>[
            DeckImportPreviewRow(lineNumber: 2, front: 'hello', back: 'world'),
            DeckImportPreviewRow(lineNumber: 3, front: 'Bye', back: 'See ya'),
          ],
        );

        expect(result, isA<Err<int>>());
        expect(
          (result as Err<int>).failure,
          isA<ValidationFailure>().having(
            (ValidationFailure failure) => failure.code,
            'code',
            ValidationCode.duplicate,
          ),
        );
        expect(await db.select(db.flashcards).get(), hasLength(1));
        expect(await db.select(db.flashcardProgress).get(), isEmpty);
      },
    );

    test('allows the same pair when it exists in another deck', () async {
      final Deck deck = await seedDeck();
      final Folder otherFolder =
          (await folderRepo.createRootFolder(name: 'Other') as Ok<Folder>)
              .value;
      final Deck otherDeck =
          (await folderRepo.createDeck(
                    parentFolderId: otherFolder.id,
                    name: 'Other deck',
                    targetLanguage: TargetLanguage.korean,
                  )
                  as Ok<Deck>)
              .value;
      await addCard(otherDeck.id, 'other', 'Hello', 'World', 0);

      final Result<int> result = await repo.commitDeckImport(
        deckId: deck.id,
        rows: const <DeckImportPreviewRow>[
          DeckImportPreviewRow(lineNumber: 2, front: 'hello', back: 'world'),
        ],
      );

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 1);
      expect(await db.select(db.flashcards).get(), hasLength(2));
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
      final FlashcardDao dao = FlashcardDao(db);
      expect((await dao.findFlashcard('c3'))?.sortOrder, 0);
      expect((await dao.findFlashcard('c1'))?.sortOrder, 1);
      expect((await dao.findFlashcard('c2'))?.sortOrder, 2);
    });

    test(
      'rejects duplicate flashcard ids and leaves the order unchanged',
      () async {
        final Deck deck = await seedDeck();
        await addCard(deck.id, 'c1', 'A', 'a', 0);
        await addCard(deck.id, 'c2', 'B', 'b', 1);
        await addCard(deck.id, 'c3', 'C', 'c', 2);

        final Result<void> result = await repo.reorderFlashcards(
          deckId: deck.id,
          orderedIds: <String>['c3', 'c1', 'c1'],
        );

        expect(result, isA<Err<void>>());
        expect(
          (result as Err<void>).failure,
          isA<ValidationFailure>().having(
            (ValidationFailure f) => f.code,
            'code',
            ValidationCode.duplicate,
          ),
        );

        final FlashcardListDetail detail = await load(deck.id);
        expect(detail.cards.map((c) => c.id), <String>['c1', 'c2', 'c3']);
      },
    );

    test('rejects missing flashcard ids', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', 'A', 'a', 0);
      await addCard(deck.id, 'c2', 'B', 'b', 1);

      final Result<void> result = await repo.reorderFlashcards(
        deckId: deck.id,
        orderedIds: <String>['missing', 'c1'],
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<NotFoundFailure>());

      final FlashcardListDetail detail = await load(deck.id);
      expect(detail.cards.map((c) => c.id), <String>['c1', 'c2']);
    });

    test('rejects flashcard ids from another deck scope', () async {
      final Deck deckA = await seedDeck();
      await addCard(deckA.id, 'a1', 'A1', 'a1', 0);
      await addCard(deckA.id, 'a2', 'A2', 'a2', 1);

      final Folder folderB =
          ((await folderRepo.createRootFolder(name: 'Other')) as Ok<Folder>)
              .value;
      final Deck deckB =
          (await folderRepo.createDeck(
                    parentFolderId: folderB.id,
                    name: 'Other deck',
                    targetLanguage: TargetLanguage.korean,
                  )
                  as Ok<Deck>)
              .value;
      await addCard(deckB.id, 'b1', 'B1', 'b1', 0);

      final Result<void> result = await repo.reorderFlashcards(
        deckId: deckA.id,
        orderedIds: <String>['b1', 'a1', 'a2'],
      );

      expect(result, isA<Err<void>>());
      expect(
        (result as Err<void>).failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.invalidFormat,
        ),
      );

      final FlashcardListDetail detail = await load(deckA.id);
      expect(detail.cards.map((c) => c.id), <String>['a1', 'a2']);
    });

    test(
      'rejects partial reorder lists and leaves the previous order unchanged',
      () async {
        final Deck deck = await seedDeck();
        await addCard(deck.id, 'c1', 'A', 'a', 0);
        await addCard(deck.id, 'c2', 'B', 'b', 1);
        await addCard(deck.id, 'c3', 'C', 'c', 2);

        final Result<void> result = await repo.reorderFlashcards(
          deckId: deck.id,
          orderedIds: <String>['c3', 'c1'],
        );

        expect(result, isA<Err<void>>());
        expect(
          (result as Err<void>).failure,
          isA<ValidationFailure>().having(
            (ValidationFailure f) => f.code,
            'code',
            ValidationCode.insufficientContent,
          ),
        );

        final FlashcardListDetail detail = await load(deck.id);
        expect(detail.cards.map((c) => c.id), <String>['c1', 'c2', 'c3']);
      },
    );
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
