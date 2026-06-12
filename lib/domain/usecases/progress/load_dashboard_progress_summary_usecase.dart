import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_progress_summary.dart';
import 'package:memox/domain/models/learning_settings.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

class LoadDashboardProgressSummaryUseCase {
  const LoadDashboardProgressSummaryUseCase(
    this._progressRepository,
    this._learningSettingsRepository,
  );

  final ProgressRepository _progressRepository;
  final LearningSettingsRepository _learningSettingsRepository;

  Future<Result<DashboardProgressSummary>> call({required DateTime now}) async {
    final Result<ProgressDueSummary> dueSummaryResult =
        await _progressRepository.loadProgressDueSummary(now: now);
    if (dueSummaryResult is Err<ProgressDueSummary>) {
      return Result<DashboardProgressSummary>.err(dueSummaryResult.failure);
    }

    final Result<Map<DateTime, int>> attemptCountsByDayResult =
        await _progressRepository.loadAttemptCountsByDay();
    if (attemptCountsByDayResult is Err<Map<DateTime, int>>) {
      return Result<DashboardProgressSummary>.err(
        attemptCountsByDayResult.failure,
      );
    }

    final Result<LearningSettings> settingsResult =
        await _learningSettingsRepository.load();
    if (settingsResult is Err<LearningSettings>) {
      return Result<DashboardProgressSummary>.err(settingsResult.failure);
    }

    final ProgressDueSummary dueSummary =
        (dueSummaryResult as Ok<ProgressDueSummary>).value;
    final Map<DateTime, int> attemptCountsByDay =
        (attemptCountsByDayResult as Ok<Map<DateTime, int>>).value;
    final LearningSettings settings =
        (settingsResult as Ok<LearningSettings>).value;
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int todayAttemptCount = attemptCountsByDay[today] ?? 0;

    final DashboardGoalSummary goalSummary = settings.goalDisabledSince == null
        ? DashboardGoalSummary.enabled(
            dailyGoal: settings.dailyNewLimit,
            todayAttemptCount: todayAttemptCount,
          )
        : DashboardGoalSummary.disabled(
            dailyGoal: settings.dailyNewLimit,
            disabledSince: settings.goalDisabledSince!,
            todayAttemptCount: todayAttemptCount,
          );

    final DashboardStreakSummary streakSummary =
        settings.goalDisabledSince == null
        ? DashboardStreakSummary.known(
            currentStreak: _computeCurrentStreak(
              attemptCountsByDay: attemptCountsByDay,
              today: today,
              dailyGoal: settings.dailyNewLimit,
            ),
          )
        : const DashboardStreakSummary.unknown();

    return Result<DashboardProgressSummary>.ok(
      DashboardProgressSummary(
        dueTodayCount: dueSummary.totalDueCount,
        goal: goalSummary,
        streak: streakSummary,
      ),
    );
  }

  int _computeCurrentStreak({
    required Map<DateTime, int> attemptCountsByDay,
    required DateTime today,
    required int dailyGoal,
  }) {
    int streak = 0;
    DateTime cursor = today;
    if ((attemptCountsByDay[cursor] ?? 0) < dailyGoal) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while ((attemptCountsByDay[cursor] ?? 0) >= dailyGoal) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
