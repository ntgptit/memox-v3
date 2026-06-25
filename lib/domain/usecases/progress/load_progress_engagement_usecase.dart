import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/models/progress_engagement.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Composes the Progress detail engagement read model (kit 19, WBS 7.4.3 / Q5):
/// the daily goal (from `LearningSettings`, SharedPreferences) + the
/// attempt-derived study-day activity (from the progress repo). Owns the `now`
/// clock so the repository stays clock-free.
///
/// Read-only — no new persistence, no streak mutation (the settings-backed
/// `RecordGoalProgressUseCase` in the contract remains Future). Values are never
/// fabricated: an empty database yields zeros and a disabled goal reports
/// `goalEnabled = false`. The first failing read short-circuits to its
/// `StorageFailure`.
class LoadProgressEngagementUseCase {
  const LoadProgressEngagementUseCase({
    required this.progressRepository,
    required this.learningSettingsRepository,
  });

  final ProgressRepository progressRepository;
  final LearningSettingsRepository learningSettingsRepository;

  Future<Result<ProgressEngagement>> call() async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final Result<StudyDayActivity> activityResult = await progressRepository
        .loadStudyActivity(now: now);
    final StudyDayActivity? activity = activityResult.data;
    if (activity == null) {
      return (failure: activityResult.failure ?? _readFailure, data: null);
    }
    final Result<LearningSettings> settingsResult =
        await learningSettingsRepository.load();
    final LearningSettings? settings = settingsResult.data;
    if (settings == null) {
      return (failure: settingsResult.failure ?? _readFailure, data: null);
    }

    return (
      failure: null,
      data: ProgressEngagement(
        goalEnabled: settings.goalDisabledSince == null,
        dailyGoalTarget: settings.dailyNewLimit,
        todayAnsweredCount: activity.todayAnsweredCount,
        currentStreak: activity.currentStreak,
        longestStreak: activity.longestStreak,
      ),
    );
  }

  // Generic fallback used only if a repo returns neither data nor a failure
  // (defensive — both sources always return one). Neutral table label since it
  // could stand in for either the attempts read or the SharedPreferences read.
  static const Failure _readFailure = Failure.storage(
    operation: StorageOp.read,
    table: 'engagement_read',
    cause: 'engagement read returned no data',
  );
}
