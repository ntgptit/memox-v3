import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/mappers/study_session_mapper.dart';
import 'package:memox/data/repositories/study_match_evaluations.dart';
import 'package:memox/data/repositories/study_session_card_actions.dart';
import 'package:memox/domain/entities/match_evaluation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/srs/box_intervals.dart';
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
       _mapper = mapper,
       _cardActions = StudySessionCardActions(dao) {
    // Share the one resolved IdGenerator instance with the collaborator (so an
    // injected/seeded generator drives both).
    _matchEvaluations = StudyMatchEvaluationActions(
      _dao,
      _idGenerator,
      _mapper,
    );
  }

  final StudySessionDao _dao;
  final IdGenerator _idGenerator;
  final StudySessionMapper _mapper;

  /// In-session bury/suspend actions (WBS 4.11.2), extracted as a data-layer
  /// collaborator to keep this file cohesive and within the line budget.
  final StudySessionCardActions _cardActions;

  /// Match-mode evaluation persistence (WBS 4.5.4), extracted likewise.
  late final StudyMatchEvaluationActions _matchEvaluations;

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

  @override
  Future<Result<void>> finalizeStudySession({
    required SessionId sessionId,
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
            message: 'Cannot finish a ${session.status} study session.',
          ),
          data: null,
        );
      }

      final List<StudySessionItemRow> items = await _dao.itemsForSession(
        sessionId,
      );
      if (items.isEmpty) {
        // A persisted session should always have items (createSession guards
        // this); an empty one is an integrity error, not a normal finalize.
        return (
          failure: const Failure.finalization(
            message: 'Study session has no items to finalize.',
          ),
          data: null,
        );
      }
      if (items.any((i) => i.answeredAt == null)) {
        // Every card must be answered before finishing — keep the session open.
        return (
          failure: const Failure.finalization(
            message: 'All cards must be answered before finishing the session.',
          ),
          data: null,
        );
      }

      // Compute each card's new SRS state from its attempts + current progress.
      // flashcard_progress is written ONLY here (box changes are finalization-
      // owned); suspend/bury state is preserved across the upsert.
      final List<FlashcardProgressCompanion> upserts =
          <FlashcardProgressCompanion>[];
      for (final StudySessionItemRow item in items) {
        final List<StudyAttemptRow> attempts = await _dao.attemptsForItem(
          item.id,
        );
        final AttemptResult terminal = _terminalResult(
          attempts.map((a) => _mapper.resultFromToken(a.result)).toList(),
        );
        final FlashcardProgressRow? progress = await _dao.progressById(
          item.flashcardId,
        );
        final int boxBefore = progress?.boxNumber ?? SrsBox.min;
        final int boxAfter = SrsBox.nextBox(boxBefore, terminal);
        upserts.add(
          FlashcardProgressCompanion.insert(
            flashcardId: item.flashcardId,
            boxNumber: Value<int>(boxAfter),
            dueAt: Value<int?>(_dueAtFor(now, boxAfter)),
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

      await _dao.finalizeSession(sessionId, upserts, now);
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

  @override
  Future<Result<void>> buryStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
    required int now,
  }) => _cardActions.apply(
    sessionId: sessionId,
    flashcardId: flashcardId,
    now: now,
    suspend: false,
  );

  @override
  Future<Result<void>> suspendStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
    required int now,
  }) => _cardActions.apply(
    sessionId: sessionId,
    flashcardId: flashcardId,
    now: now,
    suspend: true,
  );

  @override
  Future<Result<void>> recordMatchEvaluation({
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
  }) => _matchEvaluations.record(
    sessionId: sessionId,
    sessionItemId: sessionItemId,
    boardIndex: boardIndex,
    pairId: pairId,
    selectedFrontCellId: selectedFrontCellId,
    selectedBackCellId: selectedBackCellId,
    expectedFrontFlashcardId: expectedFrontFlashcardId,
    expectedBackFlashcardId: expectedBackFlashcardId,
    isCorrect: isCorrect,
    studyMode: studyMode,
    now: now,
  );

  @override
  Future<Result<List<MatchEvaluation>>> loadMatchEvaluations(
    SessionId sessionId,
  ) => _matchEvaluations.load(sessionId);

  @override
  Future<Result<StudySessionResult>> loadStudySessionResult({
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
        // integrity error, surfaced as a controlled failure (study.md
        // §LoadStudySessionResultUseCase).
        return (
          failure: Failure.validation(
            field: 'sessionItems',
            code: ValidationCode.insufficientContent,
            message: 'Study session $id has no items.',
          ),
          data: null,
        );
      }

      final List<FlashcardRow> cards = await _dao.flashcardsByIds(
        items.map((StudySessionItemRow i) => i.flashcardId),
      );
      final Map<String, FlashcardRow> cardById = <String, FlashcardRow>{
        for (final FlashcardRow card in cards) card.id: card,
      };

      final List<StudySessionResultItem> resultItems =
          <StudySessionResultItem>[];
      for (final StudySessionItemRow item in items) {
        final List<StudyAttemptRow> attempts = await _dao.attemptsForItem(
          item.id,
        );
        // Unanswered items have no attempts → null terminal result (defensive:
        // a completed session always has every item answered per the
        // finalizeStudySession guard, but this read path stays valid mid-session
        // too); otherwise reuse the same last-attempt classifier finalization
        // uses so the result screen and the persisted SRS outcome never disagree.
        final AttemptResult? terminal = attempts.isEmpty
            ? null
            : _terminalResult(
                attempts.map((a) => _mapper.resultFromToken(a.result)).toList(),
              );
        resultItems.add(
          _mapper.toResultItem(item, cardById[item.flashcardId]!, terminal),
        );
      }

      return (
        failure: null,
        data: StudySessionResult(
          session: _mapper.toEntity(sessionRow),
          items: resultItems,
        ),
      );
    } catch (error) {
      return (
        failure: Failure.storage(
          operation: StorageOp.read,
          table: 'study_attempts',
          cause: error.toString(),
        ),
        data: null,
      );
    }
  }

  /// The terminal SRS result for an item from its ordered [attempts] — the V1
  /// last-attempt classifier (`docs/business/srs/srs-review.md` §Box transition
  /// table): a last `forgot` finalizes `forgot`; an earlier `forgot` with a
  /// passing last attempt finalizes `recovered`; otherwise the last result.
  /// (V1 records one attempt per item, so this is that attempt's result.)
  AttemptResult _terminalResult(List<AttemptResult> attempts) {
    if (attempts.isEmpty) {
      // Unreachable in V1 (an answered item always has one recorded attempt);
      // defensive so a malformed row never throws inside the transaction.
      return AttemptResult.forgot;
    }
    // TODO(retry-modes): when retry/re-queue modes land, switch this to the
    // FIRST-attempt classifier (a first `forgot` finalizes `forgot` even after a
    // re-queued pass) — see srs-review.md §C1 adopted decision (2026-06-10).
    final AttemptResult last = attempts.last;
    if (last == AttemptResult.forgot) {
      return AttemptResult.forgot;
    }
    if (attempts.contains(AttemptResult.forgot)) {
      return AttemptResult.recovered;
    }
    return last;
  }

  /// The due time for a card entering [box] when finalized at [nowMs]:
  /// `localMidnight(studyDay + interval[box])` (WBS 4.6.4). Computed in Dart
  /// (local time), never via a SQLite `localtime` modifier, so "due today"
  /// counts stay stable across the day.
  int _dueAtFor(int nowMs, int box) {
    final DateTime nowLocal = DateTime.fromMillisecondsSinceEpoch(
      nowMs,
    ).toLocal();
    final DateTime studyDayMidnight = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
    );
    final DateTime due = studyDayMidnight.add(
      Duration(days: BoxIntervals.daysFor(box)),
    );
    return due.millisecondsSinceEpoch;
  }
}
