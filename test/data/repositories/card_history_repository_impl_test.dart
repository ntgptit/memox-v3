import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/card_history_dao.dart';
import 'package:memox/data/repositories/card_history_repository_impl.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/attempt_result.dart';

/// CardHistoryRepositoryImpl.loadCardHistory (kit screen 09, WBS 7.6.1): the
/// header from stored counters + the merged feed (attempts + lifecycle + a
/// synthesized `created` event), newest first.
void main() {
  group('CardHistoryRepositoryImpl.loadCardHistory', () {
    late AppDatabase db;
    late CardHistoryRepositoryImpl repository;
    const int created = 1000 * 60 * 60 * 24 * 100; // card created_at
    const int t1 = created + 5000; // oldest attempt
    const int t2 = created + 9000;
    const int t3 = created + 20000; // newest attempt

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = CardHistoryRepositoryImpl(dao: CardHistoryDao(db));
    });
    tearDown(() => db.close());

    Future<void> seedCard({
      int box = 4,
      int reviews = 3,
      int lapses = 1,
    }) async {
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'f1',
              name: 'Languages',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: created,
              updatedAt: created,
            ),
          );
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'f1',
              name: 'Japanese · N5',
              sortOrder: 0,
              createdAt: created,
              updatedAt: created,
            ),
          );
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'c1',
              deckId: 'd1',
              front: '日本 — Japan',
              back: 'Japan',
              sortOrder: 0,
              createdAt: created,
              updatedAt: created,
            ),
          );
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: 'c1',
              boxNumber: Value<int>(box),
              reviewCount: Value<int>(reviews),
              lapseCount: Value<int>(lapses),
            ),
          );
    }

    Future<void> insertSessionItem() async {
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 's1',
              entryType: 'deck',
              studyType: 'srs_review',
              status: 'completed',
              startedAt: created,
              updatedAt: created,
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
              createdAt: created,
              updatedAt: created,
            ),
          );
    }

    Future<void> insertAttempt(
      String id,
      String result,
      int attemptedAt, {
      int? durationMs,
      int boxBefore = 1,
      int boxAfter = 2,
    }) => db
        .into(db.studyAttempts)
        .insert(
          StudyAttemptsCompanion.insert(
            id: id,
            sessionItemId: 'i1',
            result: result,
            studyMode: 'review',
            boxBefore: Value<int>(boxBefore),
            boxAfter: Value<int>(boxAfter),
            durationMs: Value<int?>(durationMs),
            attemptedAt: attemptedAt,
          ),
        );

    Future<CardHistory> load() async {
      final result = await repository.loadCardHistory(flashcardId: 'c1');
      expect(result.failure, isNull, reason: 'expected success');
      return result.data!;
    }

    test('missing card → NotFoundFailure', () async {
      final result = await repository.loadCardHistory(flashcardId: 'nope');
      expect(result.data, isNull);
      expect(result.failure, isA<NotFoundFailure>());
    });

    test(
      'header reads counters; avg duration averages measured attempts',
      () async {
        await seedCard(box: 4, reviews: 3, lapses: 1);
        await insertSessionItem();
        await insertAttempt('a1', 'perfect', t1, durationMs: 4000);
        await insertAttempt('a2', 'forgot', t2, durationMs: 6000);
        await insertAttempt(
          'a3',
          'recovered',
          t3,
        ); // no duration → excluded from avg

        final CardHistory h = await load();

        expect(h.header.front, '日本 — Japan');
        expect(h.header.deckName, 'Japanese · N5');
        expect(h.header.boxNumber, 4);
        expect(h.header.reviewCount, 3);
        expect(h.header.lapseCount, 1);
        // accuracy = (3 - 1) / 3.
        expect(h.header.accuracy, closeTo(2 / 3, 1e-9));
        // avg over the two measured durations (4000, 6000) = 5000.
        expect(h.header.avgDurationMs, 5000);
      },
    );

    test(
      'feed merges attempts + a synthesized created event, newest first',
      () async {
        await seedCard();
        await insertSessionItem();
        await insertAttempt(
          'a1',
          'perfect',
          t1,
          durationMs: 4200,
          boxBefore: 3,
          boxAfter: 4,
        );
        await insertAttempt(
          'a3',
          'forgot',
          t3,
          durationMs: 11000,
          boxBefore: 4,
          boxAfter: 1,
        );

        final CardHistory h = await load();

        // 2 attempts + 1 synthesized created.
        expect(h.events.length, 3);
        expect(h.hasActivity, isTrue);
        // Newest first: t3 attempt, t1 attempt, then created (oldest).
        final CardHistoryEvent first = h.events.first;
        expect(first, isA<CardHistoryAttempt>());
        expect((first as CardHistoryAttempt).result, AttemptResult.forgot);
        expect(first.occurredAt, t3);
        final CardHistoryEvent last = h.events.last;
        expect(last, isA<CardHistoryLifecycle>());
        expect((last as CardHistoryLifecycle).kind, CardEventKind.created);
        expect(last.occurredAt, created);
      },
    );

    test(
      'a card_events reset row appears and is not double-counted as created',
      () async {
        await seedCard();
        await db
            .into(db.cardEvents)
            .insert(
              CardEventsCompanion.insert(
                id: 'e1',
                flashcardId: 'c1',
                type: 'reset',
                occurredAt: created + 1000,
              ),
            );

        final CardHistory h = await load();

        // reset event + synthesized created = 2; no attempts → not active.
        expect(h.hasActivity, isFalse);
        expect(h.events.length, 2);
        expect(
          h.events
              .whereType<CardHistoryLifecycle>()
              .map((e) => e.kind)
              .toList(),
          <CardEventKind>[CardEventKind.reset, CardEventKind.created],
        );
      },
    );

    test('no attempts → empty (created only), zero-safe header', () async {
      await seedCard(reviews: 0, lapses: 0);

      final CardHistory h = await load();

      expect(h.hasActivity, isFalse);
      expect(h.events.single, isA<CardHistoryLifecycle>());
      expect(h.header.accuracy, isNull);
      expect(h.header.avgDurationMs, isNull);
    });
  });
}
