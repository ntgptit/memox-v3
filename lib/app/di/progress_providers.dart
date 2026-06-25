import 'package:memox/app/di/database_providers.dart';
import 'package:memox/app/di/learning_settings_providers.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/data/repositories/progress_repository_impl.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/usecases/progress/load_box_distribution_usecase.dart';
import 'package:memox/domain/usecases/progress/load_due_summary_usecase.dart';
import 'package:memox/domain/usecases/progress/load_progress_engagement_usecase.dart';
import 'package:memox/domain/usecases/progress/load_progress_read_model_usecase.dart';
import 'package:memox/domain/usecases/progress/load_stats_overview_usecase.dart';
import 'package:memox/domain/usecases/progress/load_study_statistics_usecase.dart';
import 'package:memox/domain/usecases/progress/load_study_time_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_providers.g.dart';

/// Dependency-injection wiring for SRS progress reads (WBS 7.1.1 due-summary
/// slice): DAO → repository → use case.

@Riverpod(keepAlive: true)
ProgressDao progressDao(Ref ref) => ProgressDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
ProgressRepository progressRepository(Ref ref) =>
    ProgressRepositoryImpl(dao: ref.watch(progressDaoProvider));

@riverpod
LoadDueSummaryUseCase loadDueSummaryUseCase(Ref ref) =>
    LoadDueSummaryUseCase(repository: ref.watch(progressRepositoryProvider));

@riverpod
LoadBoxDistributionUseCase loadBoxDistributionUseCase(Ref ref) =>
    LoadBoxDistributionUseCase(
      repository: ref.watch(progressRepositoryProvider),
    );

@riverpod
LoadStudyStatisticsUseCase loadStudyStatisticsUseCase(Ref ref) =>
    LoadStudyStatisticsUseCase(
      repository: ref.watch(progressRepositoryProvider),
    );

@riverpod
LoadProgressReadModelUseCase loadProgressReadModelUseCase(Ref ref) =>
    LoadProgressReadModelUseCase(
      repository: ref.watch(progressRepositoryProvider),
    );

@riverpod
LoadStatsOverviewUseCase loadStatsOverviewUseCase(Ref ref) =>
    LoadStatsOverviewUseCase(repository: ref.watch(progressRepositoryProvider));

/// Kit-19 Progress detail "Time" stat (WBS 7.5.x): total on-card study time (ms)
/// since a window start.
@riverpod
LoadStudyTimeUseCase loadStudyTimeUseCase(Ref ref) =>
    LoadStudyTimeUseCase(repository: ref.watch(progressRepositoryProvider));

/// Progress detail engagement read (kit 19, WBS 7.4.3 / Q5): composes the daily
/// goal (async SharedPreferences-backed learning settings) with attempt-derived
/// study-day activity. Async because the learning-settings repo bottoms out at
/// the async SharedPreferences boot.
@riverpod
Future<LoadProgressEngagementUseCase> loadProgressEngagementUseCase(
  Ref ref,
) async => LoadProgressEngagementUseCase(
  progressRepository: ref.watch(progressRepositoryProvider),
  learningSettingsRepository: await ref.watch(
    learningSettingsRepositoryProvider.future,
  ),
);
