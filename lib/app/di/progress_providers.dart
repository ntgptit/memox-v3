import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/data/repositories/progress_repository_impl.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/usecases/progress/load_box_distribution_usecase.dart';
import 'package:memox/domain/usecases/progress/load_due_summary_usecase.dart';
import 'package:memox/domain/usecases/progress/load_study_statistics_usecase.dart';
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
