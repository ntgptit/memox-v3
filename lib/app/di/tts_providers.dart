import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/tts_settings_dao.dart';
import 'package:memox/data/repositories/tts_settings_repository_impl.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/usecases/tts_settings_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_providers.g.dart';

/// Dependency-injection wiring for TTS settings persistence (WBS 8.4.1):
/// AppDatabase → DAO → repository → use cases. The speech engine adapter
/// (`TtsService`/`FlutterTtsService`) + voice-listing land alongside the
/// Audio & speech screen (WBS 8.4.2).

@Riverpod(keepAlive: true)
TtsSettingsDao ttsSettingsDao(Ref ref) =>
    TtsSettingsDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
TtsSettingsRepository ttsSettingsRepository(Ref ref) =>
    TtsSettingsRepositoryImpl(dao: ref.watch(ttsSettingsDaoProvider));

@riverpod
GetTtsSettingsUseCase getTtsSettingsUseCase(Ref ref) =>
    GetTtsSettingsUseCase(repository: ref.watch(ttsSettingsRepositoryProvider));

@riverpod
UpdateTtsSettingsUseCase updateTtsSettingsUseCase(Ref ref) =>
    UpdateTtsSettingsUseCase(
      repository: ref.watch(ttsSettingsRepositoryProvider),
    );
