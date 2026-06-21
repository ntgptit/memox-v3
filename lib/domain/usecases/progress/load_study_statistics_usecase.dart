import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_statistics.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Loads session/attempt-based study statistics for the Progress screen
/// (WBS 7.3.1).
///
/// Thin delegation to [ProgressRepository.loadStudyStatistics]; a pure read
/// (decision row P10). A read error propagates as `StorageFailure`.
class LoadStudyStatisticsUseCase {
  const LoadStudyStatisticsUseCase({required this.repository});

  final ProgressRepository repository;

  Future<Result<StudyStatistics>> call() => repository.loadStudyStatistics();
}
