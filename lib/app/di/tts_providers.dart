import 'package:flutter_tts/flutter_tts.dart';
import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/tts_settings_dao.dart';
import 'package:memox/data/repositories/tts_settings_repository_impl.dart';
import 'package:memox/data/services/flutter_tts_service.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/usecases/tts_settings_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_providers.g.dart';

/// Dependency-injection wiring for TTS (WBS 8.4.1/8.4.2): AppDatabase → DAO →
/// repository → use cases for settings persistence, plus the `flutter_tts`
/// engine adapter ([ttsService]) for voice-listing + playback.

@Riverpod(keepAlive: true)
TtsService ttsService(Ref ref) => FlutterTtsService(FlutterTts());

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
