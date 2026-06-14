part of 'study_repository_test.dart';

void defineStudyRepositoryTestFinalization() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;
  late StudySessionDao dao;
  late DateTime now;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = StudySessionDao(db);
    _studyTestNow = DateTime(2026, 1, 15, 15, 30);
    now = _studyTestNow;
    repository = StudyRepositoryImpl(dao, now: () => _studyTestNow);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'recordStudySessionAnswer persists fill mode as a single terminal attempt and rejects a duplicate answer',
    () async {
      const String folderId = 'folder-fill-answer';
      const String deckId = 'deck-fill-answer';
      const String cardId = 'card-fill-answer';
      const String sessionId = 'session-fill-answer';
      const String sessionItemId = 'item-fill-answer';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 5,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final Result<void> firstResult = await repository
          .recordStudySessionAnswer(
            sessionId: sessionId,
            sessionItemId: sessionItemId,
            result: AttemptResult.recovered,
            studyMode: StudyMode.fill,
          );
      final Result<void> duplicateResult = await repository
          .recordStudySessionAnswer(
            sessionId: sessionId,
            sessionItemId: sessionItemId,
            result: AttemptResult.forgot,
            studyMode: StudyMode.fill,
          );

      expect(firstResult.isOk, isTrue);
      expect(duplicateResult.isErr, isTrue);
      expect(duplicateResult.failureOrNull, isA<UnsupportedActionFailure>());

      final StudyAttemptRow attempt = await db
          .select(db.studyAttempts)
          .getSingle();
      final StudySessionItemRow answeredItem = await db
          .select(db.studySessionItems)
          .getSingle();

      expect(attempt.result, 'recovered');
      expect(attempt.studyMode, 'fill');
      expect(attempt.boxBefore, 5);
      expect(attempt.boxAfter, 5);
      expect(answeredItem.answeredAt != null, isTrue);
      expect(await db.select(db.studyAttempts).get(), hasLength(1));
    },
  );

  test(
    'recordStudySessionAnswer rolls back attempt and answered_at when the transaction fails',
    () async {
      const String folderId = 'folder-answer-fail';
      const String deckId = 'deck-answer-fail';
      const String cardId = 'card-answer-fail';
      const String sessionId = 'session-answer-fail';
      const String sessionItemId = 'item-answer-fail';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 2,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );

      repository = StudyRepositoryImpl(_ThrowingStudySessionDao(db));

      final Result<void> result = await repository.recordStudySessionAnswer(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        result: AttemptResult.forgot,
        studyMode: StudyMode.recall,
      );

      expect(result.isErr, isTrue);
      expect(await db.select(db.studyAttempts).get(), isEmpty);
      expect(
        (await db.select(db.studySessionItems).getSingle()).answeredAt == null,
        isTrue,
      );
      expect((await db.select(db.flashcardProgress).getSingle()).boxNumber, 2);
    },
  );

  test(
    'recordMatchEvaluation persists append-only rows in order without updating answered_at or flashcard_progress',
    () async {
      const String folderId = 'folder-match-record';
      const String deckId = 'deck-match-record';
      const String cardId = 'card-match-record';
      const String sessionId = 'session-match-record';
      const String sessionItemId = 'item-match-record';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 3,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final Result<void> firstResult = await repository.recordMatchEvaluation(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        flashcardId: cardId,
        boardIndex: 0,
        pairId: 'pair-0',
        selectedFrontCellId: 'front-0',
        selectedBackCellId: 'back-0',
        expectedFrontFlashcardId: cardId,
        expectedBackFlashcardId: cardId,
        isCorrect: false,
        studyMode: StudyMode.match,
      );
      final Result<void> secondResult = await repository.recordMatchEvaluation(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        flashcardId: cardId,
        boardIndex: 0,
        pairId: 'pair-1',
        selectedFrontCellId: 'front-1',
        selectedBackCellId: 'back-1',
        expectedFrontFlashcardId: cardId,
        expectedBackFlashcardId: cardId,
        isCorrect: true,
        studyMode: StudyMode.match,
      );

      final Result<List<StudyMatchEvaluation>> loadResult = await repository
          .loadMatchEvaluations(sessionId: sessionId);
      final List<StudyMatchEvaluation> evaluations =
          loadResult.valueOrNull ?? const <StudyMatchEvaluation>[];
      final StudySessionItemRow sessionItem = await db
          .select(db.studySessionItems)
          .getSingle();
      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();

      expect(firstResult.isOk, isTrue);
      expect(secondResult.isOk, isTrue);
      expect(evaluations, hasLength(2));
      expect(evaluations.first.isCorrect, isFalse);
      expect(evaluations.first.attemptOrder, 0);
      expect(evaluations.last.isCorrect, isTrue);
      expect(evaluations.last.attemptOrder, 1);
      expect(sessionItem.answeredAt, equals(null));
      expect(progress.boxNumber, 3);
      expect(progress.reviewCount, 0);
      expect(progress.lapseCount, 0);
    },
  );

  test(
    'recordMatchEvaluation rejects closed sessions, missing items, and non-match modes',
    () async {
      const String folderId = 'folder-match-reject';
      const String deckId = 'deck-match-reject';
      const String cardId = 'card-match-reject';
      const String closedSessionId = 'session-match-reject-closed';
      const String openSessionId = 'session-match-reject-open';
      const String closedSessionItemId = 'item-match-reject-closed';
      const String openSessionItemId = 'item-match-reject-open';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: closedSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        status: 'completed',
      );
      await fixture.insertStudySessionItem(
        id: closedSessionItemId,
        sessionId: closedSessionId,
        flashcardId: cardId,
      );
      await fixture.insertResumableSession(
        id: openSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: openSessionItemId,
        sessionId: openSessionId,
        flashcardId: cardId,
      );

      final Result<void> closedSessionResult = await repository
          .recordMatchEvaluation(
            sessionId: closedSessionId,
            sessionItemId: closedSessionItemId,
            flashcardId: cardId,
            boardIndex: 0,
            pairId: 'pair-closed',
            selectedFrontCellId: 'front-closed',
            selectedBackCellId: 'back-closed',
            expectedFrontFlashcardId: cardId,
            expectedBackFlashcardId: cardId,
            isCorrect: true,
            studyMode: StudyMode.match,
          );
      final Result<void> missingItemResult = await repository
          .recordMatchEvaluation(
            sessionId: openSessionId,
            sessionItemId: 'missing-item',
            flashcardId: cardId,
            boardIndex: 0,
            pairId: 'pair-missing',
            selectedFrontCellId: 'front-missing',
            selectedBackCellId: 'back-missing',
            expectedFrontFlashcardId: cardId,
            expectedBackFlashcardId: cardId,
            isCorrect: true,
            studyMode: StudyMode.match,
          );
      final Result<void> wrongModeResult = await repository
          .recordMatchEvaluation(
            sessionId: openSessionId,
            sessionItemId: openSessionItemId,
            flashcardId: cardId,
            boardIndex: 0,
            pairId: 'pair-wrong-mode',
            selectedFrontCellId: 'front-wrong-mode',
            selectedBackCellId: 'back-wrong-mode',
            expectedFrontFlashcardId: cardId,
            expectedBackFlashcardId: cardId,
            isCorrect: true,
            studyMode: StudyMode.recall,
          );

      expect(
        closedSessionResult.failureOrNull,
        isA<UnsupportedActionFailure>(),
      );
      expect(missingItemResult.failureOrNull, isA<NotFoundFailure>());
      expect(wrongModeResult.failureOrNull, isA<UnsupportedActionFailure>());
      expect(await db.select(db.studyMatchEvaluations).get(), isEmpty);
    },
  );

  test(
    'finalizeStudySession succeeds, repairs missing progress, and applies SRS updates transactionally',
    () async {
      const String folderId = 'folder-finalize-ok';
      const String deckId = 'deck-finalize-ok';
      const String answeredCardId = 'card-finalize-answered';
      const String missingProgressCardId = 'card-finalize-missing';
      const String sessionId = 'session-finalize-ok';
      const String answeredItemId = 'item-finalize-answered';
      const String missingProgressItemId = 'item-finalize-missing';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: answeredCardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 3,
      );
      await fixture.insertFlashcard(id: missingProgressCardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: answeredItemId,
        sessionId: sessionId,
        flashcardId: answeredCardId,
        sortOrder: 0,
      );
      await fixture.insertStudySessionItem(
        id: missingProgressItemId,
        sessionId: sessionId,
        flashcardId: missingProgressCardId,
        sortOrder: 1,
      );
      await repository.recordStudySessionAnswer(
        sessionId: sessionId,
        sessionItemId: answeredItemId,
        result: AttemptResult.perfect,
        studyMode: StudyMode.recall,
      );
      await repository.recordStudySessionAnswer(
        sessionId: sessionId,
        sessionItemId: missingProgressItemId,
        result: AttemptResult.forgot,
        studyMode: StudyMode.recall,
      );

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: sessionId,
      );

      expect(result.isOk, isTrue);

      final StudySessionRow sessionRow = await db
          .select(db.studySessions)
          .getSingle();
      final List<FlashcardProgressRow> progressRows = await db
          .select(db.flashcardProgress)
          .get();

      final FlashcardProgressRow answeredProgress = progressRows.firstWhere(
        (FlashcardProgressRow row) => row.flashcardId == answeredCardId,
      );
      final FlashcardProgressRow repairedProgress = progressRows.firstWhere(
        (FlashcardProgressRow row) => row.flashcardId == missingProgressCardId,
      );

      expect(sessionRow.status, 'completed');
      expect(progressRows, hasLength(2));
      expect(answeredProgress.boxNumber, 4);
      expect(answeredProgress.reviewCount, 1);
      expect(answeredProgress.lapseCount, 0);
      expect(answeredProgress.dueAt, isA<int>());
      expect(repairedProgress.boxNumber, 1);
      expect(repairedProgress.reviewCount, 1);
      expect(repairedProgress.lapseCount, 1);
      expect(repairedProgress.dueAt, isA<int>());
      expect(await db.select(db.studyAttempts).get(), hasLength(2));
    },
  );

  test(
    'finalizeStudySession derives perfect for clean Match evaluations and completes the session',
    () async {
      const String folderId = 'folder-match-perfect';
      const String deckId = 'deck-match-perfect';
      const String cardId = 'card-match-perfect';
      const String sessionId = 'session-match-perfect';
      const String sessionItemId = 'item-match-perfect';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 3,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );
      await repository.recordMatchEvaluation(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        flashcardId: cardId,
        boardIndex: 0,
        pairId: 'pair-perfect',
        selectedFrontCellId: 'front-perfect',
        selectedBackCellId: 'back-perfect',
        expectedFrontFlashcardId: cardId,
        expectedBackFlashcardId: cardId,
        isCorrect: true,
        studyMode: StudyMode.match,
      );

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: sessionId,
      );

      expect(result.isOk, isTrue);
      expect(
        (await db.select(db.studySessions).getSingle()).status,
        'completed',
      );
      final StudySessionItemRow finalizedItem = await db
          .select(db.studySessionItems)
          .getSingle();
      final StudyAttemptRow finalAttempt = await db
          .select(db.studyAttempts)
          .getSingle();
      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();

      expect(finalizedItem.answeredAt != null, isTrue);
      expect(finalAttempt.result, 'perfect');
      expect(finalAttempt.studyMode, 'match');
      expect(progress.boxNumber, 4);
      expect(progress.reviewCount, 1);
      expect(progress.lapseCount, 0);
    },
  );

  test(
    'finalizeStudySession derives forgot when a wrong Match evaluation happens before the correct one',
    () async {
      const String folderId = 'folder-match-forgot';
      const String deckId = 'deck-match-forgot';
      const String cardId = 'card-match-forgot';
      const String sessionId = 'session-match-forgot';
      const String sessionItemId = 'item-match-forgot';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 2,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );
      await repository.recordMatchEvaluation(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        flashcardId: cardId,
        boardIndex: 0,
        pairId: 'pair-fail',
        selectedFrontCellId: 'front-fail',
        selectedBackCellId: 'back-fail',
        expectedFrontFlashcardId: cardId,
        expectedBackFlashcardId: cardId,
        isCorrect: false,
        studyMode: StudyMode.match,
      );
      await repository.recordMatchEvaluation(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        flashcardId: cardId,
        boardIndex: 0,
        pairId: 'pair-success',
        selectedFrontCellId: 'front-success',
        selectedBackCellId: 'back-success',
        expectedFrontFlashcardId: cardId,
        expectedBackFlashcardId: cardId,
        isCorrect: true,
        studyMode: StudyMode.match,
      );

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: sessionId,
      );

      expect(result.isOk, isTrue);
      final StudyAttemptRow finalAttempt = await db
          .select(db.studyAttempts)
          .getSingle();
      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();

      expect(finalAttempt.result, 'forgot');
      expect(progress.boxNumber, 1);
      expect(progress.lapseCount, 1);
    },
  );

  test(
    'finalizeStudySession derives forgot for Match items that never get a correct evaluation and rolls back on failure',
    () async {
      const String folderId = 'folder-match-never-correct';
      const String deckId = 'deck-match-never-correct';
      const String cardId = 'card-match-never-correct';
      const String sessionId = 'session-match-never-correct';
      const String sessionItemId = 'item-match-never-correct';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 2,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );
      await repository.recordMatchEvaluation(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        flashcardId: cardId,
        boardIndex: 0,
        pairId: 'pair-wrong',
        selectedFrontCellId: 'front-wrong',
        selectedBackCellId: 'back-wrong',
        expectedFrontFlashcardId: cardId,
        expectedBackFlashcardId: cardId,
        isCorrect: false,
        studyMode: StudyMode.match,
      );

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: sessionId,
      );

      expect(result.isOk, isTrue);
      final StudyAttemptRow finalAttempt = await db
          .select(db.studyAttempts)
          .getSingle();
      expect(finalAttempt.result, 'forgot');
    },
  );

  test(
    'finalizeStudySession rolls back Match progress writes when a write fails',
    () async {
      const String folderId = 'folder-match-rollback';
      const String deckId = 'deck-match-rollback';
      const String cardId = 'card-match-rollback';
      const String sessionId = 'session-match-rollback';
      const String sessionItemId = 'item-match-rollback';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 2,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );
      await repository.recordMatchEvaluation(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        flashcardId: cardId,
        boardIndex: 0,
        pairId: 'pair-rollback',
        selectedFrontCellId: 'front-rollback',
        selectedBackCellId: 'back-rollback',
        expectedFrontFlashcardId: cardId,
        expectedBackFlashcardId: cardId,
        isCorrect: true,
        studyMode: StudyMode.match,
      );

      repository = StudyRepositoryImpl(_ThrowingFinalizeStudySessionDao(db));

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: sessionId,
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<StorageFailure>());
      expect(
        (await db.select(db.studySessions).getSingle()).status,
        'in_progress',
      );
      expect(await db.select(db.studyAttempts).get(), isEmpty);
      expect(
        (await db.select(db.studySessionItems).getSingle()).answeredAt == null,
        isTrue,
      );
    },
  );

  test(
    'finalizeStudySession rejects when any session item is still unanswered',
    () async {
      const String folderId = 'folder-finalize-unanswered';
      const String deckId = 'deck-finalize-unanswered';
      const String answeredCardId = 'card-finalize-unanswered-answered';
      const String pendingCardId = 'card-finalize-unanswered-pending';
      const String sessionId = 'session-finalize-unanswered';
      const String answeredItemId = 'item-finalize-unanswered-answered';
      const String pendingItemId = 'item-finalize-unanswered-pending';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: answeredCardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 3,
      );
      await fixture.insertFlashcard(
        id: pendingCardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 2,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: answeredItemId,
        sessionId: sessionId,
        flashcardId: answeredCardId,
        sortOrder: 0,
      );
      await fixture.insertStudySessionItem(
        id: pendingItemId,
        sessionId: sessionId,
        flashcardId: pendingCardId,
        sortOrder: 1,
      );
      await repository.recordStudySessionAnswer(
        sessionId: sessionId,
        sessionItemId: answeredItemId,
        result: AttemptResult.perfect,
        studyMode: StudyMode.recall,
      );

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: sessionId,
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<FinalizationFailure>());
      expect(
        (await db.select(db.studySessions).getSingle()).status,
        'in_progress',
      );
      expect(await db.select(db.flashcardProgress).get(), hasLength(2));
      expect(
        (await db.select(db.flashcardProgress).get())
            .firstWhere((row) => row.flashcardId == answeredCardId)
            .boxNumber,
        3,
      );
      expect(await db.select(db.studyAttempts).get(), hasLength(1));
    },
  );

  test(
    'finalizeStudySession rejects when an answered item has no persisted attempt',
    () async {
      const String folderId = 'folder-finalize-no-attempt';
      const String deckId = 'deck-finalize-no-attempt';
      const String cardId = 'card-finalize-no-attempt';
      const String sessionId = 'session-finalize-no-attempt';
      const String itemId = 'item-finalize-no-attempt';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      final int nowMs = now.toUtc().millisecondsSinceEpoch;
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: nowMs,
        boxNumber: 2,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await db
          .into(db.studySessionItems)
          .insert(
            StudySessionItemsCompanion.insert(
              id: itemId,
              sessionId: sessionId,
              flashcardId: cardId,
              sortOrder: 0,
              answeredAt: Value<int?>(nowMs),
              createdAt: nowMs,
              updatedAt: nowMs,
            ),
          );

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: sessionId,
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<FinalizationFailure>());
      expect(
        (await db.select(db.studySessions).getSingle()).status,
        'in_progress',
      );
      expect(await db.select(db.studyAttempts).get(), isEmpty);
      expect((await db.select(db.flashcardProgress).getSingle()).boxNumber, 2);
    },
  );

  test(
    'finalizeStudySession rolls back progress writes when a write fails',
    () async {
      const String folderId = 'folder-finalize-rollback';
      const String deckId = 'deck-finalize-rollback';
      const String cardId = 'card-finalize-rollback';
      const String sessionId = 'session-finalize-rollback';
      const String itemId = 'item-finalize-rollback';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 2,
      );
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: itemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );
      await repository.recordStudySessionAnswer(
        sessionId: sessionId,
        sessionItemId: itemId,
        result: AttemptResult.perfect,
        studyMode: StudyMode.recall,
      );

      repository = StudyRepositoryImpl(_ThrowingFinalizeStudySessionDao(db));

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: sessionId,
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<StorageFailure>());
      expect(
        (await db.select(db.studySessions).getSingle()).status,
        'in_progress',
      );
      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();
      expect(progress.boxNumber, 2);
      expect(progress.reviewCount, 0);
      expect(await db.select(db.studyAttempts).get(), hasLength(1));
    },
  );
}
