// ignore_for_file: prefer_single_quotes -- reason: embedded SQL literals use single quotes.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Legacy database pinned to schema v7 (before `flashcards.part_of_speech` /
/// `is_flagged`). Only the flashcard FK chain is created.
class _LegacyV7Database extends AppDatabase {
  _LegacyV7Database(super.executor);

  @override
  int get schemaVersion => 7;

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
          created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
      ''');
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

void main() {
  test(
    'migrates part_of_speech (NULL) + is_flagged (false), data preserved',
    () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'memox_pos_flag_',
      );
      final File dbFile = File(
        '${tempDir.path}${Platform.pathSeparator}memox.sqlite',
      );

      final _LegacyV7Database legacy = _LegacyV7Database(
        NativeDatabase(dbFile),
      );
      await legacy.customStatement('PRAGMA foreign_keys = ON');
      await legacy.customStatement(
        "INSERT INTO folders (id, name, content_mode, sort_order, created_at, "
        "updated_at) VALUES ('f1', 'Korean', 'decks', 0, 1, 1)",
      );
      await legacy.customStatement(
        "INSERT INTO decks (id, folder_id, name, target_language, sort_order, "
        "created_at, updated_at) VALUES ('d1', 'f1', 'N5', 'korean', 0, 1, 1)",
      );
      await legacy.customStatement(
        "INSERT INTO flashcards (id, deck_id, front, back, sort_order, "
        "created_at, updated_at) VALUES ('c1', 'd1', '연구자', 'researcher', 0, 1, 1)",
      );
      await legacy.close();

      final AppDatabase migrated = AppDatabase(NativeDatabase(dbFile));
      expect(migrated.schemaVersion, 8);

      final FlashcardRow row = await migrated
          .select(migrated.flashcards)
          .getSingle();
      expect(row.id, 'c1');
      expect(row.front, '연구자');
      expect(row.partOfSpeech, isNull);
      expect(row.isFlagged, isFalse);

      await migrated.close();
      await tempDir.delete(recursive: true);
    },
  );
}
