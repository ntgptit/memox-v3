import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/data/repositories/progress_repository_impl.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/types/progress_range.dart';

/// Fixed local "now": a Wednesday afternoon so week buckets are predictable.
final DateTime _now = DateTime(2026, 6, 10, 15);

class _Fixture {
  _Fixture(this.db);

  final AppDatabase db;
  int _seq = 0;

  int get _nowMs => _now.millisecondsSinceEpoch;

  Future<void> seedDeck() async {
    await db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(
            id: 'folder-1',
            parentId: const Value<String?>(null),
            name: 'Folder',
            contentMode: const Value<String>('decks'),
            sortOrder: const Value<int>(0),
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: 'deck-1',
            folderId: 'folder-1',
            name: 'Deck',
            targetLanguage: const Value<String>('korean'),
            sortOrder: const Value<int>(0),
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: 'session-1',
            entryType: 'deck',
            entryRefId: const Value<String?>('deck-1'),
            studyType: 'new_cards',
            status: 'completed',
            startedAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
  }

  Future<void> seedCard({
    required String id,
    int boxNumber = 1,
    bool isSuspended = false,
    int? buriedUntil,
  }) async {
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: 'deck-1',
            front: 'Front $id',
            back: 'Back $id',
            sortOrder: const Value<int>(0),
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
    await db
        .into(db.flashcardProgress)
        .insert(
          FlashcardProgressCompanion(
            flashcardId: Value<String>(id),
            boxNumber: Value<int>(boxNumber),
            dueAt: Value<int?>(_nowMs),
            isSuspended: Value<bool>(isSuspended),
            buriedUntil: Value<int?>(buriedUntil),
            reviewCount: const Value<int>(0),
            lapseCount: const Value<int>(0),
          ),
        );
  }

  /// Records one attempt at local [day] (mid-day) with [result].
  Future<void> seedAttempt({
    required DateTime day,
    required String result,
  }) async {
    _seq += 1;
    final String itemId = 'item-$_seq';
    await db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: itemId,
            sessionId: 'session-1',
            flashcardId: 'card-1',
            sortOrder: _seq,
            answeredAt: Value<int?>(_nowMs),
            createdAt: _nowMs,
            updatedAt: _nowMs,
          ),
        );
    final DateTime at = DateTime(day.year, day.month, day.day, 12);
    await db
        .into(db.studyAttempts)
        .insert(
          StudyAttemptsCompanion.insert(
            id: 'attempt-$_seq',
            sessionItemId: itemId,
            result: result,
            studyMode: 'recall',
            boxBefore: const Value<int>(1),
            boxAfter: const Value<int>(1),
            attemptedAt: at.millisecondsSinceEpoch,
          ),
        );
  }
}

void main() {
  late AppDatabase db;
  late ProgressRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ProgressRepositoryImpl(ProgressDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  Future<ProgressOverview> load(ProgressRange range) async {
    final Result<ProgressOverview> result = await repository
        .loadProgressOverview(now: _now, range: range);
    expect(
      result.isOk,
      isTrue,
      reason: result is Err<ProgressOverview>
          ? 'loadProgressOverview failed: ${result.failure}'
          : 'loadProgressOverview must succeed',
    );
    return (result as Ok<ProgressOverview>).value;
  }

  test('empty database returns zero-safe overview for every range', () async {
    for (final ProgressRange range in ProgressRange.values) {
      final ProgressOverview overview = await load(range);
      expect(overview.activity.totalAttempts, 0);
      expect(overview.activity.distinctStudyDayCount, 0);
      expect(overview.streak.currentDays, 0);
      expect(overview.streak.longestDays, 0);
      expect(overview.cardStateCounts.suspendedCount, 0);
      expect(overview.cardStateCounts.buriedTodayCount, 0);
      expect(
        overview.activity.days.length,
        range == ProgressRange.allTime ? 0 : range.dayCount,
      );
    }
  });

  test(
    'week activity buckets attempts per local day and separates the previous range',
    () async {
      final _Fixture fixture = _Fixture(db);
      await fixture.seedDeck();
      await fixture.seedCard(id: 'card-1');

      // In range (Jun 4 – Jun 10): 3 study days.
      await fixture.seedAttempt(day: DateTime(2026, 6, 10), result: 'perfect');
      await fixture.seedAttempt(day: DateTime(2026, 6, 10), result: 'forgot');
      await fixture.seedAttempt(day: DateTime(2026, 6, 9), result: 'perfect');
      await fixture.seedAttempt(day: DateTime(2026, 6, 4), result: 'recovered');
      // Previous week (May 28 – Jun 3).
      await fixture.seedAttempt(day: DateTime(2026, 6, 1), result: 'perfect');
      await fixture.seedAttempt(day: DateTime(2026, 6, 1), result: 'forgot');
      // Outside both ranges — must be ignored.
      await fixture.seedAttempt(day: DateTime(2026, 5, 1), result: 'perfect');

      final ProgressOverview overview = await load(ProgressRange.week);
      final ProgressActivity activity = overview.activity;

      expect(activity.days.length, 7);
      expect(activity.days.first.day, DateTime(2026, 6, 4));
      expect(activity.days.last.day, DateTime(2026, 6, 10));
      expect(activity.totalAttempts, 4);
      expect(activity.correctAttempts, 3); // perfect+perfect+recovered
      expect(activity.distinctStudyDayCount, 3);
      expect(activity.days.last.attemptCount, 2);
      expect(activity.days.last.correctCount, 1);
      expect(activity.previousTotalAttempts, 2);
      expect(activity.previousCorrectAttempts, 1);
    },
  );

  test(
    'all-time activity uses whole-history totals with no day buckets',
    () async {
      final _Fixture fixture = _Fixture(db);
      await fixture.seedDeck();
      await fixture.seedCard(id: 'card-1');
      await fixture.seedAttempt(day: DateTime(2026, 5, 1), result: 'perfect');
      await fixture.seedAttempt(day: DateTime(2026, 6, 10), result: 'forgot');

      final ProgressOverview overview = await load(ProgressRange.allTime);
      expect(overview.activity.days, isEmpty);
      expect(overview.activity.totalAttempts, 2);
      expect(overview.activity.correctAttempts, 1);
      expect(overview.activity.previousTotalAttempts, 0);
      expect(overview.activity.distinctStudyDayCount, 2);
    },
  );

  test(
    'streak counts consecutive study days; an unfinished today does not break it',
    () async {
      final _Fixture fixture = _Fixture(db);
      await fixture.seedDeck();
      await fixture.seedCard(id: 'card-1');

      // Current run: Jun 7–9 (today Jun 10 has no study yet).
      await fixture.seedAttempt(day: DateTime(2026, 6, 9), result: 'perfect');
      await fixture.seedAttempt(day: DateTime(2026, 6, 8), result: 'perfect');
      await fixture.seedAttempt(day: DateTime(2026, 6, 7), result: 'perfect');
      // Older, longer run: May 1–5.
      for (int d = 1; d <= 5; d++) {
        await fixture.seedAttempt(day: DateTime(2026, 5, d), result: 'perfect');
      }

      final ProgressOverview overview = await load(ProgressRange.week);
      expect(overview.streak.currentDays, 3);
      expect(overview.streak.longestDays, 5);

      // Studying today extends the current run.
      await fixture.seedAttempt(day: DateTime(2026, 6, 10), result: 'perfect');
      final ProgressOverview updated = await load(ProgressRange.week);
      expect(updated.streak.currentDays, 4);
    },
  );

  test(
    'card state counts include suspended and currently-buried only',
    () async {
      final _Fixture fixture = _Fixture(db);
      await fixture.seedDeck();
      await fixture.seedCard(id: 'card-1');
      await fixture.seedCard(id: 'card-suspended', isSuspended: true);
      await fixture.seedCard(
        id: 'card-buried',
        buriedUntil: _now.add(const Duration(hours: 9)).millisecondsSinceEpoch,
      );
      await fixture.seedCard(
        id: 'card-bury-expired',
        buriedUntil: _now
            .subtract(const Duration(hours: 9))
            .millisecondsSinceEpoch,
      );

      final ProgressOverview overview = await load(ProgressRange.week);
      expect(overview.cardStateCounts.suspendedCount, 1);
      expect(overview.cardStateCounts.buriedTodayCount, 1);
    },
  );
}
