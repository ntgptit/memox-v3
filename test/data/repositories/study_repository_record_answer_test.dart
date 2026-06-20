import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

void main() {
  // StudyRepositoryImpl.recordStudySessionAnswer (WBS 4.4.1): insert one
  // terminal attempt, mark the item answered, touch updated_at; keep
  // flashcard_progress unchanged (decision rows S35/S36).
  group('StudyRepositoryImpl.recordStudySessionAnswer', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyRepositoryImpl(dao: StudySessionDao(db));
    });
    tearDown(() => db.close());

    Future<void> seed({
      int? progressBox,
      String status = 'in_progress',
      int? itemAnsweredAt,
    }) async {
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
      if (progressBox != null) {
        await db
            .into(db.flashcardProgress)
            .insert(
              FlashcardProgressCompanion.insert(
                flashcardId: 'c1',
                boxNumber: Value<int>(progressBox),
              ),
            );
      }
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 's1',
              entryType: 'deck',
              studyType: 'new_cards',
              status: status,
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
              answeredAt: Value<int?>(itemAnsweredAt),
            ),
          );
    }

    test('records a perfect attempt with the box transition, leaving progress '
        'untouched (S35)', () async {
      await seed(progressBox: 3);

      final result = await repository.recordStudySessionAnswer(
        sessionId: 's1',
        sessionItemId: 'i1',
        result: AttemptResult.perfect,
        studyMode: StudyMode.review,
        now: now + 500,
      );

      expect(result.failure, isNull);
      final StudyAttemptRow attempt = await db
          .select(db.studyAttempts)
          .getSingle();
      expect(attempt.result, 'perfect');
      expect(attempt.studyMode, 'review');
      expect(attempt.boxBefore, 3);
      expect(attempt.boxAfter, 4, reason: 'perfect advances one box');
      expect(attempt.attemptedAt, now + 500);

      final StudySessionItemRow item = await db
          .select(db.studySessionItems)
          .getSingle();
      expect(item.answeredAt, now + 500, reason: 'item marked answered');
      final StudySessionRow session = await db
          .select(db.studySessions)
          .getSingle();
      expect(session.updatedAt, now + 500, reason: 'session activity touched');

      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();
      expect(
        progress.boxNumber,
        3,
        reason: 'progress unchanged (finalization owns it)',
      );
    });

    test('forgot records box_after = 1 (S36)', () async {
      await seed(progressBox: 5);

      await repository.recordStudySessionAnswer(
        sessionId: 's1',
        sessionItemId: 'i1',
        result: AttemptResult.forgot,
        studyMode: StudyMode.recall,
        now: now,
      );

      final StudyAttemptRow attempt = await db
          .select(db.studyAttempts)
          .getSingle();
      expect(attempt.boxBefore, 5);
      expect(attempt.boxAfter, 1);
    });

    test('a new card with no progress row records box_before = 1', () async {
      await seed();

      await repository.recordStudySessionAnswer(
        sessionId: 's1',
        sessionItemId: 'i1',
        result: AttemptResult.perfect,
        studyMode: StudyMode.review,
        now: now,
      );

      final StudyAttemptRow attempt = await db
          .select(db.studyAttempts)
          .getSingle();
      expect(attempt.boxBefore, 1, reason: 'new card defaults to box 1');
      expect(attempt.boxAfter, 2);
    });

    test('an already-answered item is an UnsupportedActionFailure', () async {
      await seed(progressBox: 1, itemAnsweredAt: now);

      final result = await repository.recordStudySessionAnswer(
        sessionId: 's1',
        sessionItemId: 'i1',
        result: AttemptResult.perfect,
        studyMode: StudyMode.review,
        now: now,
      );

      expect(result.failure, isA<UnsupportedActionFailure>());
      expect(await db.select(db.studyAttempts).get(), isEmpty);
    });

    test('a terminal session is an UnsupportedActionFailure', () async {
      await seed(progressBox: 1, status: 'completed');

      final result = await repository.recordStudySessionAnswer(
        sessionId: 's1',
        sessionItemId: 'i1',
        result: AttemptResult.perfect,
        studyMode: StudyMode.review,
        now: now,
      );

      expect(result.failure, isA<UnsupportedActionFailure>());
    });

    test('a missing session is a NotFoundFailure', () async {
      final result = await repository.recordStudySessionAnswer(
        sessionId: 'nope',
        sessionItemId: 'i1',
        result: AttemptResult.perfect,
        studyMode: StudyMode.review,
        now: now,
      );
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('a missing item is a NotFoundFailure', () async {
      await seed(progressBox: 1);
      final result = await repository.recordStudySessionAnswer(
        sessionId: 's1',
        sessionItemId: 'missing',
        result: AttemptResult.perfect,
        studyMode: StudyMode.review,
        now: now,
      );
      expect(result.failure, isA<NotFoundFailure>());
    });
  });
}
