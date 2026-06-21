import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/migrations/v7_add_card_history.dart';

void main() {
  // Migration contract (`docs/database/migration-contract.md`): reduce the db to
  // the v6 shape with data, run the migration, and assert existing data is
  // preserved and the new table/columns work. The v6→v7 step is purely additive
  // (one new table + two nullable columns), so we drop the `card_events` table
  // and the two added columns to recreate the v6 shape, seed a card, then run
  // `migrateV6ToV7` and exercise the additions. WBS 7.0.1.
  group('v6 → v7 migration (card-history enabler)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    // Mimic the v6 shape: drop the v7 additions (one table + two columns).
    Future<void> reduceToV6() async {
      await db.customStatement('DROP TABLE card_events');
      await db.customStatement(
        'ALTER TABLE flashcard_progress DROP COLUMN last_reset_at',
      );
      await db.customStatement(
        'ALTER TABLE study_attempts DROP COLUMN duration_ms',
      );
    }

    Future<void> seedCardWithProgress() async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'folder',
              name: 'Korean',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'folder',
              name: 'Verbs',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'c1',
              deckId: 'd1',
              front: 'eat',
              back: 'an',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      await db
          .into(db.flashcardProgress)
          .insert(FlashcardProgressCompanion.insert(flashcardId: 'c1'));
    }

    test('adds card_events + columns while preserving data', () async {
      await seedCardWithProgress();
      await reduceToV6();

      await migrateV6ToV7(db.createMigrator(), db);

      // Pre-existing content survives the additive migration.
      expect(await db.select(db.flashcards).get(), hasLength(1));

      // The two new columns default NULL on existing rows.
      final FlashcardProgressRow progress = await db
          .select(db.flashcardProgress)
          .getSingle();
      expect(progress.lastResetAt, isNull);

      // card_events round-trips and cascades on card delete.
      final int ts = now();
      await db
          .into(db.cardEvents)
          .insert(
            CardEventsCompanion.insert(
              id: 'e1',
              flashcardId: 'c1',
              type: 'created',
              occurredAt: ts,
            ),
          );
      final CardEventRow event = await db.select(db.cardEvents).getSingle();
      expect(event.type, 'created');
      expect(event.detail, isNull);

      // duration_ms is writable and nullable on study_attempts.
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 's1',
              entryType: 'deck',
              studyType: 'srs_review',
              status: 'draft',
              startedAt: ts,
              updatedAt: ts,
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
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      await db
          .into(db.studyAttempts)
          .insert(
            StudyAttemptsCompanion.insert(
              id: 'a1',
              sessionItemId: 'i1',
              result: 'perfect',
              studyMode: 'review',
              attemptedAt: ts,
              durationMs: const Value<int?>(4200),
            ),
          );
      final StudyAttemptRow attempt = await db
          .select(db.studyAttempts)
          .getSingle();
      expect(attempt.durationMs, 4200);

      await db.customStatement('PRAGMA foreign_keys = ON');
      await (db.delete(db.flashcards)..where((t) => t.id.equals('c1'))).go();
      expect(
        await db.select(db.cardEvents).get(),
        isEmpty,
        reason: 'card_events cascades on flashcard delete',
      );
    });
  });
}
