import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'progress_dao.g.dart';

@DriftAccessor(include: <String>{'../drift/progress_queries.drift'})
class ProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressDaoMixin {
  ProgressDao(super.db);

  Future<List<ProgressDueDeckSummariesResult>> loadDueDeckSummaries({
    required int nowMs,
  }) => progressDueDeckSummaries(nowMs).get();

  Future<int> invalidBoxCount() => progressInvalidBoxCount().getSingle();

  Future<List<ProgressBoxDistributionResult>> loadBoxDistribution() =>
      progressBoxDistribution().get();

  Future<ProgressStudyStatisticsResult> loadStudyStatistics() =>
      progressStudyStatistics().getSingle();
}
