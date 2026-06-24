import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/data/repositories/progress_repository_impl.dart';
import 'package:memox/domain/models/deck_mastery.dart';
import 'package:memox/domain/models/stats_overview.dart';

/// ProgressRepositoryImpl.loadStatsOverview (Stats, screen 18): the current
/// local week's review activity (Monday→Sunday, zero-filled, bucketed in Dart)
/// plus per-deck mastery mapped from the average Leitner box.
void main() {
  group('ProgressRepositoryImpl.loadStatsOverview', () {
    late AppDatabase db;
    late ProgressRepositoryImpl repository;

    // A fixed local "now": Wednesday 2026-06-24 10:00. Building attempt times
    // from LOCAL DateTimes keeps the buckets deterministic across machine
    // timezones (the repo buckets by toLocal()).
    final DateTime nowDt = DateTime(2026, 6, 24, 10);
    late final int now = nowDt.millisecondsSinceEpoch;
    late final DateTime weekStart = DateTime(
      nowDt.year,
      nowDt.month,
      nowDt.day - (nowDt.weekday - DateTime.monday),
    );

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = ProgressRepositoryImpl(dao: ProgressDao(db));
    });
    tearDown(() => db.close());

    Future<void> seedFolder() => db
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

    Future<void> insertDeck(String id, String name) => db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: id,
            folderId: 'f1',
            name: name,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );

    Future<void> insertCard(String id, String deckId, {int? box}) async {
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: id,
              deckId: deckId,
              front: id,
              back: id,
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      if (box == null) return;
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: id,
              boxNumber: Value<int>(box),
            ),
          );
    }

    Future<void> insertSession(String id) => db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: id,
            entryType: 'deck',
            studyType: 'srs_review',
            status: 'completed',
            startedAt: now,
            updatedAt: now,
          ),
        );

    Future<void> insertItem(String id, String sessionId, String cardId) => db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            flashcardId: cardId,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );

    Future<void> insertAttempt(String id, String itemId, DateTime atLocal) => db
        .into(db.studyAttempts)
        .insert(
          StudyAttemptsCompanion.insert(
            id: id,
            sessionItemId: itemId,
            result: 'perfect',
            studyMode: 'review',
            attemptedAt: atLocal.millisecondsSinceEpoch,
          ),
        );

    Future<StatsOverview> load() async {
      final result = await repository.loadStatsOverview(now: now);
      expect(result.failure, isNull, reason: 'expected success');
      return result.data!;
    }

    test('empty database → zero-filled week (Mon..Sun) and no decks', () async {
      final StatsOverview overview = await load();

      expect(overview.weekActivity.days.length, 7);
      expect(overview.weekActivity.total, 0);
      expect(overview.weekActivity.hasActivity, isFalse);
      expect(overview.weekActivity.days.first.weekday, DateTime.monday);
      expect(overview.weekActivity.days.last.weekday, DateTime.sunday);
      expect(overview.deckMastery, isEmpty);
      expect(overview.hasDecks, isFalse);
    });

    test(
      'weekly chart buckets attempts by local day; prior week excluded',
      () async {
        await seedFolder();
        await insertDeck('d1', 'Alpha');
        await insertCard('c1', 'd1', box: 1);
        await insertSession('s1');
        await insertItem('i1', 's1', 'c1');

        // Two attempts on Monday, one on Wednesday, one last week (excluded).
        final DateTime monday = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
          10,
        );
        final DateTime wednesday = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + 2,
          9,
        );
        final DateTime lastSunday = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day - 1,
          23,
        );
        await insertAttempt('a1', 'i1', monday);
        await insertAttempt('a2', 'i1', monday.add(const Duration(hours: 3)));
        await insertAttempt('a3', 'i1', wednesday);
        await insertAttempt('a4', 'i1', lastSunday);

        final StatsOverview overview = await load();

        expect(overview.weekActivity.days[0].count, 2, reason: 'Monday');
        expect(overview.weekActivity.days[1].count, 0, reason: 'Tuesday');
        expect(overview.weekActivity.days[2].count, 1, reason: 'Wednesday');
        expect(overview.weekActivity.total, 3, reason: 'prior week excluded');
        expect(overview.weekActivity.maxCount, 2);
      },
    );

    test('per-deck mastery maps average box to a 0..1 fraction', () async {
      await seedFolder();
      await insertDeck('d1', 'Alpha');
      await insertDeck('d2', 'Beta');
      await insertDeck('d3', 'Gamma'); // no cards → omitted
      // Alpha: boxes 1 and 8 → avg 4.5 → (4.5-1)/7 = 0.5.
      await insertCard('a1', 'd1', box: 1);
      await insertCard('a2', 'd1', box: 8);
      // Beta: box 8 → avg 8 → 1.0.
      await insertCard('b1', 'd2', box: 8);

      final StatsOverview overview = await load();

      expect(
        overview.deckMastery.map((DeckMastery d) => d.deckId).toList(),
        <String>['d1', 'd2'],
        reason: 'ordered by deck name, decks without cards omitted',
      );
      expect(overview.deckMastery[0].masteryFraction, closeTo(0.5, 1e-9));
      expect(overview.deckMastery[0].masteryPercent, 50);
      expect(overview.deckMastery[1].masteryFraction, closeTo(1.0, 1e-9));
      expect(overview.deckMastery[1].masteryPercent, 100);
    });
  });
}
