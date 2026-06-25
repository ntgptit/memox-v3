import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/types/tts_front_language.dart';

/// Speech-engine language codes (platform engine identifiers) — NOT the same as
/// `TargetLanguage`. See `docs/contracts/types-catalog.md`.
enum TtsLanguageCode {
  koKR('ko-KR'),
  enUS('en-US');

  const TtsLanguageCode(this.localeTag);

  /// The platform BCP-47 locale tag (e.g. `ko-KR`).
  final String localeTag;
}

/// Maps the app's [TtsFrontLanguage] default to its engine [TtsLanguageCode].
extension TtsFrontLanguageCodeX on TtsFrontLanguage {
  TtsLanguageCode get languageCode => switch (this) {
    TtsFrontLanguage.korean => TtsLanguageCode.koKR,
    TtsFrontLanguage.english => TtsLanguageCode.enUS,
  };
}

/// Maps a deck's [TargetLanguage] to its engine [TtsLanguageCode], or `null`
/// when the deck is [TargetLanguage.unsupported] — the per-deck TTS gate
/// (`docs/business/tts/tts-settings.md` §Deck-level language gate). A `null`
/// result means study playback is silently skipped for that deck (WBS 8.4.3).
extension TargetLanguageTtsCodeX on TargetLanguage {
  TtsLanguageCode? get ttsLanguageCode => switch (this) {
    TargetLanguage.korean => TtsLanguageCode.koKR,
    TargetLanguage.english => TtsLanguageCode.enUS,
    TargetLanguage.unsupported => null,
  };
}
