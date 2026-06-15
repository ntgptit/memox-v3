import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// v11 — New-card due_at correction:
/// Earlier card creation wrote `flashcard_progress.due_at = now`, so
/// never-studied cards were counted as "due" instead of "new". Brand-new cards
/// must have `due_at = NULL` ("never scheduled"); `due_at` is set on the first
/// finalization. This clears `due_at` for never-studied rows only
/// (`review_count = 0`); studied cards keep their schedule.
/// See `docs/business/srs/srs-review.md` §Rules and
/// `docs/database/migration-contract.md`.
Future<void> clearNewCardDueAt(Migrator m, AppDatabase db) async {
  await db.customStatement(
    'UPDATE flashcard_progress SET due_at = NULL '
    'WHERE review_count = 0 AND due_at IS NOT NULL',
  );
}
