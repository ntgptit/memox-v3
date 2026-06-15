import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/domain/types/tts_language_code.dart';

/// Loads the persisted TTS settings.
///
/// Failure types: `StorageFailure`.
class LoadTtsSettingsUseCase {
  const LoadTtsSettingsUseCase(this._repository);

  final TtsSettingsRepository _repository;

  Future<Result<TtsSettings>> call() => _repository.load();
}

/// Updates individual TTS settings fields.
///
/// Slider writes clamp via normalize* — no ValidationFailure for out-of-range.
/// Failure types: `StorageFailure`.
class UpdateTtsSettingsUseCase {
  const UpdateTtsSettingsUseCase(this._repository);

  final TtsSettingsRepository _repository;

  Future<Result<void>> updateAutoPlay(bool autoPlay) =>
      _modify((TtsSettings s) => s.copyWith(autoPlay: autoPlay));

  Future<Result<void>> updateRate(double rate) =>
      _modify((TtsSettings s) => s.copyWith(rate: TtsSettings.normalizeRate(rate)));

  Future<Result<void>> updatePitch(double pitch) =>
      _modify((TtsSettings s) => s.copyWith(pitch: TtsSettings.normalizePitch(pitch)));

  Future<Result<void>> updateVolume(double volume) =>
      _modify((TtsSettings s) => s.copyWith(volume: TtsSettings.normalizeVolume(volume)));

  Future<Result<void>> updateVoice(String? voiceName) =>
      _modify((TtsSettings s) => s.withVoice(voiceName));

  Future<Result<void>> updateLanguage(TtsLanguageCode lang) =>
      _modify((TtsSettings s) => s.withLanguage(lang));

  Future<Result<void>> _modify(TtsSettings Function(TtsSettings) mutate) async {
    final Result<TtsSettings> loaded = await _repository.load();
    return switch (loaded) {
      Err<TtsSettings>(:final failure) => Result<void>.err(failure),
      Ok<TtsSettings>(:final value) => _repository.save(mutate(value)),
    };
  }
}

/// Speaks a flashcard's front text via the TTS engine.
///
/// - `targetLanguage == unsupported` → silent ok (no engine call).
/// - Blank `frontText` → silent ok.
/// - Engine errors → `StorageFailure` (suppressed; no user popup).
/// Failure types: `StorageFailure`.
class SpeakFlashcardUseCase {
  const SpeakFlashcardUseCase(this._ttsService, this._repository);

  final TtsService _ttsService;
  final TtsSettingsRepository _repository;

  Future<Result<void>> speakFlashcardFront({
    required String frontText,
    required TargetLanguage targetLanguage,
  }) async {
    if (targetLanguage == TargetLanguage.unsupported) {
      return const Result<void>.ok(null);
    }
    if (frontText.trim().isEmpty) {
      return const Result<void>.ok(null);
    }
    final TtsLanguageCode lang = switch (targetLanguage) {
      TargetLanguage.korean => TtsLanguageCode.koKR,
      TargetLanguage.english => TtsLanguageCode.enUS,
      TargetLanguage.unsupported => TtsLanguageCode.koKR,
    };
    return _speakWithSettings(frontText, lang);
  }

  Future<Result<void>> speakText({
    required String text,
    required TtsLanguageCode lang,
  }) async {
    if (text.trim().isEmpty) {
      return const Result<void>.ok(null);
    }
    return _speakWithSettings(text, lang);
  }

  Future<Result<void>> _speakWithSettings(
    String text,
    TtsLanguageCode lang,
  ) async {
    try {
      final Result<TtsSettings> loaded = await _repository.load();
      final TtsSettings settings = switch (loaded) {
        Ok<TtsSettings>(:final value) => value,
        Err<TtsSettings>() => TtsSettings.defaults,
      };
      await _ttsService.speak(
        text,
        languageCode: lang.engineCode,
        voiceName: settings.frontVoiceName,
        rate: settings.rate,
        pitch: settings.pitch,
        volume: settings.volume,
      );
      return const Result<void>.ok(null);
    } catch (e) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: e.toString(),
          table: 'tts_engine',
        ),
      );
    }
  }
}

/// Stops any in-progress TTS speech.
class StopSpeechUseCase {
  const StopSpeechUseCase(this._ttsService);

  final TtsService _ttsService;

  Future<Result<void>> call() async {
    try {
      await _ttsService.stop();
      return const Result<void>.ok(null);
    } catch (_) {
      return const Result<void>.ok(null);
    }
  }
}
