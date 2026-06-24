/// The app's UI language preference (kit screen 25 — Language). Persisted via
/// `LanguageSettingsRepository`; mapped to a Flutter `Locale?` in the
/// presentation layer (`AppLanguageX.locale`) so the domain stays Flutter-free.
///
/// Distinct from `TargetLanguage` (a deck's study target) — this is the app's
/// own interface language.
enum AppLanguage {
  /// Follow the device locale (`MaterialApp.locale == null`).
  system('system'),

  /// English.
  english('en'),

  /// Vietnamese.
  vietnamese('vi');

  const AppLanguage(this.storageValue);

  /// Stable string persisted in SharedPreferences (`language.appLanguage`).
  final String storageValue;

  /// Parses a stored value, falling back to [AppLanguage.system] for an
  /// unknown/missing/corrupt string.
  static AppLanguage fromStorage(String? value) {
    for (final AppLanguage language in AppLanguage.values) {
      if (language.storageValue == value) {
        return language;
      }
    }
    return AppLanguage.system;
  }
}
