import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/language_settings_repository.dart';
import 'package:memox/domain/types/app_language.dart';

/// Loads the persisted app language (kit screen 25). Pure delegation — defaults
/// and corrupt recovery live in the repository.
class LoadLanguageSettingsUseCase {
  const LoadLanguageSettingsUseCase({required this.repository});

  final LanguageSettingsRepository repository;

  Future<Result<AppLanguage>> call() => repository.load();
}

/// Persists the chosen app language.
class UpdateLanguageSettingsUseCase {
  const UpdateLanguageSettingsUseCase({required this.repository});

  final LanguageSettingsRepository repository;

  Future<Result<void>> call({required AppLanguage language}) =>
      repository.save(language);
}
