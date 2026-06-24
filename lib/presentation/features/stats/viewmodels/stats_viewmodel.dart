import 'package:memox/app/di/progress_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/stats_overview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_viewmodel.g.dart';

/// Loads the Stats screen read model — weekly review activity + per-deck mastery
/// (screen 18; `docs/wireframes/18-stats.md`). Failure stays in-band in the
/// [Result] so the screen renders the error state; refresh by invalidating this
/// provider.
@riverpod
Future<Result<StatsOverview>> statsOverview(Ref ref) =>
    ref.watch(loadStatsOverviewUseCaseProvider).call();
