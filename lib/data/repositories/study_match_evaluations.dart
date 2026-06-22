import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/mappers/study_session_mapper.dart';
import 'package:memox/domain/entities/match_evaluation.dart';
import 'package:memox/domain/srs/srs_box.dart';
import 'package:memox/domain/srs/srs_due.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Match-mode evaluation persistence (WBS 4.5.4), a data-layer collaborator of
/// `StudyRepositoryImpl` — keeps the repo impl within its line budget.
///
/// Appends append-only `study_match_evaluations` rows and loads them in order.
/// Rows do NOT mark items answered; Match finalization (WP-SM2) derives the
/// terminal attempts (`docs/contracts/repository-contracts/study-repository.md`
/// §Match).
class StudyMatchEvaluationActions {
  const StudyMatchEvaluationActions(this._dao, this._idGenerator, this._mapper);

  final StudySessionDao _dao;
  final IdGenerator _idGenerator;
  final StudySessionMapper _mapper;

  /// Appends one pair evaluation for the active session [sessionId] at [now]
  /// (epoch ms). `attempt_order` is the next per-session sequence; `flashcard_id`
  /// denormalizes [expectedFrontFlashcardId]; the session `updated_at` is touched.
  /// The session must be `in_progress` and [studyMode] must be `match`.
  Future<Result<void>> record({
    required SessionId sessionId,
    required String sessionItemId,
    required int boardIndex,
    required String pairId,
    required String selectedFrontCellId,
    required String selectedBackCellId,
    required FlashcardId expectedFrontFlashcardId,
    required FlashcardId expectedBackFlashcardId,
    required bool isCorrect,
    required StudyMode studyMode,
    required int now,
  }) async {
    try {
      if (studyMode != StudyMode.match) {
        return (
          failure: Failure.unsupportedAction(
            message: 'recordMatchEvaluation is match-only, got $studyMode.',
          ),
          data: null,
        );
      }
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
            message: 'Cannot evaluate a match in a ${session.status} session.',
          ),
          data: null,
        );
      }
      final StudySessionItemRow? item = await _dao.itemById(sessionItemId);
      if (item == null || item.sessionId != sessionId) {
        return (
          failure: const Failure.notFound(entity: 'study_session_item'),
          data: null,
        );
      }

      final int attemptOrder = await _dao.matchEvaluationCount(sessionId);
      await _dao.recordMatchEvaluation(
        evaluation: StudyMatchEvaluationsCompanion.insert(
          id: _idGenerator.newId(),
          sessionId: sessionId,
          sessionItemId: sessionItemId,
          flashcardId: expectedFrontFlashcardId,
          boardIndex: boardIndex,
          pairId: pairId,
          selectedFrontCellId: selectedFrontCellId,
          selectedBackCellId: selectedBackCellId,
          expectedFrontFlashcardId: expectedFrontFlashcardId,
          expectedBackFlashcardId: expectedBackFlashcardId,
          isCorrect: isCorrect,
          attemptOrder: attemptOrder,
          evaluatedAt: now,
          createdAt: now,
        ),
        sessionId: sessionId,
        updatedAt: now,
      );
      return (failure: null, data: null);
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.transaction,
          table: 'study_match_evaluations',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  /// Loads all evaluations for [sessionId] ordered by append sequence.
  Future<Result<List<MatchEvaluation>>> load(SessionId sessionId) async {
    try {
      final List<StudyMatchEvaluationRow> rows = await _dao
          .matchEvaluationsBySession(sessionId);
      return (
        failure: null,
        data: rows.map(_mapper.toMatchEvaluation).toList(),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'study_match_evaluations',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  /// Finalizes a Match session (WBS 4.5.4 / WP-SM2): derives **one terminal
  /// attempt per session item** from the append-only evaluations, applies the
  /// normal SRS box transition, and marks the session completed — all in one
  /// transaction. Per `docs/business/srs/srs-review.md`, a clean correct pair →
  /// `perfect`; any wrong-before-correct or never-correct path → `forgot`
  /// (first-attempt-decides). The caller (`finalizeStudySession`) routes here
  /// when the session has any evaluations.
  Future<Result<void>> finalize({
    required SessionId sessionId,
    required int now,
  }) async {
    try {
      final List<StudySessionItemRow> items = await _dao.itemsForSession(
        sessionId,
      );
      if (items.isEmpty) {
        return (
          failure: const Failure.finalization(
            message: 'Study session has no items to finalize.',
          ),
          data: null,
        );
      }
      final List<StudyMatchEvaluationRow> evals = await _dao
          .matchEvaluationsBySession(sessionId);

      final List<StudyAttemptsCompanion> attempts = <StudyAttemptsCompanion>[];
      final List<FlashcardProgressCompanion> upserts =
          <FlashcardProgressCompanion>[];
      for (final StudySessionItemRow item in items) {
        final AttemptResult terminal = _deriveTerminal(
          evals.where(
            (StudyMatchEvaluationRow e) => e.sessionItemId == item.id,
          ),
        );
        final FlashcardProgressRow? progress = await _dao.progressById(
          item.flashcardId,
        );
        final int boxBefore = progress?.boxNumber ?? SrsBox.min;
        final int boxAfter = SrsBox.nextBox(boxBefore, terminal);
        attempts.add(
          StudyAttemptsCompanion.insert(
            id: _idGenerator.newId(),
            sessionItemId: item.id,
            result: _mapper.resultToken(terminal),
            studyMode: _mapper.studyModeToken(StudyMode.match),
            boxBefore: Value<int>(boxBefore),
            boxAfter: Value<int>(boxAfter),
            attemptedAt: now,
          ),
        );
        upserts.add(
          FlashcardProgressCompanion.insert(
            flashcardId: item.flashcardId,
            boxNumber: Value<int>(boxAfter),
            dueAt: Value<int?>(dueAtFor(now, boxAfter)),
            reviewCount: Value<int>((progress?.reviewCount ?? 0) + 1),
            lapseCount: Value<int>(
              (progress?.lapseCount ?? 0) +
                  (terminal == AttemptResult.forgot ? 1 : 0),
            ),
            isSuspended: Value<bool>(progress?.isSuspended ?? false),
            buriedUntil: Value<int?>(progress?.buriedUntil),
          ),
        );
      }

      await _dao.finalizeMatchSession(
        sessionId: sessionId,
        attempts: attempts,
        answeredItemIds: items.map((StudySessionItemRow i) => i.id).toList(),
        progressUpserts: upserts,
        now: now,
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

  /// Derives an item's terminal result from its ordered evaluations: a clean
  /// correct pair (first evaluation correct) → `perfect`; a wrong-before-correct
  /// (first evaluation wrong) or never-correct (no evaluations) path → `forgot`.
  AttemptResult _deriveTerminal(Iterable<StudyMatchEvaluationRow> itemEvals) {
    final Iterator<StudyMatchEvaluationRow> it = itemEvals.iterator;
    if (!it.moveNext()) {
      return AttemptResult.forgot; // never evaluated
    }
    return it.current.isCorrect ? AttemptResult.perfect : AttemptResult.forgot;
  }
}
