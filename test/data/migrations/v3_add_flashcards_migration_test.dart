import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/migrations/v3_add_flashcards.dart';

void main() {
  // Migration contract (`docs/database/migration-contract.md`): open a database
  // shaped like the previous version with data, run the migration, assert data
  // is preserved and the new schema works. The v2→v3 step is additive
  // (flashcards + flashcard_progress + flashcard_tags + indexes), so we drop
  // those objects to recreate the v2 shape, seed a folder + deck, then run
  // `migrateV2ToV3`.
  group('v2 → v3 migration (add flashcards)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    Future<void> reduceToV2() async {
      await db.customStatement('DROP INDEX IF EXISTS idx_flashcard_tags_tag');
      await db.customStatement('DROP INDEX IF EXISTS idx_flashcards_deck');
      await db.customStatement('DROP TABLE IF EXISTS flashcard_tags');
      await db.customStatement('DROP TABLE IF EXISTS flashcard_progress');
      await db.customStatement('DROP TABLE IF EXISTS flashcards');
    }

    test('recreates the flashcard tables and preserves deck data', () async {
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

      await reduceToV2();

      await migrateV2ToV3(db.createMigrator(), db);

      // Deck data survives the additive migration.
      expect((await db.select(db.decks).getSingle()).name, 'Verbs');

      // The recreated tables accept a card + its progress + tag rows.
      await db.customStatement('PRAGMA foreign_keys = ON');
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
      await db
          .into(db.flashcardTags)
          .insert(
            FlashcardTagsCompanion.insert(flashcardId: 'c1', tag: 'verb'),
          );

      expect(await db.select(db.flashcards).get(), hasLength(1));
      final progress = await db.select(db.flashcardProgress).getSingle();
      expect(progress.boxNumber, 1, reason: 'default box 1');
      expect(progress.dueAt, isNull, reason: 'default unscheduled');
      expect(await db.select(db.flashcardTags).get(), hasLength(1));
    });
  });
}
