import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/tts_settings.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/types/tts_front_language.dart';
import 'package:memox/domain/usecases/tts_settings_usecases.dart';

class _FakeRepo implements TtsSettingsRepository {
  TtsSettings current = const TtsSettings();
  TtsSettings? lastSaved;

  @override
  Future<Result<TtsSettings>> load() async => (failure: null, data: current);

  @override
  Future<Result<void>> save(TtsSettings settings) async {
    lastSaved = settings;
    current = settings;
    return (failure: null, data: null);
  }
}

void main() {
  group('UpdateTtsSettingsUseCase', () {
    test('updateAutoPlay persists the flag', () async {
      final _FakeRepo repo = _FakeRepo();
      await UpdateTtsSettingsUseCase(repository: repo).updateAutoPlay(true);
      expect(repo.lastSaved?.autoPlay, isTrue);
    });

    test('updateRate clamps before persisting', () async {
      final _FakeRepo repo = _FakeRepo();
      await UpdateTtsSettingsUseCase(repository: repo).updateRate(9);
      expect(repo.lastSaved?.rate, TtsSettings.maxRate);
    });

    test('updatePitch / updateVolume clamp', () async {
      final _FakeRepo repo = _FakeRepo();
      final UpdateTtsSettingsUseCase uc = UpdateTtsSettingsUseCase(
        repository: repo,
      );
      await uc.updatePitch(0.1);
      expect(repo.lastSaved?.pitch, TtsSettings.minPitch);
      await uc.updateVolume(9);
      expect(repo.lastSaved?.volume, TtsSettings.maxVolume);
    });

    test('updateLanguage clears the stored voice', () async {
      final _FakeRepo repo = _FakeRepo()
        ..current = const TtsSettings(
          frontLanguage: TtsFrontLanguage.korean,
          frontVoiceName: 'ko-voice',
        );
      await UpdateTtsSettingsUseCase(
        repository: repo,
      ).updateLanguage(TtsFrontLanguage.english);
      expect(repo.lastSaved?.frontLanguage, TtsFrontLanguage.english);
      expect(repo.lastSaved?.frontVoiceName, isNull);
    });

    test('updateVoice(name) sets it; updateVoice(null) clears it', () async {
      final _FakeRepo repo = _FakeRepo();
      final UpdateTtsSettingsUseCase uc = UpdateTtsSettingsUseCase(
        repository: repo,
      );
      await uc.updateVoice('en-voice');
      expect(repo.lastSaved?.frontVoiceName, 'en-voice');
      await uc.updateVoice(null);
      expect(repo.lastSaved?.frontVoiceName, isNull);
      // Clearing the voice must not change the language.
      expect(repo.lastSaved?.frontLanguage, TtsFrontLanguage.korean);
    });
  });

  group('GetTtsSettingsUseCase', () {
    test('delegates to the repository', () async {
      final _FakeRepo repo = _FakeRepo()
        ..current = const TtsSettings(autoPlay: true);
      final Result<TtsSettings> result = await GetTtsSettingsUseCase(
        repository: repo,
      ).call();
      expect(result.data?.autoPlay, isTrue);
    });
  });
}
