import 'package:flutter_tts/flutter_tts.dart';
import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/tts_settings_dao.dart';
import 'package:memox/data/repositories/tts_settings_repository_impl.dart';
import 'package:memox/data/services/flutter_tts_service.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/tts_playback_policy.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/usecases/tts_playback_usecases.dart';
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

/// The front-only study playback policy (WBS 8.4.3). Stateless/const.
@riverpod
TtsPlaybackPolicy ttsPlaybackPolicy(Ref ref) => const TtsPlaybackPolicy();

/// Study-session speech playback (WBS 8.4.3): speaks the front side gated by the
/// deck language + the front-only policy, over the shared [ttsService] engine.
@riverpod
SpeakFlashcardUseCase speakFlashcardUseCase(Ref ref) => SpeakFlashcardUseCase(
  ttsService: ref.watch(ttsServiceProvider),
  getSettings: ref.watch(getTtsSettingsUseCaseProvider),
  playbackPolicy: ref.watch(ttsPlaybackPolicyProvider),
);

/// Stops in-flight study speech (WBS 8.4.3) — card advance/leave.
@riverpod
StopSpeechUseCase stopSpeechUseCase(Ref ref) =>
    StopSpeechUseCase(ttsService: ref.watch(ttsServiceProvider));
