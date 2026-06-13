// ignore_for_file: prefer_single_quotes -- reason: embedded SQL literals use single quotes.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Legacy database pinned to schema v5 (before `flashcard_progress.last_reset_at`).
/// Only the tables in the reset column's FK chain are created — enough to insert
/// a progress row and exercise the v6 `addColumn` migration.
class _LegacyV5Database extends AppDatabase {
  _LegacyV5Database(super.executor);

  @override
  int get schemaVersion => 5;

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
          pronunciation TEXT,
          hint TEXT,
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
      // Study tables exist since v4; needed so the v7 migration (run on reopen)
      // can ALTER study_attempts.
      await customStatement('''
        CREATE TABLE study_sessions (
          id TEXT NOT NULL PRIMARY KEY, entry_type TEXT NOT NULL,
          entry_ref_id TEXT, study_type TEXT NOT NULL, status TEXT NOT NULL,
          started_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
      ''');
      await customStatement('''
        CREATE TABLE study_session_items (
          id TEXT NOT NULL PRIMARY KEY,
          session_id TEXT NOT NULL REFERENCES study_sessions (id) ON DELETE CASCADE,
          flashcard_id TEXT NOT NULL, sort_order INTEGER NOT NULL,
          answered_at INTEGER, created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL);
      ''');
      await customStatement('''
        CREATE TABLE study_attempts (
          id TEXT NOT NULL PRIMARY KEY,
          session_item_id TEXT NOT NULL
            REFERENCES study_session_items (id) ON DELETE CASCADE,
          result TEXT NOT NULL, study_mode TEXT NOT NULL,
          box_before INTEGER NOT NULL DEFAULT 0,
          box_after INTEGER NOT NULL DEFAULT 0, user_input TEXT,
          attempted_at INTEGER NOT NULL);
      ''');
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

void main() {
  test(
    'migrates flashcard_progress.last_reset_at as NULL without losing data',
    () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'memox_last_reset_at_',
      );
      final File dbFile = File(
        '${tempDir.path}${Platform.pathSeparator}memox.sqlite',
      );

      final _LegacyV5Database legacyDb = _LegacyV5Database(
        NativeDatabase(dbFile),
      );
      await legacyDb.customStatement('PRAGMA foreign_keys = ON');
      await legacyDb.customStatement(
        "INSERT INTO folders (id, name, content_mode, sort_order, created_at, "
        "updated_at) VALUES ('f1', 'Korean', 'decks', 0, 1, 1)",
      );
      await legacyDb.customStatement(
        "INSERT INTO decks (id, folder_id, name, target_language, sort_order, "
        "created_at, updated_at) VALUES ('d1', 'f1', 'N5', 'korean', 0, 1, 1)",
      );
      await legacyDb.customStatement(
        "INSERT INTO flashcards (id, deck_id, front, back, sort_order, "
        "created_at, updated_at) VALUES ('c1', 'd1', '안녕', 'Hi', 0, 1, 1)",
      );
      await legacyDb.customStatement(
        "INSERT INTO flashcard_progress (flashcard_id, box_number, review_count, "
        "lapse_count) VALUES ('c1', 3, 5, 1)",
      );
      await legacyDb.close();

      final AppDatabase migratedDb = AppDatabase(NativeDatabase(dbFile));
      final FlashcardProgressRow row = await migratedDb
          .select(migratedDb.flashcardProgress)
          .getSingle();

      expect(migratedDb.schemaVersion, 8);
      expect(row.flashcardId, 'c1');
      expect(row.boxNumber, 3);
      expect(row.reviewCount, 5);
      expect(row.lapseCount, 1);
      expect(row.lastResetAt, isNull);

      await migratedDb.close();
      await tempDir.delete(recursive: true);
    },
  );
}
