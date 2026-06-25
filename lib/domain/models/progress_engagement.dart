import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_engagement.freezed.dart';

/// Attempt-derived study-day activity for the Progress detail (kit 19) — a pure
/// read over `study_attempts`, bucketed by **local** day in Dart (never SQL; the
/// test sqlite returns NULL for `'localtime'`). No new persistence, no migration.
///
/// Note: this is a **study-day** streak — any day with ≥1 attempt counts. It is
/// NOT the goal-met-day streak (attempts ≥ goal); the authoritative goal-met
/// streak (settings-backed `lastGoalMetDate`, `RecordGoalProgressUseCase`) stays
/// Future. The Progress detail presents this as a study-day streak.
///
/// - [todayAnsweredCount] — attempts recorded on the current local day.
/// - [currentStreak] — consecutive local study-days ending today (or yesterday
///   when today has no attempt yet, so an unfinished today never breaks it).
/// - [longestStreak] — the longest consecutive local-day run across all history.
@freezed
sealed class StudyDayActivity with _$StudyDayActivity {
  const factory StudyDayActivity({
    @Default(0) int todayAnsweredCount,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
  }) = _StudyDayActivity;
  const StudyDayActivity._();
}

/// The Progress detail engagement read model (kit 19, WBS 7.4.3 / Q5): the daily
/// goal (from `LearningSettings`, SharedPreferences) composed with the
/// attempt-derived [StudyDayActivity]. Values are never fabricated — an empty
/// database yields zeros, and a disabled goal reports [goalEnabled] `false`.
@freezed
sealed class ProgressEngagement with _$ProgressEngagement {
  const factory ProgressEngagement({
    /// Whether the daily goal is active (`LearningSettings.goalDisabledSince` is
    /// null). When `false` the goal ring shows its disabled state and the streak
    /// is informational only.
    required bool goalEnabled,

    /// The daily goal target (`LearningSettings.dailyNewLimit`, 5..200).
    required int dailyGoalTarget,
    required int todayAnsweredCount,
    required int currentStreak,
    required int longestStreak,
  }) = _ProgressEngagement;
  const ProgressEngagement._();

  /// Whether today's answered count has reached the goal (only when enabled).
  bool get goalMetToday => goalEnabled && todayAnsweredCount >= dailyGoalTarget;

  /// Goal ring fill 0..1 (0 when disabled or the target is non-positive).
  double get goalProgress {
    if (!goalEnabled || dailyGoalTarget <= 0) return 0;
    return (todayAnsweredCount / dailyGoalTarget).clamp(0.0, 1.0);
  }
}
