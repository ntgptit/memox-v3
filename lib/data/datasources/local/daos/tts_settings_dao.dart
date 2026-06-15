import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'tts_settings_dao.g.dart';

@DriftAccessor(include: <String>{'../drift/tts_settings.drift'})
class TtsSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$TtsSettingsDaoMixin {
  TtsSettingsDao(super.db);

  static const String _defaultId = 'default';

  Future<TtsSettingsRow?> loadSettings() => (select(
    attachedDatabase.ttsSettings,
  )..where((TtsSettings t) => t.id.equals(_defaultId))).getSingleOrNull();

  Future<void> saveSettings(TtsSettingsCompanion companion) =>
      into(attachedDatabase.ttsSettings).insertOnConflictUpdate(companion);
}
