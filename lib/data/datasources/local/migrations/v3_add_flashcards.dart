import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v2 → v3: add the `flashcards`, `flashcard_progress`, and
/// `flashcard_tags` tables and their indexes.
///
/// Additive migration — no existing rows are touched. Flashcards are
/// deck-owned (`deck_id` NOT NULL, FK→decks ON DELETE CASCADE); progress is 1:1
/// (PK = FK→flashcards, cascade) and tags are 0..N (FK→flashcards, cascade). See
/// `docs/database/migration-contract.md` and
/// `docs/business/flashcard/flashcard-management.md`. WBS 2.11.1.
Future<void> migrateV2ToV3(Migrator m, AppDatabase db) async {
  await m.createTable(db.flashcards);
  await m.create(db.idxFlashcardsDeck);
  await m.createTable(db.flashcardProgress);
  await m.createTable(db.flashcardTags);
  await m.create(db.idxFlashcardTagsTag);
}
