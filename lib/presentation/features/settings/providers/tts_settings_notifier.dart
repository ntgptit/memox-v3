import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/models/tts_voice.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/types/tts_language_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_settings_notifier.g.dart';

@riverpod
class TtsSettingsNotifier extends _$TtsSettingsNotifier {
  @override
  Future<TtsSettings> build() async {
    final Result<TtsSettings> result = await ref
        .read(loadTtsSettingsUseCaseProvider)
        .call();
    return switch (result) {
      Ok<TtsSettings>(:final value) => value,
      Err<TtsSettings>(:final failure) => Future<TtsSettings>.error(failure),
    };
  }

  Future<void> updateAutoPlay(bool value) =>
      _update(ref.read(updateTtsSettingsUseCaseProvider).updateAutoPlay(value));

  Future<void> updateRate(double value) =>
      _update(ref.read(updateTtsSettingsUseCaseProvider).updateRate(value));

  Future<void> updatePitch(double value) =>
      _update(ref.read(updateTtsSettingsUseCaseProvider).updatePitch(value));

  Future<void> updateVolume(double value) =>
      _update(ref.read(updateTtsSettingsUseCaseProvider).updateVolume(value));

  Future<void> updateVoice(String? voiceName) => _update(
    ref.read(updateTtsSettingsUseCaseProvider).updateVoice(voiceName),
  );

  Future<void> updateLanguage(TtsLanguageCode lang) =>
      _update(ref.read(updateTtsSettingsUseCaseProvider).updateLanguage(lang));

  Future<void> _update(Future<Result<void>> operation) async {
    await operation;
    state = const AsyncLoading<TtsSettings>();
    state = await AsyncValue.guard(build);
  }
}

@riverpod
Future<List<TtsVoice>> ttsVoices(Ref ref, TtsLanguageCode lang) async {
  final TtsService service = ref.watch(ttsServiceProvider);
  final String code = lang.engineCode;
  return service.availableVoices(code);
}
