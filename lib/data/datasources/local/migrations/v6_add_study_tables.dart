import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v5 → v6: add the study-persistence tables (ENABLER — WBS 4.0.1).
///
/// Creates `study_sessions`, `study_session_items`, and `study_attempts` (the
/// FK chain `study_sessions → study_session_items → study_attempts`, plus
/// `study_session_items.flashcard_id → flashcards`), with their resume /
/// queue-order / attempt indexes. Purely additive — no existing table is
/// touched and no data is back-filled (a fresh install has no sessions). No
/// behavior reads these yet; the study loop (session create → answer →
/// finalize → SRS transition) lands in WBS 4.1.x+. See
/// `docs/database/migration-contract.md`, `docs/database/schema-contract.md`,
/// and `docs/business/study/study-flow.md`.
Future<void> migrateV5ToV6(Migrator m, AppDatabase db) async {
  await m.createTable(db.studySessions);
  await m.create(db.idxStudySessionsResumable);
  await m.createTable(db.studySessionItems);
  await m.create(db.idxStudySessionItemsSessionSort);
  await m.createTable(db.studyAttempts);
  await m.create(db.idxStudyAttemptsSessionItem);
}
