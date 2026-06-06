import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

class _LegacyAppDatabase extends AppDatabase {
  _LegacyAppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await customStatement('''
        CREATE TABLE folders (
          id TEXT NOT NULL PRIMARY KEY,
          parent_id TEXT,
          name TEXT NOT NULL,
          content_mode TEXT NOT NULL,
          sort_order INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');
      await customStatement('''
        CREATE TABLE decks (
          id TEXT NOT NULL PRIMARY KEY,
          folder_id TEXT NOT NULL REFERENCES folders (id) ON DELETE CASCADE,
          name TEXT NOT NULL,
          target_language TEXT NOT NULL,
          sort_order INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');
      await customStatement('''
        CREATE TABLE flashcards (
          id TEXT NOT NULL PRIMARY KEY,
          deck_id TEXT NOT NULL REFERENCES decks (id) ON DELETE CASCADE,
          front TEXT NOT NULL,
          back TEXT NOT NULL,
          example_sentence TEXT,
          sort_order INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');
      await customStatement('''
        CREATE TABLE flashcard_progress (
          flashcard_id TEXT NOT NULL PRIMARY KEY
            REFERENCES flashcards (id) ON DELETE CASCADE,
          box_number INTEGER NOT NULL DEFAULT 1,
          due_at INTEGER,
          buried_until INTEGER,
          is_suspended INTEGER NOT NULL DEFAULT 0,
          review_count INTEGER NOT NULL DEFAULT 0,
          lapse_count INTEGER NOT NULL DEFAULT 0,
          last_studied_at INTEGER
        );
      ''');
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

void main() {
  test(
    'migrates flashcard optional detail columns without losing data',
    () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'memox_flashcard_optional_fields_',
      );
      final File dbFile = File(
        '${tempDir.path}${Platform.pathSeparator}memox.sqlite',
      );

      final _LegacyAppDatabase legacyDb = _LegacyAppDatabase(
        NativeDatabase(dbFile),
      );
      await legacyDb.customStatement('PRAGMA foreign_keys = ON');
      await legacyDb
          .into(legacyDb.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'f1',
              name: 'Korean',
              contentMode: const Value<String>('unlocked'),
              sortOrder: const Value<int>(0),
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await legacyDb
          .into(legacyDb.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'f1',
              name: 'N5',
              targetLanguage: const Value<String>('korean'),
              sortOrder: const Value<int>(0),
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await legacyDb
          .into(legacyDb.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'c1',
              deckId: 'd1',
              front: '안녕하세요',
              back: 'Hello',
              exampleSentence: const Value<String?>('안녕하세요, 저는 민수입니다.'),
              sortOrder: const Value<int>(0),
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await legacyDb
          .into(legacyDb.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: 'c1',
              dueAt: const Value<int?>(1),
            ),
          );
      await legacyDb.close();

      final AppDatabase migratedDb = AppDatabase(NativeDatabase(dbFile));
      final FlashcardRow migratedRow = await migratedDb
          .select(migratedDb.flashcards)
          .getSingle();

      expect(migratedRow.exampleSentence, '안녕하세요, 저는 민수입니다.');
      expect(migratedRow.pronunciation, same(null));
      expect(migratedRow.hint, same(null));

      final List<FlashcardProgressRow> progressRows = await migratedDb
          .select(migratedDb.flashcardProgress)
          .get();
      expect(progressRows, hasLength(1));
      expect(progressRows.single.flashcardId, 'c1');

      final List<FlashcardTagRow> tagRows = await migratedDb
          .select(migratedDb.flashcardTags)
          .get();
      expect(tagRows, isEmpty);

      await migratedDb.close();
      await tempDir.delete(recursive: true);
    },
  );
}
