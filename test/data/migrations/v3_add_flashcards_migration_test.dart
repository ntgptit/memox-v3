import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/migrations/v3_add_flashcards.dart';

void main() {
  // Migration contract (`docs/database/migration-contract.md`): open a database
  // shaped like the previous version with data, run the migration, assert data
  // is preserved and the new schema works. The v2→v3 step is additive
  // (flashcards table + index), so we drop `flashcards` to recreate the v2
  // shape, seed a folder + deck, then run `migrateV2ToV3`.
  group('v2 → v3 migration (add flashcards)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<void> reduceToV2() async {
      await db.customStatement('DROP INDEX IF EXISTS idx_flashcards_deck');
      await db.customStatement('DROP TABLE IF EXISTS flashcards');
    }

    test('recreates the flashcards table and preserves deck data', () async {
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'folder',
              name: 'Korean',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'deck',
              folderId: 'folder',
              name: 'Verbs',
              sortOrder: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );

      await reduceToV2();

      await migrateV2ToV3(db.createMigrator(), db);

      // Deck data survives the additive migration.
      final DeckRow deck = await db.select(db.decks).getSingle();
      expect(deck.name, 'Verbs');

      // The recreated flashcards table accepts a deck-owned card.
      await db.customStatement('PRAGMA foreign_keys = ON');
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'c1',
              deckId: 'deck',
              front: 'apple',
              back: '사과',
              sortOrder: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      expect(await db.select(db.flashcards).get(), hasLength(1));
    });
  });
}
