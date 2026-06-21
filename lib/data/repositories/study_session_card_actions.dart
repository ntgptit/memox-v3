import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/domain/srs/srs_box.dart';
import 'package:memox/domain/types/ids.dart';

/// In-session bury/suspend actions (WBS 4.11.2), a data-layer collaborator of
/// `StudyRepositoryImpl`.
///
/// Both actions share one flow: validate the active session + unanswered queued
/// card, then in one transaction set the single mutated `flashcard_progress`
/// field, remove the queue item, and touch the session. Box/due/counters are
/// preserved; a card with no progress row is created with SRS-safe defaults
/// (box 1, no due, zero counters). No `study_attempts` row is written
/// (`docs/contracts/usecase-contracts/study.md` §Bury/Suspend).
class StudySessionCardActions {
  const StudySessionCardActions(this._dao);

  final StudySessionDao _dao;

  /// Applies a bury (`suspend = false`) or suspend (`suspend = true`) to
  /// [flashcardId] in the active session [sessionId] at [now] (epoch ms). A
  /// suspend sets `is_suspended = true`; a bury sets `buried_until` to tomorrow's
  /// local midnight + 1 second. Errors: missing session → `NotFoundFailure`;
  /// non-`in_progress` session → `UnsupportedActionFailure`; card absent from the
  /// session → `NotFoundFailure`; already-answered card →
  /// `UnsupportedActionFailure`; write error → `StorageFailure`.
  Future<Result<void>> apply({
    required SessionId sessionId,
    required FlashcardId flashcardId,
    required int now,
    required bool suspend,
  }) async {
    try {
      final StudySessionRow? session = await _dao.sessionById(sessionId);
      if (session == null) {
        return (
          failure: const Failure.notFound(entity: 'study_session'),
          data: null,
        );
      }
      if (session.status != StudySessionDao.statusInProgress) {
        return (
          failure: Failure.unsupportedAction(
            message:
                'Cannot bury/suspend a card in a ${session.status} study session.',
          ),
          data: null,
        );
      }

      final StudySessionItemRow? item = await _dao.itemBySessionAndFlashcard(
        sessionId,
        flashcardId,
      );
      if (item == null) {
        return (
          failure: const Failure.notFound(entity: 'study_session_item'),
          data: null,
        );
      }
      if (item.answeredAt != null) {
        return (
          failure: const Failure.unsupportedAction(
            message: 'Cannot bury/suspend an already-answered card.',
          ),
          data: null,
        );
      }

      // Preserve every existing SRS column; mutate ONLY the one action field.
      final FlashcardProgressRow? progress = await _dao.progressById(
        flashcardId,
      );
      final FlashcardProgressCompanion upsert =
          FlashcardProgressCompanion.insert(
            flashcardId: flashcardId,
            boxNumber: Value<int>(progress?.boxNumber ?? SrsBox.min),
            dueAt: Value<int?>(progress?.dueAt),
            reviewCount: Value<int>(progress?.reviewCount ?? 0),
            lapseCount: Value<int>(progress?.lapseCount ?? 0),
            isSuspended: Value<bool>(
              suspend ? true : (progress?.isSuspended ?? false),
            ),
            buriedUntil: Value<int?>(
              suspend ? progress?.buriedUntil : _buriedUntilFor(now),
            ),
          );

      await _dao.removeCardFromSession(
        progress: upsert,
        sessionItemId: item.id,
        sessionId: sessionId,
        updatedAt: now,
      );
      return (failure: null, data: null);
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.transaction,
          table: 'flashcard_progress',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  /// `buried_until` for a card buried at [nowMs]: tomorrow's local midnight + 1
  /// second (`docs/business/study-actions/bury-suspend.md` §Bury). Computed in
  /// Dart (local time), never a SQLite modifier, so the card re-enters the queue
  /// at the start of the next local calendar day.
  int _buriedUntilFor(int nowMs) {
    final DateTime nowLocal = DateTime.fromMillisecondsSinceEpoch(
      nowMs,
    ).toLocal();
    final DateTime tomorrowMidnight = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
    ).add(const Duration(days: 1));
    return tomorrowMidnight
        .add(const Duration(seconds: 1))
        .millisecondsSinceEpoch;
  }
}
