import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart'
    as study_dao;
import 'package:memox/data/mappers/flashcard_mapper.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/data/repositories/study_repo_record_answer.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

part 'study_repo_impl_study_session.dart';

class StudyRepositoryImpl implements StudyRepository {
  StudyRepositoryImpl(this._dao);

  final study_dao.StudySessionDao _dao;

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
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
      final _ScopeSnapshot snapshot = await _loadScopeSnapshot(_dao, scope);
      final StudyEntryEmptyState? emptyState = _resolveEmptyState(
        scope: scope,
        snapshot: snapshot,
      );
      if (emptyState != null) {
        return Result<StudyEntryStartResult>.ok(
          StudyEntryStartResult.empty(emptyState: emptyState),
        );
      }

      final List<FlashcardId> eligibleIds = _eligibleFlashcardIds(
        scope: scope,
        snapshot: snapshot,
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
  Future<Result<DashboardResumeSessionSummary?>>
  findLatestResumableSessionSummary() async {
    try {
      final StudySessionRow? sessionRow = await _dao.findLatestResumableSession(
        nowMs: _nowMs,
      );
      if (sessionRow == null) {
        return const Result<DashboardResumeSessionSummary?>.ok(null);
      }

      final Result<StudySessionReview> reviewResult =
          await loadStudySessionReview(sessionId: sessionRow.id);
      if (reviewResult is Err<StudySessionReview>) {
        return Result<DashboardResumeSessionSummary?>.err(reviewResult.failure);
      }

      final StudySessionReview review =
          (reviewResult as Ok<StudySessionReview>).value;
      final String? scopeLabel = await _resolveResumableScopeLabel(
        sessionRow,
        _dao,
      );

      return Result<DashboardResumeSessionSummary?>.ok(
        DashboardResumeSessionSummary(
          session: review.session,
          answeredCount: review.items
              .where(
                (StudySessionReviewItem item) =>
                    item.sessionItem.answeredAt != null,
              )
              .length,
          totalCount: review.items.length,
          scopeLabel: scopeLabel,
        ),
      );
    } catch (error) {
      return Result<DashboardResumeSessionSummary?>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'study_sessions',
        ),
      );
    }
  }

  @override
  Future<Result<StudySession?>> findResumableSession({
    required StudyScope scope,
  }) async {
    try {
      final StudySessionRow? row = await _dao.findResumableSession(
        scope: scope,
        nowMs: _nowMs,
      );
      return Result<StudySession?>.ok(
        row == null ? null : StudyMapper.fromSessionRow(row),
      );
    } catch (error) {
      return Result<StudySession?>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: error.toString(),
          table: 'study_sessions',
        ),
      );
    }
  }

  @override
  Future<Result<void>> cancelStudySession({
    required SessionId sessionId,
  }) async {
    try {
      final int updatedRows = await _dao.cancelStudySession(
        sessionId: sessionId,
        updatedAtMs: _nowMs,
      );
      if (updatedRows == 0) {
        return Result<void>.err(
          Failure.notFound(entity: 'study_session', id: sessionId),
        );
      }
      return const Result<void>.ok(null);
    } catch (error) {
      return Result<void>.err(
        Failure.storage(
          operation: StorageOp.write,
          cause: error.toString(),
          table: 'study_sessions',
        ),
      );
    }
  }

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
          throw _RuleViolation(
            Failure.finalization(sessionId: sessionId),
          );
        }

        final List<study_dao.StudySessionReviewItemsResult> itemRows =
            await _dao.loadSessionReviewItems(sessionId);
        if (itemRows.isEmpty) {
          throw _RuleViolation(Failure.finalization(sessionId: sessionId));
        }

        final List<study_dao.StudySessionAttemptsResult> attemptRows =
            await _dao.loadSessionAttempts(sessionId);
        final Map<String, List<study_dao.StudySessionAttemptsResult>>
        attemptsByItemId = <String, List<study_dao.StudySessionAttemptsResult>>{};
        for (final study_dao.StudySessionAttemptsResult row in attemptRows) {
          attemptsByItemId.putIfAbsent(
            row.sessionItemId,
            () => <study_dao.StudySessionAttemptsResult>[],
          ).add(row);
        }

        final int nowMs = _nowMs;
        for (final study_dao.StudySessionReviewItemsResult itemRow in itemRows) {
          if (itemRow.answeredAt == null) {
            throw _RuleViolation(Failure.finalization(sessionId: sessionId));
          }

          final List<study_dao.StudySessionAttemptsResult> itemAttempts =
              attemptsByItemId[itemRow.id] ?? const <study_dao.StudySessionAttemptsResult>[];
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
          final int dueAtMs = nowMs + _intervalForBox(nextBox).inMilliseconds;
          final int reviewCount = (progressRow?.reviewCount ?? 0) + 1;
          final int lapseCount = (progressRow?.lapseCount ?? 0) +
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
  }) async => recordStudySessionAnswerTransaction(
    dao: _dao,
    sessionId: sessionId,
    sessionItemId: sessionItemId,
    result: result,
    studyMode: studyMode,
    nowMs: _nowMs,
  );

  @override
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
  }) =>
      _createSession(
        dao: _dao,
        scope: scope,
        flashcardIds: flashcardIds,
        nowMs: _nowMs,
      );

  DateTime get _now => DateTime.now().toUtc();

  int get _nowMs => _now.millisecondsSinceEpoch;

}
