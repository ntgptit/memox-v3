import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/box_distribution.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Loads the Leitner box distribution for the Progress chart (WBS 7.2.1).
///
/// Thin delegation to [ProgressRepository.loadBoxDistribution]; the result is
/// zero-filled across boxes 1..8. An out-of-range persisted box surfaces as a
/// `ValidationFailure` (decision row P9); a read error as `StorageFailure`.
class LoadBoxDistributionUseCase {
  const LoadBoxDistributionUseCase({required this.repository});

  final ProgressRepository repository;

  Future<Result<BoxDistribution>> call() => repository.loadBoxDistribution();
}
