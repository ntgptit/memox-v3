import 'package:memox/domain/types/target_language.dart';

/// Speech-engine language codes (platform engine identifiers — NOT the same as
/// [TargetLanguage]). See `docs/contracts/types-catalog.md` §TtsLanguageCode.
enum TtsLanguageCode {
  /// `ko-KR`.
  koKR,

  /// `en-US`.
  enUS,
}

/// Maps a [TargetLanguage] to its engine code, or `null` when TTS is disabled.
///
/// `korean → koKR`, `english → enUS`, `unsupported → null`.
TtsLanguageCode? ttsCodeForLanguage(TargetLanguage language) =>
    switch (language) {
      TargetLanguage.korean => TtsLanguageCode.koKR,
      TargetLanguage.english => TtsLanguageCode.enUS,
      TargetLanguage.unsupported => null,
    };

extension TtsLanguageCodeX on TtsLanguageCode {
  /// Platform TTS engine language code string.
  String get engineCode => switch (this) {
    TtsLanguageCode.koKR => 'ko-KR',
    TtsLanguageCode.enUS => 'en-US',
  };
}
