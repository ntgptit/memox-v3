import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/data/repositories/progress_repository_impl.dart';
import 'package:memox/domain/models/dashboard_deck_highlights.dart';
import 'package:memox/domain/models/progress_read_model.dart';

int _nowMs(DateTime now) => now.toUtc().millisecondsSinceEpoch;

class _ProgressFixture {
  _ProgressFixture(this.db, this.now);

  final AppDatabase db;
  final DateTime now;

  int get nowMs => _nowMs(now);

  Future<void> insertFolder({
    required String id,
    String? parentId,
    required String name,
    required int sortOrder,
  }) async {
    await db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(
            id: id,
            parentId: Value<String?>(parentId),
            name: name,
            contentMode: const Value<String>('decks'),
            sortOrder: Value<int>(sortOrder),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
  }

  Future<void> insertDeck({
    required String id,
    required String folderId,
    required String name,
    required int sortOrder,
  }) async {
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: id,
            folderId: folderId,
            name: name,
            sortOrder: Value<int>(sortOrder),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
  }

  Future<void> insertCard({
    required String id,
    required String deckId,
    required String front,
    required String back,
    int? dueAtMs,
    int boxNumber = 1,
    int? buriedUntilMs,
    bool isSuspended = false,
    int reviewCount = 0,
    int lapseCount = 0,
    int? lastStudiedAtMs,
  }) async {
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
    await db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion(
            flashcardId: Value<String>(id),
            boxNumber: Value<int>(boxNumber),
            dueAt: Value<int?>(dueAtMs),
            buriedUntil: Value<int?>(buriedUntilMs),
            isSuspended: Value<bool>(isSuspended),
            reviewCount: Value<int>(reviewCount),
            lapseCount: Value<int>(lapseCount),
            lastStudiedAt: Value<int?>(lastStudiedAtMs),
          ),
        );
  }

  Future<void> insertCompletedSession({
    required String id,
    required int startedAtMs,
  }) async {
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: id,
            entryType: 'deck',
            entryRefId: const Value<String?>(null),
            studyType: 'new_cards',
            status: 'completed',
            startedAt: startedAtMs,
            updatedAt: startedAtMs,
          ),
        );
  }

  Future<void> insertSession({
    required String id,
    required int startedAtMs,
    String status = 'in_progress',
  }) async {
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: id,
            entryType: 'deck',
            entryRefId: const Value<String?>(null),
            studyType: 'new_cards',
            status: status,
            startedAt: startedAtMs,
            updatedAt: startedAtMs,
          ),
        );
  }

  Future<void> insertSessionItem({
    required String id,
    required String sessionId,
    required String flashcardId,
    required int sortOrder,
    required int answeredAtMs,
  }) async {
    await db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            flashcardId: flashcardId,
            sortOrder: sortOrder,
            answeredAt: Value<int?>(answeredAtMs),
            createdAt: answeredAtMs,
            updatedAt: answeredAtMs,
          ),
        );
  }

  Future<void> insertAttempt({
    required String id,
    required String sessionItemId,
    required String result,
    required String studyMode,
    required int attemptedAtMs,
    required int boxBefore,
    required int boxAfter,
  }) async {
    await db
        .into(db.studyAttempts)
        .insert(
          StudyAttemptsCompanion.insert(
            id: id,
            sessionItemId: sessionItemId,
            result: result,
            studyMode: studyMode,
            boxBefore: Value<int>(boxBefore),
            boxAfter: Value<int>(boxAfter),
            attemptedAt: attemptedAtMs,
          ),
        );
  }
}

void main() {
  late AppDatabase db;
  late ProgressRepositoryImpl repo;
  late DateTime now;
  late int nowMs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ProgressRepositoryImpl(ProgressDao(db));
    now = DateTime.utc(2026, 1, 10, 12);
    nowMs = _nowMs(now);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'dashboard deck highlights: ordering, counts, and new-card count',
    () async {
      final _ProgressFixture fixture = _ProgressFixture(db, now);
      await fixture.insertFolder(
        id: 'folder-1',
        name: 'Folder 1',
        sortOrder: 0,
      );
      await fixture.insertDeck(
        id: 'deck-1',
        folderId: 'folder-1',
        name: 'Older deck',
        sortOrder: 0,
      );
      await fixture.insertDeck(
        id: 'deck-2',
        folderId: 'folder-1',
        name: 'Newer deck',
        sortOrder: 1,
      );
      // deck-2 was touched more recently → must sort first.
      await (db.update(db.decks)..where((t) => t.id.equals('deck-2'))).write(
        DecksCompanion(updatedAt: Value<int>(nowMs + 1000)),
      );

      // deck-1: one studied+due card, one never-studied card.
      await fixture.insertCard(
        id: 'card-a',
        deckId: 'deck-1',
        front: 'a',
        back: 'a',
        dueAtMs: nowMs - 1000,
        lastStudiedAtMs: nowMs - 5000,
      );
      await fixture.insertCard(
        id: 'card-b',
        deckId: 'deck-1',
        front: 'b',
        back: 'b',
      );
      // deck-2: one never-studied but suspended card (excluded from "new").
      await fixture.insertCard(
        id: 'card-c',
        deckId: 'deck-2',
        front: 'c',
        back: 'c',
        isSuspended: true,
      );

      final Result<DashboardDeckHighlights> result = await repo
          .loadDashboardDeckHighlights(now: now);

      expect(result, isA<Ok<DashboardDeckHighlights>>());
      final DashboardDeckHighlights highlights =
          (result as Ok<DashboardDeckHighlights>).value;

      expect(
        highlights.recentDecks.map((DashboardRecentDeck d) => d.deckId),
        <String>['deck-2', 'deck-1'],
      );

      final DashboardRecentDeck deckOne = highlights.recentDecks.firstWhere(
        (DashboardRecentDeck d) => d.deckId == 'deck-1',
      );
      expect(deckOne.cardCount, 2);
      expect(deckOne.dueCount, 1);
      expect(deckOne.lastStudiedAt, isNot(isNull));

      final DashboardRecentDeck deckTwo = highlights.recentDecks.firstWhere(
        (DashboardRecentDeck d) => d.deckId == 'deck-2',
      );
      expect(deckTwo.cardCount, 1);
      expect(deckTwo.dueCount, 0);
      expect(deckTwo.lastStudiedAt, isNull);

      // Only card-b is never-studied and not suspended.
      expect(highlights.newCardCount, 1);
    },
  );

  test('dashboard deck highlights respects the limit', () async {
    final _ProgressFixture fixture = _ProgressFixture(db, now);
    await fixture.insertFolder(id: 'folder-1', name: 'Folder 1', sortOrder: 0);
    for (int i = 0; i < 5; i++) {
      await fixture.insertDeck(
        id: 'deck-$i',
        folderId: 'folder-1',
        name: 'Deck $i',
        sortOrder: i,
      );
    }

    final Result<DashboardDeckHighlights> result = await repo
        .loadDashboardDeckHighlights(now: now, limit: 3);

    final DashboardDeckHighlights highlights =
        (result as Ok<DashboardDeckHighlights>).value;
    expect(highlights.recentDecks.length, 3);
  });

  test('empty database returns zero due summary', () async {
    final Result<ProgressDueSummary> result = await repo.loadProgressDueSummary(
      now: now,
    );

    expect(result, isA<Ok<ProgressDueSummary>>());
    final ProgressDueSummary summary = (result as Ok<ProgressDueSummary>).value;
    expect(summary.totalDueCount, 0);
    expect(summary.decks, isEmpty);
  });

  test(
    'due summary counts past-due, due-now, and expired-buried cards only',
    () async {
      final _ProgressFixture fixture = _ProgressFixture(db, now);
      await fixture.insertFolder(
        id: 'folder-1',
        name: 'Folder 1',
        sortOrder: 0,
      );
      await fixture.insertDeck(
        id: 'deck-1',
        folderId: 'folder-1',
        name: 'Deck 1',
        sortOrder: 0,
      );
      await fixture.insertCard(
        id: 'due-past',
        deckId: 'deck-1',
        front: 'Past',
        back: 'Past',
        dueAtMs: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'due-now',
        deckId: 'deck-1',
        front: 'Now',
        back: 'Now',
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'due-future',
        deckId: 'deck-1',
        front: 'Future',
        back: 'Future',
        dueAtMs: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'suspended',
        deckId: 'deck-1',
        front: 'Suspended',
        back: 'Suspended',
        dueAtMs: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        isSuspended: true,
      );
      await fixture.insertCard(
        id: 'buried-now',
        deckId: 'deck-1',
        front: 'Buried',
        back: 'Buried',
        dueAtMs: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        buriedUntilMs: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'buried-expired',
        deckId: 'deck-1',
        front: 'Expired',
        back: 'Expired',
        dueAtMs: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        buriedUntilMs: now
            .subtract(const Duration(minutes: 1))
            .millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'due-null',
        deckId: 'deck-1',
        front: 'Null',
        back: 'Null',
      );

      final Result<ProgressDueSummary> result = await repo
          .loadProgressDueSummary(now: now);

      final ProgressDueSummary summary =
          (result as Ok<ProgressDueSummary>).value;
      expect(summary.totalDueCount, 3);
      expect(summary.decks.single.dueCount, 3);
    },
  );

  test(
    'due summary returns multiple decks in deterministic order and does not mutate data',
    () async {
      final _ProgressFixture fixture = _ProgressFixture(db, now);
      await fixture.insertFolder(
        id: 'folder-b',
        name: 'Folder B',
        sortOrder: 0,
      );
      await fixture.insertFolder(
        id: 'folder-a',
        name: 'Folder A',
        sortOrder: 1,
      );
      await fixture.insertDeck(
        id: 'deck-b',
        folderId: 'folder-b',
        name: 'Deck B',
        sortOrder: 1,
      );
      await fixture.insertDeck(
        id: 'deck-a-zero',
        folderId: 'folder-a',
        name: 'Deck A Zero',
        sortOrder: 0,
      );
      await fixture.insertDeck(
        id: 'deck-a-due',
        folderId: 'folder-a',
        name: 'Deck A Due',
        sortOrder: 1,
      );
      await fixture.insertCard(
        id: 'b-1',
        deckId: 'deck-b',
        front: 'B1',
        back: 'B1',
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'b-2',
        deckId: 'deck-b',
        front: 'B2',
        back: 'B2',
        dueAtMs: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'a-due',
        deckId: 'deck-a-due',
        front: 'A due',
        back: 'A due',
        dueAtMs: now.millisecondsSinceEpoch,
      );

      final List<Object> beforeFlashcards = await db
          .select(db.flashcards)
          .get();
      final List<Object> beforeProgress = await db
          .select(db.flashcardProgress)
          .get();

      final Result<ProgressDueSummary> result = await repo
          .loadProgressDueSummary(now: now);

      final ProgressDueSummary summary =
          (result as Ok<ProgressDueSummary>).value;
      expect(
        summary.decks.map((DeckDueSummary row) => row.deckId).toList(),
        <String>['deck-b', 'deck-a-zero', 'deck-a-due'],
      );
      expect(
        summary.decks.map((DeckDueSummary row) => row.dueCount).toList(),
        <int>[2, 0, 1],
      );
      expect(summary.totalDueCount, 3);
      expect(
        summary.totalDueCount,
        summary.decks.fold<int>(
          0,
          (int total, DeckDueSummary row) => total + row.dueCount,
        ),
      );
      expect(await db.select(db.flashcards).get(), beforeFlashcards);
      expect(await db.select(db.flashcardProgress).get(), beforeProgress);
    },
  );

  test('empty database returns zero-filled box distribution', () async {
    final Result<BoxDistribution> result = await repo.loadBoxDistribution();

    final BoxDistribution distribution = (result as Ok<BoxDistribution>).value;
    expect(
      distribution.boxes.map((BoxDistributionItem row) => row.boxNumber),
      <int>[1, 2, 3, 4, 5, 6, 7, 8],
    );
    expect(
      distribution.boxes.every((BoxDistributionItem row) => row.cardCount == 0),
      isTrue,
    );
  });

  test(
    'box distribution counts existing boxes, zero-fills missing boxes, and does not mutate data',
    () async {
      final _ProgressFixture fixture = _ProgressFixture(db, now);
      await fixture.insertFolder(
        id: 'folder-1',
        name: 'Folder 1',
        sortOrder: 0,
      );
      await fixture.insertDeck(
        id: 'deck-1',
        folderId: 'folder-1',
        name: 'Deck 1',
        sortOrder: 0,
      );
      await fixture.insertCard(
        id: 'box-1-a',
        deckId: 'deck-1',
        front: 'B1A',
        back: 'B1A',
        boxNumber: 1,
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'box-1-b',
        deckId: 'deck-1',
        front: 'B1B',
        back: 'B1B',
        boxNumber: 1,
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'box-3',
        deckId: 'deck-1',
        front: 'B3',
        back: 'B3',
        boxNumber: 3,
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'box-8',
        deckId: 'deck-1',
        front: 'B8',
        back: 'B8',
        boxNumber: 8,
        dueAtMs: now.millisecondsSinceEpoch,
      );

      final int flashcardCountBefore = await db
          .select(db.flashcards)
          .get()
          .then((rows) => rows.length);
      final int progressCountBefore = await db
          .select(db.flashcardProgress)
          .get()
          .then((rows) => rows.length);

      final Result<BoxDistribution> result = await repo.loadBoxDistribution();

      final BoxDistribution distribution =
          (result as Ok<BoxDistribution>).value;
      expect(
        distribution.boxes.map((BoxDistributionItem row) => row.cardCount),
        <int>[2, 0, 1, 0, 0, 0, 0, 1],
      );
      expect(
        await db.select(db.flashcards).get(),
        hasLength(flashcardCountBefore),
      );
      expect(
        await db.select(db.flashcardProgress).get(),
        hasLength(progressCountBefore),
      );
    },
  );

  test('invalid box numbers surface an integrity failure', () async {
    final _ProgressFixture fixture = _ProgressFixture(db, now);
    await fixture.insertFolder(id: 'folder-1', name: 'Folder 1', sortOrder: 0);
    await fixture.insertDeck(
      id: 'deck-1',
      folderId: 'folder-1',
      name: 'Deck 1',
      sortOrder: 0,
    );
    await fixture.insertCard(
      id: 'bad-box',
      deckId: 'deck-1',
      front: 'Bad',
      back: 'Bad',
      boxNumber: 9,
      dueAtMs: now.millisecondsSinceEpoch,
    );

    final Result<BoxDistribution> result = await repo.loadBoxDistribution();

    expect(result, isA<Err<BoxDistribution>>());
    expect((result as Err<BoxDistribution>).failure, isA<IntegrityFailure>());
  });

  test('empty database returns zero study statistics', () async {
    final Result<StudyStatistics> result = await repo.loadStudyStatistics();

    final StudyStatistics statistics = (result as Ok<StudyStatistics>).value;
    expect(statistics.completedSessionCount, 0);
    expect(statistics.totalAttemptCount, 0);
    expect(statistics.correctCount, 0);
    expect(statistics.forgotCount, 0);
    expect(statistics.lastStudiedAt, isNull);
  });

  test(
    'study statistics count completed sessions, attempts, outcomes, and last studied at',
    () async {
      final _ProgressFixture fixture = _ProgressFixture(db, now);
      await fixture.insertCompletedSession(
        id: 'session-completed',
        startedAtMs: nowMs,
      );
      await fixture.insertFolder(
        id: 'folder-1',
        name: 'Folder 1',
        sortOrder: 0,
      );
      await fixture.insertDeck(
        id: 'deck-1',
        folderId: 'folder-1',
        name: 'Deck 1',
        sortOrder: 0,
      );
      await fixture.insertCard(
        id: 'a',
        deckId: 'deck-1',
        front: 'A',
        back: 'A',
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'b',
        deckId: 'deck-1',
        front: 'B',
        back: 'B',
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'c',
        deckId: 'deck-1',
        front: 'C',
        back: 'C',
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'd',
        deckId: 'deck-1',
        front: 'D',
        back: 'D',
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'e',
        deckId: 'deck-1',
        front: 'E',
        back: 'E',
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertSessionItem(
        id: 'item-a',
        sessionId: 'session-completed',
        flashcardId: 'a',
        sortOrder: 0,
        answeredAtMs: nowMs - 4000,
      );
      await fixture.insertSessionItem(
        id: 'item-b',
        sessionId: 'session-completed',
        flashcardId: 'b',
        sortOrder: 1,
        answeredAtMs: nowMs - 3000,
      );
      await fixture.insertSessionItem(
        id: 'item-c',
        sessionId: 'session-completed',
        flashcardId: 'c',
        sortOrder: 2,
        answeredAtMs: nowMs - 2000,
      );
      await fixture.insertSessionItem(
        id: 'item-d',
        sessionId: 'session-completed',
        flashcardId: 'd',
        sortOrder: 3,
        answeredAtMs: nowMs - 1000,
      );
      await fixture.insertAttempt(
        id: 'attempt-a',
        sessionItemId: 'item-a',
        result: 'perfect',
        studyMode: 'recall',
        attemptedAtMs: nowMs - 4000,
        boxBefore: 1,
        boxAfter: 2,
      );
      await fixture.insertAttempt(
        id: 'attempt-b',
        sessionItemId: 'item-b',
        result: 'initial_passed',
        studyMode: 'recall',
        attemptedAtMs: nowMs - 3000,
        boxBefore: 2,
        boxAfter: 3,
      );
      await fixture.insertAttempt(
        id: 'attempt-c',
        sessionItemId: 'item-c',
        result: 'recovered',
        studyMode: 'recall',
        attemptedAtMs: nowMs - 2000,
        boxBefore: 3,
        boxAfter: 3,
      );
      await fixture.insertAttempt(
        id: 'attempt-d',
        sessionItemId: 'item-d',
        result: 'forgot',
        studyMode: 'recall',
        attemptedAtMs: nowMs - 1000,
        boxBefore: 4,
        boxAfter: 1,
      );
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 'session-draft',
              entryType: 'deck',
              entryRefId: const Value<String?>(null),
              studyType: 'new_cards',
              status: 'draft',
              startedAt: nowMs,
              updatedAt: nowMs,
            ),
          );
      await fixture.insertSessionItem(
        id: 'item-e',
        sessionId: 'session-draft',
        flashcardId: 'e',
        sortOrder: 0,
        answeredAtMs: nowMs,
      );
      await fixture.insertAttempt(
        id: 'attempt-e',
        sessionItemId: 'item-e',
        result: 'perfect',
        studyMode: 'recall',
        attemptedAtMs: nowMs,
        boxBefore: 1,
        boxAfter: 2,
      );

      final int sessionsBefore = await db
          .select(db.studySessions)
          .get()
          .then((rows) => rows.length);
      final int attemptsBefore = await db
          .select(db.studyAttempts)
          .get()
          .then((rows) => rows.length);

      final Result<StudyStatistics> result = await repo.loadStudyStatistics();

      final StudyStatistics statistics = (result as Ok<StudyStatistics>).value;
      expect(statistics.completedSessionCount, 1);
      expect(statistics.totalAttemptCount, 5);
      expect(statistics.correctCount, 4);
      expect(statistics.forgotCount, 1);
      expect(
        statistics.lastStudiedAt,
        DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true),
      );
      expect(
        await db.select(db.studySessions).get(),
        hasLength(sessionsBefore),
      );
      expect(
        await db.select(db.studyAttempts).get(),
        hasLength(attemptsBefore),
      );
    },
  );

  test(
    'combined read model returns due summary, box distribution, and statistics together for mixed data',
    () async {
      final _ProgressFixture fixture = _ProgressFixture(db, now);
      await fixture.insertFolder(
        id: 'folder-1',
        name: 'Folder 1',
        sortOrder: 0,
      );
      await fixture.insertDeck(
        id: 'deck-1',
        folderId: 'folder-1',
        name: 'Deck 1',
        sortOrder: 0,
      );
      await fixture.insertCard(
        id: 'due',
        deckId: 'deck-1',
        front: 'Due',
        back: 'Due',
        boxNumber: 2,
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'future',
        deckId: 'deck-1',
        front: 'Future',
        back: 'Future',
        boxNumber: 3,
        dueAtMs: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await fixture.insertCard(
        id: 'suspended',
        deckId: 'deck-1',
        front: 'Suspended',
        back: 'Suspended',
        boxNumber: 4,
        dueAtMs: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        isSuspended: true,
      );
      await fixture.insertCard(
        id: 'buried',
        deckId: 'deck-1',
        front: 'Buried',
        back: 'Buried',
        boxNumber: 5,
        dueAtMs: now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        buriedUntilMs: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
      );
      await fixture.insertCompletedSession(
        id: 'session-completed',
        startedAtMs: nowMs - 5000,
      );
      await fixture.insertSessionItem(
        id: 'item-due',
        sessionId: 'session-completed',
        flashcardId: 'due',
        sortOrder: 0,
        answeredAtMs: nowMs - 5000,
      );
      await fixture.insertAttempt(
        id: 'attempt-due',
        sessionItemId: 'item-due',
        result: 'perfect',
        studyMode: 'recall',
        attemptedAtMs: nowMs - 5000,
        boxBefore: 2,
        boxAfter: 3,
      );

      final Result<ProgressReadModel> result = await repo.loadProgressReadModel(
        now: now,
      );

      final ProgressReadModel model = (result as Ok<ProgressReadModel>).value;
      expect(model.dueSummary.totalDueCount, 1);
      expect(model.dueSummary.decks.single.deckId, 'deck-1');
      expect(model.dueSummary.decks.single.dueCount, 1);
      expect(
        model.boxDistribution.boxes.map(
          (BoxDistributionItem row) => row.cardCount,
        ),
        <int>[0, 1, 1, 1, 1, 0, 0, 0],
      );
      expect(model.studyStatistics.completedSessionCount, 1);
      expect(model.studyStatistics.totalAttemptCount, 1);
      expect(model.studyStatistics.correctCount, 1);
      expect(model.studyStatistics.forgotCount, 0);
      expect(
        model.studyStatistics.lastStudiedAt,
        DateTime.fromMillisecondsSinceEpoch(nowMs - 5000, isUtc: true),
      );
    },
  );

  test(
    'attempt counts by day return local-day buckets in ascending order',
    () async {
      final _ProgressFixture fixture = _ProgressFixture(db, now);
      await fixture.insertFolder(
        id: 'folder-1',
        name: 'Folder 1',
        sortOrder: 0,
      );
      await fixture.insertDeck(
        id: 'deck-1',
        folderId: 'folder-1',
        name: 'Deck 1',
        sortOrder: 0,
      );
      await fixture.insertCard(
        id: 'card-1',
        deckId: 'deck-1',
        front: 'Card 1',
        back: 'Card 1',
        dueAtMs: now.millisecondsSinceEpoch,
      );
      await fixture.insertSession(
        id: 'session-1',
        startedAtMs: nowMs - 86_400_000,
      );
      await fixture.insertSessionItem(
        id: 'item-1',
        sessionId: 'session-1',
        flashcardId: 'card-1',
        sortOrder: 0,
        answeredAtMs: nowMs - 86_400_000,
      );
      await fixture.insertAttempt(
        id: 'attempt-yesterday',
        sessionItemId: 'item-1',
        result: 'perfect',
        studyMode: 'recall',
        attemptedAtMs: nowMs - 86_400_000,
        boxBefore: 1,
        boxAfter: 2,
      );
      await fixture.insertSession(id: 'session-2', startedAtMs: nowMs);
      await fixture.insertSessionItem(
        id: 'item-2',
        sessionId: 'session-2',
        flashcardId: 'card-1',
        sortOrder: 0,
        answeredAtMs: nowMs,
      );
      await fixture.insertAttempt(
        id: 'attempt-today-1',
        sessionItemId: 'item-2',
        result: 'perfect',
        studyMode: 'recall',
        attemptedAtMs: nowMs,
        boxBefore: 2,
        boxAfter: 3,
      );
      await fixture.insertAttempt(
        id: 'attempt-today-2',
        sessionItemId: 'item-2',
        result: 'forgot',
        studyMode: 'recall',
        attemptedAtMs: nowMs + 1000,
        boxBefore: 3,
        boxAfter: 1,
      );

      final Result<Map<DateTime, int>> result = await repo
          .loadAttemptCountsByDay();

      expect(result, isA<Ok<Map<DateTime, int>>>());
      final Map<DateTime, int> countsByDay =
          (result as Ok<Map<DateTime, int>>).value;
      expect(countsByDay.keys.toList(), <DateTime>[
        DateTime(2026, 1, 9),
        DateTime(2026, 1, 10),
      ]);
      expect(countsByDay[DateTime(2026, 1, 9)], 1);
      expect(countsByDay[DateTime(2026, 1, 10)], 2);
    },
  );
}
