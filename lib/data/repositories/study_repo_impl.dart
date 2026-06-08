import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart'
    as study_dao;
import 'package:memox/data/mappers/flashcard_mapper.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

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
      final _ScopeSnapshot snapshot = await _loadScopeSnapshot(scope);
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
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
  }) async {
    if (flashcardIds.isEmpty) {
      return const Result<StudySession>.err(
        Failure.validation(
          field: 'flashcardIds',
          code: ValidationCode.insufficientContent,
        ),
      );
    }

    try {
      final StudySession? session = await _dao.transaction(() async {
        final int nowMs = _nowMs;
        final String sessionId = IdGenerator.newId();
        await _dao.insertStudySession(
          StudySessionsCompanion.insert(
            id: sessionId,
            entryType: scope.entryType.name,
            entryRefId: Value<String?>(scope.entryRefId),
            studyType: StudyMapper.studyTypeToStorage(scope.studyType),
            status: StudyMapper.sessionStatusToStorage(
              SessionStatus.inProgress,
            ),
            startedAt: nowMs,
            updatedAt: nowMs,
          ),
        );
        for (int index = 0; index < flashcardIds.length; index++) {
          await _dao.insertStudySessionItem(
            StudySessionItemsCompanion.insert(
              id: IdGenerator.newId(),
              sessionId: sessionId,
              flashcardId: flashcardIds[index],
              sortOrder: index,
              createdAt: nowMs,
              updatedAt: nowMs,
            ),
          );
        }
        final StudySessionRow? row = await _dao.findSession(sessionId);
        return row == null ? null : StudyMapper.fromSessionRow(row);
      });

      if (session == null) {
        return const Result<StudySession>.err(
          Failure.storage(
            operation: StorageOp.write,
            cause: 'Session insert returned null.',
            table: 'study_sessions',
          ),
        );
      }
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

  Future<_ScopeSnapshot> _loadScopeSnapshot(StudyScope scope) async {
    if (scope.entryType == EntryType.today) {
      return _ScopeSnapshot(
        cards: (await _dao.loadTodayCards())
            .map(_ScopeCard.fromTodayRow)
            .toList(growable: false),
        now: _now,
      );
    }

    final String? refId = scope.entryRefId;
    if (refId == null) {
      throw const _RuleViolation(
        Failure.validation(field: 'entryRefId', code: ValidationCode.empty),
      );
    }

    if (scope.entryType == EntryType.deck) {
      if (await _dao.findDeck(refId) == null) {
        throw _RuleViolation(Failure.notFound(entity: 'deck', id: refId));
      }
      return _ScopeSnapshot(
        cards: (await _dao.loadDeckCards(
          refId,
        )).map(_ScopeCard.fromDeckRow).toList(growable: false),
        now: _now,
      );
    }

    if (await _dao.findFolder(refId) == null) {
      throw _RuleViolation(Failure.notFound(entity: 'folder', id: refId));
    }
    return _ScopeSnapshot(
      cards: (await _dao.loadFolderCards(
        refId,
      )).map(_ScopeCard.fromFolderRow).toList(growable: false),
      now: _now,
    );
  }

  List<FlashcardId> _eligibleFlashcardIds({
    required StudyScope scope,
    required _ScopeSnapshot snapshot,
  }) {
    final DateTime now = snapshot.now;
    return snapshot.cards
        .where((card) => card.isVisible(now))
        .where(
          (card) => switch (scope.studyType) {
            StudyType.newCards => card.isNewEligible(now),
            StudyType.srsReview => card.isDueEligible(now),
          },
        )
        .map((card) => card.flashcardId)
        .toList(growable: false);
  }

  StudyEntryEmptyState? _resolveEmptyState({
    required StudyScope scope,
    required _ScopeSnapshot snapshot,
  }) {
    final DateTime now = snapshot.now;
    final List<_ScopeCard> cards = snapshot.cards;
    if (cards.isEmpty) {
      return StudyEntryEmptyState(
        variant: switch (scope.entryType) {
          EntryType.today => StudyEntryEmptyVariant.todayNoContent,
          EntryType.deck => StudyEntryEmptyVariant.deckNoCards,
          EntryType.folder => StudyEntryEmptyVariant.folderNoCards,
        },
      );
    }

    final int suspendedCount = cards.where((card) => card.isSuspended).length;
    if (suspendedCount == cards.length) {
      return const StudyEntryEmptyState(
        variant: StudyEntryEmptyVariant.allSuspended,
      );
    }

    final int buriedCount = cards.where((card) => card.isBuried(now)).length;
    if (buriedCount == cards.length) {
      return const StudyEntryEmptyState(
        variant: StudyEntryEmptyVariant.allBuried,
      );
    }

    final List<_ScopeCard> eligibleCards = _eligibleCards(
      scope: scope,
      snapshot: snapshot,
    );
    if (eligibleCards.isNotEmpty) {
      return null;
    }

    return StudyEntryEmptyState(
      variant: switch (scope.entryType) {
        EntryType.today => StudyEntryEmptyVariant.todayAllDone,
        EntryType.deck => switch (scope.studyType) {
          StudyType.newCards => StudyEntryEmptyVariant.deckNoCards,
          StudyType.srsReview => StudyEntryEmptyVariant.deckNoDueCards,
        },
        EntryType.folder => switch (scope.studyType) {
          StudyType.newCards => StudyEntryEmptyVariant.folderNoCards,
          StudyType.srsReview => StudyEntryEmptyVariant.folderNoDueCards,
        },
      },
      nextDueAt: scope.studyType == StudyType.srsReview
          ? _nextDueAt(cards, now)
          : null,
    );
  }

  List<_ScopeCard> _eligibleCards({
    required StudyScope scope,
    required _ScopeSnapshot snapshot,
  }) {
    final DateTime now = snapshot.now;
    return snapshot.cards
        .where((card) => card.isVisible(now))
        .where(
          (card) => switch (scope.studyType) {
            StudyType.newCards => card.isNewEligible(now),
            StudyType.srsReview => card.isDueEligible(now),
          },
        )
        .toList(growable: false);
  }

  DateTime? _nextDueAt(List<_ScopeCard> cards, DateTime now) {
    final Iterable<DateTime> futureDue = cards
        .where((card) => card.isVisible(now) && card.dueAt != null)
        .map((card) => card.dueAt!)
        .where((DateTime dueAt) => dueAt.isAfter(now));
    if (futureDue.isEmpty) {
      return null;
    }
    return futureDue.reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b);
  }

  DateTime get _now => DateTime.now().toUtc();

  int get _nowMs => _now.millisecondsSinceEpoch;

  StudySessionReviewItem _fromSessionReviewRow(
    study_dao.StudySessionReviewItemsResult row,
  ) =>
      StudySessionReviewItem(
        sessionItem: StudyMapper.sessionItemFromStorageFields(
          id: row.id,
          sessionId: row.sessionId,
          flashcardId: row.flashcardId,
          sortOrder: row.sortOrder,
          answeredAt: row.answeredAt,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        ),
        flashcard: FlashcardMapper.fromStorageFields(
          id: row.cardId,
          deckId: row.deckId,
          front: row.front,
          back: row.back,
          exampleSentence: row.exampleSentence,
          pronunciation: row.pronunciation,
          hint: row.hint,
          sortOrder: row.cardSortOrder,
          createdAt: row.cardCreatedAt,
          updatedAt: row.cardUpdatedAt,
        ),
      );
}

class _RuleViolation implements Exception {
  const _RuleViolation(this.failure);

  final Failure failure;
}

class _ScopeSnapshot {
  const _ScopeSnapshot({required this.cards, required this.now});

  final List<_ScopeCard> cards;
  final DateTime now;
}

class _ScopeCard {
  const _ScopeCard({
    required this.flashcardId,
    required this.boxNumber,
    required this.dueAt,
    required this.buriedUntil,
    required this.isSuspended,
  });

  factory _ScopeCard.fromDeckRow(study_dao.StudyDeckCardsResult row) =>
      _ScopeCard(
    flashcardId: row.id,
    boxNumber: row.boxNumber,
    dueAt: row.dueAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row.dueAt!, isUtc: true),
    buriedUntil: row.buriedUntil == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row.buriedUntil!, isUtc: true),
    isSuspended: row.isSuspended ?? false,
  );

  factory _ScopeCard.fromFolderRow(study_dao.StudyFolderCardsResult row) =>
      _ScopeCard.fromDeckRow(
        study_dao.StudyDeckCardsResult(
          id: row.id,
          boxNumber: row.boxNumber,
          dueAt: row.dueAt,
          buriedUntil: row.buriedUntil,
          isSuspended: row.isSuspended,
        ),
      );

  factory _ScopeCard.fromTodayRow(study_dao.StudyTodayCardsResult row) =>
      _ScopeCard.fromDeckRow(
        study_dao.StudyDeckCardsResult(
          id: row.id,
          boxNumber: row.boxNumber,
          dueAt: row.dueAt,
          buriedUntil: row.buriedUntil,
          isSuspended: row.isSuspended,
        ),
      );

  final FlashcardId flashcardId;
  final int? boxNumber;
  final DateTime? dueAt;
  final DateTime? buriedUntil;
  final bool isSuspended;

  bool isBuried(DateTime now) =>
      buriedUntil != null && buriedUntil!.isAfter(now);

  bool isVisible(DateTime now) => !isSuspended && !isBuried(now);

  bool isDueEligible(DateTime now) =>
      isVisible(now) && dueAt != null && !dueAt!.isAfter(now);

  bool isNewEligible(DateTime now) =>
      isVisible(now) && (boxNumber == null || boxNumber! <= 1);
}
