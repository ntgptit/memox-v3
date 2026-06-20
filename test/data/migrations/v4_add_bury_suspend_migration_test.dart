import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/migrations/v4_add_bury_suspend.dart';

void main() {
  // Migration contract (`docs/database/migration-contract.md`): open a database
  // shaped like the previous version with data, run the migration, assert data
  // is preserved and the new columns work with their documented defaults. The
  // v3→v4 step is additive (two columns on `flashcard_progress`), so we drop the
  // columns to recreate the v3 shape, seed a card + progress row, then run
  // `migrateV3ToV4`. WBS 4.0.2.
  group('v3 → v4 migration (add bury/suspend columns)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    // Rebuild `flashcard_progress` without the v4 columns to mimic the v3 shape,
    // preserving the seeded progress row.
    Future<void> reduceToV3() async {
      await db.customStatement('PRAGMA foreign_keys = OFF');
      await db.customStatement('''
        CREATE TABLE flashcard_progress_v3 (
          flashcard_id TEXT NOT NULL PRIMARY KEY
            REFERENCES flashcards (id) ON DELETE CASCADE,
          box_number INTEGER NOT NULL DEFAULT 1,
          due_at INTEGER,
          review_count INTEGER NOT NULL DEFAULT 0,
          lapse_count INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.customStatement('''
        INSERT INTO flashcard_progress_v3
          (flashcard_id, box_number, due_at, review_count, lapse_count)
        SELECT flashcard_id, box_number, due_at, review_count, lapse_count
        FROM flashcard_progress
      ''');
      await db.customStatement('DROP TABLE flashcard_progress');
      await db.customStatement(
        'ALTER TABLE flashcard_progress_v3 RENAME TO flashcard_progress',
      );
      await db.customStatement('PRAGMA foreign_keys = ON');
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
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: 'c1',
              boxNumber: const Value<int>(3),
              reviewCount: const Value<int>(5),
            ),
          );
    }

    test(
      'adds the columns, preserves rows, and applies documented defaults',
      () async {
        await seedCardWithProgress();
        await reduceToV3();

        await migrateV3ToV4(db.createMigrator(), db);

        // Existing progress survives the additive migration and back-fills the
        // documented defaults: not-suspended / not-buried.
        final FlashcardProgressRow row = await db
            .select(db.flashcardProgress)
            .getSingle();
        expect(row.boxNumber, 3, reason: 'pre-existing data preserved');
        expect(row.reviewCount, 5, reason: 'pre-existing data preserved');
        expect(row.isSuspended, isFalse, reason: 'default not-suspended');
        expect(row.buriedUntil, isNull, reason: 'default not-buried');
      },
    );

    test('the recreated columns accept explicit bury/suspend values', () async {
      await seedCardWithProgress();
      await reduceToV3();
      await migrateV3ToV4(db.createMigrator(), db);

      final int buryUntil = now() + 60000;
      await (db.update(
        db.flashcardProgress,
      )..where((t) => t.flashcardId.equals('c1'))).write(
        FlashcardProgressCompanion(
          isSuspended: const Value<bool>(true),
          buriedUntil: Value<int>(buryUntil),
        ),
      );

      final FlashcardProgressRow row = await db
          .select(db.flashcardProgress)
          .getSingle();
      expect(row.isSuspended, isTrue);
      expect(row.buriedUntil, buryUntil);
    });
  });
}
