import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// v9 — TTS settings:
/// - `tts_settings` single-row table (id = 'default') for TTS playback config.
/// See `docs/business/tts/tts-settings.md`.
Future<void> addTtsSettings(Migrator m, AppDatabase db) async {
  await m.createTable(db.ttsSettings);
}
