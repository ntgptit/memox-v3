import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'study_entry_dao.g.dart';

/// Normalized scope counts used to classify study entry eligibility (WBS 4.1.1).
/// See `lib/data/datasources/local/drift/study_entry_queries.drift` for the
/// column semantics.
typedef StudyScopeCounts = ({
  int total,
  int suspended,
  int activeNonBuried,
  int dueEligible,
  int? nextDueAt,
});

/// Thin Drift accessor for the study entry eligibility count queries (WBS 4.1.1).
///
/// No business logic here (`docs/database/drift-guide.md`): each method runs one
/// single-row count query and normalizes it to [StudyScopeCounts]; the
/// repository owns the empty-scope classification and the use case owns the
/// `now` clock.
@DriftAccessor(include: <String>{'../drift/study_entry_queries.drift'})
class StudyEntryDao extends DatabaseAccessor<AppDatabase>
    with _$StudyEntryDaoMixin {
  StudyEntryDao(super.db);

  /// Counts for a single deck.
  Future<StudyScopeCounts> deckCounts(String deckId, int now) async {
    final DeckScopeCountsResult row = await deckScopeCounts(
      now,
      deckId,
    ).getSingle();
    return (
      total: row.totalCards,
      suspended: row.suspendedCount,
      activeNonBuried: row.activeNonBuried,
      dueEligible: row.dueEligible,
      nextDueAt: row.nextDueAt,
    );
  }

  /// Counts for a folder, recursive over its subtree.
  Future<StudyScopeCounts> folderCounts(String folderId, int now) async {
    // NOTE: generated param order follows first-appearance-in-SQL; `:folderId`
    // appears first (the recursive CTE seed), so the signature is (folderId, now).
    final FolderScopeCountsResult row = await folderScopeCounts(
      folderId,
      now,
    ).getSingle();
    return (
      total: row.totalCards,
      suspended: row.suspendedCount,
      activeNonBuried: row.activeNonBuried,
      dueEligible: row.dueEligible,
      nextDueAt: row.nextDueAt,
    );
  }

  /// Counts across every flashcard the user has (the `today` scope).
  Future<StudyScopeCounts> todayCounts(int now) async {
    final TodayScopeCountsResult row = await todayScopeCounts(now).getSingle();
    return (
      total: row.totalCards,
      suspended: row.suspendedCount,
      activeNonBuried: row.activeNonBuried,
      dueEligible: row.dueEligible,
      nextDueAt: row.nextDueAt,
    );
  }
}
