import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/migrations/v6_add_study_tables.dart';

void main() {
  // Migration contract (`docs/database/migration-contract.md`): bring the
  // database to the previous (v5) shape with data, run the migration, assert
  // existing data is preserved and the new tables work. The v5→v6 step is purely
  // additive (three brand-new study tables), so we drop them to recreate the v5
  // shape, seed a deck/flashcard, then run `migrateV5ToV6` and exercise the new
  // tables. WBS 4.0.1.
  group('v5 → v6 migration (add study tables)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    // Drop the v6 study tables to mimic the v5 shape, so `migrateV5ToV6` can be
    // exercised in isolation. `study_match_evaluations` (added in v8) FK-references
    // both `study_session_items` and `study_sessions` (ON DELETE CASCADE), so with
    // foreign keys ON it must be dropped FIRST — otherwise dropping `study_sessions`
    // tries to cascade into `study_match_evaluations` and hits the already-dropped
    // `study_session_items` ("no such table"). v5 predates match-evaluations anyway,
    // so removing it is part of reducing to the v5 shape. Drop dependents first.
    Future<void> reduceToV5() async {
      await db.customStatement('DROP TABLE study_match_evaluations');
      await db.customStatement('DROP TABLE study_attempts');
      await db.customStatement('DROP TABLE study_session_items');
      await db.customStatement('DROP TABLE study_sessions');
    }

    Future<void> seedDeckWithCard() async {
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
    }

    test('creates the study tables while preserving existing data', () async {
      await seedDeckWithCard();
      await reduceToV5();

      await migrateV5ToV6(db.createMigrator(), db);

      // Pre-existing content survives the additive migration.
      expect(await db.select(db.flashcards).get(), hasLength(1));

      // The new tables exist and round-trip the FK chain.
      final int ts = now();
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
            ),
          );

      expect(await db.select(db.studySessions).get(), hasLength(1));
      expect(await db.select(db.studySessionItems).get(), hasLength(1));
      final StudyAttemptRow attempt = await db
          .select(db.studyAttempts)
          .getSingle();
      // box_before / box_after default to 0 ("unknown" → history renders "—").
      expect(attempt.boxBefore, 0);
      expect(attempt.boxAfter, 0);
      expect(attempt.userInput, isNull);
    });
  });
}
