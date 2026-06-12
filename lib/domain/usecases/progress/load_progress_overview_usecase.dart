import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/types/progress_range.dart';

/// Loads everything the Progress screen renders for one selected range
/// (`docs/wireframes/03-progress.md`).
class LoadProgressOverviewUseCase {
  const LoadProgressOverviewUseCase(this._repository);

  final ProgressRepository _repository;

  Future<Result<ProgressOverview>> call({
    required DateTime now,
    required ProgressRange range,
  }) => _repository.loadProgressOverview(now: now, range: range);
}
