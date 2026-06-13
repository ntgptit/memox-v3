import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'card_history_dao.g.dart';

/// Read access for the Card History screen plus the per-card progress reset.
///
/// The timeline loads fully (attempts + lifecycle events merged in Dart); per-card
/// scale is small, so there is no offset pagination
/// (`docs/business/history/card-history.md`).
@DriftAccessor(include: <String>{'../drift/history_queries.drift'})
class CardHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$CardHistoryDaoMixin {
  CardHistoryDao(super.db);

  Future<CardHistoryHeaderResult?> loadHeader(String flashcardId) =>
      cardHistoryHeader(flashcardId).getSingleOrNull();

  Future<List<CardHistoryAttemptsResult>> loadAttempts(String flashcardId) =>
      cardHistoryAttempts(flashcardId).get();

  Future<List<CardHistoryCardEventsResult>> loadCardEvents(
    String flashcardId,
  ) => cardHistoryCardEvents(flashcardId).get();

  /// Attempt results newest-first, used to compute the correct streak.
  Future<List<String>> loadResultsDesc(String flashcardId) =>
      cardHistoryResultsDesc(flashcardId).get();

  /// Appends a lifecycle event (e.g. 'reset') to the card's timeline.
  Future<void> insertCardEvent({
    required String id,
    required String flashcardId,
    required String type,
    required int occurredAt,
    String? detail,
  }) => into(attachedDatabase.cardEvents).insert(
    CardEventsCompanion.insert(
      id: id,
      flashcardId: flashcardId,
      type: type,
      occurredAt: occurredAt,
      detail: Value<String?>(detail),
    ),
  );

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
