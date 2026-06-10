import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart'
    as study_dao;
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';

Future<Result<void>> recordStudySessionAnswerTransaction({
  required study_dao.StudySessionDao dao,
  required SessionId sessionId,
  required String sessionItemId,
  required AttemptResult result,
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
        throw _RuleViolation(
          Failure.unsupportedAction(
            action: 'recordStudySessionAnswer:${status.name}',
          ),
        );
      }

      final itemRows = await dao.loadSessionReviewItems(sessionId);
      final matches = itemRows
          .where((row) => row.id == sessionItemId)
          .toList(growable: false);
      if (matches.isEmpty) {
        throw _RuleViolation(
          Failure.notFound(entity: 'study_session_item', id: sessionItemId),
        );
      }
      final itemRow = matches.first;
      if (itemRow.answeredAt != null) {
        throw _RuleViolation(
          const Failure.unsupportedAction(
            action: 'recordStudySessionAnswer:answered',
          ),
        );
      }

      final FlashcardProgressRow? progressRow = await dao.findFlashcardProgress(
        itemRow.flashcardId,
      );
      final int boxBefore = progressRow?.boxNumber ?? 1;
      final int boxAfter = _boxAfter(boxBefore, result);

      await dao.insertStudyAttempt(
        StudyAttemptsCompanion.insert(
          id: IdGenerator.newId(),
          sessionItemId: sessionItemId,
          result: StudyMapper.attemptResultToStorage(result),
          studyMode: StudyMapper.studyModeToStorage(studyMode),
          boxBefore: Value<int>(boxBefore),
          boxAfter: Value<int>(boxAfter),
          attemptedAt: nowMs,
        ),
      );
      await dao.markStudySessionItemAnswered(
        sessionItemId: sessionItemId,
        answeredAtMs: nowMs,
        updatedAtMs: nowMs,
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
        table: 'study_attempts',
      ),
    );
  }
}

int _boxAfter(int currentBox, AttemptResult result) => switch (result) {
  AttemptResult.perfect ||
  AttemptResult.initialPassed => currentBox >= 8 ? 8 : currentBox + 1,
  AttemptResult.recovered => currentBox,
  AttemptResult.forgot => 1,
};

class _RuleViolation implements Exception {
  _RuleViolation(this.failure);

  final Failure failure;
}
