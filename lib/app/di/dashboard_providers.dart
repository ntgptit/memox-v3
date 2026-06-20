import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/dashboard_dao.dart';
import 'package:memox/data/repositories/dashboard_repository_impl.dart';
import 'package:memox/domain/repositories/dashboard_repository.dart';
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
