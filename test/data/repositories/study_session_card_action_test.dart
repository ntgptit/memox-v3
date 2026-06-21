import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';

void main() {
  // StudyRepositoryImpl bury/suspend in-session actions (WBS 4.11.2): set the one
  // action field, remove the queue item, touch updated_at, record NO attempt, and
  // preserve SRS box/due/counters (decision rows BS1/BS2/BS4/BS5;
  // docs/contracts/usecase-contracts/study.md §Bury/Suspend).
  group('StudyRepositoryImpl bury/suspend in-session', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    // A fixed "now" inside a known local day so the tomorrow-midnight maths is
    // deterministic regardless of the test machine's timezone.
    final int now = DateTime(2026, 6, 21, 9, 30).millisecondsSinceEpoch;

    int expectedBuriedUntil() {
      final DateTime local = DateTime.fromMillisecondsSinceEpoch(now).toLocal();
      return DateTime(
        local.year,
        local.month,
        local.day,
      ).add(const Duration(days: 1, seconds: 1)).millisecondsSinceEpoch;
    }

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyRepositoryImpl(dao: StudySessionDao(db));
    });
    tearDown(() => db.close());

    Future<void> insertCard(String id) => db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: 'd1',
            front: id,
            back: id,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );

    Future<void> insertProgress(
      String cardId, {
      int box = 3,
      int? dueAt,
      int reviewCount = 5,
      int lapseCount = 2,
    }) => db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion.insert(
            flashcardId: cardId,
            boxNumber: Value<int>(box),
            dueAt: Value<int?>(dueAt),
            reviewCount: Value<int>(reviewCount),
            lapseCount: Value<int>(lapseCount),
          ),
        );

    Future<void> insertItem(
      String id,
      String cardId, {
      int? answeredAt,
      String sessionId = 's1',
    }) => db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            flashcardId: cardId,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
            answeredAt: Value<int?>(answeredAt),
          ),
        );

    Future<void> seedSession({String status = 'in_progress'}) async {
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'f1',
              name: 'f1',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'f1',
              name: 'd1',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 's1',
              entryType: 'deck',
              studyType: 'srs_review',
              status: status,
              startedAt: now - 10000,
              updatedAt: now - 10000,
              entryRefId: const Value<String?>('d1'),
            ),
          );
    }

    Future<FlashcardProgressRow?> progress(String cardId) => (db.select(
      db.flashcardProgress,
    )..where((t) => t.flashcardId.equals(cardId))).getSingleOrNull();

    Future<int> itemCount() async =>
        (await db.select(db.studySessionItems).get()).length;

    Future<int> attemptCount() async =>
        (await db.select(db.studyAttempts).get()).length;

    test('bury sets buried_until, removes item, preserves SRS (BS1)', () async {
      await seedSession();
      await insertCard('c1');
      await insertProgress(
        'c1',
        box: 3,
        dueAt: now - 100,
        reviewCount: 5,
        lapseCount: 2,
      );
      await insertItem('i1', 'c1');

      final result = await repository.buryStudySessionCard(
        sessionId: 's1',
        flashcardId: 'c1',
        now: now,
      );

      expect(result.failure, isNull);
      final FlashcardProgressRow? p = await progress('c1');
      expect(p!.buriedUntil, expectedBuriedUntil());
      expect(p.isSuspended, isFalse);
      expect(p.boxNumber, 3, reason: 'box preserved');
      expect(p.dueAt, now - 100, reason: 'due_at preserved');
      expect(p.reviewCount, 5);
      expect(p.lapseCount, 2);
      expect(await itemCount(), 0, reason: 'item removed from queue');
      expect(await attemptCount(), 0, reason: 'no attempt recorded');

      final session = await db.select(db.studySessions).getSingle();
      expect(session.updatedAt, now, reason: 'updated_at touched');
    });

    test('bury creates default progress for a new card (BS2)', () async {
      await seedSession();
      await insertCard('c1'); // no progress row
      await insertItem('i1', 'c1');

      final result = await repository.buryStudySessionCard(
        sessionId: 's1',
        flashcardId: 'c1',
        now: now,
      );

      expect(result.failure, isNull);
      final FlashcardProgressRow? p = await progress('c1');
      expect(p, isNotNull, reason: 'progress row created');
      expect(p!.buriedUntil, expectedBuriedUntil());
      expect(p.boxNumber, 1, reason: 'SRS-safe default box');
      expect(p.dueAt, isNull);
      expect(p.reviewCount, 0);
      expect(p.lapseCount, 0);
    });

    test(
      'suspend sets is_suspended, removes item, preserves SRS (BS4)',
      () async {
        await seedSession();
        await insertCard('c1');
        await insertProgress('c1', box: 4, dueAt: now + 5000);
        await insertItem('i1', 'c1');

        final result = await repository.suspendStudySessionCard(
          sessionId: 's1',
          flashcardId: 'c1',
          now: now,
        );

        expect(result.failure, isNull);
        final FlashcardProgressRow? p = await progress('c1');
        expect(p!.isSuspended, isTrue);
        expect(
          p.buriedUntil,
          isNull,
          reason: 'suspend does not set buried_until',
        );
        expect(p.boxNumber, 4);
        expect(p.dueAt, now + 5000);
        expect(await itemCount(), 0);
        expect(await attemptCount(), 0);
      },
    );

    test('suspend preserves an existing buried_until (BS4 edge)', () async {
      await seedSession();
      await insertCard('c1');
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: 'c1',
              boxNumber: const Value<int>(2),
              buriedUntil: Value<int?>(now + 99999),
            ),
          );
      await insertItem('i1', 'c1');

      final result = await repository.suspendStudySessionCard(
        sessionId: 's1',
        flashcardId: 'c1',
        now: now,
      );

      expect(result.failure, isNull);
      final FlashcardProgressRow? p = await progress('c1');
      expect(p!.isSuspended, isTrue);
      expect(
        p.buriedUntil,
        now + 99999,
        reason: 'suspend leaves an existing buried_until untouched',
      );
    });

    test('suspend creates default progress for a new card (BS5)', () async {
      await seedSession();
      await insertCard('c1');
      await insertItem('i1', 'c1');

      final result = await repository.suspendStudySessionCard(
        sessionId: 's1',
        flashcardId: 'c1',
        now: now,
      );

      expect(result.failure, isNull);
      final FlashcardProgressRow? p = await progress('c1');
      expect(p!.isSuspended, isTrue);
      expect(p.boxNumber, 1);
      expect(p.reviewCount, 0);
    });

    test('a non-in_progress session is an UnsupportedActionFailure', () async {
      await seedSession(status: 'completed');
      await insertCard('c1');
      await insertItem('i1', 'c1');

      final result = await repository.buryStudySessionCard(
        sessionId: 's1',
        flashcardId: 'c1',
        now: now,
      );

      expect(result.failure, isA<UnsupportedActionFailure>());
      expect(await itemCount(), 1, reason: 'queue untouched');
    });

    test('a missing session is a NotFoundFailure', () async {
      final result = await repository.suspendStudySessionCard(
        sessionId: 'nope',
        flashcardId: 'c1',
        now: now,
      );
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('a card not in the session is a NotFoundFailure', () async {
      await seedSession();
      await insertCard('c1');
      await insertItem('i1', 'c1');

      final result = await repository.buryStudySessionCard(
        sessionId: 's1',
        flashcardId: 'other',
        now: now,
      );

      expect(result.failure, isA<NotFoundFailure>());
    });

    test('an already-answered card is an UnsupportedActionFailure', () async {
      await seedSession();
      await insertCard('c1');
      await insertItem('i1', 'c1', answeredAt: now - 50);

      final result = await repository.suspendStudySessionCard(
        sessionId: 's1',
        flashcardId: 'c1',
        now: now,
      );

      expect(result.failure, isA<UnsupportedActionFailure>());
      expect(await itemCount(), 1, reason: 'answered item not removed');
    });
  });
}
