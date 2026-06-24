import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'tts_settings_dao.g.dart';

/// Thin Drift accessor for the single-row `tts_settings` table (id `'default'`).
/// No business logic (`docs/database/drift-guide.md`) — defaults, normalization,
/// and row↔model mapping live in `TtsSettingsRepositoryImpl`.
@DriftAccessor(include: <String>{'../drift/tts_settings.drift'})
class TtsSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$TtsSettingsDaoMixin {
  TtsSettingsDao(super.db);

  /// The single-row primary key.
  static const String defaultRowId = 'default';

  /// The persisted row, or `null` when it has not been written yet.
  Future<TtsSettingsRow?> read() => (select(
    ttsSettings,
  )..where((t) => t.id.equals(defaultRowId))).getSingleOrNull();

  /// Insert-or-update the single row.
  Future<void> upsert(TtsSettingsCompanion row) =>
      into(ttsSettings).insertOnConflictUpdate(row);
}
