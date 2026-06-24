/// The app's default TTS front-side language (kit screen 23 — Audio & speech).
/// Persisted in `tts_settings.front_language`. Distinct from `TargetLanguage`
/// (a deck's declared language) — this is the app-level default; a deck's
/// `target_language` wins for that deck's playback
/// (`docs/business/tts/tts-settings.md`).
enum TtsFrontLanguage {
  korean('korean'),
  english('english');

  const TtsFrontLanguage(this.storageValue);

  /// Stable string persisted in `tts_settings.front_language`.
  final String storageValue;

  /// App default TTS language is Korean.
  static const TtsFrontLanguage fallback = TtsFrontLanguage.korean;

  /// Parses a stored value; an unknown/missing string falls back to Korean.
  static TtsFrontLanguage fromStorage(String? value) {
    for (final TtsFrontLanguage language in TtsFrontLanguage.values) {
      if (language.storageValue == value) {
        return language;
      }
    }
    return fallback;
  }
}
