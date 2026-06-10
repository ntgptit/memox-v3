import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/flashcard_bulk_repository_impl.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/bulk_delete_result.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  late AppDatabase db;
  late FlashcardBulkRepositoryImpl repo;
  late FolderRepositoryImpl folderRepo;
  late FolderDao folderDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    folderDao = FolderDao(db);
    folderRepo = FolderRepositoryImpl(folderDao);
    repo = FlashcardBulkRepositoryImpl(FlashcardDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  Future<Folder> createRoot(String name) async =>
      (await folderRepo.createRootFolder(name: name) as Ok<Folder>).value;

  Future<Deck> createDeck(String parentFolderId, String name) async =>
      (await folderRepo.createDeck(
                parentFolderId: parentFolderId,
                name: name,
                targetLanguage: TargetLanguage.korean,
              )
              as Ok<Deck>)
          .value;

  Future<void> addCard(
    String deckId,
    String id,
    String front,
    String back, {
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
            sortOrder: const Value<int>(0),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion.insert(
            flashcardId: id,
            dueAt: Value<int?>(now),
          ),
        );
    for (final String tag in tags) {
      await db
          .into(db.flashcardTags)
          .insert(
            FlashcardTagsCompanion.insert(
              flashcardId: id,
              tag: TagValidator.storageValue(tag),
            ),
          );
    }
  }

  group('deleteMany', () {
    test('rejects an empty selection', () async {
      final Result<BulkDeleteResult> result = await repo.deleteMany(
        ids: const <String>[],
      );

      expect(result, isA<Err<BulkDeleteResult>>());
      expect(
        (result as Err<BulkDeleteResult>).failure,
        isA<ValidationFailure>(),
      );
    });

    test('deletes a single existing card with cascade intact', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a', tags: <String>['weak']);

      final Result<BulkDeleteResult> result = await repo.deleteMany(
        ids: <String>['c1'],
      );

      expect(result, isA<Ok<BulkDeleteResult>>());
      final BulkDeleteResult value = (result as Ok<BulkDeleteResult>).value;
      expect(value.deletedCount, 1);
      expect(value.skippedCount, 0);
      expect(await db.select(db.flashcards).get(), isEmpty);
      expect(await db.select(db.flashcardProgress).get(), isEmpty);
      expect(await db.select(db.flashcardTags).get(), isEmpty);
      expect((await folderDao.findDeck(deck.id))?.folderId, folder.id);
      expect((await folderDao.findFolder(folder.id))?.id, folder.id);
    });

    test('deletes multiple existing cards in one operation', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a');
      await addCard(deck.id, 'c2', 'B', 'b');
      await addCard(deck.id, 'c3', 'C', 'c');

      final Result<BulkDeleteResult> result = await repo.deleteMany(
        ids: <String>['c1', 'c2', 'c3'],
      );

      expect((result as Ok<BulkDeleteResult>).value.deletedCount, 3);
      expect(await db.select(db.flashcards).get(), isEmpty);
    });

    test('skips missing ids and reports the skipped count', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a');

      final Result<BulkDeleteResult> result = await repo.deleteMany(
        ids: <String>['c1', 'missing'],
      );

      expect(result, isA<Ok<BulkDeleteResult>>());
      final BulkDeleteResult value = (result as Ok<BulkDeleteResult>).value;
      expect(value.deletedCount, 1);
      expect(value.skippedCount, 1);
      expect(await db.select(db.flashcards).get(), isEmpty);
    });

    test(
      'mixed existing and missing ids delete surviving cards only',
      () async {
        final Folder folder = await createRoot('Folder');
        final Deck deck = await createDeck(folder.id, 'Deck');
        await addCard(deck.id, 'c1', 'A', 'a');
        await addCard(deck.id, 'c2', 'B', 'b');

        final Result<BulkDeleteResult> result = await repo.deleteMany(
          ids: <String>['c1', 'missing', 'c2'],
        );

        expect(result, isA<Ok<BulkDeleteResult>>());
        final BulkDeleteResult value = (result as Ok<BulkDeleteResult>).value;
        expect(value.deletedCount, 2);
        expect(value.skippedCount, 1);
        expect(await db.select(db.flashcards).get(), isEmpty);
      },
    );

    test('failed bulk delete rolls back all surviving card deletes', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a');
      await addCard(deck.id, 'c2', 'B', 'b');

      final Result<BulkDeleteResult> result = await repo.deleteMany(
        ids: <String>['c1', '', 'c2'],
      );

      expect(result, isA<Err<BulkDeleteResult>>());
      expect(await db.select(db.flashcards).get(), hasLength(2));
      expect(await db.select(db.flashcardProgress).get(), hasLength(2));
    });
  });
}
