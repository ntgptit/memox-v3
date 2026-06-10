import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/progress_read_model.dart';

abstract interface class ProgressRepository {
  Future<Result<ProgressDueSummary>> loadProgressDueSummary({
    required DateTime now,
  });

  Future<Result<BoxDistribution>> loadBoxDistribution();

  Future<Result<StudyStatistics>> loadStudyStatistics();

  Future<Result<ProgressReadModel>> loadProgressReadModel({
    required DateTime now,
  });
}
