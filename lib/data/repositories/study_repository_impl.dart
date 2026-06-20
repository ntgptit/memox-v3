import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/mappers/study_session_mapper.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/srs/srs_box.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';

/// Drift-backed [StudyRepository] (WBS 4.0.1 retention sweep + WBS 4.2.1 session
/// creation + WBS 4.10.1 cancel).
///
/// Owns the stale-session retention sweep, the transactional session+items
/// insert, and the cancel (status→`cancelled`, never delete) operation,
/// delegating row mutation to [StudySessionDao]. Grading / finalization / SRS
/// transitions land with later study use cases (WBS 4.4.x+).
class StudyRepositoryImpl implements StudyRepository {
  StudyRepositoryImpl({
    required StudySessionDao dao,
    IdGenerator? idGenerator,
    StudySessionMapper mapper = const StudySessionMapper(),
  }) : _dao = dao,
       _idGenerator = idGenerator ?? IdGenerator(),
       _mapper = mapper;

  final StudySessionDao _dao;
  final IdGenerator _idGenerator;
  final StudySessionMapper _mapper;

  @override
  Future<Result<int>> expireOldSessions({required int now}) async {
    try {
      final int cutoff = now - StudyRepository.resumeWindow.inMilliseconds;
      final int cancelled = await _dao.cancelSessionsUpdatedBefore(cutoff);
      return (failure: null, data: cancelled);
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.write,
          table: 'study_sessions',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
    required int now,
  }) async {
    // Defensive mirror of the use-case guard (CreateStudySessionUseCase): never
    // persist a session with no items even if called directly.
    if (flashcardIds.isEmpty) {
      return (
        failure: const Failure.validation(
          field: 'flashcardIds',
          code: ValidationCode.insufficientContent,
          message: 'Cannot create a study session with no cards.',
        ),
        data: null,
      );
    }

    final String sessionId = _idGenerator.newId();
    // V1 persists a new session directly as in_progress (study-flow.md
    // §Session lifecycle); status is never `draft` on create.
    const SessionStatus status = SessionStatus.inProgress;

    final session = StudySessionsCompanion.insert(
      id: sessionId,
      entryType: _mapper.entryTypeToken(scope.entryType),
      studyType: _mapper.studyTypeToken(scope.studyType),
      status: _mapper.statusToken(status),
      startedAt: now,
      updatedAt: now,
      entryRefId: Value<String?>(scope.entryRefId),
    );

    final List<StudySessionItemsCompanion> items = <StudySessionItemsCompanion>[
      for (final (int index, FlashcardId flashcardId) in flashcardIds.indexed)
        StudySessionItemsCompanion.insert(
          id: _idGenerator.newId(),
          sessionId: sessionId,
          flashcardId: flashcardId,
          sortOrder: index,
          createdAt: now,
          updatedAt: now,
        ),
    ];

    try {
      await _dao.createSessionWithItems(session, items);
      return (
        failure: null,
        data: StudySession(
          id: sessionId,
          scope: scope,
          status: status,
          startedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
        ),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.transaction,
          table: 'study_sessions',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<void>> cancelSession({required SessionId id}) async {
    try {
      final int updated = await _dao.markCancelled(id);
      if (updated > 0) {
        return (failure: null, data: null);
      }
      // No resumable row updated: distinguish a missing session from one in a
      // terminal state (completed / cancelled / failed_to_finalize), which is a
      // forbidden transition (study-repository.md §Constraints).
      final StudySessionRow? row = await _dao.sessionById(id);
      if (row == null) {
        return (
          failure: const Failure.notFound(entity: 'study_session'),
          data: null,
        );
      }
      return (
        failure: Failure.unsupportedAction(
          message: 'Cannot cancel a ${row.status} study session.',
        ),
        data: null,
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.write,
          table: 'study_sessions',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<StudySessionReview>> loadStudySessionReview({
    required SessionId id,
  }) async {
    try {
      final StudySessionRow? sessionRow = await _dao.sessionById(id);
      if (sessionRow == null) {
        return (
          failure: const Failure.notFound(entity: 'study_session'),
          data: null,
        );
      }

      final List<StudySessionItemRow> items = await _dao.itemsForSession(id);
      if (items.isEmpty) {
        // A persisted session must always have items; an empty list is an
        // integrity error, surfaced as a controlled failure.
        return (
          failure: Failure.validation(
            field: 'sessionItems',
            code: ValidationCode.insufficientContent,
            message: 'Study session $id has no items.',
          ),
          data: null,
        );
      }

      // Pair each ordered item with its flashcard (loaded in one IN query). FK
      // cascade guarantees every item's flashcard still exists.
      final List<FlashcardRow> cards = await _dao.flashcardsByIds(
        items.map((StudySessionItemRow i) => i.flashcardId),
      );
      final Map<String, FlashcardRow> cardById = <String, FlashcardRow>{
        for (final FlashcardRow card in cards) card.id: card,
      };

      return (
        failure: null,
        data: StudySessionReview(
          session: _mapper.toEntity(sessionRow),
          items: <StudySessionReviewItem>[
            for (final StudySessionItemRow item in items)
              _mapper.toReviewItem(item, cardById[item.flashcardId]!),
          ],
        ),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'study_session_items',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<void>> recordStudySessionAnswer({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
    required int now,
  }) async {
    try {
      final StudySessionRow? session = await _dao.sessionById(sessionId);
      if (session == null) {
        return (
          failure: const Failure.notFound(entity: 'study_session'),
          data: null,
        );
      }
      if (session.status != StudySessionDao.statusDraft &&
          session.status != StudySessionDao.statusInProgress) {
        return (
          failure: Failure.unsupportedAction(
            message: 'Cannot answer in a ${session.status} study session.',
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
      if (item.answeredAt != null) {
        return (
          failure: const Failure.unsupportedAction(
            message: 'This card has already been answered.',
          ),
          data: null,
        );
      }

      // box_before is the card's current box (a card with no progress row is a
      // new card at box 1); box_after is the Leitner transition recorded on the
      // attempt. flashcard_progress itself is untouched (finalization owns it).
      final int boxBefore =
          await _dao.flashcardProgressBox(item.flashcardId) ?? SrsBox.min;
      final int boxAfter = SrsBox.nextBox(boxBefore, result);

      await _dao.recordAnswer(
        attempt: StudyAttemptsCompanion.insert(
          id: _idGenerator.newId(),
          sessionItemId: sessionItemId,
          result: _mapper.resultToken(result),
          studyMode: _mapper.studyModeToken(studyMode),
          boxBefore: Value<int>(boxBefore),
          boxAfter: Value<int>(boxAfter),
          attemptedAt: now,
        ),
        sessionItemId: sessionItemId,
        sessionId: sessionId,
        answeredAt: now,
        updatedAt: now,
      );
      return (failure: null, data: null);
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.transaction,
          table: 'study_attempts',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  @override
  Future<Result<StudySession?>> findResumable({
    required StudyScope scope,
    required int now,
  }) async {
    try {
      final int cutoff = now - StudyRepository.resumeWindow.inMilliseconds;
      final StudySessionRow? row = await _dao.findResumableSession(
        entryType: _mapper.entryTypeToken(scope.entryType),
        entryRefId: scope.entryRefId,
        cutoff: cutoff,
      );
      return (failure: null, data: row == null ? null : _mapper.toEntity(row));
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'study_sessions',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }
}
