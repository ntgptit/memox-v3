import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_settings.freezed.dart';

/// Persisted study-default settings used by the study-entry and engagement
/// surfaces. Stored outside Drift in SharedPreferences — see
/// `docs/contracts/repository-contracts/learning-settings-repository.md` and
/// `docs/database/storage-boundaries.md`.
///
/// - [dailyNewLimit] — max new cards entering study per local-day. Defaults to
///   [defaultDailyNewLimit] (20); valid values are on a step of
///   [dailyNewLimitStep] within [minDailyNewLimit]..[maxDailyNewLimit]
///   (validated by `UpdateLearningSettingsUseCase`, not the repository).
/// - [goalDisabledSince] — local date (midnight, time stripped) the daily goal
///   was turned off, or `null` when the goal is active. Persisted as a
///   `YYYY-MM-DD` string.
@freezed
sealed class LearningSettings with _$LearningSettings {
  const factory LearningSettings({
    @Default(LearningSettings.defaultDailyNewLimit) int dailyNewLimit,
    DateTime? goalDisabledSince,
  }) = _LearningSettings;

  /// Default daily new-card limit when nothing is persisted yet.
  static const int defaultDailyNewLimit = 20;

  /// Inclusive lower bound for [dailyNewLimit].
  static const int minDailyNewLimit = 5;

  /// Inclusive upper bound for [dailyNewLimit].
  static const int maxDailyNewLimit = 200;

  /// [dailyNewLimit] must be a multiple of this step.
  static const int dailyNewLimitStep = 5;

  /// Whether [value] is a valid [dailyNewLimit]: within
  /// [minDailyNewLimit]..[maxDailyNewLimit] and on the [dailyNewLimitStep]
  /// step. Shared by `UpdateLearningSettingsUseCase` (rejects invalid input)
  /// and the repository (recovers a corrupt persisted value to the default).
  static bool isValidDailyNewLimit(int value) =>
      value >= minDailyNewLimit &&
      value <= maxDailyNewLimit &&
      value % dailyNewLimitStep == 0;
}
