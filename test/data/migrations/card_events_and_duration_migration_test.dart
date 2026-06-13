// ignore_for_file: prefer_single_quotes -- reason: embedded SQL literals use single quotes.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Legacy database pinned to schema v6 (before `card_events` /
/// `study_attempts.duration_ms`). Only the tables in the attempt FK chain are
/// created — enough to insert an attempt and exercise the v7 migration.
class _LegacyV6Database extends AppDatabase {
  _LegacyV6Database(super.executor);

  @override
  int get schemaVersion => 6;

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
    'migrates duration_ms (NULL) + creates card_events, data preserved',
    () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'memox_card_events_',
      );
      final File dbFile = File(
        '${tempDir.path}${Platform.pathSeparator}memox.sqlite',
      );

      final _LegacyV6Database legacy = _LegacyV6Database(
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
        "created_at, updated_at) VALUES ('c1', 'd1', '안녕', 'Hi', 0, 1, 1)",
      );
      await legacy.customStatement(
        "INSERT INTO study_sessions (id, entry_type, study_type, status, "
        "started_at, updated_at) VALUES ('s1', 'deck', 'srs_review', "
        "'completed', 1, 1)",
      );
      await legacy.customStatement(
        "INSERT INTO study_session_items (id, session_id, flashcard_id, "
        "sort_order, created_at, updated_at) VALUES ('i1', 's1', 'c1', 0, 1, 1)",
      );
      await legacy.customStatement(
        "INSERT INTO study_attempts (id, session_item_id, result, study_mode, "
        "box_before, box_after, attempted_at) VALUES "
        "('a1', 'i1', 'perfect', 'review', 1, 2, 1000)",
      );
      await legacy.close();

      final AppDatabase migrated = AppDatabase(NativeDatabase(dbFile));
      expect(migrated.schemaVersion, 8);

      final StudyAttemptRow attempt = await migrated
          .select(migrated.studyAttempts)
          .getSingle();
      expect(attempt.id, 'a1');
      expect(attempt.durationMs, isNull);

      // card_events table exists and accepts inserts post-migration.
      await migrated
          .into(migrated.cardEvents)
          .insert(
            CardEventsCompanion.insert(
              id: 'e1',
              flashcardId: 'c1',
              type: 'created',
              occurredAt: 1,
            ),
          );
      final CardEventRow event = await migrated
          .select(migrated.cardEvents)
          .getSingle();
      expect(event.type, 'created');

      await migrated.close();
      await tempDir.delete(recursive: true);
    },
  );
}
