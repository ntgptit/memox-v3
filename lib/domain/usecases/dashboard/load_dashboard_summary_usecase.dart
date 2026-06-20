import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:memox/domain/repositories/dashboard_repository.dart';

/// Loads the Dashboard "today snapshot" (WBS 5.x — design redesign).
///
/// Owns the `now` clock (epoch ms) used for the due cutoff so the repository
/// stays clock-free. Failures propagate as `StorageFailure(read)`.
class LoadDashboardSummaryUseCase {
  const LoadDashboardSummaryUseCase({required this.repository});

  final DashboardRepository repository;

  Future<Result<DashboardSummary>> call() =>
      repository.loadSummary(now: DateTime.now().millisecondsSinceEpoch);
}
