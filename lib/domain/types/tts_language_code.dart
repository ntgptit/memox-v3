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
