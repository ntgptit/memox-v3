import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Loads the Dashboard Today's-review due summary: the total due count plus the
/// per-deck breakdown used to derive "across N decks"
/// (`docs/wireframes/01-dashboard.md` §Today's review).
class LoadDashboardDueSummaryUseCase {
  const LoadDashboardDueSummaryUseCase(this._progressRepository);

  final ProgressRepository _progressRepository;

  Future<Result<ProgressDueSummary>> call({required DateTime now}) =>
      _progressRepository.loadProgressDueSummary(now: now);
}
