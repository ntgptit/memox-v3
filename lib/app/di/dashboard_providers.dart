import 'package:memox/app/di/database_providers.dart';
import 'package:memox/app/di/progress_providers.dart';
import 'package:memox/data/datasources/local/daos/dashboard_dao.dart';
import 'package:memox/data/repositories/dashboard_repository_impl.dart';
import 'package:memox/domain/repositories/dashboard_repository.dart';
import 'package:memox/domain/usecases/dashboard/load_dashboard_engagement_usecase.dart';
import 'package:memox/domain/usecases/dashboard/load_dashboard_resume_summary_usecase.dart';
import 'package:memox/domain/usecases/dashboard/load_dashboard_summary_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

/// Dependency-injection wiring for the Dashboard summary (WBS 5.x): DAO →
/// repository → use case. Presentation depends only on the use-case provider.

@Riverpod(keepAlive: true)
DashboardDao dashboardDao(Ref ref) =>
    DashboardDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
DashboardRepository dashboardRepository(Ref ref) =>
    DashboardRepositoryImpl(dao: ref.watch(dashboardDaoProvider));

@riverpod
LoadDashboardSummaryUseCase loadDashboardSummaryUseCase(Ref ref) =>
    LoadDashboardSummaryUseCase(
      repository: ref.watch(dashboardRepositoryProvider),
    );

@riverpod
LoadDashboardResumeSummaryUseCase loadDashboardResumeSummaryUseCase(Ref ref) =>
    LoadDashboardResumeSummaryUseCase(
      repository: ref.watch(dashboardRepositoryProvider),
    );

/// Engagement overview use case (WBS 5.x). Async because it composes the
/// progress-engagement use case, whose provider is itself async.
@riverpod
Future<LoadDashboardEngagementUseCase> loadDashboardEngagementUseCase(
  Ref ref,
) async => LoadDashboardEngagementUseCase(
  repository: ref.watch(dashboardRepositoryProvider),
  loadStudyStatistics: ref.watch(loadStudyStatisticsUseCaseProvider),
  loadProgressEngagement: await ref.watch(
    loadProgressEngagementUseCaseProvider.future,
  ),
);
