import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/types/entry_type.dart';

/// Authoritative interval ladder from `docs/business/srs/srs-review.md`
/// §Interval table. Finalization must schedule `due_at = now + interval[box]`
/// for the box the card lands in.
const Map<int, Duration> _intervalByBox = <int, Duration>{
  1: Duration(days: 1),
  2: Duration(days: 2),
  3: Duration(days: 3),
  4: Duration(days: 4),
  5: Duration(days: 5),
  6: Duration(days: 12),
  7: Duration(days: 30),
  8: Duration(days: 60),
};

class _SrsFixture {
  _SrsFixture(this.db, {DateTime? now}) : _now = now ?? _srsTestNow;

  final AppDatabase db;
  final DateTime _now;

  DateTime get now => _now;

  int get nowMs => _now.toUtc().millisecondsSinceEpoch;

  Future<void> seedDeck({
    required String folderId,
    required String deckId,
  }) async {
    await db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(
            id: folderId,
            parentId: const Value<String?>(null),
            name: 'Folder $folderId',
            contentMode: const Value<String>('decks'),
            sortOrder: const Value<int>(0),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: deckId,
            folderId: folderId,
            name: 'Deck $deckId',
            targetLanguage: const Value<String>('korean'),
            sortOrder: const Value<int>(0),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
  }

  Future<void> seedSession({
    required String sessionId,
    required String deckId,
  }) async {
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: sessionId,
            entryType: EntryType.deck.name,
            entryRefId: Value<String?>(deckId),
            studyType: 'new_cards',
            status: 'in_progress',
            startedAt: nowMs,
            updatedAt: nowMs,
          ),
        );
  }

  /// Inserts a flashcard at [boxNumber] with one answered session item and
  /// one attempt row per entry in [attemptResults] (in order).
  Future<void> seedAnsweredCard({
    required String sessionId,
    required String deckId,
    required String cardId,
    required int boxNumber,
    required List<String> attemptResults,
  }) async {
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: cardId,
            deckId: deckId,
            front: 'Front $cardId',
            back: 'Back $cardId',
            sortOrder: const Value<int>(0),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
    await db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion(
            flashcardId: Value<String>(cardId),
            boxNumber: Value<int>(boxNumber),
            dueAt: Value<int?>(nowMs),
            reviewCount: const Value<int>(0),
            lapseCount: const Value<int>(0),
          ),
        );
    final String itemId = 'item-$cardId';
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
    for (int i = 0; i < attemptResults.length; i++) {
      await db
          .into(db.studyAttempts)
          .insert(
            StudyAttemptsCompanion.insert(
              id: 'attempt-$cardId-$i',
              sessionItemId: itemId,
              result: attemptResults[i],
              studyMode: 'recall',
              boxBefore: Value<int>(boxNumber),
              boxAfter: Value<int>(boxNumber),
              attemptedAt: nowMs + i,
            ),
          );
    }
  }

  Future<FlashcardProgressRow> progressOf(String cardId) async => (db.select(
    db.flashcardProgress,
  )..where((FlashcardProgress t) => t.flashcardId.equals(cardId))).getSingle();
}

late DateTime _srsTestNow;

void _expectDueAtMatchesInterval({
  required FlashcardProgressRow progress,
  required int box,
  required DateTime now,
}) {
  final DateTime localNow = now.toLocal();
  final DateTime expectedDueAt = DateTime(
    localNow.year,
    localNow.month,
    localNow.day,
  ).add(_intervalByBox[box]!);
  final int dueAt = progress.dueAt!;
  expect(
    dueAt,
    expectedDueAt.millisecondsSinceEpoch,
    reason:
        'box $box due_at must normalize to local midnight of the target day',
  );
}

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;
  late DateTime now;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 1, 15, 15, 30);
    _srsTestNow = now;
    repository = StudyRepositoryImpl(
      StudySessionDao(db),
      now: () => _srsTestNow,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'S11: perfect from boxes 1-7 advances one box and schedules now + interval[next]',
    () async {
      final _SrsFixture fixture = _SrsFixture(db);
      await fixture.seedDeck(folderId: 'folder-s11', deckId: 'deck-s11');
      await fixture.seedSession(sessionId: 'session-s11', deckId: 'deck-s11');
      for (int box = 1; box <= 7; box++) {
        await fixture.seedAnsweredCard(
          sessionId: 'session-s11',
          deckId: 'deck-s11',
          cardId: 'card-s11-box$box',
          boxNumber: box,
          attemptResults: const <String>['perfect'],
        );
      }

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: 'session-s11',
      );

      expect(result.isOk, isTrue);
      for (int box = 1; box <= 7; box++) {
        final FlashcardProgressRow progress = await fixture.progressOf(
          'card-s11-box$box',
        );
        expect(
          progress.boxNumber,
          box + 1,
          reason: 'perfect from box $box must land in box ${box + 1}',
        );
        expect(progress.reviewCount, 1);
        expect(progress.lapseCount, 0);
        _expectDueAtMatchesInterval(progress: progress, box: box + 1, now: now);
      }
    },
  );

  test(
    'S14: perfect at box 8 stays in box 8 and schedules now + interval[8]',
    () async {
      final _SrsFixture fixture = _SrsFixture(db);
      await fixture.seedDeck(folderId: 'folder-s14', deckId: 'deck-s14');
      await fixture.seedSession(sessionId: 'session-s14', deckId: 'deck-s14');
      await fixture.seedAnsweredCard(
        sessionId: 'session-s14',
        deckId: 'deck-s14',
        cardId: 'card-s14',
        boxNumber: 8,
        attemptResults: const <String>['perfect'],
      );

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: 'session-s14',
      );

      expect(result.isOk, isTrue);
      final FlashcardProgressRow progress = await fixture.progressOf(
        'card-s14',
      );
      expect(progress.boxNumber, 8);
      expect(progress.lapseCount, 0);
      _expectDueAtMatchesInterval(progress: progress, box: 8, now: now);
    },
  );

  test(
    'S12+S15: forgot resets to box 1, increments lapse_count, schedules now + interval[1]',
    () async {
      final _SrsFixture fixture = _SrsFixture(db);
      await fixture.seedDeck(folderId: 'folder-s12', deckId: 'deck-s12');
      await fixture.seedSession(sessionId: 'session-s12', deckId: 'deck-s12');
      await fixture.seedAnsweredCard(
        sessionId: 'session-s12',
        deckId: 'deck-s12',
        cardId: 'card-s12',
        boxNumber: 5,
        attemptResults: const <String>['forgot'],
      );

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: 'session-s12',
      );

      expect(result.isOk, isTrue);
      final FlashcardProgressRow progress = await fixture.progressOf(
        'card-s12',
      );
      expect(progress.boxNumber, 1);
      expect(progress.reviewCount, 1);
      expect(progress.lapseCount, 1);
      _expectDueAtMatchesInterval(progress: progress, box: 1, now: now);
    },
  );

  test(
    'S13: forgot-then-perfect finalizes as recovered, keeps the box, schedules now + interval[box]',
    () async {
      final _SrsFixture fixture = _SrsFixture(db);
      await fixture.seedDeck(folderId: 'folder-s13', deckId: 'deck-s13');
      await fixture.seedSession(sessionId: 'session-s13', deckId: 'deck-s13');
      await fixture.seedAnsweredCard(
        sessionId: 'session-s13',
        deckId: 'deck-s13',
        cardId: 'card-s13',
        boxNumber: 4,
        attemptResults: const <String>['forgot', 'perfect'],
      );

      final Result<void> result = await repository.finalizeStudySession(
        sessionId: 'session-s13',
      );

      expect(result.isOk, isTrue);
      final FlashcardProgressRow progress = await fixture.progressOf(
        'card-s13',
      );
      expect(progress.boxNumber, 4);
      expect(progress.reviewCount, 1);
      expect(progress.lapseCount, 0);
      _expectDueAtMatchesInterval(progress: progress, box: 4, now: now);
    },
  );
}
