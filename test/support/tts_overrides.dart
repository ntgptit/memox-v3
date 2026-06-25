import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/types/tts_language_code.dart';

/// A no-op [TtsService] for widget tests — records nothing, throws nothing, and
/// (crucially) never touches the platform `flutter_tts` plugin. Study screens
/// wired with auto-play (WBS 8.4.3) read the TTS providers on mount, so tests
/// that pump those screens override the engine + settings store with these.
class FakeStudyTtsService implements TtsService {
  int stopCalls = 0;
  String? spokenText;

  @override
  Future<void> init() async {}

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguageCode language) async =>
      <TtsVoice>[];

  @override
  Future<void> applySettings(TtsSettings settings) async {}

  @override
  Future<void> speak(String text, {required TtsLanguageCode language}) async {
    spokenText = text;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }
}

/// An in-memory [TtsSettingsRepository] for widget tests — no Drift / DB.
class FakeStudyTtsSettingsRepo implements TtsSettingsRepository {
  FakeStudyTtsSettingsRepo([this.current = const TtsSettings()]);
  TtsSettings current;

  @override
  Future<Result<TtsSettings>> load() async => (failure: null, data: current);

  @override
  Future<Result<void>> save(TtsSettings settings) async {
    current = settings;
    return (failure: null, data: null);
  }
}

// Riverpod's `Override` is `@publicInMisc` and not usable as a named type in
// app/test code, so a helper that returns `List<Override>` can't satisfy the
// strict-inference lints. Tests instead inline the two overrides below directly
// in the `ProviderScope(overrides: [...])` literal (context-typed there):
//
//   ttsServiceProvider.overrideWithValue(FakeStudyTtsService()),
//   ttsSettingsRepositoryProvider.overrideWithValue(FakeStudyTtsSettingsRepo()),
