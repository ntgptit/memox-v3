import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart'
    as study_dao;
import 'package:memox/data/mappers/deck_mapper.dart';
import 'package:memox/data/mappers/flashcard_mapper.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/data/repositories/study_repo_record_answer.dart';
import 'package:memox/domain/entities/study_match_evaluation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/learning_settings.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/study/study_session_limits.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

part 'study_repo_impl_match.dart';
part 'study_repo_impl_study_actions.dart';
part 'study_repo_impl_study_session.dart';
part 'study_repo_impl_study_session_helpers.dart';
part 'study_repo_impl_summary.dart';

class StudyRepositoryImpl implements StudyRepository {
  StudyRepositoryImpl(this._dao, {DateTime Function()? now})
    : _nowProvider = now ?? DateTime.now;

  final study_dao.StudySessionDao _dao;
  final DateTime Function() _nowProvider;

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    int dailyNewLimit = LearningSettings.defaultDailyNewLimit,
    StudyMode? mode,
  }) async {
    final Result<StudySession?> resumable = await findResumableSession(
      scope: scope,
    );
    if (resumable is Err<StudySession?>) {
      return Result<StudyEntryStartResult>.err(resumable.failure);
    }
    final StudySession? session = (resumable as Ok<StudySession?>).value;
    if (session != null) {
      return Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.resumeRequired(sessionId: session.id),
      );
    }

    try {
      final DateTime now = _now;
      final _ScopeSnapshot snapshot = await _loadScopeSnapshot(
        _dao,
        scope,
        now: now,
      );
      final StudyEntryEmptyState? emptyState = _resolveEmptyState(
        scope: scope,
        snapshot: snapshot,
        dailyNewLimit: dailyNewLimit,
      );
      if (emptyState != null) {
        return Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.empty(emptyState: emptyState),
        );
      }

      final List<FlashcardId> eligibleIds = _eligibleFlashcardIds(
        scope: scope,
        snapshot: snapshot,
        dailyNewLimit: dailyNewLimit,
      );
      final Result<StudySession> created = await createSession(
        scope: scope,
        flashcardIds: eligibleIds,
      );
      return created.map(
        (StudySession session) =>
            StudyEntryStartResult.started(sessionId: session.id),
      );
    } on _RuleViolation catch (violation) {
      return Result<StudyEntryStartResult>.err(violation.failure);
    } catch (error) {
      return Result<StudyEntryStartResult>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'study_sessions',
        ),
      );
    }
  }

  @override
  Future<Result<StudySession>> restartStudySession({
    required SessionId previousSessionId,
    required StudyScope scope,
    int dailyNewLimit = LearningSettings.defaultDailyNewLimit,
    StudyMode? mode,
  }) async {
    try {
      final StudySession session = await _dao.transaction(() async {
        final StudySessionRow? previousRow = await _dao.findSession(
          previousSessionId,
        );
        if (previousRow == null) {
          throw _RuleViolation(
            Failure.notFound(entity: 'study_session', id: previousSessionId),
          );
        }

        final SessionStatus previousStatus =
            StudyMapper.sessionStatusFromStorage(previousRow.status);
        if (previousStatus != SessionStatus.draft &&
            previousStatus != SessionStatus.inProgress) {
          throw const _RuleViolation(
            Failure.unsupportedAction(action: 'restart_study_session'),
          );
        }

        if (!_matchesRestartScope(previousRow, scope)) {
          throw const _RuleViolation(
            Failure.unsupportedAction(action: 'restart_study_session'),
          );
        }

        final DateTime now = _now;
        final _ScopeSnapshot snapshot = await _loadScopeSnapshot(
          _dao,
          scope,
          now: now,
        );
        final List<FlashcardId> eligibleIds = _eligibleFlashcardIds(
          scope: scope,
          snapshot: snapshot,
          dailyNewLimit: dailyNewLimit,
        );
        if (eligibleIds.isEmpty) {
          throw const _RuleViolation(
            Failure.validation(
              field: 'flashcardIds',
              code: ValidationCode.insufficientContent,
            ),
          );
        }

        final int nowMs = now.millisecondsSinceEpoch;
        final int cancelledRows = await _dao.cancelStudySession(
          sessionId: previousSessionId,
          updatedAtMs: nowMs,
        );
        if (cancelledRows == 0) {
          throw _RuleViolation(
            Failure.notFound(entity: 'study_session', id: previousSessionId),
          );
        }

        return _persistSession(
          dao: _dao,
          scope: scope,
          flashcardIds: eligibleIds,
          nowMs: nowMs,
        );
      });
      return Result<StudySession>.ok(session);
    } on _RuleViolation catch (violation) {
      return Result<StudySession>.err(violation.failure);
    } catch (error) {
      return Result<StudySession>.err(
        Failure.storage(
          operation: StorageOp.transaction,
          cause: error.toString(),
          table: 'study_sessions',
        ),
      );
    }
  }

  @override
  Future<Result<StudySessionReview>> loadStudySessionReview({
    required SessionId sessionId,
  }) async {
    try {
      final StudySessionRow? sessionRow = await _dao.findSession(sessionId);
      if (sessionRow == null) {
        return Result<StudySessionReview>.err(
          Failure.notFound(entity: 'study_session', id: sessionId),
        );
      }

      final List<study_dao.StudySessionReviewItemsResult> itemRows = await _dao
          .loadSessionReviewItems(sessionId);
      if (itemRows.isEmpty) {
        return const Result<StudySessionReview>.err(
          Failure.storage(
            operation: StorageOp.read,
            cause: 'Study session has no items.',
            table: 'study_session_items',
          ),
        );
      }

      return Result<StudySessionReview>.ok(
        StudySessionReview(
          session: StudyMapper.fromSessionRow(sessionRow),
          items: itemRows.map(_fromSessionReviewRow).toList(growable: false),
        ),
      );
    } catch (error) {
      return Result<StudySessionReview>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'study_sessions',
        ),
      );
    }
  }

  @override
  Future<Result<StudySessionResult>> loadStudySessionResult({
    required SessionId sessionId,
  }) async => _loadStudySessionResult(_dao, sessionId);

  @override
  Future<Result<DashboardResumeSessionSummary?>>
  findLatestResumableSessionSummary() =>
      _findLatestResumableSessionSummary(_dao, _nowMs);

  @override
  Future<Result<StudySession?>> findResumableSession({
    required StudyScope scope,
  }) => _findResumableSession(_dao, _nowMs, scope);

  @override
  Future<Result<void>> cancelStudySession({required SessionId sessionId}) =>
      _cancelStudySession(_dao, _nowMs, sessionId);

  @override
  Future<Result<void>> buryStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) async => _applyStudySessionCardAction(
    dao: _dao,
    action: _StudySessionCardAction.bury,
    sessionId: sessionId,
    flashcardId: flashcardId,
    nowMs: _nowMs,
  );

  @override
  Future<Result<void>> suspendStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) async => _applyStudySessionCardAction(
    dao: _dao,
    action: _StudySessionCardAction.suspend,
    sessionId: sessionId,
    flashcardId: flashcardId,
    nowMs: _nowMs,
  );

  @override
  Future<Result<void>> finalizeStudySession({
    required SessionId sessionId,
  }) async {
    try {
      await _dao.transaction(() async {
        final StudySessionRow? sessionRow = await _dao.findSession(sessionId);
        if (sessionRow == null) {
          throw _RuleViolation(
            Failure.notFound(entity: 'study_session', id: sessionId),
          );
        }

        final SessionStatus status = StudyMapper.sessionStatusFromStorage(
          sessionRow.status,
        );
        if (status != SessionStatus.draft &&
            status != SessionStatus.inProgress) {
          throw _RuleViolation(Failure.finalization(sessionId: sessionId));
        }

        final List<study_dao.StudySessionReviewItemsResult> itemRows =
            await _dao.loadSessionReviewItems(sessionId);
        if (itemRows.isEmpty) {
          throw _RuleViolation(Failure.finalization(sessionId: sessionId));
        }

        final List<study_dao.StudySessionAttemptsResult> attemptRows =
            await _dao.loadSessionAttempts(sessionId);
        final List<StudyMatchEvaluationsRow> matchRows = await _dao
            .loadMatchEvaluations(sessionId);
        final bool hasMatchEvaluations = matchRows.isNotEmpty;
        if (hasMatchEvaluations && attemptRows.isNotEmpty) {
          throw _RuleViolation(Failure.finalization(sessionId: sessionId));
        }

        final DateTime now = _now;
        final int nowMs = now.millisecondsSinceEpoch;
        if (hasMatchEvaluations) {
          await _finalizeMatchStudySession(
            dao: _dao,
            sessionId: sessionId,
            itemRows: itemRows,
            now: now,
          );
        }
        if (!hasMatchEvaluations) {
          final Map<String, List<study_dao.StudySessionAttemptsResult>>
          attemptsByItemId =
              <String, List<study_dao.StudySessionAttemptsResult>>{};
          for (final study_dao.StudySessionAttemptsResult row in attemptRows) {
            attemptsByItemId
                .putIfAbsent(
                  row.sessionItemId,
                  () => <study_dao.StudySessionAttemptsResult>[],
                )
                .add(row);
          }

          for (final study_dao.StudySessionReviewItemsResult itemRow
              in itemRows) {
            if (itemRow.answeredAt == null) {
              throw _RuleViolation(Failure.finalization(sessionId: sessionId));
            }

            final List<study_dao.StudySessionAttemptsResult> itemAttempts =
                attemptsByItemId[itemRow.id] ??
                const <study_dao.StudySessionAttemptsResult>[];
            if (itemAttempts.isEmpty) {
              throw _RuleViolation(Failure.finalization(sessionId: sessionId));
            }

            final AttemptResult finalResult = _finalizeResultForAttempts(
              itemAttempts,
            );
            final FlashcardProgressRow? progressRow = await _dao
                .findFlashcardProgress(itemRow.flashcardId);
            final int currentBox = progressRow?.boxNumber ?? 1;
            final int nextBox = _boxAfterFinalization(currentBox, finalResult);
            final int dueAtMs = _dueAtForInterval(now, nextBox);
            final int reviewCount = (progressRow?.reviewCount ?? 0) + 1;
            final int lapseCount =
                (progressRow?.lapseCount ?? 0) +
                (finalResult == AttemptResult.forgot ? 1 : 0);

            if (progressRow == null) {
              await _dao.insertFlashcardProgress(
                FlashcardProgressCompanion.insert(
                  flashcardId: itemRow.flashcardId,
                ),
              );
            }

            final int updatedRows = await _dao.updateFlashcardProgress(
              flashcardId: itemRow.flashcardId,
              boxNumber: nextBox,
              dueAtMs: dueAtMs,
              reviewCount: reviewCount,
              lapseCount: lapseCount,
              lastStudiedAtMs: nowMs,
            );
            if (updatedRows == 0) {
              throw _RuleViolation(Failure.finalization(sessionId: sessionId));
            }
          }
        }

        final int sessionUpdatedRows = await _dao.updateStudySessionStatus(
          sessionId: sessionId,
          status: StudyMapper.sessionStatusToStorage(SessionStatus.completed),
          updatedAtMs: nowMs,
        );
        if (sessionUpdatedRows == 0) {
          throw _RuleViolation(Failure.finalization(sessionId: sessionId));
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

  @override
  Future<Result<void>> recordStudySessionAnswer({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
    int? durationMs,
  }) async => recordStudySessionAnswerTransaction(
    dao: _dao,
    sessionId: sessionId,
    sessionItemId: sessionItemId,
    result: result,
    studyMode: studyMode,
    durationMs: durationMs,
    nowMs: _nowMs,
  );

  @override
  Future<Result<void>> recordMatchEvaluation({
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
  }) async => _recordMatchEvaluationTransaction(
    dao: _dao,
    sessionId: sessionId,
    sessionItemId: sessionItemId,
    flashcardId: flashcardId,
    boardIndex: boardIndex,
    pairId: pairId,
    selectedFrontCellId: selectedFrontCellId,
    selectedBackCellId: selectedBackCellId,
    expectedFrontFlashcardId: expectedFrontFlashcardId,
    expectedBackFlashcardId: expectedBackFlashcardId,
    isCorrect: isCorrect,
    studyMode: studyMode,
    nowMs: _nowMs,
  );

  @override
  Future<Result<List<StudyMatchEvaluation>>> loadMatchEvaluations({
    required SessionId sessionId,
  }) async {
    try {
      final List<StudyMatchEvaluationsRow> rows = await _dao
          .loadMatchEvaluations(sessionId);
      return Result<List<StudyMatchEvaluation>>.ok(
        rows.map(StudyMapper.fromMatchEvaluationRow).toList(growable: false),
      );
    } catch (error) {
      return Result<List<StudyMatchEvaluation>>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'study_match_evaluations',
        ),
      );
    }
  }

  @override
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
  }) async {
    final List<FlashcardId> cappedFlashcardIds = _capSessionFlashcardIds(
      flashcardIds,
    );
    if (cappedFlashcardIds.isEmpty) {
      return const Result<StudySession>.err(
        Failure.validation(
          field: 'flashcardIds',
          code: ValidationCode.insufficientContent,
        ),
      );
    }

    try {
      final DateTime now = _now;
      final StudySession session = await _dao.transaction(
        () => _persistSession(
          dao: _dao,
          scope: scope,
          flashcardIds: cappedFlashcardIds,
          nowMs: now.millisecondsSinceEpoch,
        ),
      );
      return Result<StudySession>.ok(session);
    } catch (error) {
      return Result<StudySession>.err(
        Failure.storage(
          operation: StorageOp.transaction,
          cause: error.toString(),
          table: 'study_sessions',
        ),
      );
    }
  }

  DateTime get _now => _nowProvider();

  int get _nowMs => _now.millisecondsSinceEpoch;
}

bool _matchesRestartScope(StudySessionRow row, StudyScope scope) =>
    StudyMapper.entryTypeFromStorage(row.entryType) == scope.entryType &&
    row.entryRefId == scope.entryRefId &&
    StudyMapper.studyTypeFromStorage(row.studyType) == scope.studyType;
