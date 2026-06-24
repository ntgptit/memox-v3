import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/migrations/v9_add_tts_settings.dart';

void main() {
  // Migration contract (`docs/database/migration-contract.md`): reduce the db to
  // the v8 shape with data, run the migration, and assert existing data is
  // preserved and the new table works. The v8→v9 step is purely additive (one
  // new single-row table), so we drop `tts_settings` to recreate the v8 shape,
  // seed a folder, then run `migrateV8ToV9` and exercise the addition. WBS 8.4.1.
  group('v8 → v9 migration (TTS settings enabler)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    Future<void> reduceToV8() async {
      await db.customStatement('DROP TABLE tts_settings');
    }

    test('adds tts_settings while preserving data', () async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'folder',
              name: 'Korean',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      await reduceToV8();

      await migrateV8ToV9(db.createMigrator(), db);

      // Pre-existing content survives the additive migration.
      expect(await db.select(db.folders).get(), hasLength(1));

      // The new single-row table round-trips with its defaults.
      await db
          .into(db.ttsSettings)
          .insert(TtsSettingsCompanion.insert(id: 'default'));
      final TtsSettingsRow row = await db.select(db.ttsSettings).getSingle();
      expect(row.id, 'default');
      expect(row.autoPlay, isFalse);
      expect(row.frontLanguage, 'korean');
      expect(row.rate, 0.5);
      expect(row.pitch, 1.0);
      expect(row.volume, 1.0);
      expect(row.frontVoiceName, isNull);
    });

    test(
      'rate/pitch/volume CHECK constraints reject out-of-range writes',
      () async {
        await reduceToV8();
        await migrateV8ToV9(db.createMigrator(), db);

        Future<void> insertWith(TtsSettingsCompanion overrides) =>
            db.into(db.ttsSettings).insert(overrides);

        await expectLater(
          insertWith(
            TtsSettingsCompanion.insert(
              id: 'r',
              rate: const Value<double>(0.9), // > maxRate 0.7
            ),
          ),
          throwsA(anything),
          reason: 'rate CHECK',
        );
        await expectLater(
          insertWith(
            TtsSettingsCompanion.insert(
              id: 'p',
              pitch: const Value<double>(2.0), // > maxPitch 1.5
            ),
          ),
          throwsA(anything),
          reason: 'pitch CHECK',
        );
        await expectLater(
          insertWith(
            TtsSettingsCompanion.insert(
              id: 'v',
              volume: const Value<double>(5.0), // > maxVolume 1.0
            ),
          ),
          throwsA(anything),
          reason: 'volume CHECK',
        );
      },
    );
  });
}
