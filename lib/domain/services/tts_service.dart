import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/types/tts_language_code.dart';

/// Port over the platform text-to-speech engine (kit screen 23). Implemented by
/// `FlutterTtsService` (data layer) over `flutter_tts`. Voice listing + playback
/// only — settings persistence is `TtsSettingsRepository`.
///
/// Engine failures (init/list/speak) surface as thrown exceptions; callers map
/// them to the screen's no-voices / engine-error states (and, in study, log +
/// silently skip per `docs/contracts/usecase-contracts/tts.md`).
abstract interface class TtsService {
  /// Initialize the engine (e.g. await-speak-completion). Idempotent.
  Future<void> init();

  /// Available device voices for [language] (filtered by locale).
  Future<List<TtsVoice>> availableVoices(TtsLanguageCode language);

  /// Apply [settings] (language, rate, pitch, volume, voice) to the engine.
  Future<void> applySettings(TtsSettings settings);

  /// Speak [text] in [language] (front-side only — never the back).
  Future<void> speak(String text, {required TtsLanguageCode language});

  /// Stop any in-flight playback.
  Future<void> stop();
}
