import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';

void main() {
  // StudyRepositoryImpl.cancelSession (WBS 4.10.1): move the session to
  // `cancelled` without deleting the row; preserve attempts + items
  // (docs/contracts/usecase-contracts/study.md §CancelSessionUseCase).
  group('StudyRepositoryImpl.cancelSession', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyRepositoryImpl(dao: StudySessionDao(db));
    });
    tearDown(() => db.close());

    Future<void> seedSessionWithAttempt() async {
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
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'c1',
              deckId: 'd1',
              front: 'f',
              back: 'b',
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
              studyType: 'new_cards',
              status: 'in_progress',
              startedAt: now,
              updatedAt: now,
              entryRefId: const Value<String?>('d1'),
            ),
          );
      await db
          .into(db.studySessionItems)
          .insert(
            StudySessionItemsCompanion.insert(
              id: 'i1',
              sessionId: 's1',
              flashcardId: 'c1',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.studyAttempts)
          .insert(
            StudyAttemptsCompanion.insert(
              id: 'a1',
              sessionItemId: 'i1',
              result: 'perfect',
              studyMode: 'review',
              attemptedAt: now,
            ),
          );
    }

    test('cancels the session and preserves attempts + items', () async {
      await seedSessionWithAttempt();

      final result = await repository.cancelSession(id: 's1');

      expect(result.failure, isNull);
      final StudySessionRow row = await db.select(db.studySessions).getSingle();
      expect(row.status, 'cancelled', reason: 'status moved, row not deleted');
      expect(
        await db.select(db.studyAttempts).get(),
        hasLength(1),
        reason: 'recorded attempts preserved',
      );
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
    });

    test('a missing session is a NotFoundFailure', () async {
      final result = await repository.cancelSession(id: 'nope');
      expect(result.failure, isA<NotFoundFailure>());
    });

    test(
      'cancelling a completed session is an UnsupportedActionFailure',
      () async {
        await seedSessionWithAttempt();
        await (db.update(db.studySessions)..where((t) => t.id.equals('s1')))
            .write(const StudySessionsCompanion(status: Value('completed')));

        final result = await repository.cancelSession(id: 's1');

        expect(result.failure, isA<UnsupportedActionFailure>());
        final StudySessionRow row = await db
            .select(db.studySessions)
            .getSingle();
        expect(
          row.status,
          'completed',
          reason: 'terminal status not overwritten',
        );
      },
    );

    test('re-cancelling an already-cancelled session is unsupported', () async {
      await seedSessionWithAttempt();
      final first = await repository.cancelSession(id: 's1');
      expect(first.failure, isNull);

      // cancelled is terminal — re-cancel is a forbidden transition, not a no-op.
      final second = await repository.cancelSession(id: 's1');
      expect(second.failure, isA<UnsupportedActionFailure>());
    });
  });
}
