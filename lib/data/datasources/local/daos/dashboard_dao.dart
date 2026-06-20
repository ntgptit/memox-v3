import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'dashboard_dao.g.dart';

/// Thin Drift accessor for the dashboard summary read model (WBS 5.x).
///
/// No business logic here (`docs/database/drift-guide.md`); the use case owns
/// the `now` clock and maps the row to the domain model.
@DriftAccessor(include: <String>{'../drift/dashboard_queries.drift'})
class DashboardDao extends DatabaseAccessor<AppDatabase>
    with _$DashboardDaoMixin {
  DashboardDao(super.db);

  /// One row: count of due cards + distinct decks with due cards, as of [now]
  /// (epoch ms).
  Future<DashboardDueSummaryResult> dueSummary(int now) =>
      dashboardDueSummary(now).getSingle();
}
