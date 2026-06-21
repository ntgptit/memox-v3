import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_entry_dao.dart';
import 'package:memox/data/datasources/local/daos/study_scope_dao.dart';
import 'package:memox/data/repositories/study_entry_repository_impl.dart';
import 'package:memox/domain/repositories/study_entry_repository.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

void main() {
  // StudyEntryRepositoryImpl.resolveEligibleCardIds daily new-card cap (WBS
  // 4.5.10): new-card eligibility is reduced by the quota consumed in the local
  // day (cancelled new-card sessions still count); srs_review is unaffected
  // (docs/business/study/study-flow.md §Rules).
  group('Daily new-card limit', () {
    late AppDatabase db;
    late StudyEntryRepositoryImpl repository;

    // A fixed local-day anchor so the [start,end) window is deterministic.
    final int now = DateTime(2026, 6, 21, 10).millisecondsSinceEpoch;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyEntryRepositoryImpl(
        dao: StudyEntryDao(db),
        scopeDao: StudyScopeDao(db),
      );
    });
    tearDown(() => db.close());

    Future<void> seedDeck(int cardCount) async {
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
      for (int i = 0; i < cardCount; i++) {
        await db
            .into(db.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                id: 'c$i',
                deckId: 'd1',
                front: 'c$i',
                back: 'c$i',
                sortOrder: i,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    }

    /// Records [count] consumed new-card slots via a session started at
    /// [startedAt] (default today) with [status]. Filler cards live in a separate
    /// deck so they count toward the global daily quota without inflating the
    /// study deck's own new eligibility.
    Future<void> consumeNewQuota(
      int count, {
      int? startedAt,
      String status = 'completed',
      String sessionId = 's1',
      String studyType = 'new_cards',
    }) async {
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'filler-$sessionId',
              folderId: 'f1',
              name: 'filler-$sessionId',
              sortOrder: 1,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: sessionId,
              entryType: 'deck',
              studyType: studyType,
              status: status,
              startedAt: startedAt ?? now,
              updatedAt: startedAt ?? now,
            ),
          );
      for (int i = 0; i < count; i++) {
        await db
            .into(db.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                id: '$sessionId-fc$i',
                deckId: 'filler-$sessionId',
                front: 'f$i',
                back: 'f$i',
                sortOrder: i,
                createdAt: now,
                updatedAt: now,
              ),
            );
        await db
            .into(db.studySessionItems)
            .insert(
              StudySessionItemsCompanion.insert(
                id: '$sessionId-i$i',
                sessionId: sessionId,
                flashcardId: '$sessionId-fc$i',
                sortOrder: i,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    }

    Future<List<String>> resolveNew() async {
      final result = await repository.resolveEligibleCardIds(
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: 'd1',
          studyType: StudyType.newCards,
        ),
        now: now,
      );
      expect(result.failure, isNull);
      return result.data!;
    }

    test('no quota used → full new eligibility (under cap)', () async {
      await seedDeck(5);
      expect((await resolveNew()).length, 5);
    });

    test('caps new eligibility at the remaining daily quota', () async {
      await seedDeck(10);
      // 18 of 20 used today → only 2 remaining.
      await consumeNewQuota(18);

      expect((await resolveNew()).length, 2);
    });

    test('quota exhausted → zero new eligibility', () async {
      await seedDeck(10);
      await consumeNewQuota(StudyEntryRepository.dailyNewLimit);

      expect(await resolveNew(), isEmpty);
    });

    test('cancelled new-card sessions still consume quota', () async {
      await seedDeck(10);
      await consumeNewQuota(
        StudyEntryRepository.dailyNewLimit,
        status: 'cancelled',
      );

      expect(await resolveNew(), isEmpty);
    });

    test('quota from a prior local day does not count', () async {
      await seedDeck(5);
      final int yesterday = DateTime(2026, 6, 20, 10).millisecondsSinceEpoch;
      await consumeNewQuota(18, startedAt: yesterday);

      expect((await resolveNew()).length, 5, reason: 'yesterday excluded');
    });

    test('srs_review sessions do not consume new quota', () async {
      await seedDeck(5);
      await consumeNewQuota(18, studyType: 'srs_review');

      expect((await resolveNew()).length, 5, reason: 'review not counted');
    });
  });
}
