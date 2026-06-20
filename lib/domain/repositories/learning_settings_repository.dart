import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/learning_settings.dart';

/// Port for persisting [LearningSettings]. Use cases depend on this interface;
/// `LearningSettingsRepositoryImpl` (data layer) implements it over
/// SharedPreferences.
///
/// Persistence only — validation (range/step) stays in the use case. See
/// `docs/contracts/repository-contracts/learning-settings-repository.md`.
abstract interface class LearningSettingsRepository {
  /// Load the persisted settings, returning defaults when keys are missing and
  /// recovering a corrupt `dailyNewLimit` to [LearningSettings.defaultDailyNewLimit].
  ///
  /// Fails with [StorageFailure] on a SharedPreferences read error.
  Future<Result<LearningSettings>> load();

  /// Persist [settings]. `goalDisabledSince` is stored as a local `YYYY-MM-DD`
  /// string when set, or cleared when `null`.
  ///
  /// Fails with [StorageFailure] on a SharedPreferences write error.
  Future<Result<void>> save(LearningSettings settings);
}
