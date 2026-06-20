import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/session_status.dart';

void main() {
  // StudyRepositoryImpl.loadStudySessionReview (WBS 4.3.1): load the session
  // header + ordered items joined with flashcards
  // (docs/contracts/usecase-contracts/study.md §LoadStudySessionReviewUseCase).
  group('StudyRepositoryImpl.loadStudySessionReview', () {
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
            exampleSentence: Value<String?>('ex-$id'),
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

    Future<void> seedSession() async {
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
              studyType: 'new_cards',
              status: 'in_progress',
              startedAt: now,
              updatedAt: now,
              entryRefId: const Value<String?>('d1'),
            ),
          );
    }

    test('loads the header + ordered items joined with flashcards', () async {
      await seedSession();
      await insertCard('c1', 0);
      await insertCard('c2', 1);
      // Insert items out of order to prove the query orders by sort_order.
      await insertItem('i2', 'c2', 1);
      await insertItem('i1', 'c1', 0, answeredAt: now);

      final result = await repository.loadStudySessionReview(id: 's1');

      expect(result.failure, isNull);
      final StudySessionReview review = result.data!;
      expect(review.session.status, SessionStatus.inProgress);
      expect(
        review.items.map((i) => i.sessionItemId).toList(),
        <String>['i1', 'i2'],
        reason: 'ordered by sort_order',
      );
      expect(review.items.first.front, 'front-c1');
      expect(review.items.first.exampleSentence, 'ex-c1');
      expect(review.items.first.isAnswered, isTrue);
      expect(review.items.last.isAnswered, isFalse);
      expect(review.total, 2);
      expect(review.answeredCount, 1);
      expect(review.firstUnansweredIndex, 1);
      expect(review.isComplete, isFalse);
    });

    test('a missing session is a NotFoundFailure', () async {
      final result = await repository.loadStudySessionReview(id: 'nope');
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('a session with no items is a controlled ValidationFailure', () async {
      await seedSession();

      final result = await repository.loadStudySessionReview(id: 's1');

      expect(result.data, isNull);
      expect(result.failure, isA<ValidationFailure>());
    });
  });
}
