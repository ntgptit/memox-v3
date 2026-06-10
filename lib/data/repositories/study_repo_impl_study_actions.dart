part of 'study_repo_impl.dart';

enum _StudySessionCardAction { bury, suspend }

Future<Result<void>> _applyStudySessionCardAction({
  required study_dao.StudySessionDao dao,
  required SessionId sessionId,
  required FlashcardId flashcardId,
  required _StudySessionCardAction action,
  required int nowMs,
}) async {
  try {
    await dao.transaction(() async {
      final StudySessionRow? sessionRow = await dao.findSession(sessionId);
      if (sessionRow == null) {
        throw _RuleViolation(
          Failure.notFound(entity: 'study_session', id: sessionId),
        );
      }

      final SessionStatus status = StudyMapper.sessionStatusFromStorage(
        sessionRow.status,
      );
      if (status != SessionStatus.inProgress) {
        throw const _RuleViolation(
          Failure.validation(
            field: 'status',
            code: ValidationCode.invalidFormat,
          ),
        );
      }

      final List<study_dao.StudySessionReviewItemsResult> itemRows = await dao
          .loadSessionReviewItems(sessionId);
      final List<study_dao.StudySessionReviewItemsResult> matches = itemRows
          .where(
            (study_dao.StudySessionReviewItemsResult row) =>
                row.flashcardId == flashcardId,
          )
          .toList(growable: false);
      if (matches.isEmpty) {
        throw const _RuleViolation(
          Failure.validation(
            field: 'flashcardId',
            code: ValidationCode.invalidFormat,
          ),
        );
      }

      final study_dao.StudySessionReviewItemsResult itemRow = matches.first;
      if (itemRow.answeredAt != null) {
        throw const _RuleViolation(
          Failure.validation(
            field: 'flashcardId',
            code: ValidationCode.invalidFormat,
          ),
        );
      }

      final FlashcardProgressRow? progressRow = await dao.findFlashcardProgress(
        flashcardId,
      );

      if (action == _StudySessionCardAction.bury) {
        final int buriedUntilMs = _buryUntilTomorrowMs(
          DateTime.fromMillisecondsSinceEpoch(nowMs),
        );
        await _persistBuriedProgress(
          dao: dao,
          flashcardId: flashcardId,
          progressRow: progressRow,
          buriedUntilMs: buriedUntilMs,
        );
      }

      if (action == _StudySessionCardAction.suspend) {
        await _persistSuspendedProgress(
          dao: dao,
          flashcardId: flashcardId,
          progressRow: progressRow,
        );
      }

      final int deletedRows = await dao.deleteStudySessionItem(
        sessionItemId: itemRow.id,
      );
      if (deletedRows == 0) {
        throw const _RuleViolation(
          Failure.storage(
            operation: StorageOp.transaction,
            cause: 'Failed to remove current session item.',
            table: 'study_session_items',
          ),
        );
      }

      final int touchedRows = await dao.touchStudySession(
        sessionId: sessionId,
        updatedAtMs: nowMs,
      );
      if (touchedRows == 0) {
        throw _RuleViolation(
          Failure.notFound(entity: 'study_session', id: sessionId),
        );
      }
    });
    return const Result<void>.ok(null);
  } on _RuleViolation catch (violation) {
    return Result<void>.err(violation.failure);
  } catch (error) {
    return Result<void>.err(
      Failure.storage(
        operation: StorageOp.transaction,
        cause: error.toString(),
        table: 'study_sessions',
      ),
    );
  }
}

int _buryUntilTomorrowMs(DateTime now) {
  final DateTime localNow = now.toLocal();
  final DateTime localTomorrowMidnight = DateTime(
    localNow.year,
    localNow.month,
    localNow.day + 1,
  );
  return localTomorrowMidnight.millisecondsSinceEpoch + 1000;
}

Future<void> _persistBuriedProgress({
  required study_dao.StudySessionDao dao,
  required FlashcardId flashcardId,
  required FlashcardProgressRow? progressRow,
  required int buriedUntilMs,
}) async {
  if (progressRow == null) {
    await dao.insertFlashcardProgress(
      FlashcardProgressCompanion.insert(
        flashcardId: flashcardId,
        buriedUntil: Value<int?>(buriedUntilMs),
      ),
    );
    return;
  }

  final int updatedRows = await dao.updateFlashcardProgressBuriedUntil(
    flashcardId: flashcardId,
    buriedUntilMs: buriedUntilMs,
  );
  if (updatedRows == 0) {
    throw const _RuleViolation(
      Failure.storage(
        operation: StorageOp.transaction,
        cause: 'Failed to update buried_until.',
        table: 'flashcard_progress',
      ),
    );
  }
}

Future<void> _persistSuspendedProgress({
  required study_dao.StudySessionDao dao,
  required FlashcardId flashcardId,
  required FlashcardProgressRow? progressRow,
}) async {
  if (progressRow == null) {
    await dao.insertFlashcardProgress(
      FlashcardProgressCompanion.insert(
        flashcardId: flashcardId,
        isSuspended: const Value<bool>(true),
      ),
    );
    return;
  }

  final int updatedRows = await dao.updateFlashcardProgressSuspended(
    flashcardId: flashcardId,
    isSuspended: true,
  );
  if (updatedRows == 0) {
    throw const _RuleViolation(
      Failure.storage(
        operation: StorageOp.transaction,
        cause: 'Failed to update is_suspended.',
        table: 'flashcard_progress',
      ),
    );
  }
}
