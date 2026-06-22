import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/migrations/v8_add_match_evaluations.dart';

void main() {
  // Migration contract (`docs/database/migration-contract.md`): reduce the db to
  // the v7 shape with data, run the migration, and assert existing data is
  // preserved and the new table works. The v7→v8 step is purely additive (one new
  // append-only table + two indexes), so we drop `study_match_evaluations` to
  // recreate the v7 shape, seed a session/item/card, then run `migrateV7ToV8` and
  // exercise the addition (insert + read + cascade). WBS 4.5.4 (WP-SM1a).
  group('v7 → v8 migration (Match-evaluation enabler)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    // Mimic the v7 shape: drop the v8 addition (one table; indexes go with it).
    Future<void> reduceToV7() async {
      await db.customStatement('DROP TABLE study_match_evaluations');
    }

    Future<void> seedSessionItem() async {
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
              front: '먹다',
              back: 'to eat',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 's1',
              entryType: 'deck',
              studyType: 'srs_review',
              status: 'in_progress',
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
    }

    test('adds study_match_evaluations while preserving data', () async {
      await seedSessionItem();
      await reduceToV7();

      await migrateV7ToV8(db.createMigrator(), db);

      // Pre-existing content survives the additive migration.
      expect(await db.select(db.studySessions).get(), hasLength(1));

      // The new append-only table round-trips.
      final int ts = now();
      await db
          .into(db.studyMatchEvaluations)
          .insert(
            StudyMatchEvaluationsCompanion.insert(
              id: 'm1',
              sessionId: 's1',
              sessionItemId: 'i1',
              flashcardId: 'c1',
              boardIndex: 0,
              pairId: 'c1',
              selectedFrontCellId: 'cell-f0',
              selectedBackCellId: 'cell-b0',
              expectedFrontFlashcardId: 'c1',
              expectedBackFlashcardId: 'c1',
              isCorrect: true,
              attemptOrder: 0,
              evaluatedAt: ts,
              createdAt: ts,
            ),
          );
      final StudyMatchEvaluationRow row = await db
          .select(db.studyMatchEvaluations)
          .getSingle();
      expect(row.isCorrect, isTrue);
      expect(row.attemptOrder, 0);

      // Cascades on session delete.
      await db.customStatement('PRAGMA foreign_keys = ON');
      await (db.delete(db.studySessions)..where((t) => t.id.equals('s1'))).go();
      expect(
        await db.select(db.studyMatchEvaluations).get(),
        isEmpty,
        reason: 'study_match_evaluations cascades on session delete',
      );
    });
  });
}
