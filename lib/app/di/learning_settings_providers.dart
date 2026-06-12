import 'package:memox/data/datasources/local/preferences/learning_settings_store.dart';
import 'package:memox/data/repositories/learning_settings_repository_impl.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/usecases/learning_settings_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'learning_settings_providers.g.dart';

@Riverpod(keepAlive: true)
SharedPreferencesAsync sharedPreferencesAsync(Ref ref) =>
    SharedPreferencesAsync();

@Riverpod(keepAlive: true)
LearningSettingsStore learningSettingsStore(Ref ref) =>
    SharedPreferencesLearningSettingsStore(
      ref.watch(sharedPreferencesAsyncProvider),
    );

@Riverpod(keepAlive: true)
LearningSettingsRepository learningSettingsRepository(Ref ref) =>
    LearningSettingsRepositoryImpl(ref.watch(learningSettingsStoreProvider));

@Riverpod(keepAlive: true)
LoadLearningSettingsUseCase loadLearningSettingsUseCase(Ref ref) =>
    LoadLearningSettingsUseCase(ref.watch(learningSettingsRepositoryProvider));

@Riverpod(keepAlive: true)
UpdateLearningSettingsUseCase updateLearningSettingsUseCase(Ref ref) =>
    UpdateLearningSettingsUseCase(
      ref.watch(learningSettingsRepositoryProvider),
    );
