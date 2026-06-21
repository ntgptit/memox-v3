import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';

void main() {
  // StudyRepositoryImpl.finalizeStudySession (WBS 4.6.1): the finalization
  // transaction — validate all answered, apply SRS outcome, mark completed,
  // rollback on failure (decision rows S9/S10).
  group('StudyRepositoryImpl.finalizeStudySession', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyRepositoryImpl(dao: StudySessionDao(db));
    });
    tearDown(() => db.close());

    Future<void> insertCard(String id, {bool suspended = false, int? buried}) =>
        db
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
            )
            .then((_) async {
              await db
                  .into(db.flashcardProgress)
                  .insert(
                    FlashcardProgressCompanion.insert(
                      flashcardId: id,
                      boxNumber: const Value<int>(2),
                      isSuspended: Value<bool>(suspended),
                      buriedUntil: Value<int?>(buried),
                    ),
                  );
            });

    Future<void> insertItem(
      String id,
      String cardId, {
      int? answeredAt,
      String? attemptResult,
    }) async {
      await db
          .into(db.studySessionItems)
          .insert(
            StudySessionItemsCompanion.insert(
              id: id,
              sessionId: 's1',
              flashcardId: cardId,
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
              answeredAt: Value<int?>(answeredAt),
            ),
          );
      if (attemptResult != null) {
        await db
            .into(db.studyAttempts)
            .insert(
              StudyAttemptsCompanion.insert(
                id: 'att-$id',
                sessionItemId: id,
                result: attemptResult,
                studyMode: 'recall',
                attemptedAt: now,
              ),
            );
      }
    }

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
              startedAt: now,
              updatedAt: now,
              entryRefId: const Value<String?>('d1'),
            ),
          );
    }

    test(
      'finalizes a fully answered session: progress updated + completed',
      () async {
        await seedSession();
        await insertCard('c1');
        await insertCard('c2');
        await insertItem('i1', 'c1', answeredAt: now, attemptResult: 'perfect');
        await insertItem('i2', 'c2', answeredAt: now, attemptResult: 'forgot');

        final result = await repository.finalizeStudySession(
          sessionId: 's1',
          now: now + 9,
        );

        expect(result.failure, isNull);
        final StudySessionRow session = await db
            .select(db.studySessions)
            .getSingle();
        expect(session.status, 'completed');
        expect(
          session.updatedAt,
          now + 9,
          reason: 'finalize touches updated_at',
        );

        final c1 = await (db.select(
          db.flashcardProgress,
        )..where((t) => t.flashcardId.equals('c1'))).getSingle();
        expect(c1.boxNumber, 3, reason: 'perfect: box 2 → 3');
        final c2 = await (db.select(
          db.flashcardProgress,
        )..where((t) => t.flashcardId.equals('c2'))).getSingle();
        expect(c2.boxNumber, 1, reason: 'forgot: box → 1');
        expect(c2.lapseCount, 1);
      },
    );

    test(
      'an unanswered item is a FinalizationFailure and keeps the session open',
      () async {
        await seedSession();
        await insertCard('c1');
        await insertCard('c2');
        await insertItem('i1', 'c1', answeredAt: now, attemptResult: 'perfect');
        await insertItem('i2', 'c2'); // unanswered

        final result = await repository.finalizeStudySession(
          sessionId: 's1',
          now: now,
        );

        expect(result.failure, isA<FinalizationFailure>());
        final StudySessionRow session = await db
            .select(db.studySessions)
            .getSingle();
        expect(session.status, 'in_progress', reason: 'session stays open');
        // No progress mutation: c1 still at its seeded box.
        final c1 = await (db.select(
          db.flashcardProgress,
        )..where((t) => t.flashcardId.equals('c1'))).getSingle();
        expect(c1.boxNumber, 2, reason: 'no partial finalize');
      },
    );

    test(
      'finalizing a terminal session is an UnsupportedActionFailure',
      () async {
        await seedSession(status: 'completed');
        final result = await repository.finalizeStudySession(
          sessionId: 's1',
          now: now,
        );
        expect(result.failure, isA<UnsupportedActionFailure>());
      },
    );

    test('a missing session is a NotFoundFailure', () async {
      final result = await repository.finalizeStudySession(
        sessionId: 'nope',
        now: now,
      );
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('preserves suspend/bury state across finalization', () async {
      await seedSession();
      await insertCard('c1', suspended: true, buried: now + 999);
      await insertItem('i1', 'c1', answeredAt: now, attemptResult: 'perfect');

      await repository.finalizeStudySession(sessionId: 's1', now: now);

      final c1 = await db.select(db.flashcardProgress).getSingle();
      expect(c1.boxNumber, 3, reason: 'box still advances');
      expect(c1.isSuspended, isTrue, reason: 'suspend preserved');
      expect(c1.buriedUntil, now + 999, reason: 'bury preserved');
    });
  });
}
