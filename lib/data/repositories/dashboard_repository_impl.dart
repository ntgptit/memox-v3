import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/dashboard_dao.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:memox/domain/repositories/dashboard_repository.dart';

/// Drift-backed [DashboardRepository] (WBS 5.x — design redesign).
///
/// Maps the single summary row to [DashboardSummary]; read errors map to
/// `StorageFailure(read)`. No business logic here — the use case owns the clock.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({required DashboardDao dao}) : _dao = dao;

  final DashboardDao _dao;

  @override
  Future<Result<DashboardSummary>> loadSummary({required int now}) async {
    try {
      final row = await _dao.dueSummary(now);
      return (
        failure: null,
        data: DashboardSummary(
          cardsDue: row.cardsDue,
          decksWithDue: row.decksWithDue,
        ),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'flashcard_progress',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }
}
