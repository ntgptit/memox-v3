import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// v8 — Flashcard List enrichment:
/// - `flashcards.part_of_speech TEXT NULL` (grammatical POS chip on list/editor).
/// - `flashcards.is_flagged BOOLEAN NOT NULL DEFAULT FALSE` (Flagged filter).
/// Both additive; existing rows migrate to NULL / false.
/// See `docs/database/migration-contract.md`.
Future<void> addFlashcardPosAndFlag(Migrator m, AppDatabase db) async {
  await m.addColumn(db.flashcards, db.flashcards.partOfSpeech);
  await m.addColumn(db.flashcards, db.flashcards.isFlagged);
}
