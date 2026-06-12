import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/entities/study_match_evaluation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

class _StudyDbFixture {
  _StudyDbFixture(this.db, {DateTime? now}) : _now = now ?? _studyTestNow;

  final AppDatabase db;
  final DateTime _now;

  Future<void> insertFolder({
    required String id,
    String? parentId,
    String contentMode = 'decks',
    int sortOrder = 0,
  }) => db
      .into(db.folders)
      .insert(
        FoldersCompanion.insert(
          id: id,
          parentId: Value<String?>(parentId),
          name: 'Folder $id',
          contentMode: Value<String>(contentMode),
          sortOrder: Value<int>(sortOrder),
          createdAt: _nowMs,
          updatedAt: _nowMs,
        ),
      );

  Future<void> insertDeck({
    required String id,
    required String folderId,
    int sortOrder = 0,
  }) => db
      .into(db.decks)
      .insert(
        DecksCompanion.insert(
          id: id,
          folderId: folderId,
          name: 'Deck $id',
          targetLanguage: const Value<String>('korean'),
          sortOrder: Value<int>(sortOrder),
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
    int sortOrder = 0,
  }) async {
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: 'Front $id',
            back: 'Back $id',
            sortOrder: Value<int>(sortOrder),
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
    int? startedAt,
    int? updatedAt,
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
            startedAt: startedAt ?? _nowMs,
            updatedAt: updatedAt ?? _nowMs,
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

  int get _nowMs => _now.toUtc().millisecondsSinceEpoch;
}

late DateTime _studyTestNow;

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

  test(
    'findResumableSession keeps old started_at sessions resumable when updated_at is fresh and ignores stale updated_at sessions',
    () async {
      const String folderId = 'folder-resume-expiry';
      const String deckId = 'deck-resume-expiry';
      const String qualifyingSessionId = 'session-resume-fresh';
      const String staleSessionId = 'session-resume-stale';
      const String cardId = 'card-resume-expiry';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: qualifyingSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        startedAt: _studyTestNow
            .toUtc()
            .subtract(const Duration(days: 45))
            .millisecondsSinceEpoch,
        updatedAt: _studyTestNow
            .toUtc()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch,
      );
      await fixture.insertStudySessionItem(
        id: 'item-resume-fresh',
        sessionId: qualifyingSessionId,
        flashcardId: cardId,
      );
      await fixture.insertResumableSession(
        id: staleSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        startedAt: _studyTestNow
            .toUtc()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch,
        updatedAt: _studyTestNow
            .toUtc()
            .subtract(const Duration(days: 45))
            .millisecondsSinceEpoch,
      );
      await fixture.insertStudySessionItem(
        id: 'item-resume-stale',
        sessionId: staleSessionId,
        flashcardId: cardId,
      );

      final Result<StudySession?> result = await repository
          .findResumableSession(
            scope: const StudyScope(
              entryType: EntryType.deck,
              entryRefId: deckId,
              studyType: StudyType.newCards,
            ),
          );

      final StudySession? session = result.valueOrNull;
      expect(session?.id, qualifyingSessionId);
      expect(session?.startedAt, isA<DateTime>());
      expect(await db.select(db.studySessions).get(), hasLength(2));
    },
  );

  test(
    'findResumableSession excludes sessions with stale updated_at even when started_at is recent',
    () async {
      const String folderId = 'folder-resume-expiry-null';
      const String deckId = 'deck-resume-expiry-null';
      const String sessionId = 'session-resume-expiry-null';
      const String cardId = 'card-resume-expiry-null';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertResumableSession(
        id: sessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        startedAt: _studyTestNow
            .toUtc()
            .subtract(const Duration(days: 1))
            .millisecondsSinceEpoch,
        updatedAt: _studyTestNow
            .toUtc()
            .subtract(const Duration(days: 45))
            .millisecondsSinceEpoch,
      );
      await fixture.insertStudySessionItem(
        id: 'item-resume-expiry-null',
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final Result<StudySession?> result = await repository
          .findResumableSession(
            scope: const StudyScope(
              entryType: EntryType.deck,
              entryRefId: deckId,
              studyType: StudyType.newCards,
            ),
          );

      expect(result.valueOrNull, null);
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

  test('loadStudySessionReview does not mutate session updated_at', () async {
    const String folderId = 'folder-review-read';
    const String deckId = 'deck-review-read';
    const String sessionId = 'session-review-read';
    const String cardId = 'card-review-read';
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
      id: 'item-review-read',
      sessionId: sessionId,
      flashcardId: cardId,
    );

    final int beforeUpdatedAt =
        (await db.select(db.studySessions).getSingle()).updatedAt;
    final Result<StudySessionReview> result = await repository
        .loadStudySessionReview(sessionId: sessionId);
    expect(result.isOk, isTrue);
    final int afterUpdatedAt =
        (await db.select(db.studySessions).getSingle()).updatedAt;

    expect(afterUpdatedAt, beforeUpdatedAt);
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
        dueAt: now.toUtc().add(const Duration(days: 1)).millisecondsSinceEpoch,
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

  test('deck scope caps eligible cards at 20 and preserves order', () async {
    const String folderId = 'folder-cap-deck';
    const String deckId = 'deck-cap-deck';
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    for (int index = 0; index < 25; index++) {
      await fixture.insertFlashcard(
        id: 'card-$index',
        deckId: deckId,
        sortOrder: index,
      );
    }

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
    final List<StudySessionItemRow> items = await db
        .select(db.studySessionItems)
        .get();

    expect(items, hasLength(20));
    expect(
      items.map((row) => row.sortOrder),
      List<int>.generate(20, (int i) => i),
    );
    expect(
      items.map((row) => row.flashcardId),
      List<String>.generate(20, (int i) => 'card-$i'),
    );
    expect(
      items.every((StudySessionItemRow row) => row.sessionId == sessionId),
      isTrue,
    );
  });

  test(
    'deck scope includes all eligible cards when fewer than 20 exist',
    () async {
      const String folderId = 'folder-under-cap';
      const String deckId = 'deck-under-cap';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      for (int index = 0; index < 19; index++) {
        await fixture.insertFlashcard(
          id: 'card-under-$index',
          deckId: deckId,
          sortOrder: index,
        );
      }

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
      expect(await db.select(db.studySessionItems).get(), hasLength(19));
    },
  );

  test(
    'deck scope includes all eligible cards when exactly 20 exist',
    () async {
      const String folderId = 'folder-exact-cap';
      const String deckId = 'deck-exact-cap';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      for (int index = 0; index < 20; index++) {
        await fixture.insertFlashcard(
          id: 'card-exact-$index',
          deckId: deckId,
          sortOrder: index,
        );
      }

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
      expect(await db.select(db.studySessionItems).get(), hasLength(20));
    },
  );

  test('folder recursive scope caps eligible cards at 20', () async {
    const String folderId = 'folder-cap-folder';
    const String firstDeckId = 'deck-cap-folder-a';
    const String secondDeckId = 'deck-cap-folder-b';
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: firstDeckId, folderId: folderId, sortOrder: 0);
    await fixture.insertDeck(
      id: secondDeckId,
      folderId: folderId,
      sortOrder: 1,
    );
    for (int index = 0; index < 12; index++) {
      await fixture.insertFlashcard(
        id: 'card-a-$index',
        deckId: firstDeckId,
        sortOrder: index,
      );
    }
    for (int index = 0; index < 13; index++) {
      await fixture.insertFlashcard(
        id: 'card-b-$index',
        deckId: secondDeckId,
        sortOrder: index,
      );
    }

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
    final List<StudySessionItemRow> items = await db
        .select(db.studySessionItems)
        .get();

    expect(items, hasLength(20));
    expect(items.first.flashcardId, 'card-a-0');
    expect(items.last.flashcardId, 'card-b-7');
  });

  test('today scope caps due cards at 20 and keeps due ordering', () async {
    const String folderId = 'folder-cap-today';
    const String deckId = 'deck-cap-today';
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    for (int index = 0; index < 25; index++) {
      await fixture.insertFlashcard(
        id: 'card-today-$index',
        deckId: deckId,
        dueAt: _studyTestNow
            .toUtc()
            .subtract(Duration(days: index + 1))
            .millisecondsSinceEpoch,
        boxNumber: 2,
      );
    }

    final Result<StudyEntryStartResult> result = await repository
        .startStudySession(
          scope: const StudyScope(
            entryType: EntryType.today,
            entryRefId: null,
            studyType: StudyType.srsReview,
          ),
        );

    final StudyEntryStartResult? value = result.valueOrNull;
    expect(value, isA<StudyEntryStartStarted>());
    final List<StudySessionItemRow> items = await db
        .select(db.studySessionItems)
        .get();

    expect(items, hasLength(20));
    expect(items.first.flashcardId, 'card-today-24');
    expect(items.last.flashcardId, 'card-today-5');
  });

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
        startedAt: _studyTestNow
            .subtract(const Duration(days: 1))
            .toUtc()
            .millisecondsSinceEpoch,
        updatedAt: _studyTestNow
            .subtract(const Duration(days: 1))
            .toUtc()
            .millisecondsSinceEpoch,
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
    'restartStudySession cancels the previous session before creating a capped replacement batch',
    () async {
      const String folderId = 'folder-restart-cap';
      const String deckId = 'deck-restart-cap';
      const String previousSessionId = 'session-restart-cap-old';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertResumableSession(
        id: previousSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        startedAt: _studyTestNow
            .subtract(const Duration(days: 1))
            .toUtc()
            .millisecondsSinceEpoch,
        updatedAt: _studyTestNow
            .subtract(const Duration(days: 1))
            .toUtc()
            .millisecondsSinceEpoch,
      );
      for (int index = 0; index < 25; index++) {
        await fixture.insertFlashcard(
          id: 'card-restart-$index',
          deckId: deckId,
          sortOrder: index,
        );
      }
      await fixture.insertStudySessionItem(
        id: 'item-restart-cap-old',
        sessionId: previousSessionId,
        flashcardId: 'card-restart-0',
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
      final List<StudySessionItemRow> items = await db
          .select(db.studySessionItems)
          .get();

      expect(
        (await db.select(db.studySessions).get())
            .firstWhere((StudySessionRow row) => row.id == previousSessionId)
            .status,
        'cancelled',
      );
      expect(
        items.where((StudySessionItemRow row) => row.sessionId == session.id),
        hasLength(20),
      );
      expect(
        items.where(
          (StudySessionItemRow row) => row.sessionId == previousSessionId,
        ),
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

      final int sessionUpdatedBefore =
          (await db.select(db.studySessions).getSingle()).updatedAt;
      _studyTestNow = _studyTestNow.add(const Duration(minutes: 5));

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
      final StudySessionRow updatedSession = await db
          .select(db.studySessions)
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
      expect(updatedSession.updatedAt, greaterThan(sessionUpdatedBefore));
      expect(progress.boxNumber, 3);
      expect(progress.reviewCount, 0);
      expect(progress.lapseCount, 0);
    },
  );

  test(
    'recordStudySessionAnswer persists review mode with the perfect result',
    () async {
      const String folderId = 'folder-review-answer';
      const String deckId = 'deck-review-answer';
      const String cardId = 'card-review-answer';
      const String sessionId = 'session-review-answer';
      const String sessionItemId = 'item-review-answer';
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

      final Result<void> result = await repository.recordStudySessionAnswer(
        sessionId: sessionId,
        sessionItemId: sessionItemId,
        result: AttemptResult.perfect,
        studyMode: StudyMode.review,
      );

      expect(result.isOk, isTrue);

      final StudyAttemptRow attempt = await db
          .select(db.studyAttempts)
          .getSingle();
      expect(attempt.result, 'perfect');
      expect(attempt.studyMode, 'review');
      expect(attempt.boxBefore, 2);
      expect(attempt.boxAfter, 3);
      expect(
        (await db.select(db.studySessionItems).getSingle()).answeredAt != null,
        isTrue,
      );
    },
  );

  test(
    'recordStudySessionAnswer persists guess mode with the forgot result',
    () async {
      const String folderId = 'folder-guess-answer';
      const String deckId = 'deck-guess-answer';
      const String cardId = 'card-guess-answer';
      const String sessionId = 'session-guess-answer';
      const String sessionItemId = 'item-guess-answer';
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: now.toUtc().millisecondsSinceEpoch,
        boxNumber: 4,
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
        result: AttemptResult.forgot,
        studyMode: StudyMode.guess,
      );

      expect(result.isOk, isTrue);

      final StudyAttemptRow attempt = await db
          .select(db.studyAttempts)
          .getSingle();
      expect(attempt.result, 'forgot');
      expect(attempt.studyMode, 'guess');
      expect(attempt.boxBefore, 4);
      expect(attempt.boxAfter, 1);
      expect(
        (await db.select(db.studySessionItems).getSingle()).answeredAt != null,
        isTrue,
      );
    },
  );

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
