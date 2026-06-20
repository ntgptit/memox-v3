import 'package:memox/app/di/dashboard_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_viewmodel.g.dart';

/// Loads the Dashboard "today snapshot" (WBS 5.x — design redesign). Failure
/// stays in-band in the [Result] so the screen renders the error state; refresh
/// by invalidating this provider.
@riverpod
Future<Result<DashboardSummary>> dashboardSummary(Ref ref) =>
    ref.watch(loadDashboardSummaryUseCaseProvider).call();
