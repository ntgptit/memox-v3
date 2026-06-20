import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

void main() {
  group('AppDatabase schema (v5)', () {
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
      expect(AppDatabase.currentSchemaVersion, 5);
      expect(db.schemaVersion, 5);
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

    Future<void> insertFlashcardRow(String id, String deckId) async {
      final int ts = now();
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: id,
              deckId: deckId,
              front: 'front',
              back: 'back',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
    }

    test('creates the flashcards table and round-trips a card', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');

      final List<FlashcardRow> rows = await db.select(db.flashcards).get();
      expect(rows, hasLength(1));
      expect(rows.single.front, 'front');
      expect(rows.single.exampleSentence, isNull);
    });

    test('flashcard_progress 1:1 cascades when its card is deleted', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await db
          .into(db.flashcardProgress)
          .insert(FlashcardProgressCompanion.insert(flashcardId: 'c1'));

      await (db.delete(db.flashcards)..where((t) => t.id.equals('c1'))).go();

      expect(await db.select(db.flashcardProgress).get(), isEmpty);
    });

    test('flashcard_progress defaults to not-suspended / not-buried', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await db
          .into(db.flashcardProgress)
          .insert(FlashcardProgressCompanion.insert(flashcardId: 'c1'));

      final FlashcardProgressRow row = await db
          .select(db.flashcardProgress)
          .getSingle();
      expect(row.isSuspended, isFalse, reason: 'v4 default: not suspended');
      expect(row.buriedUntil, isNull, reason: 'v4 default: not buried');
    });

    test('flashcard_tags cascade when their card is deleted', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await db
          .into(db.flashcardTags)
          .insert(
            FlashcardTagsCompanion.insert(flashcardId: 'c1', tag: 'noun'),
          );

      await (db.delete(db.flashcards)..where((t) => t.id.equals('c1'))).go();

      expect(await db.select(db.flashcardTags).get(), isEmpty);
    });

    test('deleting a deck cascades its flashcards', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');

      await (db.delete(db.decks)..where((t) => t.id.equals('d1'))).go();

      expect(await db.select(db.flashcards).get(), isEmpty);
    });

    test('rejects a flashcard with a missing deck (FK)', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      final int ts = now();
      expect(
        () => db
            .into(db.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                id: 'orphan',
                deckId: 'does-not-exist',
                front: 'f',
                back: 'b',
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
      // color/icon default to NULL when not supplied (WBS 2.22.1).
      expect(rows.single.color, isNull);
      expect(rows.single.icon, isNull);
    });

    test('round-trips the optional folder color + icon tokens', () async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'styled',
              name: 'Styled',
              contentMode: 'unlocked',
              color: const Value('coral'),
              icon: const Value('book'),
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      final FolderRow row = await db.select(db.folders).getSingle();
      expect(row.color, 'coral');
      expect(row.icon, 'book');
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
