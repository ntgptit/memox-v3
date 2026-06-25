import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/data/repositories/progress_repository_impl.dart';
import 'package:memox/domain/models/progress_engagement.dart';

/// ProgressRepositoryImpl.loadStudyActivity (kit 19 / Q5): today's answered
/// count + current/longest study-day streak, bucketed by LOCAL day in Dart.
void main() {
  group('ProgressRepositoryImpl.loadStudyActivity', () {
    late AppDatabase db;
    late ProgressRepositoryImpl repository;

    // Fixed local "now": Wednesday 2026-06-24 10:00. Attempt times are built
    // from LOCAL DateTimes so day-bucketing is deterministic across timezones.
    final DateTime nowDt = DateTime(2026, 6, 24, 10);
    late final int now = nowDt.millisecondsSinceEpoch;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = ProgressRepositoryImpl(dao: ProgressDao(db));
    });
    tearDown(() => db.close());

    Future<void> seed() async {
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
              front: 'c1',
              back: 'c1',
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
              status: 'completed',
              startedAt: now,
              updatedAt: now,
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

    int id = 0;
    Future<void> attemptOn(DateTime atLocal) => db
        .into(db.studyAttempts)
        .insert(
          StudyAttemptsCompanion.insert(
            id: 'a${id++}',
            sessionItemId: 'i1',
            result: 'perfect',
            studyMode: 'review',
            attemptedAt: atLocal.millisecondsSinceEpoch,
          ),
        );

    /// A local day at noon, [delta] days from now's calendar day.
    DateTime day(int delta) =>
        DateTime(nowDt.year, nowDt.month, nowDt.day + delta, 12);

    Future<StudyDayActivity> load() async {
      final result = await repository.loadStudyActivity(now: now);
      expect(result.failure, isNull, reason: 'expected success');
      return result.data!;
    }

    test('empty database → all-zero activity', () async {
      final StudyDayActivity a = await load();
      expect(a.todayAnsweredCount, 0);
      expect(a.currentStreak, 0);
      expect(a.longestStreak, 0);
    });

    test('today count + streak ending today, multiple attempts/day', () async {
      await seed();
      // Today (2 attempts), yesterday, day-before → a 3-day current streak.
      await attemptOn(day(0));
      await attemptOn(day(0).add(const Duration(hours: 2)));
      await attemptOn(day(-1));
      await attemptOn(day(-2));

      final StudyDayActivity a = await load();
      expect(a.todayAnsweredCount, 2, reason: 'two attempts today');
      expect(a.currentStreak, 3);
      expect(a.longestStreak, 3);
    });

    test('unfinished today: streak counts from yesterday', () async {
      await seed();
      // No attempt today; yesterday + day-before → current streak 2 (today open).
      await attemptOn(day(-1));
      await attemptOn(day(-2));

      final StudyDayActivity a = await load();
      expect(a.todayAnsweredCount, 0);
      expect(a.currentStreak, 2, reason: 'today open does not break the run');
      expect(a.longestStreak, 2);
    });

    test(
      'a gap breaks the current streak; longest spans the longer run',
      () async {
        await seed();
        // Recent run: today + yesterday (current = 2).
        await attemptOn(day(0));
        await attemptOn(day(-1));
        // Older run of 3 (days -5,-6,-7) after a gap at day -2..-4.
        await attemptOn(day(-5));
        await attemptOn(day(-6));
        await attemptOn(day(-7));

        final StudyDayActivity a = await load();
        expect(a.currentStreak, 2);
        expect(a.longestStreak, 3, reason: 'older 3-day run is the longest');
      },
    );
  });

  // The kit-19 "Time" stat: total on-card study time since a window start.
  // Unlogged attempts contribute nothing; an empty range yields zero.
  group('ProgressRepositoryImpl.loadStudyTimeMs', () {
    late AppDatabase db;
    late ProgressRepositoryImpl repository;
    final int now = DateTime(2026, 6, 24, 10).millisecondsSinceEpoch;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = ProgressRepositoryImpl(dao: ProgressDao(db));
    });
    tearDown(() => db.close());

    Future<void> seedChain() async {
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
              front: 'c1',
              back: 'c1',
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
              status: 'completed',
              startedAt: now,
              updatedAt: now,
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

    int aid = 0;
    Future<void> attempt(int atMs, int? durationMs) => db
        .into(db.studyAttempts)
        .insert(
          StudyAttemptsCompanion.insert(
            id: 't${aid++}',
            sessionItemId: 'i1',
            result: 'perfect',
            studyMode: 'review',
            attemptedAt: atMs,
            durationMs: Value<int?>(durationMs),
          ),
        );

    test('empty database → 0 ms', () async {
      final result = await repository.loadStudyTimeMs(since: 0);
      expect(result.failure, isNull);
      expect(result.data, 0);
    });

    test(
      'sums duration_ms since the window; NULLs skipped; before excluded',
      () async {
        await seedChain();
        await attempt(now, 5000);
        await attempt(now + 1000, 3000);
        await attempt(now + 2000, null); // unlogged → contributes 0
        await attempt(now - 10000, 9999); // before the window → excluded

        final result = await repository.loadStudyTimeMs(since: now);
        expect(result.failure, isNull);
        expect(result.data, 8000);
      },
    );
  });
}
