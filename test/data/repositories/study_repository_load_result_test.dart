import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/session_status.dart';

void main() {
  // StudyRepositoryImpl.loadStudySessionResult (WBS 4.7.1): header + ordered
  // items joined with flashcards, each paired with the terminal AttemptResult
  // derived from its attempts (last-attempt classifier), plus aggregate counts
  // (docs/contracts/usecase-contracts/study.md §LoadStudySessionResultUseCase).
  group('StudyRepositoryImpl.loadStudySessionResult', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyRepositoryImpl(dao: StudySessionDao(db));
    });
    tearDown(() => db.close());

    Future<void> insertCard(String id, int order) => db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: 'd1',
            front: 'front-$id',
            back: 'back-$id',
            sortOrder: order,
            createdAt: now,
            updatedAt: now,
          ),
        );

    Future<void> insertItem(
      String id,
      String cardId,
      int order, {
      int? answeredAt,
    }) => db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: 's1',
            flashcardId: cardId,
            sortOrder: order,
            createdAt: now,
            updatedAt: now,
            answeredAt: Value<int?>(answeredAt),
          ),
        );

    Future<void> insertAttempt(
      String id,
      String itemId,
      String result,
      int attemptedAt,
    ) => db
        .into(db.studyAttempts)
        .insert(
          StudyAttemptsCompanion.insert(
            id: id,
            sessionItemId: itemId,
            result: result,
            studyMode: 'review',
            attemptedAt: attemptedAt,
          ),
        );

    Future<void> seedSession({String status = 'completed'}) async {
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
      'returns header + ordered items with terminal results and counts',
      () async {
        await seedSession();
        await insertCard('c1', 0);
        await insertCard('c2', 1);
        await insertCard('c3', 2);
        // Insert items out of order to prove ordering by sort_order.
        await insertItem('i3', 'c3', 2, answeredAt: now);
        await insertItem('i1', 'c1', 0, answeredAt: now);
        await insertItem('i2', 'c2', 1, answeredAt: now);
        // i1 passed; i2 forgot; i3 recovered (an earlier forgot then a pass).
        await insertAttempt('a1', 'i1', 'perfect', now);
        await insertAttempt('a2', 'i2', 'forgot', now);
        await insertAttempt('a3a', 'i3', 'forgot', now);
        await insertAttempt('a3b', 'i3', 'perfect', now + 1);

        final result = await repository.loadStudySessionResult(id: 's1');

        expect(result.failure, isNull);
        final StudySessionResult summary = result.data!;
        expect(summary.session.status, SessionStatus.completed);
        expect(
          summary.items.map((i) => i.sessionItemId).toList(),
          <String>['i1', 'i2', 'i3'],
          reason: 'ordered by sort_order',
        );
        expect(summary.items[0].result, AttemptResult.perfect);
        expect(summary.items[1].result, AttemptResult.forgot);
        expect(
          summary.items[2].result,
          AttemptResult.recovered,
          reason: 'earlier forgot then a passing last attempt → recovered',
        );
        expect(summary.items.first.front, 'front-c1');
        expect(summary.total, 3);
        expect(summary.answeredCount, 3);
        expect(summary.forgotCount, 1);
        expect(summary.passedCount, 2);
      },
    );

    test('an unanswered item has a null terminal result', () async {
      await seedSession(status: 'in_progress');
      await insertCard('c1', 0);
      await insertItem('i1', 'c1', 0);

      final result = await repository.loadStudySessionResult(id: 's1');

      expect(result.failure, isNull);
      final StudySessionResult summary = result.data!;
      expect(summary.items.single.result, isNull);
      expect(summary.items.single.isAnswered, isFalse);
      expect(summary.total, 1);
      expect(summary.answeredCount, 0);
      expect(summary.forgotCount, 0);
      expect(summary.passedCount, 0);
    });

    test('a missing session is a NotFoundFailure', () async {
      final result = await repository.loadStudySessionResult(id: 'nope');
      expect(result.data, isNull);
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('a session with no items is a controlled ValidationFailure', () async {
      await seedSession();

      final result = await repository.loadStudySessionResult(id: 's1');

      expect(result.data, isNull);
      expect(result.failure, isA<ValidationFailure>());
    });
  });
}
