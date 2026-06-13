import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'card_history_dao.g.dart';

/// One row of a card's attempt timeline, flattened from the
/// `history_queries.drift` page queries so both pages share a single shape.
typedef CardHistoryAttemptRow = ({
  String id,
  String result,
  String studyMode,
  int boxBefore,
  int boxAfter,
  int attemptedAt,
  String sessionId,
  String sessionStatus,
});

/// Read access for the Card History screen plus the per-card progress reset.
///
/// Timeline reads are cursor-paginated on `(attempted_at, id)` DESC — never
/// offset — per `docs/business/history/card-history.md`.
@DriftAccessor(include: <String>{'../drift/history_queries.drift'})
class CardHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$CardHistoryDaoMixin {
  CardHistoryDao(super.db);

  Future<CardHistoryHeaderResult?> loadHeader(String flashcardId) =>
      cardHistoryHeader(flashcardId).getSingleOrNull();

  Future<int> loadEventCount(String flashcardId) =>
      cardHistoryEventCount(flashcardId).getSingle();

  /// Attempt results newest-first, used to compute the correct streak.
  Future<List<String>> loadResultsDesc(String flashcardId) =>
      cardHistoryResultsDesc(flashcardId).get();

  /// First [limit] timeline rows, newest first.
  Future<List<CardHistoryAttemptRow>> loadFirstPage({
    required String flashcardId,
    required int limit,
  }) async {
    final List<CardHistoryFirstPageResult> rows = await cardHistoryFirstPage(
      flashcardId,
      limit,
    ).get();
    return rows
        .map(
          (CardHistoryFirstPageResult row) => (
            id: row.id,
            result: row.result,
            studyMode: row.studyMode,
            boxBefore: row.boxBefore,
            boxAfter: row.boxAfter,
            attemptedAt: row.attemptedAt,
            sessionId: row.sessionId,
            sessionStatus: row.sessionStatus,
          ),
        )
        .toList(growable: false);
  }

  /// Next [limit] timeline rows after the `(beforeAttemptedAt, beforeId)`
  /// cursor, newest first.
  Future<List<CardHistoryAttemptRow>> loadNextPage({
    required String flashcardId,
    required int beforeAttemptedAt,
    required String beforeId,
    required int limit,
  }) async {
    final List<CardHistoryNextPageResult> rows = await cardHistoryNextPage(
      flashcardId,
      beforeAttemptedAt,
      beforeId,
      limit,
    ).get();
    return rows
        .map(
          (CardHistoryNextPageResult row) => (
            id: row.id,
            result: row.result,
            studyMode: row.studyMode,
            boxBefore: row.boxBefore,
            boxAfter: row.boxAfter,
            attemptedAt: row.attemptedAt,
            sessionId: row.sessionId,
            sessionStatus: row.sessionStatus,
          ),
        )
        .toList(growable: false);
  }

  /// Resets an existing card's SRS scheduling to box 1 / due now and stamps
  /// `last_reset_at`. Lifetime counters and attempts are intentionally retained.
  /// Returns the number of rows updated (0 when the card was never studied).
  Future<int> resetProgress({
    required String flashcardId,
    required int nowMs,
  }) =>
      (update(
        flashcardProgress,
      )..where((tbl) => tbl.flashcardId.equals(flashcardId))).write(
        FlashcardProgressCompanion(
          boxNumber: const Value<int>(1),
          dueAt: Value<int?>(nowMs),
          buriedUntil: const Value<int?>(null),
          lastResetAt: Value<int?>(nowMs),
        ),
      );
}
