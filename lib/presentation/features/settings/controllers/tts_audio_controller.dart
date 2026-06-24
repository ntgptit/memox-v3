import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/types/tts_front_language.dart';
import 'package:memox/domain/types/tts_language_code.dart';
import 'package:memox/domain/usecases/tts_settings_usecases.dart';
import 'package:memox/presentation/features/settings/controllers/tts_audio_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_audio_controller.g.dart';

/// Drives the Audio & speech screen (kit screen 23): loads the persisted
/// [TtsSettings] + the device voices for the current language (applying the
/// settings to the engine), then mutates language/voice/rate/pitch (persisted +
/// re-applied) and runs the sample preview. A voice-list/engine failure surfaces
/// as `AsyncError` (the engine-error state); empty voices is the no-voices state.
@riverpod
class TtsAudioController extends _$TtsAudioController {
  @override
  Future<TtsAudioView> build() async {
    final TtsService service = ref.watch(ttsServiceProvider);
    // Stop any in-flight preview when the screen leaves (also avoids a late
    // `play()` write racing disposal).
    ref.onDispose(service.stop);
    await service.init();
    final GetTtsSettingsUseCase getUseCase = ref.watch(
      getTtsSettingsUseCaseProvider,
    );
    final TtsSettings settings =
        (await getUseCase.call()).data ?? const TtsSettings();
    await service.applySettings(settings);
    final List<TtsVoice> voices = await service.availableVoices(
      settings.frontLanguage.languageCode,
    );
    return TtsAudioView(settings: settings, voices: voices);
  }

  UpdateTtsSettingsUseCase get _update =>
      ref.read(updateTtsSettingsUseCaseProvider);
  TtsService get _service => ref.read(ttsServiceProvider);

  /// Switch the front language: persist (clears the voice), reload that
  /// language's voices, and re-apply to the engine.
  Future<void> setLanguage(TtsFrontLanguage language) async {
    final TtsAudioView? current = state.asData?.value;
    if (current == null || language == current.settings.frontLanguage) {
      return;
    }
    state = AsyncData<TtsAudioView>(current.copyWith(isSaving: true));
    await _update.updateLanguage(language);
    final TtsSettings next = current.settings.withFrontLanguage(language);
    await _service.applySettings(next);
    final List<TtsVoice> voices = await _service.availableVoices(
      language.languageCode,
    );
    state = AsyncData<TtsAudioView>(
      TtsAudioView(settings: next, voices: voices),
    );
  }

  /// Select a voice (or null = system default) and persist it.
  Future<void> setVoice(String? voiceName) async {
    final TtsAudioView? current = state.asData?.value;
    if (current == null) {
      return;
    }
    await _update.updateVoice(voiceName);
    final TtsSettings next = current.settings.copyWith(
      frontVoiceName: voiceName,
    );
    await _service.applySettings(next);
    final TtsAudioView? after = state.asData?.value;
    if (after == null) {
      return;
    }
    state = AsyncData<TtsAudioView>(after.copyWith(settings: next));
  }

  /// Persist + apply a new speech rate (clamped).
  Future<void> setRate(double rate) => _mutateSlider(
    (TtsSettings s) => s.copyWith(rate: rate),
    _update.updateRate(rate),
  );

  /// Persist + apply a new pitch (clamped).
  Future<void> setPitch(double pitch) => _mutateSlider(
    (TtsSettings s) => s.copyWith(pitch: pitch),
    _update.updatePitch(pitch),
  );

  Future<void> _mutateSlider(
    TtsSettings Function(TtsSettings) change,
    Future<void> persist,
  ) async {
    final TtsAudioView? current = state.asData?.value;
    if (current == null) {
      return;
    }
    final TtsSettings next = change(current.settings).normalized();
    state = AsyncData<TtsAudioView>(
      current.copyWith(settings: next, isSaving: true),
    );
    await persist;
    await _service.applySettings(next);
    // Re-read after the awaits so an overlapping slider drag isn't clobbered.
    final TtsAudioView? after = state.asData?.value;
    if (after == null) {
      return;
    }
    state = AsyncData<TtsAudioView>(
      after.copyWith(settings: next, isSaving: false),
    );
  }

  /// Speak [sample] in the current language; flips [TtsAudioView.isPlaying]
  /// while in flight (the engine awaits speak-completion).
  Future<void> play(String sample) async {
    final TtsAudioView? current = state.asData?.value;
    if (current == null || current.isPlaying) {
      return;
    }
    state = AsyncData<TtsAudioView>(current.copyWith(isPlaying: true));
    await _service.speak(
      sample,
      language: current.settings.frontLanguage.languageCode,
    );
    final TtsAudioView? after = state.asData?.value;
    if (after != null) {
      state = AsyncData<TtsAudioView>(after.copyWith(isPlaying: false));
    }
  }

  /// Stop the preview.
  Future<void> stop() async {
    await _service.stop();
    final TtsAudioView? current = state.asData?.value;
    if (current != null) {
      state = AsyncData<TtsAudioView>(current.copyWith(isPlaying: false));
    }
  }
}
