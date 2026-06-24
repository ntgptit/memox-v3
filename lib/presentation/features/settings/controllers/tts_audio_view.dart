import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';

part 'tts_audio_view.freezed.dart';

/// The Audio & speech screen view-state (kit screen 23): the persisted
/// [TtsSettings] + the device [voices] for the current language, plus transient
/// [isPlaying] (preview) / [isSaving] flags. An empty [voices] list is the kit
/// "no voices" state; a failed engine load surfaces as `AsyncError` (the
/// "engine error" state).
@freezed
sealed class TtsAudioView with _$TtsAudioView {
  const factory TtsAudioView({
    required TtsSettings settings,
    required List<TtsVoice> voices,
    @Default(false) bool isPlaying,
    @Default(false) bool isSaving,
  }) = _TtsAudioView;
}
