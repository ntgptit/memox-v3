// ignore_for_file: prefer_single_quotes -- reason: embedded SQL literals use single quotes.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Legacy database pinned to schema v9 (before `study_sessions.study_flow` /
/// `current_mode`). Only the `study_sessions` table is needed — the new
/// columns are additive on that table.
class _LegacyV9Database extends AppDatabase {
  _LegacyV9Database(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await customStatement('''
        CREATE TABLE study_sessions (
          id TEXT NOT NULL PRIMARY KEY,
          entry_type TEXT NOT NULL,
          entry_ref_id TEXT,
          study_type TEXT NOT NULL,
          status TEXT NOT NULL,
          started_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL);
      ''');
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

void main() {
  test(
    'migrates study_flow (recall default) + current_mode (NULL), data preserved',
    () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'memox_study_flow_',
      );
      final File dbFile = File(
        '${tempDir.path}${Platform.pathSeparator}memox.sqlite',
      );

      final _LegacyV9Database legacy = _LegacyV9Database(
        NativeDatabase(dbFile),
      );
      await legacy.customStatement(
        "INSERT INTO study_sessions (id, entry_type, entry_ref_id, study_type, "
        "status, started_at, updated_at) "
        "VALUES ('s1', 'deck', 'd1', 'new_cards', 'in_progress', 1, 1)",
      );
      await legacy.close();

      final AppDatabase migrated = AppDatabase(NativeDatabase(dbFile));
      expect(migrated.schemaVersion, 10);

      final StudySessionRow row = await migrated
          .select(migrated.studySessions)
          .getSingle();
      expect(row.id, 's1');
      expect(row.studyType, 'new_cards');
      expect(row.studyFlow, 'srs_recall_review');
      expect(row.currentMode, isNull);

      await migrated.close();
      await tempDir.delete(recursive: true);
    },
  );
}
