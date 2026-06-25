import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/learning_settings.dart';
import 'package:memox/domain/models/box_distribution.dart';
import 'package:memox/domain/models/due_summary.dart';
import 'package:memox/domain/models/progress_engagement.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/models/stats_overview.dart';
import 'package:memox/domain/models/study_statistics.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/usecases/progress/load_progress_engagement_usecase.dart';

/// Only `loadStudyActivity` is exercised; the other reads throw to prove they
/// are not on the engagement path.
class _FakeProgressRepo implements ProgressRepository {
  _FakeProgressRepo(this._activity);
  final Result<StudyDayActivity> _activity;

  @override
  Future<Result<StudyDayActivity>> loadStudyActivity({
    required int now,
  }) async => _activity;

  @override
  Future<Result<DueSummary>> loadDueSummary({required int now}) =>
      throw UnimplementedError();
  @override
  Future<Result<BoxDistribution>> loadBoxDistribution() =>
      throw UnimplementedError();
  @override
  Future<Result<StudyStatistics>> loadStudyStatistics() =>
      throw UnimplementedError();
  @override
  Future<Result<ProgressReadModel>> loadProgressReadModel({required int now}) =>
      throw UnimplementedError();
  @override
  Future<Result<StatsOverview>> loadStatsOverview({required int now}) =>
      throw UnimplementedError();
}

class _FakeLearningRepo implements LearningSettingsRepository {
  _FakeLearningRepo(this._settings);
  final Result<LearningSettings> _settings;

  @override
  Future<Result<LearningSettings>> load() async => _settings;
  @override
  Future<Result<void>> save(LearningSettings settings) =>
      throw UnimplementedError();
}

LoadProgressEngagementUseCase _useCase({
  required Result<StudyDayActivity> activity,
  required Result<LearningSettings> settings,
}) => LoadProgressEngagementUseCase(
  progressRepository: _FakeProgressRepo(activity),
  learningSettingsRepository: _FakeLearningRepo(settings),
);

void main() {
  group('LoadProgressEngagementUseCase', () {
    const StudyDayActivity activity = StudyDayActivity(
      todayAnsweredCount: 12,
      currentStreak: 4,
      longestStreak: 9,
    );

    test('composes the goal (enabled) with study-day activity', () async {
      final Result<ProgressEngagement> r = await _useCase(
        activity: (failure: null, data: activity),
        settings: (
          failure: null,
          data: const LearningSettings(dailyNewLimit: 20),
        ),
      ).call();

      final ProgressEngagement e = r.data!;
      expect(e.goalEnabled, isTrue);
      expect(e.dailyGoalTarget, 20);
      expect(e.todayAnsweredCount, 12);
      expect(e.currentStreak, 4);
      expect(e.longestStreak, 9);
      expect(e.goalMetToday, isFalse, reason: '12 < 20');
      expect(e.goalProgress, closeTo(12 / 20, 1e-9));
    });

    test('goal met when today reaches the target', () async {
      final Result<ProgressEngagement> r = await _useCase(
        activity: (
          failure: null,
          data: const StudyDayActivity(todayAnsweredCount: 20),
        ),
        settings: (
          failure: null,
          data: const LearningSettings(dailyNewLimit: 20),
        ),
      ).call();
      expect(r.data!.goalMetToday, isTrue);
      expect(r.data!.goalProgress, 1.0);
    });

    test('disabled goal → goalEnabled false, no progress fill', () async {
      final Result<ProgressEngagement> r = await _useCase(
        activity: (failure: null, data: activity),
        settings: (
          failure: null,
          data: LearningSettings(
            dailyNewLimit: 20,
            goalDisabledSince: DateTime(2026, 6, 1),
          ),
        ),
      ).call();
      expect(r.data!.goalEnabled, isFalse);
      expect(r.data!.goalMetToday, isFalse);
      expect(r.data!.goalProgress, 0);
      // Streak stays informational even with the goal off.
      expect(r.data!.currentStreak, 4);
    });

    test('activity read failure short-circuits', () async {
      final Result<ProgressEngagement> r = await _useCase(
        activity: (
          failure: const Failure.storage(
            operation: StorageOp.read,
            table: 'study_attempts',
            cause: 'boom',
          ),
          data: null,
        ),
        settings: (failure: null, data: const LearningSettings()),
      ).call();
      expect(r.data, isNull);
      expect(r.failure, isA<StorageFailure>());
    });

    test('settings read failure short-circuits', () async {
      final Result<ProgressEngagement> r = await _useCase(
        activity: (failure: null, data: activity),
        settings: (
          failure: const Failure.storage(
            operation: StorageOp.read,
            table: 'learning_settings',
            cause: 'prefs crash',
          ),
          data: null,
        ),
      ).call();
      expect(r.data, isNull);
      expect(r.failure, isA<StorageFailure>());
    });
  });
}
