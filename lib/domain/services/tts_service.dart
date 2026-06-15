import 'package:memox/domain/models/tts_voice.dart';

/// TTS playback states.
/// `paused` is reserved — UI must NOT expose a pause action.
enum TtsState { idle, speaking, paused, error }

/// Platform-agnostic TTS engine port.
/// See `docs/business/tts/tts-settings.md` §Playback policy.
abstract interface class TtsService {
  Stream<TtsState> get stateStream;
  TtsState get currentState;

  /// Speaks [text] with the given engine parameters.
  /// Stops any in-flight speech before starting.
  Future<void> speak(
    String text, {
    required String languageCode,
    String? voiceName,
    required double rate,
    required double pitch,
    required double volume,
  });

  Future<void> stop();

  /// Available voices whose locale starts with [languageCode] (e.g. 'ko-KR').
  /// Returns empty list on error — never throws.
  Future<List<TtsVoice>> availableVoices(String languageCode);

  void dispose();
}
