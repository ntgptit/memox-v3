import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_progress_summary.freezed.dart';

@freezed
abstract class DashboardGoalSummary with _$DashboardGoalSummary {
  const factory DashboardGoalSummary.enabled({
    required int dailyGoal,
    required int todayAttemptCount,
  }) = DashboardGoalSummaryEnabled;

  const factory DashboardGoalSummary.disabled({
    required int dailyGoal,
    required DateTime disabledSince,
    required int todayAttemptCount,
  }) = DashboardGoalSummaryDisabled;

  const factory DashboardGoalSummary.unknown() = DashboardGoalSummaryUnknown;
}

@freezed
abstract class DashboardStreakSummary with _$DashboardStreakSummary {
  const factory DashboardStreakSummary.known({required int currentStreak}) =
      DashboardStreakSummaryKnown;

  const factory DashboardStreakSummary.unknown() =
      DashboardStreakSummaryUnknown;
}

@freezed
abstract class DashboardProgressSummary with _$DashboardProgressSummary {
  const factory DashboardProgressSummary({
    required int dueTodayCount,
    required DashboardGoalSummary goal,
    required DashboardStreakSummary streak,
  }) = _DashboardProgressSummary;
}
