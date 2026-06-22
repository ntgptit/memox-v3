import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/entities/match_evaluation.dart';
import 'package:memox/domain/types/study_mode.dart';

void main() {
  // StudyRepositoryImpl Match-evaluation persistence (WBS 4.5.4 / WP-SM1b): append
  // a `study_match_evaluations` row, assign attempt_order as the per-session
  // sequence, denormalize flashcard_id = expectedFront, touch the session
  // updated_at, and never mark items answered. Append-only; finalization (WP-SM2)
  // derives terminal attempts. (`docs/contracts/repository-contracts/study-repository.md` §Match)
  group('StudyRepositoryImpl Match evaluation', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    final int now = DateTime(2026, 6, 22, 10).millisecondsSinceEpoch;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyRepositoryImpl(dao: StudySessionDao(db));
    });
    tearDown(() => db.close());

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
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'c1',
              deckId: 'd1',
              front: '먹다',
              back: 'to eat',
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
    }

    Future<Result<void>> record({
      bool isCorrect = true,
      StudyMode studyMode = StudyMode.match,
      int at = 0,
    }) => repository.recordMatchEvaluation(
      sessionId: 's1',
      sessionItemId: 'i1',
      boardIndex: 0,
      pairId: 'c1',
      selectedFrontCellId: 'cell-f$at',
      selectedBackCellId: 'cell-b$at',
      expectedFrontFlashcardId: 'c1',
      expectedBackFlashcardId: 'c1',
      isCorrect: isCorrect,
      studyMode: studyMode,
      now: now + at,
    );

    test(
      'appends a row, denormalizes flashcard_id, touches updated_at',
      () async {
        await seedSession();

        final Result<void> result = await record();
        expect(result.failure, isNull);

        final List<StudyMatchEvaluationRow> rows = await db
            .select(db.studyMatchEvaluations)
            .get();
        expect(rows, hasLength(1));
        expect(rows.single.flashcardId, 'c1'); // = expectedFront
        expect(rows.single.attemptOrder, 0);
        expect(rows.single.isCorrect, isTrue);

        // The item is NOT marked answered.
        final StudySessionItemRow item = await (db.select(
          db.studySessionItems,
        )..where((t) => t.id.equals('i1'))).getSingle();
        expect(item.answeredAt, isNull);

        // The session updated_at advanced to now.
        final StudySessionRow session = await (db.select(
          db.studySessions,
        )..where((t) => t.id.equals('s1'))).getSingle();
        expect(session.updatedAt, now);
      },
    );

    test('append-only: attempt_order increments per session', () async {
      await seedSession();
      await record(at: 0);
      await record(at: 1, isCorrect: false);
      await record(at: 2);

      final Result<List<MatchEvaluation>> loaded = await repository
          .loadMatchEvaluations('s1');
      expect(loaded.failure, isNull);
      final List<MatchEvaluation> evals = loaded.data!;
      expect(evals.map((e) => e.attemptOrder), <int>[0, 1, 2]);
      expect(evals.map((e) => e.isCorrect), <bool>[true, false, true]);
    });

    test('rejects a non-in_progress session', () async {
      await seedSession(status: 'completed');
      final Result<void> result = await record();
      expect(result.failure, isA<Failure>());
      expect(await db.select(db.studyMatchEvaluations).get(), isEmpty);
    });

    test('rejects a missing session', () async {
      // no seed
      final Result<void> result = await record();
      expect(result.failure, isA<Failure>());
    });

    test('rejects an item that is not in the session', () async {
      await seedSession();
      final Result<void> result = await repository.recordMatchEvaluation(
        sessionId: 's1',
        sessionItemId: 'not-in-session',
        boardIndex: 0,
        pairId: 'c1',
        selectedFrontCellId: 'cell-f0',
        selectedBackCellId: 'cell-b0',
        expectedFrontFlashcardId: 'c1',
        expectedBackFlashcardId: 'c1',
        isCorrect: true,
        studyMode: StudyMode.match,
        now: now,
      );
      expect(result.failure, isA<Failure>());
      expect(await db.select(db.studyMatchEvaluations).get(), isEmpty);
    });

    test('rejects a non-match study mode', () async {
      await seedSession();
      final Result<void> result = await record(studyMode: StudyMode.review);
      expect(result.failure, isA<Failure>());
      expect(await db.select(db.studyMatchEvaluations).get(), isEmpty);
    });

    test(
      'loadMatchEvaluations returns empty for a session with none',
      () async {
        await seedSession();
        final Result<List<MatchEvaluation>> loaded = await repository
            .loadMatchEvaluations('s1');
        expect(loaded.failure, isNull);
        expect(loaded.data, isEmpty);
      },
    );
  });
}
