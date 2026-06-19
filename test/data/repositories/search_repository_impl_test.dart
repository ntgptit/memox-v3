import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/search_dao.dart';
import 'package:memox/data/repositories/search_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';

void main() {
  // SearchRepositoryImpl: LIKE escaping + case-insensitive substring filtering
  // over folders/decks/flashcards. WBS 3.5.1, decision rows SR2, SR3, SR4.
  group('SearchRepositoryImpl', () {
    late AppDatabase db;
    late SearchRepositoryImpl repo;
    int clock = 1000;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repo = SearchRepositoryImpl(dao: SearchDao(db));
      clock = 1000;
    });
    tearDown(() => db.close());

    Future<void> seedFolder(String id, String name) => db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(
            id: id,
            name: name,
            contentMode: 'unlocked',
            sortOrder: 0,
            createdAt: clock,
            updatedAt: clock++,
          ),
        );

    Future<void> seedDeck(String id, String folderId, String name) => db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: id,
            folderId: folderId,
            name: name,
            sortOrder: 0,
            createdAt: clock,
            updatedAt: clock++,
          ),
        );

    Future<void> seedCard(
      String id,
      String deckId,
      String front,
      String back,
    ) => db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            sortOrder: 0,
            createdAt: clock,
            updatedAt: clock++,
          ),
        );

    test('SR2: folder name substring match, case-insensitive', () async {
      await seedFolder('f1', 'Korean Basics');
      await seedFolder('f2', 'Japanese');

      final result = await repo.searchFolders('korean');

      expect(result.isSuccess, isTrue);
      final List<Folder> folders = result.data!;
      expect(folders.map((Folder f) => f.id), <String>['f1']);
    });

    test('SR3: deck name substring match', () async {
      await seedFolder('f1', 'Root');
      await seedDeck('d1', 'f1', 'Verbs');
      await seedDeck('d2', 'f1', 'Nouns');

      final result = await repo.searchDecks('verb');

      expect(result.data!.map((Deck d) => d.id), <String>['d1']);
    });

    test('SR4: flashcard matches on front OR back', () async {
      await seedFolder('f1', 'Root');
      await seedDeck('d1', 'f1', 'Deck');
      await seedCard('c1', 'd1', 'apple', '사과');
      await seedCard('c2', 'd1', 'banana', 'apple pie'); // matches on back
      await seedCard('c3', 'd1', 'cherry', '체리');

      final result = await repo.searchFlashcards('apple');

      expect(result.data!.map((Flashcard c) => c.id).toSet(), <String>{
        'c1',
        'c2',
      });
    });

    test('escapes % so it is matched literally, not as a wildcard', () async {
      await seedFolder('f1', '100% Korean');
      await seedFolder('f2', 'Anything');

      // A literal "%" only matches the folder that actually contains it.
      final pctResult = await repo.searchFolders('100%');
      expect(pctResult.data!.map((Folder f) => f.id), <String>['f1']);
    });

    test('escapes _ so it is matched literally', () async {
      await seedFolder('f1', 'a_b');
      await seedFolder('f2', 'axb');

      final result = await repo.searchFolders('a_b');
      expect(result.data!.map((Folder f) => f.id), <String>['f1']);
    });

    test('SR-err: read error maps to StorageFailure(read)', () async {
      // Drop the folders table so the LIKE query throws a SQL error.
      await db.customStatement('DROP TABLE folders');

      final result = await repo.searchFolders('korean');

      expect(result.isFailure, isTrue);
      final Failure failure = result.failure!;
      expect(failure, isA<StorageFailure>());
      expect((failure as StorageFailure).operation, StorageOp.read);
    });
  });
}
