import 'package:shared_preferences/shared_preferences.dart';

/// Thin SharedPreferences accessor for the app-language key. Reads/writes the
/// raw string only — defaults and corrupt recovery live in
/// `LanguageSettingsRepositoryImpl` (`docs/database/storage-boundaries.md`).
class LanguageSettingsStore {
  LanguageSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  /// Persisted SharedPreferences key, per
  /// `docs/database/storage-boundaries.md` §Language settings.
  static const String appLanguageKey = 'language.appLanguage';

  /// Raw stored language string, or `null` when unset. Reading a value stored
  /// under the wrong type returns `null` (treated as missing by the repository)
  /// instead of throwing.
  String? readAppLanguage() {
    final Object? value = _prefs.get(appLanguageKey);
    return value is String ? value : null;
  }

  Future<void> writeAppLanguage(String value) =>
      _prefs.setString(appLanguageKey, value);
}
