import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_voice.freezed.dart';

/// A platform text-to-speech voice (kit screen 23 voice list). [name] is the
/// platform-specific voice identifier stored in `tts_settings.front_voice_name`.
@freezed
sealed class TtsVoice with _$TtsVoice {
  const factory TtsVoice({required String name, required String localeTag}) =
      _TtsVoice;
}
