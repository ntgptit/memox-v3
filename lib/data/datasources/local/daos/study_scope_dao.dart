import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'study_scope_dao.g.dart';

/// Thin Drift accessor for the ordered eligible-card queue queries (WBS 4.11.1).
///
/// No business logic here (`docs/database/drift-guide.md`): each method runs one
/// query from `lib/data/datasources/local/drift/study_scope_queries.drift` and
/// returns the ordered eligible flashcard ids. Suspended / currently-buried
/// exclusion lives in the SQL; the repository picks due vs new by study type and
/// the use case owns the `now` clock + the `maxSessionItems` batch cap.
///
/// Generated query methods take positional params in first-appearance-in-SQL
/// order; these wrappers expose named params so callers can't transpose them
/// (`docs/database/drift-guide.md` §named-param order).
@DriftAccessor(include: <String>{'../drift/study_scope_queries.drift'})
class StudyScopeDao extends DatabaseAccessor<AppDatabase>
    with _$StudyScopeDaoMixin {
  StudyScopeDao(super.db);

  /// Due (SRS review) cards for a single deck, ordered by due date.
  Future<List<String>> deckDueCardIds({
    required String deckId,
    required int now,
  }) => deckDueQueue(deckId, now).get();

  /// New-study cards (every active, non-buried card) for a deck, by sort order.
  Future<List<String>> deckNewCardIds({
    required String deckId,
    required int now,
  }) => deckNewQueue(deckId, now).get();

  /// Due cards across a folder subtree, ordered by due date.
  Future<List<String>> folderDueCardIds({
    required String folderId,
    required int now,
  }) => folderDueQueue(folderId, now).get();

  /// New-study cards across a folder subtree, by sort order.
  Future<List<String>> folderNewCardIds({
    required String folderId,
    required int now,
  }) => folderNewQueue(folderId, now).get();

  /// Due cards across every deck (the `today` scope), ordered by due date.
  Future<List<String>> todayDueCardIds({required int now}) =>
      todayDueQueue(now).get();

  /// New-study cards across every deck (the `today` scope), by sort order.
  Future<List<String>> todayNewCardIds({required int now}) =>
      todayNewQueue(now).get();
}
