part of 'study_repo_impl.dart';

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
  required int dailyNewLimit,
}) => _eligibleCards(
  scope: scope,
  snapshot: snapshot,
  dailyNewLimit: dailyNewLimit,
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
  required int dailyNewLimit,
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
    dailyNewLimit: dailyNewLimit,
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
  required int dailyNewLimit,
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
