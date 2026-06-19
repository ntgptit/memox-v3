import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

void main() {
  group('AppDatabase schema (v3)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    Future<void> insertFolderRow(String id) async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: id,
              name: id,
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
    }

    test('reports the current schema version', () {
      expect(AppDatabase.currentSchemaVersion, 3);
      expect(db.schemaVersion, 3);
    });

    Future<void> insertDeckRow(String id, String folderId) async {
      final int ts = now();
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: id,
              folderId: folderId,
              name: id,
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
    }

    test('creates the flashcards table and round-trips a card', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('deck', 'folder');
      final int ts = now();
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'c1',
              deckId: 'deck',
              front: 'apple',
              back: '사과',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      final List<FlashcardRow> rows = await db.select(db.flashcards).get();
      expect(rows, hasLength(1));
      expect(rows.single.front, 'apple');
      expect(rows.single.deckId, 'deck');
      // is_flagged defaults to false; optional fields default to null.
      expect(rows.single.isFlagged, isFalse);
      expect(rows.single.exampleSentence, isNull);
    });

    test('cascades flashcard delete when its deck is removed', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('deck', 'folder');
      final int ts = now();
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'c1',
              deckId: 'deck',
              front: 'apple',
              back: '사과',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      await (db.delete(db.decks)..where((t) => t.id.equals('deck'))).go();

      expect(await db.select(db.flashcards).get(), isEmpty);
    });

    test('rejects a flashcard with a missing deck (parent-child FK)', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      final int ts = now();
      expect(
        () => db
            .into(db.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                id: 'orphan',
                deckId: 'does-not-exist',
                front: 'apple',
                back: '사과',
                sortOrder: 0,
                createdAt: ts,
                updatedAt: ts,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('creates the decks table and round-trips a deck', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      final int ts = now();
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'folder',
              name: 'Verbs',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      final List<DeckRow> rows = await db.select(db.decks).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Verbs');
      expect(rows.single.folderId, 'folder');
      // target_language defaults to 'korean'.
      expect(rows.single.targetLanguage, 'korean');
    });

    test('cascades deck delete when its folder is removed', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      final int ts = now();
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'folder',
              name: 'Verbs',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      await (db.delete(db.folders)..where((t) => t.id.equals('folder'))).go();

      expect(await db.select(db.decks).get(), isEmpty);
    });

    test('rejects a deck with a missing folder (FK)', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      final int ts = now();
      expect(
        () => db
            .into(db.decks)
            .insert(
              DecksCompanion.insert(
                id: 'orphan',
                folderId: 'does-not-exist',
                name: 'Orphan',
                sortOrder: 0,
                createdAt: ts,
                updatedAt: ts,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('creates the folders table and round-trips a root folder', () async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'f1',
              name: 'Root',
              contentMode: 'empty',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      final List<FolderRow> rows = await db.select(db.folders).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Root');
      expect(rows.single.parentId, isNull);
    });

    test('persists a subfolder self-reference', () async {
      final int ts = now();
      Future<void> insertFolder(String id, {String? parentId}) => db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: id,
              name: id,
              contentMode: 'empty',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
              parentId: Value<String?>(parentId),
            ),
          );

      await insertFolder('root');
      await insertFolder('child', parentId: 'root');

      final FolderRow child = await (db.select(
        db.folders,
      )..where((t) => t.id.equals('child'))).getSingle();
      expect(child.parentId, 'root');
    });

    test(
      'enforces the parent foreign key (RESTRICT on missing parent)',
      () async {
        await db.customStatement('PRAGMA foreign_keys = ON');
        final int ts = now();

        expect(
          () => db
              .into(db.folders)
              .insert(
                FoldersCompanion.insert(
                  id: 'orphan',
                  name: 'orphan',
                  contentMode: 'empty',
                  sortOrder: 0,
                  createdAt: ts,
                  updatedAt: ts,
                  parentId: const Value<String?>('does-not-exist'),
                ),
              ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
