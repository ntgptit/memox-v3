// ignore_for_file: prefer_single_quotes -- reason: embedded SQL literals use single quotes.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Legacy database pinned to schema v10 (before the new-card due_at correction).
/// Only the flashcard FK chain + flashcard_progress are needed.
class _LegacyV10Database extends AppDatabase {
  _LegacyV10Database(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await customStatement('''
        CREATE TABLE folders (
          id TEXT NOT NULL PRIMARY KEY, parent_id TEXT, name TEXT NOT NULL,
          content_mode TEXT NOT NULL, sort_order INTEGER NOT NULL,
          created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
      ''');
      await customStatement('''
        CREATE TABLE decks (
          id TEXT NOT NULL PRIMARY KEY,
          folder_id TEXT NOT NULL REFERENCES folders (id) ON DELETE CASCADE,
          name TEXT NOT NULL, target_language TEXT NOT NULL,
          sort_order INTEGER NOT NULL, created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL);
      ''');
      await customStatement('''
        CREATE TABLE flashcards (
          id TEXT NOT NULL PRIMARY KEY,
          deck_id TEXT NOT NULL REFERENCES decks (id) ON DELETE CASCADE,
          front TEXT NOT NULL, back TEXT NOT NULL, example_sentence TEXT,
          pronunciation TEXT, hint TEXT, sort_order INTEGER NOT NULL DEFAULT 0,
          part_of_speech TEXT, is_flagged INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
      ''');
      await customStatement('''
        CREATE TABLE flashcard_progress (
          flashcard_id TEXT NOT NULL PRIMARY KEY
            REFERENCES flashcards (id) ON DELETE CASCADE,
          box_number INTEGER NOT NULL DEFAULT 1, due_at INTEGER,
          buried_until INTEGER, is_suspended INTEGER NOT NULL DEFAULT 0,
          review_count INTEGER NOT NULL DEFAULT 0,
          lapse_count INTEGER NOT NULL DEFAULT 0,
          last_studied_at INTEGER, last_reset_at INTEGER);
      ''');
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

void main() {
  test(
    'clears due_at for never-studied cards; keeps studied cards scheduled',
    () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'memox_clear_due_',
      );
      final File dbFile = File(
        '${tempDir.path}${Platform.pathSeparator}memox.sqlite',
      );

      final _LegacyV10Database legacy = _LegacyV10Database(
        NativeDatabase(dbFile),
      );
      await legacy.customStatement(
        "INSERT INTO folders (id, name, content_mode, sort_order, created_at, "
        "updated_at) VALUES ('f1', 'Korean', 'decks', 0, 1, 1)",
      );
      await legacy.customStatement(
        "INSERT INTO decks (id, folder_id, name, target_language, sort_order, "
        "created_at, updated_at) VALUES ('d1', 'f1', 'N5', 'korean', 0, 1, 1)",
      );
      for (final String id in <String>['new', 'studied']) {
        await legacy.customStatement(
          "INSERT INTO flashcards (id, deck_id, front, back, sort_order, "
          "created_at, updated_at) VALUES ('$id', 'd1', '$id', 'b', 0, 1, 1)",
        );
      }
      // Never-studied card written with the old due_at=now bug.
      await legacy.customStatement(
        "INSERT INTO flashcard_progress (flashcard_id, box_number, due_at, "
        "review_count) VALUES ('new', 1, 1000, 0)",
      );
      // Studied card with a real schedule must be preserved.
      await legacy.customStatement(
        "INSERT INTO flashcard_progress (flashcard_id, box_number, due_at, "
        "review_count) VALUES ('studied', 2, 2000, 3)",
      );
      await legacy.close();

      final AppDatabase migrated = AppDatabase(NativeDatabase(dbFile));
      expect(migrated.schemaVersion, 11);

      final FlashcardProgressRow newRow = await (migrated.select(
        migrated.flashcardProgress,
      )..where((t) => t.flashcardId.equals('new'))).getSingle();
      expect(newRow.dueAt, isNull, reason: 'never-studied card cleared');

      final FlashcardProgressRow studiedRow = await (migrated.select(
        migrated.flashcardProgress,
      )..where((t) => t.flashcardId.equals('studied'))).getSingle();
      expect(studiedRow.dueAt, 2000, reason: 'studied card preserved');

      await migrated.close();
      await tempDir.delete(recursive: true);
    },
  );
}
