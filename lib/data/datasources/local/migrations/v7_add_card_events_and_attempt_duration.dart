import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// v7 — Card History activity feed support:
/// - `study_attempts.duration_ms INTEGER NULL` (time-on-card, ms; NULL = older
///   rows / non-timed flows → "duration not logged").
/// - `card_events` table + index for per-card lifecycle events (created/edited/
///   audio added) shown alongside attempts in the timeline.
/// See `docs/database/migration-contract.md`.
Future<void> addCardEventsAndAttemptDuration(Migrator m, AppDatabase db) async {
  await m.addColumn(db.studyAttempts, db.studyAttempts.durationMs);
  await m.createTable(db.cardEvents);
  await m.createIndex(db.idxCardEventsFlashcard);
}
