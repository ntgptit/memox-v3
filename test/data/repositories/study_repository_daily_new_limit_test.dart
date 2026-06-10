import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull;
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

late DateTime _studyTestNow;

class _StudyDbFixture {
  _StudyDbFixture(this.db, {DateTime? now}) : _now = now ?? _studyTestNow;

  final AppDatabase db;
  final DateTime _now;

  int get _nowMs => _now.toUtc().millisecondsSinceEpoch;

  Future<void> insertFolder({required String id}) => db
      .into(db.folders)
      .insert(
        FoldersCompanion.insert(
          id: id,
          name: 'Folder $id',
          contentMode: const Value<String>('decks'),
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
          createdAt: _nowMs,
          updatedAt: _nowMs,
        ),
      );

  Future<void> insertFlashcard({
    required String id,
    required String deckId,
    int sortOrder = 0,
  }) => db
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

  Future<void> insertProgress({
    required String flashcardId,
    int? dueAt,
    int boxNumber = 1,
  }) => db
      .into(db.flashcardProgress)
      .insert(
        FlashcardProgressCompanion.insert(
          flashcardId: flashcardId,
          boxNumber: Value<int>(boxNumber),
          dueAt: Value<int?>(dueAt),
        ),
      );

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
}

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    _studyTestNow = DateTime(2026, 1, 15, 15, 30);
    repository = StudyRepositoryImpl(
      StudySessionDao(db),
      now: () => _studyTestNow,
    );
  });

  tearDown(() async => db.close());

  test(
    'deck scope with 25 eligible new cards and no quota usage creates 20 items',
    () async {
      const String folderId = 'folder-daily-consumed';
      const String deckId = 'deck-daily-consumed';
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

      final result = await repository.startStudySession(
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: deckId,
          studyType: StudyType.newCards,
        ),
      );

      final value = result.valueOrNull;
      expect(value, isA<StudyEntryStartStarted>());
      final String sessionId = (value as StudyEntryStartStarted).sessionId;
      final items =
          await (db.select(db.studySessionItems)..where(
                (StudySessionItems row) => row.sessionId.equals(sessionId),
              ))
              .get();

      expect(items, hasLength(20));
      expect(
        items.map((row) => row.flashcardId),
        List<String>.generate(20, (int index) => 'card-$index'),
      );
      expect(
        items.map((row) => row.sortOrder),
        List<int>.generate(20, (int index) => index),
      );
    },
  );

  test('10 consumed new cards today leaves 10 eligible new cards', () async {
    const String folderId = 'folder-daily-partial';
    const String deckId = 'deck-daily-partial';
    const String consumedSessionId = 'session-daily-partial-consumed';
    final int twoHoursAgo = _studyTestNow
        .subtract(const Duration(hours: 2))
        .toUtc()
        .millisecondsSinceEpoch;
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    for (int index = 0; index < 30; index++) {
      await fixture.insertFlashcard(
        id: 'card-partial-$index',
        deckId: deckId,
        sortOrder: index,
      );
    }
    // BE V1: cancelled new-card sessions still consume today's quota because quota usage is derived
    // from persisted new-card session items, not session status.
    await fixture.insertResumableSession(
      id: consumedSessionId,
      entryType: EntryType.deck.name,
      entryRefId: deckId,
      studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      status: 'cancelled',
      startedAt: twoHoursAgo,
      updatedAt: twoHoursAgo,
    );
    for (int index = 0; index < 10; index++) {
      await fixture.insertStudySessionItem(
        id: 'item-daily-partial-$index',
        sessionId: consumedSessionId,
        flashcardId: 'card-partial-$index',
        sortOrder: index,
      );
    }

    final result = await repository.startStudySession(
      scope: const StudyScope(
        entryType: EntryType.deck,
        entryRefId: deckId,
        studyType: StudyType.newCards,
      ),
    );

    final value = result.valueOrNull;
    expect(value, isA<StudyEntryStartStarted>());
    final String sessionId = (value as StudyEntryStartStarted).sessionId;
    final items = await (db.select(
      db.studySessionItems,
    )..where((StudySessionItems row) => row.sessionId.equals(sessionId))).get();

    expect(items, hasLength(10));
    expect(
      items.map((row) => row.flashcardId),
      List<String>.generate(10, (int index) => 'card-partial-${index + 10}'),
    );
    expect(
      items.map((row) => row.sortOrder),
      List<int>.generate(10, (int index) => index),
    );
  });

  test(
    '20 consumed new cards today returns empty and does not persist a new session',
    () async {
      const String folderId = 'folder-daily-exhausted';
      const String deckId = 'deck-daily-exhausted';
      const String consumedSessionId = 'session-daily-exhausted-consumed';
      final int twoHoursAgo = _studyTestNow
          .subtract(const Duration(hours: 2))
          .toUtc()
          .millisecondsSinceEpoch;
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      for (int index = 0; index < 25; index++) {
        await fixture.insertFlashcard(
          id: 'card-exhausted-$index',
          deckId: deckId,
          sortOrder: index,
        );
      }
      await fixture.insertResumableSession(
        id: consumedSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        status: 'cancelled',
        startedAt: twoHoursAgo,
        updatedAt: twoHoursAgo,
      );
      for (int index = 0; index < 20; index++) {
        await fixture.insertStudySessionItem(
          id: 'item-daily-exhausted-$index',
          sessionId: consumedSessionId,
          flashcardId: 'card-exhausted-$index',
          sortOrder: index,
        );
      }

      final result = await repository.startStudySession(
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: deckId,
          studyType: StudyType.newCards,
        ),
      );

      final value = result.valueOrNull;
      expect(value, isA<StudyEntryStartEmpty>());
      expect(
        (value as StudyEntryStartEmpty).emptyState.variant,
        StudyEntryEmptyVariant.deckNoCards,
      );
      expect(await db.select(db.studySessions).get(), hasLength(1));
      expect(await db.select(db.studySessionItems).get(), hasLength(20));
    },
  );

  test('yesterday new-card items do not reduce today quota', () async {
    const String folderId = 'folder-daily-yesterday';
    const String deckId = 'deck-daily-yesterday';
    const String yesterdaySessionId = 'session-daily-yesterday';
    final int yesterday = _studyTestNow
        .subtract(const Duration(days: 1))
        .toUtc()
        .millisecondsSinceEpoch;
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    for (int index = 0; index < 25; index++) {
      await fixture.insertFlashcard(
        id: 'card-yesterday-$index',
        deckId: deckId,
        sortOrder: index,
      );
    }
    await fixture.insertResumableSession(
      id: yesterdaySessionId,
      entryType: EntryType.deck.name,
      entryRefId: deckId,
      studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      status: 'cancelled',
      startedAt: yesterday,
      updatedAt: yesterday,
    );
    for (int index = 0; index < 20; index++) {
      await fixture.insertStudySessionItem(
        id: 'item-daily-yesterday-$index',
        sessionId: yesterdaySessionId,
        flashcardId: 'card-yesterday-$index',
        sortOrder: index,
      );
    }

    final result = await repository.startStudySession(
      scope: const StudyScope(
        entryType: EntryType.deck,
        entryRefId: deckId,
        studyType: StudyType.newCards,
      ),
    );

    final value = result.valueOrNull;
    expect(value, isA<StudyEntryStartStarted>());
    final String sessionId = (value as StudyEntryStartStarted).sessionId;
    expect(await db.select(db.studySessions).get(), hasLength(2));
    expect(
      await (db.select(db.studySessionItems)
            ..where((StudySessionItems row) => row.sessionId.equals(sessionId)))
          .get(),
      hasLength(20),
    );
  });

  test('future new-card items do not reduce today quota', () async {
    const String folderId = 'folder-daily-future';
    const String deckId = 'deck-daily-future';
    const String futureSessionId = 'session-daily-future';
    final int tomorrow = _studyTestNow
        .add(const Duration(days: 1))
        .toUtc()
        .millisecondsSinceEpoch;
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    for (int index = 0; index < 25; index++) {
      await fixture.insertFlashcard(
        id: 'card-future-$index',
        deckId: deckId,
        sortOrder: index,
      );
    }
    await fixture.insertResumableSession(
      id: futureSessionId,
      entryType: EntryType.deck.name,
      entryRefId: deckId,
      studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
      status: 'cancelled',
      startedAt: tomorrow,
      updatedAt: tomorrow,
    );
    for (int index = 0; index < 20; index++) {
      await fixture.insertStudySessionItem(
        id: 'item-daily-future-$index',
        sessionId: futureSessionId,
        flashcardId: 'card-future-$index',
        sortOrder: index,
      );
    }

    final result = await repository.startStudySession(
      scope: const StudyScope(
        entryType: EntryType.deck,
        entryRefId: deckId,
        studyType: StudyType.newCards,
      ),
    );

    final value = result.valueOrNull;
    expect(value, isA<StudyEntryStartStarted>());
    final String sessionId = (value as StudyEntryStartStarted).sessionId;
    expect(await db.select(db.studySessions).get(), hasLength(2));
    expect(
      await (db.select(db.studySessionItems)
            ..where((StudySessionItems row) => row.sessionId.equals(sessionId)))
          .get(),
      hasLength(20),
    );
  });

  test(
    'SRS review ignores consumed new-card quota and still caps at 20',
    () async {
      const String folderId = 'folder-daily-srs';
      const String deckId = 'deck-daily-srs';
      const String consumedSessionId = 'session-daily-srs-consumed';
      final int twoHoursAgo = _studyTestNow
          .subtract(const Duration(hours: 2))
          .toUtc()
          .millisecondsSinceEpoch;
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      for (int index = 0; index < 25; index++) {
        final String cardId = 'card-srs-$index';
        await fixture.insertFlashcard(
          id: cardId,
          deckId: deckId,
          sortOrder: index,
        );
        await fixture.insertProgress(
          flashcardId: cardId,
          dueAt: _studyTestNow
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
        );
      }
      await fixture.insertResumableSession(
        id: consumedSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        status: 'cancelled',
        startedAt: twoHoursAgo,
        updatedAt: twoHoursAgo,
      );
      for (int index = 0; index < 20; index++) {
        await fixture.insertStudySessionItem(
          id: 'item-daily-srs-$index',
          sessionId: consumedSessionId,
          flashcardId: 'card-srs-$index',
          sortOrder: index,
        );
      }

      final result = await repository.startStudySession(
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: deckId,
          studyType: StudyType.srsReview,
        ),
      );

      final value = result.valueOrNull;
      expect(value, isA<StudyEntryStartStarted>());
      final String sessionId = (value as StudyEntryStartStarted).sessionId;
      expect(await db.select(db.studySessions).get(), hasLength(2));
      expect(
        await (db.select(db.studySessionItems)..where(
              (StudySessionItems row) => row.sessionId.equals(sessionId),
            ))
            .get(),
        hasLength(20),
      );
    },
  );

  test('createSession directly caps at maxSessionItems', () async {
    const String folderId = 'folder-direct-create';
    const String deckId = 'deck-direct-create';
    final _StudyDbFixture fixture = _StudyDbFixture(db);
    await fixture.insertFolder(id: folderId);
    await fixture.insertDeck(id: deckId, folderId: folderId);
    for (int index = 0; index < 25; index++) {
      await fixture.insertFlashcard(
        id: 'card-direct-$index',
        deckId: deckId,
        sortOrder: index,
      );
    }

    final result = await repository.createSession(
      scope: const StudyScope(
        entryType: EntryType.deck,
        entryRefId: deckId,
        studyType: StudyType.newCards,
      ),
      flashcardIds: List<String>.generate(
        25,
        (int index) => 'card-direct-$index',
      ),
    );

    final session = result.valueOrNull;
    expect(session != null, isTrue);
    final List<StudySessionItemRow> items =
        await (db.select(db.studySessionItems)..where(
              (StudySessionItems row) => row.sessionId.equals(session!.id),
            ))
            .get();

    expect(items, hasLength(20));
    expect(
      items.map((row) => row.sortOrder),
      List<int>.generate(20, (int index) => index),
    );
  });

  test(
    'restartStudySession leaves the previous session untouched when the daily new quota is exhausted',
    () async {
      const String folderId = 'folder-restart-daily-empty';
      const String deckId = 'deck-restart-daily-empty';
      const String consumedSessionId = 'session-restart-daily-consumed';
      const String previousSessionId = 'session-restart-daily-old';
      final int threeHoursAgo = _studyTestNow
          .subtract(const Duration(hours: 3))
          .toUtc()
          .millisecondsSinceEpoch;
      final int yesterday = _studyTestNow
          .subtract(const Duration(days: 1))
          .toUtc()
          .millisecondsSinceEpoch;
      final _StudyDbFixture fixture = _StudyDbFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      for (int index = 0; index < 25; index++) {
        await fixture.insertFlashcard(
          id: 'card-restart-daily-$index',
          deckId: deckId,
          sortOrder: index,
        );
      }
      await fixture.insertResumableSession(
        id: consumedSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        status: 'cancelled',
        startedAt: threeHoursAgo,
        updatedAt: threeHoursAgo,
      );
      for (int index = 0; index < 20; index++) {
        await fixture.insertStudySessionItem(
          id: 'item-restart-daily-consumed-$index',
          sessionId: consumedSessionId,
          flashcardId: 'card-restart-daily-$index',
          sortOrder: index,
        );
      }
      await fixture.insertResumableSession(
        id: previousSessionId,
        entryType: EntryType.deck.name,
        entryRefId: deckId,
        studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
        startedAt: yesterday,
        updatedAt: yesterday,
      );
      await fixture.insertStudySessionItem(
        id: 'item-restart-daily-old',
        sessionId: previousSessionId,
        flashcardId: 'card-restart-daily-20',
      );

      final result = await repository.restartStudySession(
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
        (await db.select(db.studySessions).get())
            .firstWhere((StudySessionRow row) => row.id == previousSessionId)
            .status,
        'in_progress',
      );
      expect(await db.select(db.studySessionItems).get(), hasLength(21));
    },
  );
}
