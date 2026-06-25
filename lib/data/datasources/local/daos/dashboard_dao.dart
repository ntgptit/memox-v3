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

  /// The most recently active resumable session (any scope) whose `updated_at`
  /// is newer than [cutoff] (epoch ms), with its progress, or `null` when none
  /// (WBS 5.1.1).
  Future<DashboardResumeSessionResult?> resumeSession(int cutoff) =>
      dashboardResumeSession(cutoff).getSingleOrNull();

  /// Total number of decks (engagement stat strip).
  Future<int> deckCount() => dashboardDeckCount().getSingle();

  /// Recently studied decks (most-recently-studied first), capped at [limit],
  /// as of [now] (epoch ms) for the due count (engagement "Recent decks").
  Future<List<DashboardRecentDecksResult>> recentDecks(int now, int limit) =>
      dashboardRecentDecks(now, limit).get();
}
