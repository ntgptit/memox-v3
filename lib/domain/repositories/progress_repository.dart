import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/types/progress_range.dart';

abstract interface class ProgressRepository {
  /// Everything the Progress screen renders for [range]: per-day activity,
  /// box distribution, study streak, and card-state counts.
  Future<Result<ProgressOverview>> loadProgressOverview({
    required DateTime now,
    required ProgressRange range,
  });

  Future<Result<ProgressDueSummary>> loadProgressDueSummary({
    required DateTime now,
  });

  Future<Result<BoxDistribution>> loadBoxDistribution();

  Future<Result<StudyStatistics>> loadStudyStatistics();

  Future<Result<ProgressReadModel>> loadProgressReadModel({
    required DateTime now,
  });
}
