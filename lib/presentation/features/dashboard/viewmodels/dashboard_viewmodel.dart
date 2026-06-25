import 'package:memox/app/di/dashboard_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_engagement.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_viewmodel.g.dart';

/// Loads the Dashboard "today snapshot" (WBS 5.x — design redesign). Failure
/// stays in-band in the [Result] so the screen renders the error state; refresh
/// by invalidating this provider.
@riverpod
Future<Result<DashboardSummary>> dashboardSummary(Ref ref) =>
    ref.watch(loadDashboardSummaryUseCaseProvider).call();

/// Loads the Dashboard engagement overview (WBS 5.x — engagement): stat strip,
/// continue-studying, due snapshot, and recent decks in one snapshot. The core
/// due summary's failure stays in-band so the screen renders the error state;
/// enrichments degrade inside the use case. Refresh by invalidating this provider.
@riverpod
Future<Result<DashboardEngagement>> dashboardEngagement(Ref ref) async {
  final useCase = await ref.watch(
    loadDashboardEngagementUseCaseProvider.future,
  );
  return useCase.call();
}
