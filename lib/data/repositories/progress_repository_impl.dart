import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/domain/models/box_distribution.dart';
import 'package:memox/domain/models/due_summary.dart';
import 'package:memox/domain/models/study_statistics.dart';
import 'package:memox/domain/repositories/progress_repository.dart';
import 'package:memox/domain/srs/srs_box.dart';

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

  @override
  Future<Result<BoxDistribution>> loadBoxDistribution() async {
    try {
      final List<BoxCountRow> rows = await _dao.boxCounts();
      // Zero-fill the full ladder so the chart axis is stable.
      final Map<int, int> counts = <int, int>{
        for (int box = SrsBox.min; box <= SrsBox.max; box++) box: 0,
      };
      for (final BoxCountRow row in rows) {
        if (row.boxNumber < SrsBox.min || row.boxNumber > SrsBox.max) {
          // Fail fast: a persisted box outside 1..8 is a data-invariant
          // violation (decision row P9), not user input — surface it as an
          // IntegrityFailure (logged severe / blocking) rather than silently
          // bucketing it (`docs/contracts/error-contract.md` §IntegrityFailure).
          return (
            failure: Failure.integrity(
              message:
                  'Persisted box_number ${row.boxNumber} is outside '
                  'SrsBox.min..SrsBox.max (1..8) in flashcard_progress.',
            ),
            data: null,
          );
        }
        counts[row.boxNumber] = row.cardCount;
      }
      return (failure: null, data: BoxDistribution(countsByBox: counts));
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

  @override
  Future<Result<StudyStatistics>> loadStudyStatistics() async {
    try {
      final int completed = await _dao.completedSessions();
      final AttemptStatsRow attempts = await _dao.attemptStats();
      return (
        failure: null,
        data: StudyStatistics(
          completedSessions: completed,
          totalAttempts: attempts.total,
          // correct = every non-forgot outcome (perfect / recovered / the
          // compatibility-only initial_passed); only `forgot` is a lapse.
          correctCount: attempts.total - attempts.forgot,
          forgotCount: attempts.forgot,
          lastStudiedAt: attempts.lastStudiedAt,
        ),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'study_attempts',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }
}
