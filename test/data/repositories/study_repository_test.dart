import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull;
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

class _StudyDbFixture {
  _StudyDbFixture(this.db);

  final AppDatabase db;

  Future<void> insertFolder({
    required String id,
    String? parentId,
    String contentMode = 'decks',
  }) => db
      .into(db.folders)
      .insert(
        FoldersCompanion.insert(
          id: id,
          parentId: Value<String?>(parentId),
          name: 'Folder $id',
          contentMode: Value<String>(contentMode),
          sortOrder: const Value<int>(0),
          createdAt: _nowMs,
          updatedAt: _nowMs,
        ),
      );

  Future<void> insertDeck({required String id, required String folderId}) => db
      .into(db.decks)
      .insert(
        DecksCompanion.insert(
          id: id,
          folderId: folderId,
          name: 'Deck $id',
          targetLanguage: const Value<String>('korean'),
          sortOrder: const Value<int>(0),
          createdAt: _nowMs,
          updatedAt: _nowMs,
        ),
      );

  Future<void> insertFlashcard({
    required String id,
    required String deckId,
    int? dueAt,
    int? boxNumber,
    int? buriedUntil,
    bool isSuspended = false,
  }) async {
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: 'Front $id',
            back: 'Back $id',
            sortOrder: const Value<int>(0),
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
    if (dueAt != null ||
        boxNumber != null ||
        buriedUntil != null ||
        isSuspended) {
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion(
              flashcardId: Value<String>(id),
              boxNumber: boxNumber == null
                  ? const Value<int>(1)
                  : Value<int>(boxNumber),
              dueAt: Value<int?>(dueAt),
              buriedUntil: Value<int?>(buriedUntil),
              isSuspended: Value<bool>(isSuspended),
              reviewCount: const Value<int>(0),
              lapseCount: const Value<int>(0),
              lastStudiedAt: const Value<int?>(null),
            ),
          );
    }
  }

  Future<void> insertResumableSession({
    required String id,
    required String entryType,
    required String? entryRefId,
    required String studyType,
    String status = 'in_progress',
  }) async {
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: id,
            entryType: entryType,
            entryRefId: Value<String?>(entryRefId),
            studyType: studyType,
            status: status,
            startedAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
  }

  Future<void> insertStudySessionItem({
    required String id,
    required String sessionId,
    required String flashcardId,
    int sortOrder = 0,
    int? answeredAt,
  }) async {
    await db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            flashcardId: flashcardId,
            sortOrder: sortOrder,
            answeredAt: Value<int?>(answeredAt),
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
  }

  int get _nowMs => DateTime.now().toUtc().millisecondsSinceEpoch;
}

class _ThrowingStudySessionDao extends StudySessionDao {
  _ThrowingStudySessionDao(super.db);

  @override
  Future<void> insertStudyAttempt(StudyAttemptsCompanion attempt) async {
    await super.insertStudyAttempt(attempt);
    throw StateError('boom');
  }
}

class _ThrowingFinalizeStudySessionDao extends StudySessionDao {
  _ThrowingFinalizeStudySessionDao(super.db);

  @override
  Future<int> updateFlashcardProgress({
    required String flashcardId,
    required int boxNumber,
    required int dueAtMs,
    required int reviewCount,
    required int lapseCount,
    required int lastStudiedAtMs,
  }) async {
    throw StateError('boom');
  }
}

class _ThrowingRestartStudySessionDao extends StudySessionDao {
  _ThrowingRestartStudySessionDao(super.db);

  @override
  Future<void> insertStudySessionItem(StudySessionItemsCompanion item) async {
    await super.insertStudySessionItem(item);
    throw StateError('boom');
  }
}

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;
  late StudySessionDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = StudySessionDao(db);
    repository = StudyRepositoryImpl(dao);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'deck scope with zero cards returns empty and persists no session',
    () async {
      const String folderId = 'folder-empty';
      const String deckId = 'deck-empty';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);

      final Result<StudyEntryStartResult> result = await repository
          .startStudySession(
            scope: const StudyScope(
              entryType: EntryType.deck,
              entryRefId: deckId,
              studyType: StudyType.newCards,
            ),
          );

      final StudyEntryStartResult? value = result.valueOrNull;
      expect(value, isA<StudyEntryStartEmpty>());
      expect(
        (value as StudyEntryStartEmpty).emptyState.variant,
        StudyEntryEmptyVariant.deckNoCards,
      );
      expect(await db.select(db.studySessions).get(), isEmpty);
      expect(await db.select(db.studySessionItems).get(), isEmpty);
    },
  );

  test('deck scope with missing progress creates a session and item', () async {
    const String folderId = 'folder-deck';
    const String deckId = 'deck-study';
    const String cardId = 'card-study';
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    await fixture.insertFlashcard(id: cardId, deckId: deckId);

    final Result<StudyEntryStartResult> result = await repository
        .startStudySession(
          scope: const StudyScope(
            entryType: EntryType.deck,
            entryRefId: deckId,
            studyType: StudyType.newCards,
          ),
        );

    final StudyEntryStartResult? value = result.valueOrNull;
    expect(value, isA<StudyEntryStartStarted>());
    final String sessionId = (value as StudyEntryStartStarted).sessionId;

    final List<StudySessionRow> sessions = await db
        .select(db.studySessions)
        .get();
    final List<StudySessionItemRow> items = await db
        .select(db.studySessionItems)
        .get();

    expect(sessions, hasLength(1));
    expect(sessions.single.id, sessionId);
    expect(sessions.single.status, 'in_progress');
    expect(items, hasLength(1));
    expect(items.single.sessionId, sessionId);
    expect(items.single.flashcardId, cardId);
    expect(items.single.sortOrder, 0);
  });

  test(
    'folder scope with eligible cards creates a session and items',
    () async {
      const String folderId = 'folder-root';
      const String deckId = 'deck-child';
      const String cardId = 'card-folder';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);

      final Result<StudyEntryStartResult> result = await repository
          .startStudySession(
            scope: const StudyScope(
              entryType: EntryType.folder,
              entryRefId: folderId,
              studyType: StudyType.newCards,
            ),
          );

      final StudyEntryStartResult? value = result.valueOrNull;
      expect(value, isA<StudyEntryStartStarted>());
      expect(await db.select(db.studySessions).get(), hasLength(1));
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
    },
  );

  test(
    'resumable deck scope returns resumeRequired without duplicate session',
    () async {
      const String folderId = 'folder-resume';
      const String deckId = 'deck-resume';
      const String cardId = 'card-resume';
      const String sessionId = 'session-resume';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: 'item-resume',
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final Result<StudyEntryStartResult> result = await repository
          .startStudySession(
            scope: const StudyScope(
              entryType: EntryType.deck,
              entryRefId: deckId,
              studyType: StudyType.newCards,
            ),
          );

      final StudyEntryStartResult? value = result.valueOrNull;
      expect(value, isA<StudyEntryStartResumeRequired>());
      expect((value as StudyEntryStartResumeRequired).sessionId, sessionId);
      expect(await db.select(db.studySessions).get(), hasLength(1));
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
    },
  );

  test('missing session returns notFound', () async {
    final Result<StudySessionReview> result = await repository
        .loadStudySessionReview(sessionId: 'missing-session');

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test('loadStudySessionReview orders session items by sort_order', () async {
    const String folderId = 'folder-review';
    const String deckId = 'deck-review';
    const String sessionId = 'session-review';
    const String firstCardId = 'card-first';
    const String secondCardId = 'card-second';
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    await fixture.insertFlashcard(id: firstCardId, deckId: deckId);
    await fixture.insertFlashcard(id: secondCardId, deckId: deckId);
    await fixture.insertResumableSession(
      id: sessionId,
      entryType: EntryType.deck.name,
      entryRefId: deckId,
      studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
    );
    await fixture.insertStudySessionItem(
      id: 'item-second',
      sessionId: sessionId,
      flashcardId: secondCardId,
      sortOrder: 2,
    );
    await fixture.insertStudySessionItem(
      id: 'item-first',
      sessionId: sessionId,
      flashcardId: firstCardId,
      sortOrder: 1,
    );

    final Result<StudySessionReview> result = await repository
        .loadStudySessionReview(sessionId: sessionId);

    final StudySessionReview review = switch (result) {
      Ok<StudySessionReview>(:final value) => value,
      Err<StudySessionReview>(:final failure) => fail(
        'expected ok, got $failure',
      ),
    };

    expect(review.items, hasLength(2));
    expect(review.items.first.sessionItem.id, 'item-first');
    expect(review.items.first.flashcard.id, firstCardId);
    expect(review.items.last.sessionItem.id, 'item-second');
    expect(review.items.last.flashcard.id, secondCardId);
  });

  test(
    'loadStudySessionReview keeps answered items answered after reload',
    () async {
      const String folderId = 'folder-review-answered';
      const String deckId = 'deck-review-answered';
      const String sessionId = 'session-review-answered';
      const String firstCardId = 'card-review-first';
      const String secondCardId = 'card-review-second';
      const String thirdCardId = 'card-review-third';
      final int answeredAtMs = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: firstCardId, deckId: deckId);
      await fixture.insertFlashcard(id: secondCardId, deckId: deckId);
      await fixture.insertFlashcard(id: thirdCardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: 'item-third',
        sessionId: sessionId,
        flashcardId: thirdCardId,
        sortOrder: 3,
        answeredAt: answeredAtMs,
      );
      await fixture.insertStudySessionItem(
        id: 'item-first',
        sessionId: sessionId,
        flashcardId: firstCardId,
        sortOrder: 1,
      );
      await fixture.insertStudySessionItem(
        id: 'item-second',
        sessionId: sessionId,
        flashcardId: secondCardId,
        sortOrder: 2,
        answeredAt: answeredAtMs,
      );

      final Result<StudySessionReview> firstLoad = await repository
          .loadStudySessionReview(sessionId: sessionId);
      final Result<StudySessionReview> secondLoad = await repository
          .loadStudySessionReview(sessionId: sessionId);

      final StudySessionReview review = switch (firstLoad) {
        Ok<StudySessionReview>(:final value) => value,
        Err<StudySessionReview>(:final failure) => fail(
          'expected ok, got $failure',
        ),
      };
      final StudySessionReview reloaded = switch (secondLoad) {
        Ok<StudySessionReview>(:final value) => value,
        Err<StudySessionReview>(:final failure) => fail(
          'expected ok, got $failure',
        ),
      };

      expect(review, equals(reloaded));
      expect(review.session.id, sessionId);
      expect(review.items, hasLength(3));
      expect(review.items.map((item) => item.sessionItem.id), <String>[
        'item-first',
        'item-second',
        'item-third',
      ]);
      expect(review.items.first.sessionItem.answeredAt == null, isTrue);
      expect(review.items[1].sessionItem.answeredAt != null, isTrue);
      expect(review.items[2].sessionItem.answeredAt != null, isTrue);
    },
  );

  test(
    'today scope with future due cards returns an all-done empty state',
    () async {
      const String folderId = 'folder-today';
      const String deckId = 'deck-today';
      const String cardId = 'card-future';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: DateTime.now()
            .toUtc()
            .add(const Duration(days: 1))
            .millisecondsSinceEpoch,
        boxNumber: 2,
      );

      final Result<StudyEntryStartResult> result = await repository
          .startStudySession(
            scope: const StudyScope(
              entryType: EntryType.today,
              entryRefId: null,
              studyType: StudyType.srsReview,
            ),
          );

      final StudyEntryStartResult? value = result.valueOrNull;
      expect(value, isA<StudyEntryStartEmpty>());
      expect(
        (value as StudyEntryStartEmpty).emptyState.variant,
        StudyEntryEmptyVariant.todayAllDone,
      );
      expect(await db.select(db.studySessions).get(), isEmpty);
    },
  );

  test(
    'createSession rolls back session writes when an item insert fails',
    () async {
      final Result<StudySession> result = await repository.createSession(
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: 'deck-missing',
          studyType: StudyType.newCards,
        ),
        flashcardIds: const <String>['missing-card'],
      );

      expect(result.isErr, isTrue);
      expect(await db.select(db.studySessions).get(), isEmpty);
      expect(await db.select(db.studySessionItems).get(), isEmpty);
    },
  );

  test(
    'restartStudySession cancels the previous session and creates exactly one new active session',
    () async {
      const String folderId = 'folder-restart-ok';
      const String deckId = 'deck-restart-ok';
      const String cardId = 'card-restart-ok';
      const String previousSessionId = 'session-restart-old';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: previousSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: 'item-restart-old',
        sessionId: previousSessionId,
        flashcardId: cardId,
      );

      final Result<StudySession> result = await repository.restartStudySession(
        previousSessionId: previousSessionId,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: deckId,
          studyType: StudyType.newCards,
        ),
      );

      final StudySession session = switch (result) {
        Ok<StudySession>(:final value) => value,
        Err<StudySession>(:final failure) => fail('expected ok, got $failure'),
      };

      final List<StudySessionRow> sessions = await db
          .select(db.studySessions)
          .get();
      final List<StudySessionItemRow> items = await db
          .select(db.studySessionItems)
          .get();

      expect(sessions, hasLength(2));
      expect(
        sessions.where((StudySessionRow row) => row.status == 'in_progress'),
        hasLength(1),
      );
      expect(
        sessions
            .firstWhere((StudySessionRow row) => row.id == previousSessionId)
            .status,
        'cancelled',
      );
      expect(
        sessions
            .firstWhere((StudySessionRow row) => row.id == session.id)
            .status,
        'in_progress',
      );
      expect(items, hasLength(2));
      expect(
        items.where((StudySessionItemRow row) => row.sessionId == session.id),
        hasLength(1),
      );
    },
  );

  test(
    'restartStudySession rolls back the cancel when creating the replacement fails',
    () async {
      const String folderId = 'folder-restart-rollback';
      const String deckId = 'deck-restart-rollback';
      const String cardId = 'card-restart-rollback';
      const String previousSessionId = 'session-restart-rollback';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: previousSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: 'item-restart-rollback',
        sessionId: previousSessionId,
        flashcardId: cardId,
      );

      repository = StudyRepositoryImpl(_ThrowingRestartStudySessionDao(db));

      final Result<StudySession> result = await repository.restartStudySession(
        previousSessionId: previousSessionId,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: deckId,
          studyType: StudyType.newCards,
        ),
      );

      expect(result.isErr, isTrue);
      expect(
        (await db.select(db.studySessions).get()).single.status,
        'in_progress',
      );
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
    },
  );

  test(
    'restartStudySession rejects a previous session from a different scope and leaves it untouched',
    () async {
      const String folderId = 'folder-restart-scope';
      const String oldDeckId = 'deck-restart-scope-old';
      const String newDeckId = 'deck-restart-scope-new';
      const String oldCardId = 'card-restart-scope-old';
      const String newCardId = 'card-restart-scope-new';
      const String previousSessionId = 'session-restart-scope';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: oldDeckId, folderId: folderId);
      await fixture.insertDeck(id: newDeckId, folderId: folderId);
      await fixture.insertFlashcard(id: oldCardId, deckId: oldDeckId);
      await fixture.insertFlashcard(id: newCardId, deckId: newDeckId);
      await fixture.insertResumableSession(
        id: previousSessionId,
        entryType: EntryType.deck.name,
        entryRefId: oldDeckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: 'item-restart-scope-old',
        sessionId: previousSessionId,
        flashcardId: oldCardId,
      );

      final Result<StudySession> result = await repository.restartStudySession(
        previousSessionId: previousSessionId,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: newDeckId,
          studyType: StudyType.newCards,
        ),
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<UnsupportedActionFailure>());
      expect(
        (await db.select(db.studySessions).get()).single.status,
        'in_progress',
      );
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
    },
  );

  test(
    'restartStudySession rejects an empty eligible batch and leaves the previous session untouched',
    () async {
      const String folderId = 'folder-restart-empty';
      const String deckId = 'deck-restart-empty';
      const String cardId = 'card-restart-empty';
      const String previousSessionId = 'session-restart-empty';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId, boxNumber: 2);
      await fixture.insertResumableSession(
        id: previousSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      );
      await fixture.insertStudySessionItem(
        id: 'item-restart-empty',
        sessionId: previousSessionId,
        flashcardId: cardId,
      );

      final Result<StudySession> result = await repository.restartStudySession(
        previousSessionId: previousSessionId,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: deckId,
          studyType: StudyType.newCards,
        ),
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(
        (await db.select(db.studySessions).get()).single.status,
        'in_progress',
      );
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
    },
  );

  test(
    'restartStudySession rejects a completed previous session and leaves it untouched',
    () async {
      const String folderId = 'folder-restart-complete';
      const String deckId = 'deck-restart-complete';
      const String cardId = 'card-restart-complete';
      const String previousSessionId = 'session-restart-complete';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: previousSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        status: 'completed',
      );
      await fixture.insertStudySessionItem(
        id: 'item-restart-complete',
        sessionId: previousSessionId,
        flashcardId: cardId,
      );

      final Result<StudySession> result = await repository.restartStudySession(
        previousSessionId: previousSessionId,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: deckId,
          studyType: StudyType.newCards,
        ),
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<UnsupportedActionFailure>());
      expect(
        (await db.select(db.studySessions).get()).single.status,
        'completed',
      );
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
    },
  );

  test(
    'restartStudySession rejects a cancelled previous session and leaves it untouched',
    () async {
      const String folderId = 'folder-restart-cancelled';
      const String deckId = 'deck-restart-cancelled';
      const String cardId = 'card-restart-cancelled';
      const String previousSessionId = 'session-restart-cancelled';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: previousSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        status: 'cancelled',
      );
      await fixture.insertStudySessionItem(
        id: 'item-restart-cancelled',
        sessionId: previousSessionId,
        flashcardId: cardId,
      );

      final Result<StudySession> result = await repository.restartStudySession(
        previousSessionId: previousSessionId,
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: deckId,
          studyType: StudyType.newCards,
        ),
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<UnsupportedActionFailure>());
      expect(
        (await db.select(db.studySessions).get()).single.status,
        'cancelled',
      );
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
    },
  );

  test(
    'recordStudySessionAnswer inserts one attempt and marks the session item answered without updating flashcard_progress',
    () async {
      const String folderId = 'folder-answer';
      const String deckId = 'deck-answer';
      const String cardId = 'card-answer';
      const String sessionId = 'session-answer';
      const String sessionItemId = 'item-answer';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: DateTime.now().toUtc().millisecondsSinceEpoch,
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

      final Result<void> result = await repository.recordStudySessionAnswer(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        result: AttemptResult.perfect,
        studyMode: StudyMode.recall,
      );

      expect(result.isOk, isTrue);

      final List<StudyAttemptRow> attempts = await db
          .select(db.studyAttempts)
          .get();
      final StudySessionItemRow updatedItem = await db
          .select(db.studySessionItems)
          .getSingle();
      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();

      expect(attempts, hasLength(1));
      expect(attempts.single.sessionItemId, sessionItemId);
      expect(attempts.single.result, 'perfect');
      expect(attempts.single.studyMode, 'recall');
      expect(attempts.single.boxBefore, 3);
      expect(attempts.single.boxAfter, 4);
      expect(updatedItem.answeredAt != null, isTrue);
      expect(progress.boxNumber, 3);
      expect(progress.reviewCount, 0);
      expect(progress.lapseCount, 0);
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
        dueAt: DateTime.now().toUtc().millisecondsSinceEpoch,
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
        dueAt: DateTime.now().toUtc().millisecondsSinceEpoch,
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
        dueAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        boxNumber: 3,
      );
      await fixture.insertFlashcard(
        id: pendingCardId,
        deckId: deckId,
        dueAt: DateTime.now().toUtc().millisecondsSinceEpoch,
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
      final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
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
        dueAt: DateTime.now().toUtc().millisecondsSinceEpoch,
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
