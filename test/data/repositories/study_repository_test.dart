import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/types/study_mode.dart';

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
  }) async {
    await db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            flashcardId: flashcardId,
            sortOrder: sortOrder,
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
      Err<StudySessionReview>(:final failure) =>
        fail('expected ok, got $failure'),
    };

    expect(review.items, hasLength(2));
    expect(review.items.first.sessionItem.id, 'item-first');
    expect(review.items.first.flashcard.id, firstCardId);
    expect(review.items.last.sessionItem.id, 'item-second');
    expect(review.items.last.flashcard.id, secondCardId);
  });

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

      final List<StudyAttemptRow> attempts = await db.select(db.studyAttempts).get();
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
}
