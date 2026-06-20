import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_summary.dart';

/// Read access for the Dashboard summary (WBS 5.x — design redesign).
abstract interface class DashboardRepository {
  /// The current due snapshot (cards due + decks with due) as of [now] (epoch
  /// ms). Returns a `StorageFailure` on a read error.
  Future<Result<DashboardSummary>> loadSummary({required int now});
}
