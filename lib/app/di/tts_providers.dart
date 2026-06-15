import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/tts_settings_dao.dart';
import 'package:memox/data/repositories/tts_settings_repository_impl.dart';
import 'package:memox/data/services/flutter_tts_service.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/usecases/tts_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_providers.g.dart';

@Riverpod(keepAlive: true)
TtsService ttsService(Ref ref) {
  final FlutterTtsService service = FlutterTtsService();
  ref.onDispose(service.dispose);
  return service;
}

@Riverpod(keepAlive: true)
TtsSettingsDao ttsSettingsDao(Ref ref) =>
    TtsSettingsDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
TtsSettingsRepository ttsSettingsRepository(Ref ref) =>
    TtsSettingsRepositoryImpl(ref.watch(ttsSettingsDaoProvider));

@Riverpod(keepAlive: true)
LoadTtsSettingsUseCase loadTtsSettingsUseCase(Ref ref) =>
    LoadTtsSettingsUseCase(ref.watch(ttsSettingsRepositoryProvider));

@Riverpod(keepAlive: true)
UpdateTtsSettingsUseCase updateTtsSettingsUseCase(Ref ref) =>
    UpdateTtsSettingsUseCase(ref.watch(ttsSettingsRepositoryProvider));

@Riverpod(keepAlive: true)
SpeakFlashcardUseCase speakFlashcardUseCase(Ref ref) => SpeakFlashcardUseCase(
  ref.watch(ttsServiceProvider),
  ref.watch(ttsSettingsRepositoryProvider),
);

@Riverpod(keepAlive: true)
StopSpeechUseCase stopSpeechUseCase(Ref ref) =>
    StopSpeechUseCase(ref.watch(ttsServiceProvider));
