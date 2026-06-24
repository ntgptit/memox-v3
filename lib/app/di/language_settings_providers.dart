import 'package:memox/app/di/app_providers.dart';
import 'package:memox/data/datasources/local/preferences/language_settings_store.dart';
import 'package:memox/data/repositories/language_settings_repository_impl.dart';
import 'package:memox/domain/repositories/language_settings_repository.dart';
import 'package:memox/domain/usecases/language_settings_usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'language_settings_providers.g.dart';

/// Dependency-injection wiring for app-language settings: SharedPreferences →
/// store → repository → use cases. The SharedPreferences instance comes from
/// the app-level [sharedPreferencesProvider].

@Riverpod(keepAlive: true)
Future<LanguageSettingsRepository> languageSettingsRepository(Ref ref) async {
  final SharedPreferences prefs = await ref.watch(
    sharedPreferencesProvider.future,
  );
  return LanguageSettingsRepositoryImpl(store: LanguageSettingsStore(prefs));
}

// Async because the dependency chain bottoms out at the async
// [sharedPreferencesProvider]; consumers await `.future` / observe `AsyncValue`.
@riverpod
Future<LoadLanguageSettingsUseCase> loadLanguageSettingsUseCase(
  Ref ref,
) async => LoadLanguageSettingsUseCase(
  repository: await ref.watch(languageSettingsRepositoryProvider.future),
);

@riverpod
Future<UpdateLanguageSettingsUseCase> updateLanguageSettingsUseCase(
  Ref ref,
) async => UpdateLanguageSettingsUseCase(
  repository: await ref.watch(languageSettingsRepositoryProvider.future),
);
