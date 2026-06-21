import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/progress_dao.dart';
import 'package:memox/data/repositories/progress_repository_impl.dart';
import 'package:memox/domain/models/box_distribution.dart';
import 'package:memox/domain/models/due_summary.dart';

void main() {
  // ProgressRepositoryImpl.loadDueSummary (WBS 7.1.1): aggregate due-card counts
  // (global + per-deck) excluding suspended and currently-buried cards, matching
  // the study-queue exclusion (docs/business/study-actions/bury-suspend.md).
  group('ProgressRepositoryImpl.loadDueSummary', () {
    late AppDatabase db;
    late ProgressRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100;
    const int past = now - 1;
    const int future = now + 1000;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = ProgressRepositoryImpl(dao: ProgressDao(db));
    });
    tearDown(() => db.close());

    Future<void> insertDeck(String id, {String? name}) => db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: id,
            folderId: 'f1',
            name: name ?? id,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );

    Future<void> insertCard(
      String id,
      String deckId, {
      bool withProgress = true,
      int? dueAt,
      bool suspended = false,
      int? buriedUntil,
    }) async {
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
      if (!withProgress) return;
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: id,
              dueAt: Value<int?>(dueAt),
              isSuspended: Value<bool>(suspended),
              buriedUntil: Value<int?>(buriedUntil),
            ),
          );
    }

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

    Future<DueSummary> load() async {
      final result = await repository.loadDueSummary(now: now);
      expect(result.failure, isNull, reason: 'expected success');
      return result.data!;
    }

    test('totals and per-deck counts exclude suspended/buried/new', () async {
      await seedFolder();
      await insertDeck('d1', name: 'Alpha');
      await insertDeck('d2', name: 'Beta');
      await insertDeck('d3', name: 'Gamma'); // no due → omitted
      // d1: two due, one not-due, one new (no due_at).
      await insertCard('a1', 'd1', dueAt: past);
      await insertCard('a2', 'd1', dueAt: now);
      await insertCard('a3', 'd1', dueAt: future);
      await insertCard('a4', 'd1'); // new card, no due_at
      // d2: one due, one suspended-due, one buried-due (both excluded).
      await insertCard('b1', 'd2', dueAt: past);
      await insertCard('b2', 'd2', dueAt: past, suspended: true);
      await insertCard('b3', 'd2', dueAt: past, buriedUntil: future);
      // d3: only a not-due card.
      await insertCard('c1', 'd3', dueAt: future);

      final summary = await load();

      expect(summary.totalDueCount, 3, reason: '2 (d1) + 1 (d2)');
      expect(summary.decksWithDueCount, 2);
      expect(summary.hasDue, isTrue);
      // Ordered by due_count desc, then name.
      expect(summary.decksWithDue.map((d) => d.deckId).toList(), <String>[
        'd1',
        'd2',
      ]);
      expect(summary.decksWithDue.first.deckName, 'Alpha');
      expect(summary.decksWithDue.first.dueCount, 2);
      expect(summary.decksWithDue[1].dueCount, 1);
    });

    test('an expired bury re-enters the due count', () async {
      await seedFolder();
      await insertDeck('d1');
      await insertCard('a1', 'd1', dueAt: past, buriedUntil: past);
      // Boundary: buried_until == now is "expired" (predicate is <= now).
      await insertCard('a2', 'd1', dueAt: past, buriedUntil: now);

      final summary = await load();

      expect(summary.totalDueCount, 2);
      expect(summary.decksWithDue.single.dueCount, 2);
    });

    test('nothing due → empty caught-up summary', () async {
      await seedFolder();
      await insertDeck('d1');
      await insertCard('a1', 'd1', dueAt: future);
      await insertCard('a2', 'd1'); // new

      final summary = await load();

      expect(summary.totalDueCount, 0);
      expect(summary.decksWithDue, isEmpty);
      expect(summary.hasDue, isFalse);
    });
  });

  // ProgressRepositoryImpl.loadBoxDistribution (WBS 7.2.1): card counts per
  // Leitner box 1..8 from flashcard_progress, zero-filled, fail-fast on an
  // out-of-range box (decision row P9).
  group('ProgressRepositoryImpl.loadBoxDistribution', () {
    late AppDatabase db;
    late ProgressRepositoryImpl repository;
    const int now = 1000 * 60 * 60 * 24 * 100;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = ProgressRepositoryImpl(dao: ProgressDao(db));
    });
    tearDown(() => db.close());

    Future<void> seedDeck() async {
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
    }

    Future<void> insertCardInBox(String id, int box) async {
      await db
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
          );
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: id,
              boxNumber: Value<int>(box),
            ),
          );
    }

    test('counts per box, zero-filled across 1..8', () async {
      await seedDeck();
      await insertCardInBox('a', 1);
      await insertCardInBox('b', 1);
      await insertCardInBox('c', 3);
      await insertCardInBox('d', 8);

      final result = await repository.loadBoxDistribution();

      expect(result.failure, isNull);
      final BoxDistribution dist = result.data!;
      expect(dist.countsByBox.keys.toList()..sort(), <int>[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
      ]);
      expect(dist.countFor(1), 2);
      expect(dist.countFor(3), 1);
      expect(dist.countFor(8), 1);
      expect(dist.countFor(2), 0, reason: 'empty box zero-filled');
      expect(dist.total, 4);
    });

    test('empty db → all boxes zero', () async {
      final result = await repository.loadBoxDistribution();
      expect(result.failure, isNull);
      expect(result.data!.total, 0);
      expect(result.data!.countsByBox.length, 8);
    });

    test('an out-of-range box fails fast (P9)', () async {
      await seedDeck();
      await insertCardInBox('a', 1);
      await insertCardInBox('bad', 9); // invalid box

      final result = await repository.loadBoxDistribution();

      expect(result.data, isNull);
      expect(result.failure, isA<IntegrityFailure>());
    });
  });
}
