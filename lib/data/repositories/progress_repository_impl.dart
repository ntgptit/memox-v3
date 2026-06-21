import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/domain/models/due_summary.dart';
import 'package:memox/domain/repositories/progress_repository.dart';

/// Drift-backed [ProgressRepository] (WBS 7.1.1 due-summary slice).
///
/// Runs the per-deck due-count query and derives the global total as the sum of
/// the per-deck counts (every flashcard belongs to exactly one deck), keeping the
/// global and per-deck numbers consistent by construction. Suspended /
/// currently-buried exclusion lives in the query.
class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl({required ProgressDao dao}) : _dao = dao;

  final ProgressDao _dao;

  @override
  Future<Result<DueSummary>> loadDueSummary({required int now}) async {
    try {
      final List<DeckDueCountRow> rows = await _dao.dueCounts(now);
      final List<DeckDueCount> decks = <DeckDueCount>[
        for (final DeckDueCountRow row in rows)
          DeckDueCount(
            deckId: row.deckId,
            deckName: row.deckName,
            dueCount: row.dueCount,
          ),
      ];
      final int total = decks.fold<int>(0, (sum, d) => sum + d.dueCount);
      return (
        failure: null,
        data: DueSummary(totalDueCount: total, decksWithDue: decks),
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
