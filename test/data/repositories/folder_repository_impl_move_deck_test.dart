import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  late AppDatabase db;
  late FolderRepositoryImpl repo;
  late FolderDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = FolderDao(db);
    repo = FolderRepositoryImpl(dao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<Folder> createRoot(String name) async =>
      (await repo.createRootFolder(name: name) as Ok<Folder>).value;

  Future<Deck> createDeck(String parentFolderId, String name) async =>
      (await repo.createDeck(
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
    bool withProgress = true,
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
    if (withProgress) {
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: id,
              dueAt: Value<int?>(now),
            ),
          );
    }
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

  Future<List<String>> deckIdsInFolder(String folderId) async {
    final rows = await dao.getDeckItems(
      folderId: folderId,
      nowMs: DateTime.now().toUtc().millisecondsSinceEpoch,
      sort: ContentSortMode.manual,
      normalizedSearch: null,
    );
    return rows.map((row) => row.id).toList(growable: false);
  }

  group('moveDeck', () {
    test('moves a deck from one folder to an unlocked folder', () async {
      final Folder source = await createRoot('Source');
      final Folder target = await createRoot('Target');
      final Deck deck = await createDeck(source.id, 'Deck');

      final Result<Deck> result = await repo.moveDeck(
        deckId: deck.id,
        newParentId: target.id,
      );

      expect(result, isA<Ok<Deck>>());
      expect((result as Ok<Deck>).value.folderId, target.id);
      expect((await dao.findFolder(source.id))?.contentMode, 'unlocked');
      expect((await dao.findFolder(target.id))?.contentMode, 'decks');
    });

    test(
      'moves a deck into a decks-mode folder and appends sort order',
      () async {
        final Folder source = await createRoot('Source');
        final Folder target = await createRoot('Target');
        final Deck existing = await createDeck(target.id, 'Existing');
        final Deck moved = await createDeck(source.id, 'Moved');

        final Result<Deck> result = await repo.moveDeck(
          deckId: moved.id,
          newParentId: target.id,
        );

        expect(result, isA<Ok<Deck>>());
        expect((result as Ok<Deck>).value.folderId, target.id);
        expect((await dao.findDeck(existing.id))?.sortOrder, 0);
        expect((await dao.findDeck(moved.id))?.sortOrder, 1);
        expect(await deckIdsInFolder(target.id), <String>[
          existing.id,
          moved.id,
        ]);
      },
    );

    test(
      'source folder becomes unlocked when it loses its last deck',
      () async {
        final Folder source = await createRoot('Source');
        final Folder target = await createRoot('Target');
        final Deck deck = await createDeck(source.id, 'Deck');

        await repo.moveDeck(deckId: deck.id, newParentId: target.id);

        expect((await dao.findFolder(source.id))?.contentMode, 'unlocked');
      },
    );

    test('source folder remains decks when other decks remain', () async {
      final Folder source = await createRoot('Source');
      final Folder target = await createRoot('Target');
      final Deck keep = await createDeck(source.id, 'Keep');
      final Deck move = await createDeck(source.id, 'Move');

      await repo.moveDeck(deckId: move.id, newParentId: target.id);

      expect((await dao.findFolder(source.id))?.contentMode, 'decks');
      expect((await dao.findDeck(keep.id))?.folderId, source.id);
    });

    test('moving to the same folder is a no-op', () async {
      final Folder source = await createRoot('Source');
      final Deck deck = await createDeck(source.id, 'Deck');

      final Result<Deck> result = await repo.moveDeck(
        deckId: deck.id,
        newParentId: source.id,
      );

      expect(result, isA<Ok<Deck>>());
      expect((result as Ok<Deck>).value.folderId, source.id);
      expect((await dao.findDeck(deck.id))?.sortOrder, 0);
    });

    test('rejects moves into subfolders-mode folders', () async {
      final Folder source = await createRoot('Source');
      final Folder target = await createRoot('Target');
      await repo.createSubfolder(parentId: target.id, name: 'Child');
      final Deck deck = await createDeck(source.id, 'Deck');

      final Result<Deck> result = await repo.moveDeck(
        deckId: deck.id,
        newParentId: target.id,
      );

      expect(result, isA<Err<Deck>>());
      expect((result as Err<Deck>).failure, isA<UnsupportedActionFailure>());
      expect((await dao.findDeck(deck.id))?.folderId, source.id);
    });

    test('returns not found for a missing deck', () async {
      final Folder target = await createRoot('Target');

      final Result<Deck> result = await repo.moveDeck(
        deckId: 'missing',
        newParentId: target.id,
      );

      expect(result, isA<Err<Deck>>());
      expect((result as Err<Deck>).failure, isA<NotFoundFailure>());
    });

    test('returns not found for a missing target folder', () async {
      final Folder source = await createRoot('Source');
      final Deck deck = await createDeck(source.id, 'Deck');

      final Result<Deck> result = await repo.moveDeck(
        deckId: deck.id,
        newParentId: 'missing',
      );

      expect(result, isA<Err<Deck>>());
      expect((result as Err<Deck>).failure, isA<NotFoundFailure>());
      expect((await dao.findDeck(deck.id))?.folderId, source.id);
    });

    test(
      'rejects duplicate names in the target folder case-insensitively',
      () async {
        final Folder source = await createRoot('Source');
        final Folder target = await createRoot('Target');
        await createDeck(target.id, 'Study');
        final Deck deck = await createDeck(source.id, ' study ');

        final Result<Deck> result = await repo.moveDeck(
          deckId: deck.id,
          newParentId: target.id,
        );

        expect(result, isA<Err<Deck>>());
        expect(
          (result as Err<Deck>).failure,
          isA<ValidationFailure>().having(
            (ValidationFailure failure) => failure.code,
            'code',
            ValidationCode.duplicate,
          ),
        );
        expect((await dao.findDeck(deck.id))?.folderId, source.id);
      },
    );

    test('preserves flashcards, progress, and tags during move', () async {
      final Folder source = await createRoot('Source');
      final Folder target = await createRoot('Target');
      final Deck deck = await createDeck(source.id, 'Deck');
      await addCard(deck.id, 'card-1', 'Front', 'Back', tags: <String>['weak']);

      final int beforeFlashcards = await db
          .select(db.flashcards)
          .get()
          .then((rows) => rows.length);
      final int beforeProgress = await db
          .select(db.flashcardProgress)
          .get()
          .then((rows) => rows.length);
      final int beforeTags = await db
          .select(db.flashcardTags)
          .get()
          .then((rows) => rows.length);

      await repo.moveDeck(deckId: deck.id, newParentId: target.id);

      expect(
        await db.select(db.flashcards).get().then((rows) => rows.length),
        beforeFlashcards,
      );
      expect(
        await db.select(db.flashcardProgress).get().then((rows) => rows.length),
        beforeProgress,
      );
      expect(
        await db.select(db.flashcardTags).get().then((rows) => rows.length),
        beforeTags,
      );
      expect((await dao.findDeck(deck.id))?.folderId, target.id);
    });

    test('rolls back the move when a duplicate name failure occurs', () async {
      final Folder source = await createRoot('Source');
      final Folder target = await createRoot('Target');
      final Deck deck = await createDeck(source.id, 'Deck');
      await createDeck(target.id, 'Deck');

      final Result<Deck> result = await repo.moveDeck(
        deckId: deck.id,
        newParentId: target.id,
      );

      expect(result, isA<Err<Deck>>());
      expect((await dao.findDeck(deck.id))?.folderId, source.id);
      expect((await dao.findFolder(source.id))?.contentMode, 'decks');
      expect((await dao.findFolder(target.id))?.contentMode, 'decks');
    });
  });
}
