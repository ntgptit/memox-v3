import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v6 → v7: the card-history enabler (WBS 7.0.1).
///
/// Purely additive: creates the `card_events` lifecycle table (+ its
/// `idx_card_events_flashcard` index) and adds two nullable columns —
/// `flashcard_progress.last_reset_at` and `study_attempts.duration_ms`. No
/// existing data is touched (new columns default NULL, no back-fill) and no
/// behavior reads these yet; the review-history query lands in WBS 7.6.1. See
/// `docs/database/migration-contract.md`, `docs/database/schema-contract.md`,
/// and `docs/business/history/card-history.md`.
Future<void> migrateV6ToV7(Migrator m, AppDatabase db) async {
  await m.createTable(db.cardEvents);
  await m.create(db.idxCardEventsFlashcard);
  await m.addColumn(db.flashcardProgress, db.flashcardProgress.lastResetAt);
  await m.addColumn(db.studyAttempts, db.studyAttempts.durationMs);
}
