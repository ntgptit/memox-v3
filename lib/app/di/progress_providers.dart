import 'package:memox/app/di/database_providers.dart';
import 'package:memox/app/di/learning_settings_providers.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/data/repositories/progress_repository_impl.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/usecases/progress/load_dashboard_progress_summary_usecase.dart';
import 'package:memox/domain/usecases/progress/load_progress_read_model_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_providers.g.dart';

@Riverpod(keepAlive: true)
ProgressDao progressDao(Ref ref) => ProgressDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
ProgressRepository progressRepository(Ref ref) =>
    ProgressRepositoryImpl(ref.watch(progressDaoProvider));

@Riverpod(keepAlive: true)
LoadProgressReadModelUseCase loadProgressReadModelUseCase(Ref ref) =>
    LoadProgressReadModelUseCase(ref.watch(progressRepositoryProvider));

@Riverpod(keepAlive: true)
LoadDashboardProgressSummaryUseCase loadDashboardProgressSummaryUseCase(
  Ref ref,
) => LoadDashboardProgressSummaryUseCase(
  ref.watch(progressRepositoryProvider),
  ref.watch(learningSettingsRepositoryProvider),
);
