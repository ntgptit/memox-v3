import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/appearance_settings_repository.dart';
import 'package:memox/domain/types/app_theme_mode.dart';

/// Loads the persisted theme mode (kit screen 24). Pure delegation — defaults
/// and corrupt recovery live in the repository.
class LoadAppearanceSettingsUseCase {
  const LoadAppearanceSettingsUseCase({required this.repository});

  final AppearanceSettingsRepository repository;

  Future<Result<AppThemeMode>> call() => repository.load();
}

/// Persists the chosen theme mode.
class UpdateAppearanceSettingsUseCase {
  const UpdateAppearanceSettingsUseCase({required this.repository});

  final AppearanceSettingsRepository repository;

  Future<Result<void>> call({required AppThemeMode mode}) =>
      repository.save(mode);
}
