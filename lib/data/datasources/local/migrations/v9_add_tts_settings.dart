import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v8 → v9: the TTS-settings enabler (WBS 8.4.1).
///
/// Purely additive: creates the single-row `tts_settings` table (id `'default'`)
/// for the app's global speech preferences. No existing data is touched (fresh
/// table, no back-fill); the row is created lazily by the repository on first
/// load (defaults applied). See `docs/database/migration-contract.md`,
/// `docs/database/schema-contract.md` §tts_settings, and
/// `docs/business/tts/tts-settings.md`.
Future<void> migrateV8ToV9(Migrator m, AppDatabase db) async {
  await m.createTable(db.ttsSettings);
}
