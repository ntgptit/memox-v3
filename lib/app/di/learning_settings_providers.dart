import 'package:memox/app/di/app_providers.dart';
import 'package:memox/data/datasources/local/preferences/learning_settings_store.dart';
import 'package:memox/data/repositories/learning_settings_repository_impl.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/usecases/learning_settings_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'learning_settings_providers.g.dart';

/// Dependency-injection wiring for learning settings: SharedPreferences → store
/// → repository → use cases. The SharedPreferences instance comes from the
/// app-level [sharedPreferencesProvider] (`docs/contracts/code-style.md`
/// §Providers).

@Riverpod(keepAlive: true)
Future<LearningSettingsRepository> learningSettingsRepository(Ref ref) async {
  final SharedPreferences prefs = await ref.watch(
    sharedPreferencesProvider.future,
  );
  return LearningSettingsRepositoryImpl(store: LearningSettingsStore(prefs));
}

// The use-case providers are async because the dependency chain bottoms out at
// the async [sharedPreferencesProvider] (SharedPreferences boot). Consumers
// await `.future` / observe `AsyncValue`; do not make these synchronous.
@riverpod
Future<LoadLearningSettingsUseCase> loadLearningSettingsUseCase(
  Ref ref,
) async => LoadLearningSettingsUseCase(
  repository: await ref.watch(learningSettingsRepositoryProvider.future),
);

@riverpod
Future<UpdateLearningSettingsUseCase> updateLearningSettingsUseCase(
  Ref ref,
) async => UpdateLearningSettingsUseCase(
  repository: await ref.watch(learningSettingsRepositoryProvider.future),
);
