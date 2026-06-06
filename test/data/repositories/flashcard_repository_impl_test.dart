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
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
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
        as Ok<Deck>).value;
  }

  Future<void> addCard(
    DeckId deckId,
    String id,
    String front,
    String back,
    int order,
  ) async {
    final int now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            sortOrder: Value<int>(order),
            createdAt: now,
            updatedAt: now,
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

    test('search no-results keeps totalCount > 0 (distinct from empty deck)', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', '안녕하세요', 'Hello', 0);

      final FlashcardListDetail detail = await load(deck.id, search: 'zzz');

      expect(detail.cards, isEmpty);
      expect(detail.totalCount, 1);
    });

    test('search matches front/back substring', () async {
      final Deck deck = await seedDeck();
      await addCard(deck.id, 'c1', '안녕하세요', 'Hello', 0);
      await addCard(deck.id, 'c2', '감사합니다', 'Thank you', 1);

      final FlashcardListDetail detail = await load(deck.id, search: 'thank');

      expect(detail.cards.single.front, '감사합니다');
      expect(detail.totalCount, 2);
    });

    test('unknown deck id surfaces a NotFoundFailure', () async {
      final Result<FlashcardListDetail> result = await repo
          .watchFlashcardList('missing')
          .first;

      expect(result, isA<Err<FlashcardListDetail>>());
      expect((result as Err<FlashcardListDetail>).failure, isA<NotFoundFailure>());
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
      expect((after as Err<FlashcardListDetail>).failure, isA<NotFoundFailure>());
    });
  });
}
