import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// v6 — add `flashcard_progress.last_reset_at` (UTC epoch ms, NULL = never
/// reset). Backs the Card History reset divider; existing rows migrate to NULL.
/// See `docs/database/migration-contract.md`.
Future<void> addFlashcardProgressLastResetAt(Migrator m, AppDatabase db) async {
  await m.addColumn(db.flashcardProgress, db.flashcardProgress.lastResetAt);
}
