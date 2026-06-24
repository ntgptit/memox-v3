import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/daos/card_history_dao.dart';
import 'package:memox/data/mappers/study_session_mapper.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Drift-backed [CardHistoryRepository] (WBS 7.6.1): composes the Card History
/// header from the stored counters and merges the activity feed.
///
/// The feed is built fully in Dart (per-card scale is small): graded attempts +
/// any `card_events` lifecycle rows + a synthesized `created` event from the
/// card's `created_at`, sorted by `occurred_at` DESC. Accuracy/retention comes
/// from the counters, never by scanning attempts
/// (`docs/contracts/usecase-contracts/history.md` §Forbidden).
class CardHistoryRepositoryImpl implements CardHistoryRepository {
  const CardHistoryRepositoryImpl({
    required CardHistoryDao dao,
    StudySessionMapper mapper = const StudySessionMapper(),
  }) : _dao = dao,
       _mapper = mapper;

  final CardHistoryDao _dao;
  final StudySessionMapper _mapper;

  @override
  Future<Result<CardHistory>> loadCardHistory({
    required FlashcardId flashcardId,
  }) async {
    try {
      final CardHistoryHeaderRow? headerRow = await _dao.header(flashcardId);
      if (headerRow == null) {
        return (
          failure: const Failure.notFound(entity: 'flashcard'),
          data: null,
        );
      }
      final double? avgMs = await _dao.avgDuration(flashcardId);
      final List<CardHistoryAttemptRow> attempts = await _dao.attempts(
        flashcardId,
      );
      final List<CardHistoryEventRow> lifecycle = await _dao.events(
        flashcardId,
      );

      final CardHistoryHeader header = CardHistoryHeader(
        front: headerRow.front,
        deckName: headerRow.deckName,
        boxNumber: headerRow.boxNumber,
        reviewCount: headerRow.reviewCount,
        lapseCount: headerRow.lapseCount,
        createdAt: headerRow.createdAt,
        avgDurationMs: avgMs?.round(),
        lastResetAt: headerRow.lastResetAt,
      );

      final List<CardHistoryEvent> events =
          <CardHistoryEvent>[
            for (final CardHistoryAttemptRow a in attempts)
              CardHistoryEvent.attempt(
                occurredAt: a.attemptedAt,
                result: _mapper.resultFromToken(a.result),
                mode: _mapper.studyModeFromToken(a.studyMode),
                boxBefore: a.boxBefore,
                boxAfter: a.boxAfter,
                durationMs: a.durationMs,
              ),
            for (final CardHistoryEventRow e in lifecycle)
              CardHistoryEvent.lifecycle(
                occurredAt: e.occurredAt,
                kind: CardEventKind.fromToken(e.type),
                detail: e.detail,
              ),
            // Synthesized "Card created" — always the earliest event (the feed's
            // floor), unless a real `created` card_events row already exists.
            if (!lifecycle.any((CardHistoryEventRow e) => e.type == 'created'))
              CardHistoryEvent.lifecycle(
                occurredAt: headerRow.createdAt,
                kind: CardEventKind.created,
              ),
          ]..sort(
            // Newest first; the synthesized created event sinks to the bottom.
            (CardHistoryEvent a, CardHistoryEvent b) =>
                b.occurredAt.compareTo(a.occurredAt),
          );

      return (failure: null, data: CardHistory(header: header, events: events));
    } catch (error) {
      // The read spans flashcards/decks/flashcard_progress/study_attempts/
      // card_events — name the logical read, not one physical table.
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'card_history',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }
}
