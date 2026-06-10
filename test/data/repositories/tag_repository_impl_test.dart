import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/data/repositories/tag_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  late AppDatabase db;
  late FolderRepositoryImpl folderRepo;
  late TagRepositoryImpl repo;
  late FolderDao folderDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    folderDao = FolderDao(db);
    folderRepo = FolderRepositoryImpl(folderDao);
    repo = TagRepositoryImpl(FlashcardDao(db));
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

  Future<List<FlashcardTagRow>> tagRows() => db.select(db.flashcardTags).get();

  group('watchAllWithCount', () {
    test('returns distinct lowercased tags with usage counts', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a', tags: <String>['Weak', 'Grammar']);
      await addCard(deck.id, 'c2', 'B', 'b', tags: <String>['weak']);

      final Result<List<TagWithCount>> result = await repo
          .watchAllWithCount()
          .first;

      expect(result, isA<Ok<List<TagWithCount>>>());
      final List<TagWithCount> tags = (result as Ok<List<TagWithCount>>).value;
      expect(tags.map((t) => t.tag), <String>['grammar', 'weak']);
      expect(tags.firstWhere((t) => t.tag == 'weak').usageCount, 2);
      expect(tags.firstWhere((t) => t.tag == 'grammar').usageCount, 1);
    });

    test('search is case-insensitive and empty search returns all', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a', tags: <String>['Weak']);
      await addCard(deck.id, 'c2', 'B', 'b', tags: <String>['Grammar']);

      final Result<List<TagWithCount>> filtered = await repo
          .watchAllWithCount(searchTerm: '  WEA  ')
          .first;
      final Result<List<TagWithCount>> all = await repo
          .watchAllWithCount(searchTerm: '   ')
          .first;

      expect(
        (filtered as Ok<List<TagWithCount>>).value.map((t) => t.tag),
        <String>['weak'],
      );
      expect((all as Ok<List<TagWithCount>>).value, hasLength(2));
    });
  });

  group('rename', () {
    test('updates all matching rows', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a', tags: <String>['weak']);
      await addCard(deck.id, 'c2', 'B', 'b', tags: <String>['WEAK']);

      final Result<void> result = await repo.rename(
        oldName: ' weak ',
        newName: ' vocabulary ',
      );

      expect(result, isA<Ok<void>>());
      final List<FlashcardTagRow> rows = await tagRows();
      expect(rows.map((row) => row.tag), <String>['vocabulary', 'vocabulary']);
    });

    test('rejects validation errors from the current validator', () async {
      final Result<void> empty = await repo.rename(
        oldName: 'weak',
        newName: ' ',
      );
      final Result<void> comma = await repo.rename(
        oldName: 'weak',
        newName: 'bad,tag',
      );
      final Result<void> tooLong = await repo.rename(
        oldName: 'weak',
        newName: 'x' * (TagValidator.maxLength + 1),
      );

      expect((empty as Err<void>).failure, isA<ValidationFailure>());
      expect((comma as Err<void>).failure, isA<ValidationFailure>());
      expect((tooLong as Err<void>).failure, isA<ValidationFailure>());
    });

    test(
      'returns conflict on rename collision and leaves rows unchanged',
      () async {
        final Folder folder = await createRoot('Folder');
        final Deck deck = await createDeck(folder.id, 'Deck');
        await addCard(deck.id, 'c1', 'A', 'a', tags: <String>['weak']);
        await addCard(deck.id, 'c2', 'B', 'b', tags: <String>['grammar']);

        final Result<void> result = await repo.rename(
          oldName: 'weak',
          newName: 'grammar',
        );

        expect(result, isA<Err<void>>());
        expect((result as Err<void>).failure, isA<ConflictFailure>());
        expect(
          (await tagRows()).map((row) => row.tag),
          unorderedEquals(<String>['grammar', 'weak']),
        );
      },
    );
  });

  group('merge', () {
    test('moves source tags into the target and dedupes target rows', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a', tags: <String>['weak', 'grammar']);
      await addCard(deck.id, 'c2', 'B', 'b', tags: <String>['weak']);

      final Result<MergeResult> result = await repo.merge(
        sourceNames: <String>['weak'],
        targetName: 'grammar',
      );

      expect(result, isA<Ok<MergeResult>>());
      expect((result as Ok<MergeResult>).value.affectedCardCount, 2);
      expect((await tagRows()).map((row) => row.tag), <String>[
        'grammar',
        'grammar',
      ]);
    });

    test('rejects source equal target', () async {
      final Result<MergeResult> result = await repo.merge(
        sourceNames: <String>['weak'],
        targetName: 'weak',
      );

      expect(result, isA<Err<MergeResult>>());
      expect((result as Err<MergeResult>).failure, isA<ValidationFailure>());
    });

    test('leaves rows unchanged when merge validation fails', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a', tags: <String>['weak']);
      await addCard(deck.id, 'c2', 'B', 'b', tags: <String>['grammar']);

      final Result<MergeResult> result = await repo.merge(
        sourceNames: <String>['weak'],
        targetName: 'weak',
      );

      expect(result, isA<Err<MergeResult>>());
      expect(
        (await tagRows()).map((row) => row.tag),
        unorderedEquals(<String>['weak', 'grammar']),
      );
    });
  });

  group('delete', () {
    test('removes tag rows only and leaves cards intact', () async {
      final Folder folder = await createRoot('Folder');
      final Deck deck = await createDeck(folder.id, 'Deck');
      await addCard(deck.id, 'c1', 'A', 'a', tags: <String>['weak']);
      await addCard(deck.id, 'c2', 'B', 'b', tags: <String>['weak', 'grammar']);

      final Result<int> result = await repo.delete(name: 'weak');

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 2);
      expect(await db.select(db.flashcards).get(), hasLength(2));
      expect((await tagRows()).map((row) => row.tag), <String>['grammar']);
    });
  });
}
