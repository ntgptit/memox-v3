import 'package:shared_preferences/shared_preferences.dart';

/// Thin SharedPreferences accessor for the appearance (theme-mode) key.
/// Reads/writes the raw string only — defaults and corrupt recovery live in
/// `AppearanceSettingsRepositoryImpl` (`docs/database/storage-boundaries.md`).
class AppearanceSettingsStore {
  AppearanceSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  /// Persisted SharedPreferences key, per
  /// `docs/database/storage-boundaries.md` §Appearance settings.
  static const String themeModeKey = 'appearance.themeMode';

  /// Raw stored theme-mode string, or `null` when unset. Reading a value stored
  /// under the wrong type returns `null` (treated as missing by the repository)
  /// instead of throwing.
  String? readThemeMode() {
    final Object? value = _prefs.get(themeModeKey);
    return value is String ? value : null;
  }

  Future<void> writeThemeMode(String value) =>
      _prefs.setString(themeModeKey, value);
}
