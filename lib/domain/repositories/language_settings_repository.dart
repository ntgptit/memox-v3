import 'package:memox/core/error/result.dart';
import 'package:memox/domain/types/app_language.dart';

/// Port for persisting the app's [AppLanguage] preference. Use cases depend on
/// this interface; `LanguageSettingsRepositoryImpl` (data layer) implements it
/// over SharedPreferences.
///
/// Persistence only. See
/// `docs/contracts/repository-contracts/language-settings-repository.md`.
abstract interface class LanguageSettingsRepository {
  /// Load the persisted language, returning [AppLanguage.system] when the key
  /// is missing or holds an unrecognized value.
  ///
  /// Fails with [StorageFailure] on a SharedPreferences read error.
  Future<Result<AppLanguage>> load();

  /// Persist [language] as its `storageValue`.
  ///
  /// Fails with [StorageFailure] on a SharedPreferences write error.
  Future<Result<void>> save(AppLanguage language);
}
