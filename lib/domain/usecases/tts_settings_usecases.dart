import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/types/tts_front_language.dart';

/// Loads the global TTS settings (kit screen 23). Pure delegation — defaults +
/// normalization live in the repository.
class GetTtsSettingsUseCase {
  const GetTtsSettingsUseCase({required this.repository});

  final TtsSettingsRepository repository;

  Future<Result<TtsSettings>> call() => repository.load();
}

/// Mutates the global TTS settings, one field at a time. Slider writes clamp via
/// `TtsSettings.normalize*` (values are never rejected — sliders enforce range in
/// the UI and corrupt DB values self-heal). `updateLanguage` clears the stored
/// voice (it belonged to the previous language).
class UpdateTtsSettingsUseCase {
  const UpdateTtsSettingsUseCase({required this.repository});

  final TtsSettingsRepository repository;

  Future<Result<void>> updateAutoPlay(bool value) =>
      _mutate((TtsSettings s) => s.copyWith(autoPlay: value));

  Future<Result<void>> updateRate(double value) => _mutate(
    (TtsSettings s) => s.copyWith(rate: TtsSettings.normalizeRate(value)),
  );

  Future<Result<void>> updatePitch(double value) => _mutate(
    (TtsSettings s) => s.copyWith(pitch: TtsSettings.normalizePitch(value)),
  );

  Future<Result<void>> updateVolume(double value) => _mutate(
    (TtsSettings s) => s.copyWith(volume: TtsSettings.normalizeVolume(value)),
  );

  /// Select a platform voice id, or `null` for the system default.
  Future<Result<void>> updateVoice(String? voiceName) => _mutate(
    (TtsSettings s) => voiceName == null
        // freezed copyWith cannot null a field; rebuild to clear it.
        ? s.withFrontLanguage(s.frontLanguage)
        : s.copyWith(frontVoiceName: voiceName),
  );

  /// Switch the front language (clears the stored voice).
  Future<Result<void>> updateLanguage(TtsFrontLanguage language) =>
      _mutate((TtsSettings s) => s.withFrontLanguage(language));

  Future<Result<void>> _mutate(TtsSettings Function(TtsSettings) change) async {
    final Result<TtsSettings> loaded = await repository.load();
    final TtsSettings? current = loaded.data;
    if (loaded.failure != null || current == null) {
      return (
        failure:
            loaded.failure ??
            const Failure.storage(
              operation: StorageOp.read,
              table: 'tts_settings',
              cause: 'no settings',
            ),
        data: null,
      );
    }
    return repository.save(change(current).normalized());
  }
}
