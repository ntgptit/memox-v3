// ignore_for_file: prefer_single_quotes -- reason: embedded SQL literals use single quotes.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Legacy database pinned to schema v8 (before `tts_settings`).
/// Since `tts_settings` has no foreign keys, no tables need to be created.
/// The database is opened at v8 so that opening it as v9 triggers the upgrade
/// path that creates `tts_settings`.
class _LegacyV8Database extends AppDatabase {
  _LegacyV8Database(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // tts_settings has no foreign keys — no tables needed for this test.
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

void main() {
  test(
    'v8→v9: tts_settings table is created and is usable after migration',
    () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'memox_tts_settings_',
      );
      final File dbFile = File(
        '${tempDir.path}${Platform.pathSeparator}memox.sqlite',
      );

      // Open and close at v8 — no tts_settings table should exist.
      final _LegacyV8Database legacy = _LegacyV8Database(
        NativeDatabase(dbFile),
      );
      final List<Map<String, Object?>> tablesBefore = await legacy
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='tts_settings'",
          )
          .get()
          .then(
            (rows) => rows.map((r) => r.data).toList(),
          );
      expect(
        tablesBefore,
        isEmpty,
        reason: 'tts_settings must not exist before v9 migration',
      );
      await legacy.close();

      // Open as v9 — migration creates tts_settings.
      final AppDatabase migrated = AppDatabase(NativeDatabase(dbFile));
      expect(migrated.schemaVersion, 9);

      final List<Map<String, Object?>> tablesAfter = await migrated
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='tts_settings'",
          )
          .get()
          .then(
            (rows) => rows.map((r) => r.data).toList(),
          );
      expect(
        tablesAfter,
        isNotEmpty,
        reason: 'tts_settings must exist after v9 migration',
      );

      // Insert a settings row and read it back to confirm all columns exist.
      await migrated.customStatement(
        "INSERT INTO tts_settings (id, auto_play, front_language, rate, pitch, volume, front_voice_name) "
        "VALUES ('default', 0, 'korean', 0.5, 1.0, 1.0, NULL)",
      );

      final List<Map<String, Object?>> rows = await migrated
          .customSelect('SELECT * FROM tts_settings WHERE id = ?',
              variables: [const Variable<String>('default')])
          .get()
          .then((rows) => rows.map((r) => r.data).toList());

      expect(rows, hasLength(1));
      final Map<String, Object?> row = rows.first;
      expect(row['id'], 'default');
      expect(row['auto_play'], 0);
      expect(row['front_language'], 'korean');
      expect(row['rate'], closeTo(0.5, 0.001));
      expect(row['pitch'], closeTo(1.0, 0.001));
      expect(row['volume'], closeTo(1.0, 0.001));
      expect(row['front_voice_name'], isNull);

      await migrated.close();
      await tempDir.delete(recursive: true);
    },
  );
}
