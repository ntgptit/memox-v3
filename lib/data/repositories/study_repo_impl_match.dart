part of 'study_repo_impl.dart';

Future<Result<void>> _recordMatchEvaluationTransaction({
  required study_dao.StudySessionDao dao,
  required SessionId sessionId,
  required String sessionItemId,
  required FlashcardId flashcardId,
  required int boardIndex,
  required String pairId,
  required String selectedFrontCellId,
  required String selectedBackCellId,
  required FlashcardId expectedFrontFlashcardId,
  required FlashcardId expectedBackFlashcardId,
  required bool isCorrect,
  required StudyMode studyMode,
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
      if (status != SessionStatus.draft && status != SessionStatus.inProgress) {
        throw const _RuleViolation(
          Failure.unsupportedAction(action: 'recordMatchEvaluation'),
        );
      }
      if (studyMode != StudyMode.match) {
        throw const _RuleViolation(
          Failure.unsupportedAction(action: 'recordMatchEvaluation'),
        );
      }

      final List<study_dao.StudySessionReviewItemsResult> itemRows = await dao
          .loadSessionReviewItems(sessionId);
      final List<study_dao.StudySessionReviewItemsResult> matches = itemRows
          .where(
            (study_dao.StudySessionReviewItemsResult row) =>
                row.id == sessionItemId,
          )
          .toList(growable: false);
      if (matches.isEmpty) {
        throw _RuleViolation(
          Failure.notFound(entity: 'study_session_item', id: sessionItemId),
        );
      }
      final study_dao.StudySessionReviewItemsResult itemRow = matches.first;
      if (itemRow.flashcardId != flashcardId) {
        throw const _RuleViolation(
          Failure.validation(
            field: 'flashcardId',
            code: ValidationCode.invalidFormat,
          ),
        );
      }
      if (itemRow.answeredAt != null) {
        throw const _RuleViolation(
          Failure.unsupportedAction(action: 'recordMatchEvaluation:answered'),
        );
      }

      final int nextAttemptOrder = (await dao.loadMatchEvaluations(
        sessionId,
      )).length;
      await dao.insertStudyMatchEvaluation(
        StudyMatchEvaluationsCompanion.insert(
          id: IdGenerator.newId(),
          sessionId: sessionId,
          sessionItemId: sessionItemId,
          flashcardId: flashcardId,
          boardIndex: boardIndex,
          pairId: pairId,
          selectedFrontCellId: selectedFrontCellId,
          selectedBackCellId: selectedBackCellId,
          expectedFrontFlashcardId: expectedFrontFlashcardId,
          expectedBackFlashcardId: expectedBackFlashcardId,
          isCorrect: Value<bool>(isCorrect),
          attemptOrder: nextAttemptOrder,
          evaluatedAt: nowMs,
          createdAt: nowMs,
        ),
      );
      await dao.touchStudySession(sessionId: sessionId, updatedAtMs: nowMs);
    });
    return const Result<void>.ok(null);
  } on _RuleViolation catch (violation) {
    return Result<void>.err(violation.failure);
  } catch (error) {
    return Result<void>.err(
      Failure.storage(
        operation: StorageOp.transaction,
        cause: error.toString(),
        table: 'study_match_evaluations',
      ),
    );
  }
}
