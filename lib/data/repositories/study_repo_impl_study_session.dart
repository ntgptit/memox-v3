part of 'study_repo_impl.dart';

Future<StudySession> _persistSession({
  required study_dao.StudySessionDao dao,
  required StudyScope scope,
  required List<FlashcardId> flashcardIds,
  required int nowMs,
}) async {
  final String sessionId = IdGenerator.newId();
  await dao.insertStudySession(
    StudySessionsCompanion.insert(
      id: sessionId,
      entryType: scope.entryType.name,
      entryRefId: Value<String?>(scope.entryRefId),
      studyType: StudyMapper.studyTypeToStorage(scope.studyType),
      status: StudyMapper.sessionStatusToStorage(SessionStatus.inProgress),
      startedAt: nowMs,
      updatedAt: nowMs,
    ),
  );
  for (int index = 0; index < flashcardIds.length; index++) {
    await dao.insertStudySessionItem(
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
  final StudySessionRow? row = await dao.findSession(sessionId);
  if (row == null) {
    throw StateError('Session insert returned null.');
  }
  return StudyMapper.fromSessionRow(row);
}

StudySessionReviewItem _fromSessionReviewRow(
  study_dao.StudySessionReviewItemsResult row,
) => StudySessionReviewItem(
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

Future<Result<StudySessionResult>> _loadStudySessionResult(
  study_dao.StudySessionDao dao,
  SessionId sessionId,
) async {
  try {
    final StudySessionRow? sessionRow = await dao.findSession(sessionId);
    if (sessionRow == null) {
      return Result<StudySessionResult>.err(
        Failure.notFound(entity: 'study_session', id: sessionId),
      );
    }

    final List<study_dao.StudySessionReviewItemsResult> itemRows = await dao
        .loadSessionReviewItems(sessionId);
    if (itemRows.isEmpty) {
      return const Result<StudySessionResult>.err(
        Failure.storage(
          operation: StorageOp.read,
          cause: 'Study session has no items.',
          table: 'study_session_items',
        ),
      );
    }

    final List<study_dao.StudySessionAttemptsResult> attemptRows = await dao
        .loadSessionAttempts(sessionId);
    final Map<String, List<study_dao.StudySessionAttemptsResult>>
    attemptsByItemId = <String, List<study_dao.StudySessionAttemptsResult>>{};
    for (final study_dao.StudySessionAttemptsResult row in attemptRows) {
      attemptsByItemId
          .putIfAbsent(
            row.sessionItemId,
            () => <study_dao.StudySessionAttemptsResult>[],
          )
          .add(row);
    }

    final bool isCompleted =
        StudyMapper.sessionStatusFromStorage(sessionRow.status) ==
        SessionStatus.completed;
    int answeredCount = 0;
    int forgotCount = 0;
    int passedCount = 0;
    for (final study_dao.StudySessionReviewItemsResult itemRow in itemRows) {
      if (itemRow.answeredAt != null) {
        answeredCount++;
      }
      final List<study_dao.StudySessionAttemptsResult> itemAttempts =
          attemptsByItemId[itemRow.id] ??
          const <study_dao.StudySessionAttemptsResult>[];
      if (isCompleted && itemRow.answeredAt != null && itemAttempts.isEmpty) {
        return const Result<StudySessionResult>.err(
          Failure.storage(
            operation: StorageOp.read,
            cause: 'Completed study session is missing attempts.',
            table: 'study_attempts',
          ),
        );
      }
      if (itemAttempts.isEmpty) {
        continue;
      }
      final AttemptResult finalResult = _finalizeResultForAttempts(
        itemAttempts,
      );
      switch (finalResult) {
        case AttemptResult.forgot:
          forgotCount++;
        case AttemptResult.perfect:
        case AttemptResult.initialPassed:
        case AttemptResult.recovered:
          passedCount++;
      }
    }

    return Result<StudySessionResult>.ok(
      StudySessionResult(
        session: StudyMapper.fromSessionRow(sessionRow),
        totalCount: itemRows.length,
        answeredCount: answeredCount,
        forgotCount: forgotCount,
        passedCount: passedCount,
      ),
    );
  } catch (error) {
    return Result<StudySessionResult>.err(
      Failure.storage(
        operation: StorageOp.read,
        cause: error.toString(),
        table: 'study_sessions',
      ),
    );
  }
}

Future<String?> _resolveResumableScopeLabel(
  StudySessionRow row,
  study_dao.StudySessionDao dao,
) async {
  switch (StudyMapper.entryTypeFromStorage(row.entryType)) {
    case EntryType.today:
      return null;
    case EntryType.deck:
      final DeckRow? deckRow = await dao.findDeck(row.entryRefId ?? '');
      return deckRow?.name;
    case EntryType.folder:
      final FolderRow? folderRow = await dao.findFolder(row.entryRefId ?? '');
      return folderRow?.name;
  }
}

AttemptResult _finalizeResultForAttempts(
  List<study_dao.StudySessionAttemptsResult> attempts,
) {
  final List<AttemptResult> results = attempts
      .map(
        (study_dao.StudySessionAttemptsResult row) =>
            StudyMapper.attemptResultFromStorage(row.result),
      )
      .toList(growable: false);
  final AttemptResult lastResult = results.last;
  if (lastResult == AttemptResult.forgot) {
    return AttemptResult.forgot;
  }
  if (results.any((AttemptResult result) => result == AttemptResult.forgot)) {
    return AttemptResult.recovered;
  }
  return lastResult;
}

Future<void> _finalizeMatchStudySession({
  required study_dao.StudySessionDao dao,
  required SessionId sessionId,
  required List<study_dao.StudySessionReviewItemsResult> itemRows,
  required DateTime now,
}) async {
  final List<StudyMatchEvaluationsRow> evaluationRows = await dao
      .loadMatchEvaluations(sessionId);
  final Map<String, List<StudyMatchEvaluationsRow>> evaluationsByItemId =
      <String, List<StudyMatchEvaluationsRow>>{};
  for (final StudyMatchEvaluationsRow row in evaluationRows) {
    evaluationsByItemId
        .putIfAbsent(row.sessionItemId, () => <StudyMatchEvaluationsRow>[])
        .add(row);
  }

  final int nowMs = now.millisecondsSinceEpoch;
  for (final study_dao.StudySessionReviewItemsResult itemRow in itemRows) {
    final List<StudyMatchEvaluationsRow> itemEvaluations =
        evaluationsByItemId[itemRow.id] ?? const <StudyMatchEvaluationsRow>[];
    final AttemptResult finalResult = _finalizeResultForMatchEvaluations(
      itemEvaluations,
    );
    final FlashcardProgressRow? progressRow = await dao.findFlashcardProgress(
      itemRow.flashcardId,
    );
    final int currentBox = progressRow?.boxNumber ?? 1;
    final int nextBox = _boxAfterFinalization(currentBox, finalResult);
    final int dueAtMs = _dueAtForInterval(now, nextBox);
    final int reviewCount = (progressRow?.reviewCount ?? 0) + 1;
    final int lapseCount =
        (progressRow?.lapseCount ?? 0) +
        (finalResult == AttemptResult.forgot ? 1 : 0);

    await dao.insertStudyAttempt(
      StudyAttemptsCompanion.insert(
        id: IdGenerator.newId(),
        sessionItemId: itemRow.id,
        result: StudyMapper.attemptResultToStorage(finalResult),
        studyMode: StudyMapper.studyModeToStorage(StudyMode.match),
        boxBefore: Value<int>(currentBox),
        boxAfter: Value<int>(nextBox),
        attemptedAt: nowMs,
      ),
    );
    await dao.markStudySessionItemAnswered(
      sessionItemId: itemRow.id,
      answeredAtMs: nowMs,
      updatedAtMs: nowMs,
    );

    if (progressRow == null) {
      await dao.insertFlashcardProgress(
        FlashcardProgressCompanion.insert(flashcardId: itemRow.flashcardId),
      );
    }

    final int updatedRows = await dao.updateFlashcardProgress(
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

AttemptResult _finalizeResultForMatchEvaluations(
  List<StudyMatchEvaluationsRow> evaluations,
) {
  bool sawWrongBeforeCorrect = false;
  for (final StudyMatchEvaluationsRow row in evaluations) {
    if (row.isCorrect) {
      return sawWrongBeforeCorrect
          ? AttemptResult.forgot
          : AttemptResult.perfect;
    }
    sawWrongBeforeCorrect = true;
  }
  return AttemptResult.forgot;
}

int _boxAfterFinalization(int currentBox, AttemptResult result) =>
    switch (result) {
      AttemptResult.perfect ||
      AttemptResult.initialPassed => currentBox >= 8 ? 8 : currentBox + 1,
      AttemptResult.recovered => currentBox,
      AttemptResult.forgot => 1,
    };

int _dueAtForInterval(DateTime now, int boxNumber) {
  final DateTime localNow = now.toLocal();
  final DateTime localStudyDayStart = DateTime(
    localNow.year,
    localNow.month,
    localNow.day,
  );
  return localStudyDayStart
      .add(_intervalForBox(boxNumber))
      .millisecondsSinceEpoch;
}

Duration _intervalForBox(int boxNumber) => switch (boxNumber) {
  1 => const Duration(days: 1),
  2 => const Duration(days: 2),
  3 => const Duration(days: 3),
  4 => const Duration(days: 4),
  5 => const Duration(days: 5),
  6 => const Duration(days: 12),
  7 => const Duration(days: 30),
  8 => const Duration(days: 60),
  _ => throw ArgumentError.value(boxNumber, 'boxNumber', 'Expected 1..8'),
};

class _RuleViolation implements Exception {
  const _RuleViolation(this.failure);

  final Failure failure;
}

class _ScopeSnapshot {
  const _ScopeSnapshot({
    required this.cards,
    required this.now,
    required this.consumedNewFlashcardIdsToday,
  });

  final List<_ScopeCard> cards;
  final DateTime now;
  final Set<FlashcardId> consumedNewFlashcardIdsToday;
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
            : DateTime.fromMillisecondsSinceEpoch(
                row.buriedUntil!,
                isUtc: true,
              ),
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

Future<_ScopeSnapshot> _loadScopeSnapshot(
  study_dao.StudySessionDao dao,
  StudyScope scope, {
  required DateTime now,
}) async {
  final Set<FlashcardId> consumedNewFlashcardIdsToday =
      scope.studyType == StudyType.newCards
      ? await _loadConsumedNewFlashcardIdsToday(dao, now)
      : const <FlashcardId>{};

  if (scope.entryType == EntryType.today) {
    return _ScopeSnapshot(
      cards: (await dao.loadTodayCards())
          .map(_ScopeCard.fromTodayRow)
          .toList(growable: false),
      now: now,
      consumedNewFlashcardIdsToday: consumedNewFlashcardIdsToday,
    );
  }

  final String? refId = scope.entryRefId;
  if (refId == null) {
    throw const _RuleViolation(
      Failure.validation(field: 'entryRefId', code: ValidationCode.empty),
    );
  }

  if (scope.entryType == EntryType.deck) {
    if (await dao.findDeck(refId) == null) {
      throw _RuleViolation(Failure.notFound(entity: 'deck', id: refId));
    }
    return _ScopeSnapshot(
      cards: (await dao.loadDeckCards(
        refId,
      )).map(_ScopeCard.fromDeckRow).toList(growable: false),
      now: now,
      consumedNewFlashcardIdsToday: consumedNewFlashcardIdsToday,
    );
  }

  if (await dao.findFolder(refId) == null) {
    throw _RuleViolation(Failure.notFound(entity: 'folder', id: refId));
  }
  return _ScopeSnapshot(
    cards: (await dao.loadFolderCards(
      refId,
    )).map(_ScopeCard.fromFolderRow).toList(growable: false),
    now: now,
    consumedNewFlashcardIdsToday: consumedNewFlashcardIdsToday,
  );
}

List<FlashcardId> _eligibleFlashcardIds({
  required StudyScope scope,
  required _ScopeSnapshot snapshot,
}) => _eligibleCards(
  scope: scope,
  snapshot: snapshot,
).take(maxSessionItems).map((card) => card.flashcardId).toList(growable: false);

List<FlashcardId> _capSessionFlashcardIds(List<FlashcardId> flashcardIds) {
  if (flashcardIds.length <= maxSessionItems) {
    return flashcardIds;
  }
  return flashcardIds.take(maxSessionItems).toList(growable: false);
}

Future<Set<FlashcardId>> _loadConsumedNewFlashcardIdsToday(
  study_dao.StudySessionDao dao,
  DateTime now,
) async {
  final DateTime localNow = now.toLocal();
  final DateTime localDayStart = DateTime(
    localNow.year,
    localNow.month,
    localNow.day,
  );
  final DateTime localDayEnd = localDayStart.add(const Duration(days: 1));
  final int localDayStartMs = localDayStart.millisecondsSinceEpoch;
  final int localDayEndMs = localDayEnd.millisecondsSinceEpoch;
  final rows =
      await (dao.select(dao.studySessionItems).join([
            innerJoin(
              dao.studySessions,
              dao.studySessionItems.sessionId.equalsExp(dao.studySessions.id),
            ),
          ])..where(
            dao.studySessions.studyType.equals(
                  StudyMapper.studyTypeToStorage(StudyType.newCards),
                ) &
                dao.studySessions.startedAt.isBiggerOrEqualValue(
                  localDayStartMs,
                ) &
                dao.studySessions.startedAt.isSmallerThanValue(localDayEndMs),
          ))
          .get();
  return rows
      .map((row) => row.readTable(dao.studySessionItems).flashcardId)
      .toSet();
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
  final Set<FlashcardId> consumedIds = snapshot.consumedNewFlashcardIdsToday;
  final List<_ScopeCard> eligibleCards = snapshot.cards
      .where((card) => card.isVisible(now))
      .where(
        (card) => switch (scope.studyType) {
          StudyType.newCards => card.isNewEligible(now),
          StudyType.srsReview => card.isDueEligible(now),
        },
      )
      .where((card) => !consumedIds.contains(card.flashcardId))
      .toList(growable: false);

  if (scope.studyType == StudyType.newCards) {
    final int remainingDailyQuota = dailyNewLimit - consumedIds.length;
    if (remainingDailyQuota <= 0) {
      return const <_ScopeCard>[];
    }
    return eligibleCards.take(remainingDailyQuota).toList(growable: false);
  }

  return eligibleCards;
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
