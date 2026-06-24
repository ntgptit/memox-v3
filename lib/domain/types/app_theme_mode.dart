/// The app's theme preference (kit screen 24 — Appearance). Persisted via
/// `AppearanceSettingsRepository`; mapped to Flutter's `ThemeMode` in the
/// presentation layer so the domain stays Flutter-free.
enum AppThemeMode {
  /// Follow the device's light/dark schedule.
  system('system'),

  /// Always light.
  light('light'),

  /// Always dark.
  dark('dark');

  const AppThemeMode(this.storageValue);

  /// Stable string persisted in SharedPreferences (`appearance.themeMode`).
  final String storageValue;

  /// Parses a stored value, falling back to [AppThemeMode.system] for an
  /// unknown/missing/corrupt string.
  static AppThemeMode fromStorage(String? value) {
    for (final AppThemeMode mode in AppThemeMode.values) {
      if (mode.storageValue == value) {
        return mode;
      }
    }
    return AppThemeMode.system;
  }
}
