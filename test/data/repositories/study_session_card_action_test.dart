import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/mappers/study_mapper.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

late DateTime _studyActionTestNow;

class _StudyActionFixture {
  _StudyActionFixture(this.db, {DateTime? now})
    : _now = now ?? _studyActionTestNow;

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
    int? dueAt,
    int? boxNumber,
    int reviewCount = 0,
    int lapseCount = 0,
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
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
    if (dueAt != null ||
        boxNumber != null ||
        buriedUntil != null ||
        isSuspended ||
        reviewCount != 0 ||
        lapseCount != 0) {
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
              reviewCount: Value<int>(reviewCount),
              lapseCount: Value<int>(lapseCount),
              lastStudiedAt: const Value<int?>(null),
            ),
          );
    }
  }

  Future<void> insertSession({
    required String id,
    required String deckId,
    String status = 'in_progress',
    int? startedAt,
    int? updatedAt,
  }) async {
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: id,
            entryType: EntryType.deck.name,
            entryRefId: Value<String?>(deckId),
            studyType: StudyMapper.studyTypeToStorage(StudyType.newCards),
            status: status,
            startedAt: startedAt ?? _nowMs,
            updatedAt: updatedAt ?? _nowMs,
          ),
        );
  }

  Future<void> insertSessionItem({
    required String id,
    required String sessionId,
    required String flashcardId,
    int? answeredAt,
  }) async {
    await db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            flashcardId: flashcardId,
            sortOrder: 0,
            answeredAt: Value<int?>(answeredAt),
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
  }

  int get nowMs => _now.toUtc().millisecondsSinceEpoch;
}

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    _studyActionTestNow = DateTime(2026, 1, 15, 15, 30);
    repository = StudyRepositoryImpl(
      StudySessionDao(db),
      now: () => _studyActionTestNow,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'BS1: bury current session card sets buried_until to tomorrow local midnight + 1 second, removes the queued item, and touches the session',
    () async {
      const String folderId = 'folder-bury';
      const String deckId = 'deck-bury';
      const String cardId = 'card-bury';
      const String sessionId = 'session-bury';
      const String sessionItemId = 'item-bury';
      final _StudyActionFixture fixture = _StudyActionFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: fixture.nowMs,
        boxNumber: 4,
        reviewCount: 2,
        lapseCount: 1,
      );
      await fixture.insertSession(id: sessionId, deckId: deckId);
      await fixture.insertSessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final int beforeUpdatedAt =
          (await db.select(db.studySessions).getSingle()).updatedAt;
      _studyActionTestNow = DateTime(2026, 1, 15, 16, 0);

      final Result<void> result = await repository.buryStudySessionCard(
        sessionId: sessionId,
        flashcardId: cardId,
      );

      expect(result.isOk, isTrue);
      expect(await db.select(db.studySessionItems).get(), isEmpty);
      expect(await db.select(db.studyAttempts).get(), isEmpty);

      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();
      final StudySessionRow sessionRow = await db
          .select(db.studySessions)
          .getSingle();

      expect(progress.boxNumber, 4);
      expect(progress.dueAt, fixture.nowMs);
      expect(progress.reviewCount, 2);
      expect(progress.lapseCount, 1);
      expect(
        progress.buriedUntil,
        DateTime(2026, 1, 16, 0, 0, 1).millisecondsSinceEpoch,
      );
      expect(progress.isSuspended, isFalse);
      expect(sessionRow.updatedAt, greaterThan(beforeUpdatedAt));

      final Result<StudySessionReview> reloadResult = await repository
          .loadStudySessionReview(sessionId: sessionId);
      expect(reloadResult.isErr, isTrue);
      expect(reloadResult.failureOrNull, isA<StorageFailure>());
    },
  );

  test(
    'BS4: suspend current session card sets is_suspended=true, removes the queued item, and touches the session',
    () async {
      const String folderId = 'folder-suspend';
      const String deckId = 'deck-suspend';
      const String cardId = 'card-suspend';
      const String sessionId = 'session-suspend';
      const String sessionItemId = 'item-suspend';
      final _StudyActionFixture fixture = _StudyActionFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(
        id: cardId,
        deckId: deckId,
        dueAt: fixture.nowMs,
        boxNumber: 5,
        reviewCount: 7,
        lapseCount: 3,
      );
      await fixture.insertSession(id: sessionId, deckId: deckId);
      await fixture.insertSessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final int beforeUpdatedAt =
          (await db.select(db.studySessions).getSingle()).updatedAt;
      _studyActionTestNow = DateTime(2026, 1, 15, 16, 0);

      final Result<void> result = await repository.suspendStudySessionCard(
        sessionId: sessionId,
        flashcardId: cardId,
      );

      expect(result.isOk, isTrue);
      expect(await db.select(db.studySessionItems).get(), isEmpty);
      expect(await db.select(db.studyAttempts).get(), isEmpty);

      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();
      final StudySessionRow sessionRow = await db
          .select(db.studySessions)
          .getSingle();

      expect(progress.boxNumber, 5);
      expect(progress.dueAt, fixture.nowMs);
      expect(progress.reviewCount, 7);
      expect(progress.lapseCount, 3);
      expect(progress.buriedUntil, null);
      expect(progress.isSuspended, isTrue);
      expect(sessionRow.updatedAt, greaterThan(beforeUpdatedAt));

      final Result<void> reloadResult = await repository.loadStudySessionReview(
        sessionId: sessionId,
      );
      expect(reloadResult.isErr, isTrue);
      expect(reloadResult.failureOrNull, isA<StorageFailure>());
    },
  );

  test(
    'BS2: bury creates progress when missing without changing default SRS-safe fields',
    () async {
      const String folderId = 'folder-bury-missing';
      const String deckId = 'deck-bury-missing';
      const String cardId = 'card-bury-missing';
      const String sessionId = 'session-bury-missing';
      const String sessionItemId = 'item-bury-missing';
      final _StudyActionFixture fixture = _StudyActionFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertSession(id: sessionId, deckId: deckId);
      await fixture.insertSessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final Result<void> result = await repository.buryStudySessionCard(
        sessionId: sessionId,
        flashcardId: cardId,
      );

      expect(result.isOk, isTrue);
      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();
      expect(progress.boxNumber, 1);
      expect(progress.dueAt, null);
      expect(progress.reviewCount, 0);
      expect(progress.lapseCount, 0);
      expect(
        progress.buriedUntil,
        DateTime(2026, 1, 16, 0, 0, 1).millisecondsSinceEpoch,
      );
      expect(progress.isSuspended, isFalse);
    },
  );

  test(
    'BS5: suspend creates progress when missing without changing default SRS-safe fields',
    () async {
      const String folderId = 'folder-suspend-missing';
      const String deckId = 'deck-suspend-missing';
      const String cardId = 'card-suspend-missing';
      const String sessionId = 'session-suspend-missing';
      const String sessionItemId = 'item-suspend-missing';
      final _StudyActionFixture fixture = _StudyActionFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertSession(id: sessionId, deckId: deckId);
      await fixture.insertSessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final Result<void> result = await repository.suspendStudySessionCard(
        sessionId: sessionId,
        flashcardId: cardId,
      );

      expect(result.isOk, isTrue);
      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();
      expect(progress.boxNumber, 1);
      expect(progress.dueAt, null);
      expect(progress.reviewCount, 0);
      expect(progress.lapseCount, 0);
      expect(progress.buriedUntil, null);
      expect(progress.isSuspended, isTrue);
    },
  );

  test('BS10: missing session returns notFound', () async {
    final Result<void> result = await repository.buryStudySessionCard(
      sessionId: 'missing-session',
      flashcardId: 'missing-card',
    );

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test(
    'BS11: completed or cancelled sessions return a controlled validation failure',
    () async {
      const String folderId = 'folder-invalid-status';
      const String deckId = 'deck-invalid-status';
      const String cardId = 'card-invalid-status';
      final _StudyActionFixture fixture = _StudyActionFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);

      for (final String status in <String>['completed', 'cancelled']) {
        final String sessionId = 'session-$status';
        final String sessionItemId = 'item-$status';
        await fixture.insertSession(
          id: sessionId,
          deckId: deckId,
          status: status,
        );
        await fixture.insertSessionItem(
          id: sessionItemId,
          sessionId: sessionId,
          flashcardId: cardId,
        );

        final Result<void> result = await repository.suspendStudySessionCard(
          sessionId: sessionId,
          flashcardId: cardId,
        );

        expect(result.isErr, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
      }
    },
  );

  test(
    'BS12: flashcard not in session returns a controlled validation failure',
    () async {
      const String folderId = 'folder-not-in-session';
      const String deckId = 'deck-not-in-session';
      const String cardId = 'card-not-in-session';
      const String otherCardId = 'card-other';
      const String sessionId = 'session-not-in-session';
      final _StudyActionFixture fixture = _StudyActionFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertFlashcard(id: otherCardId, deckId: deckId);
      await fixture.insertSession(id: sessionId, deckId: deckId);
      await fixture.insertSessionItem(
        id: 'item-other',
        sessionId: sessionId,
        flashcardId: otherCardId,
      );

      final Result<void> result = await repository.buryStudySessionCard(
        sessionId: sessionId,
        flashcardId: cardId,
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    },
  );

  test(
    'BS13: already answered session items return a controlled validation failure',
    () async {
      const String folderId = 'folder-answered';
      const String deckId = 'deck-answered';
      const String cardId = 'card-answered';
      const String sessionId = 'session-answered';
      final _StudyActionFixture fixture = _StudyActionFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertSession(id: sessionId, deckId: deckId);
      await fixture.insertSessionItem(
        id: 'item-answered',
        sessionId: sessionId,
        flashcardId: cardId,
        answeredAt: fixture.nowMs,
      );

      final Result<void> result = await repository.buryStudySessionCard(
        sessionId: sessionId,
        flashcardId: cardId,
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    },
  );

  test(
    'BS15: burying in-session and then cancelling the session keeps fresh study entry from re-adding the buried card',
    () async {
      const String folderId = 'folder-fresh-bury';
      const String deckId = 'deck-fresh-bury';
      const String cardId = 'card-fresh-bury';
      const String sessionId = 'session-fresh-bury';
      const String sessionItemId = 'item-fresh-bury';
      final _StudyActionFixture fixture = _StudyActionFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertSession(id: sessionId, deckId: deckId);
      await fixture.insertSessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final Result<void> buryResult = await repository.buryStudySessionCard(
        sessionId: sessionId,
        flashcardId: cardId,
      );
      expect(buryResult.isOk, isTrue);

      final Result<void> cancelResult = await repository.cancelStudySession(
        sessionId: sessionId,
      );
      expect(cancelResult.isOk, isTrue);

      final Result<StudyEntryStartResult> startResult = await repository
          .startStudySession(
            scope: const StudyScope(
              entryType: EntryType.deck,
              entryRefId: deckId,
              studyType: StudyType.newCards,
            ),
          );

      final StudyEntryStartResult? value = startResult.valueOrNull;
      expect(value, isA<StudyEntryStartEmpty>());
      expect(
        (value as StudyEntryStartEmpty).emptyState.variant,
        StudyEntryEmptyVariant.allBuried,
      );
    },
  );

  test(
    'BS16: suspending in-session and then cancelling the session keeps fresh study entry from re-adding the suspended card',
    () async {
      const String folderId = 'folder-fresh-suspend';
      const String deckId = 'deck-fresh-suspend';
      const String cardId = 'card-fresh-suspend';
      const String sessionId = 'session-fresh-suspend';
      const String sessionItemId = 'item-fresh-suspend';
      final _StudyActionFixture fixture = _StudyActionFixture(db);
      await fixture.insertFolder(id: folderId);
      await fixture.insertDeck(id: deckId, folderId: folderId);
      await fixture.insertFlashcard(id: cardId, deckId: deckId);
      await fixture.insertSession(id: sessionId, deckId: deckId);
      await fixture.insertSessionItem(
        id: sessionItemId,
        sessionId: sessionId,
        flashcardId: cardId,
      );

      final Result<void> suspendResult = await repository
          .suspendStudySessionCard(sessionId: sessionId, flashcardId: cardId);
      expect(suspendResult.isOk, isTrue);

      final Result<void> cancelResult = await repository.cancelStudySession(
        sessionId: sessionId,
      );
      expect(cancelResult.isOk, isTrue);

      final Result<StudyEntryStartResult> startResult = await repository
          .startStudySession(
            scope: const StudyScope(
              entryType: EntryType.deck,
              entryRefId: deckId,
              studyType: StudyType.newCards,
            ),
          );

      final StudyEntryStartResult? value = startResult.valueOrNull;
      expect(value, isA<StudyEntryStartEmpty>());
      expect(
        (value as StudyEntryStartEmpty).emptyState.variant,
        StudyEntryEmptyVariant.allSuspended,
      );
    },
  );
}
