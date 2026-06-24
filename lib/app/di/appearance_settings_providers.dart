import 'package:memox/app/di/app_providers.dart';
import 'package:memox/data/datasources/local/preferences/appearance_settings_store.dart';
import 'package:memox/data/repositories/appearance_settings_repository_impl.dart';
import 'package:memox/domain/repositories/appearance_settings_repository.dart';
import 'package:memox/domain/usecases/appearance_settings_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'appearance_settings_providers.g.dart';

/// Dependency-injection wiring for appearance (theme-mode) settings:
/// SharedPreferences → store → repository → use cases. The SharedPreferences
/// instance comes from the app-level [sharedPreferencesProvider].

@Riverpod(keepAlive: true)
Future<AppearanceSettingsRepository> appearanceSettingsRepository(
  Ref ref,
) async {
  final SharedPreferences prefs = await ref.watch(
    sharedPreferencesProvider.future,
  );
  return AppearanceSettingsRepositoryImpl(
    store: AppearanceSettingsStore(prefs),
  );
}

// Async because the dependency chain bottoms out at the async
// [sharedPreferencesProvider]; consumers await `.future` / observe `AsyncValue`.
@riverpod
Future<LoadAppearanceSettingsUseCase> loadAppearanceSettingsUseCase(
  Ref ref,
) async => LoadAppearanceSettingsUseCase(
  repository: await ref.watch(appearanceSettingsRepositoryProvider.future),
);

@riverpod
Future<UpdateAppearanceSettingsUseCase> updateAppearanceSettingsUseCase(
  Ref ref,
) async => UpdateAppearanceSettingsUseCase(
  repository: await ref.watch(appearanceSettingsRepositoryProvider.future),
);
