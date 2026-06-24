import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/stats_overview.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Loads the Stats screen read model — the current week's review activity plus
/// per-deck mastery (Stats, screen 18; `docs/wireframes/18-stats.md`).
///
/// Owns the `now` clock (epoch ms) for the local-week window and delegates to
/// [ProgressRepository.loadStatsOverview]; a pure read. A read error propagates
/// as `StorageFailure`.
class LoadStatsOverviewUseCase {
  const LoadStatsOverviewUseCase({required this.repository});

  final ProgressRepository repository;

  Future<Result<StatsOverview>> call() =>
      repository.loadStatsOverview(now: DateTime.now().millisecondsSinceEpoch);
}
