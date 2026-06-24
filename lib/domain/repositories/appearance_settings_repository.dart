import 'package:memox/core/error/result.dart';
import 'package:memox/domain/types/app_theme_mode.dart';

/// Port for persisting the app's [AppThemeMode] preference. Use cases depend on
/// this interface; `AppearanceSettingsRepositoryImpl` (data layer) implements it
/// over SharedPreferences.
///
/// Persistence only. See
/// `docs/contracts/repository-contracts/appearance-settings-repository.md`.
abstract interface class AppearanceSettingsRepository {
  /// Load the persisted theme mode, returning [AppThemeMode.system] when the
  /// key is missing or holds an unrecognized value.
  ///
  /// Fails with [StorageFailure] on a SharedPreferences read error.
  Future<Result<AppThemeMode>> load();

  /// Persist [mode] as its `storageValue`.
  ///
  /// Fails with [StorageFailure] on a SharedPreferences write error.
  Future<Result<void>> save(AppThemeMode mode);
}
