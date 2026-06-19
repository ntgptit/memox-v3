import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v2 → v3: add the `flashcards` table and its `idx_flashcards_deck`
/// index.
///
/// Additive migration — no existing rows are touched. Flashcards are deck-owned
/// (`deck_id` NOT NULL, FK→decks ON DELETE CASCADE), so deleting a deck (or a
/// folder above it) cascades to its flashcards. See
/// `docs/database/migration-contract.md`,
/// `docs/database/schema-contract.md` and
/// `docs/business/flashcard/flashcard-management.md`.
Future<void> migrateV2ToV3(Migrator m, AppDatabase db) async {
  await m.createTable(db.flashcards);
  await m.create(db.idxFlashcardsDeck);
}
