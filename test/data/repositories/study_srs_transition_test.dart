import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/srs/box_intervals.dart';

void main() {
  // Finalization SRS transition (WBS 4.6.2/4.6.4): box ladder, due-date interval,
  // and counters, verified table-driven against docs/business/srs/srs-review.md
  // §Box transition table + §Interval table (decision rows S11–S15, S17–S18).
  group('StudyRepositoryImpl finalize SRS transition', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100 + 12345; // a non-midnight instant

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyRepositoryImpl(dao: StudySessionDao(db));
    });
    tearDown(() => db.close());

    // The expected due is the local midnight of `now` plus interval[box] days,
    // computed exactly as the repository does (Dart local time, not SQL).
    int expectedDue(int box) {
      final DateTime n = DateTime.fromMillisecondsSinceEpoch(now).toLocal();
      final DateTime midnight = DateTime(n.year, n.month, n.day);
      return midnight
          .add(Duration(days: BoxIntervals.daysFor(box)))
          .millisecondsSinceEpoch;
    }

    Future<FlashcardProgressRow> finalizeOne({
      int? boxBefore,
      int reviewBefore = 0,
      int lapseBefore = 0,
      required String result,
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
      if (boxBefore != null) {
        await db
            .into(db.flashcardProgress)
            .insert(
              FlashcardProgressCompanion.insert(
                flashcardId: 'c1',
                boxNumber: Value<int>(boxBefore),
                reviewCount: Value<int>(reviewBefore),
                lapseCount: Value<int>(lapseBefore),
              ),
            );
      }
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 's1',
              entryType: 'deck',
              studyType: 'srs_review',
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
              answeredAt: const Value<int?>(now),
            ),
          );
      await db
          .into(db.studyAttempts)
          .insert(
            StudyAttemptsCompanion.insert(
              id: 'a1',
              sessionItemId: 'i1',
              result: result,
              studyMode: 'recall',
              attemptedAt: now,
            ),
          );

      final r = await repository.finalizeStudySession(
        sessionId: 's1',
        now: now,
      );
      expect(r.failure, isNull);
      return db.select(db.flashcardProgress).getSingle();
    }

    test(
      'S11: perfect at box < 8 advances one box, due = interval[next]',
      () async {
        final p = await finalizeOne(boxBefore: 1, result: 'perfect');
        expect(p.boxNumber, 2);
        expect(p.dueAt, expectedDue(2));
        expect(p.reviewCount, 1);
        expect(p.lapseCount, 0);
      },
    );

    test(
      'S11 + interval jump: perfect at box 5 → box 6, due = 12 days',
      () async {
        final p = await finalizeOne(boxBefore: 5, result: 'perfect');
        expect(p.boxNumber, 6);
        expect(p.dueAt, expectedDue(6));
        expect(BoxIntervals.daysFor(6), 12);
      },
    );

    test('S14: perfect at box 8 stays 8, due = 60 days', () async {
      final p = await finalizeOne(
        boxBefore: 8,
        reviewBefore: 3,
        result: 'perfect',
      );
      expect(p.boxNumber, 8);
      expect(p.dueAt, expectedDue(8));
      expect(BoxIntervals.daysFor(8), 60);
      expect(p.reviewCount, 4);
    });

    test('S12: forgot resets to box 1, lapse +1, due = 1 day', () async {
      final p = await finalizeOne(
        boxBefore: 4,
        lapseBefore: 2,
        result: 'forgot',
      );
      expect(p.boxNumber, 1);
      expect(p.dueAt, expectedDue(1));
      expect(p.lapseCount, 3, reason: 'lapse increments only on forgot');
    });

    test('S13: recovered keeps the current box, no lapse', () async {
      final p = await finalizeOne(
        boxBefore: 4,
        lapseBefore: 1,
        result: 'recovered',
      );
      expect(p.boxNumber, 4);
      expect(p.dueAt, expectedDue(4));
      expect(p.lapseCount, 1, reason: 'recovered does not lapse');
    });

    test('a new card with no progress row finalizes from box 1', () async {
      final p = await finalizeOne(result: 'perfect');
      expect(p.boxNumber, 2, reason: 'new card box 1 → 2 on perfect');
      expect(p.reviewCount, 1);
      expect(p.lapseCount, 0);
    });

    test(
      'due_at normalizes to exact local midnight (no time-of-day component)',
      () async {
        // `now` carries a +12345ms intra-day offset, yet due_at must land on the
        // exact local midnight of the target day — so "due today" is stable
        // across the day (WBS 4.6.4).
        final p = await finalizeOne(boxBefore: 2, result: 'perfect');
        final DateTime due = DateTime.fromMillisecondsSinceEpoch(
          p.dueAt!,
        ).toLocal();
        expect(due.hour, 0);
        expect(due.minute, 0);
        expect(due.second, 0);
        expect(due.millisecond, 0);
        expect(p.dueAt, expectedDue(3));
      },
    );
  });
}
