import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v3 → v4: add the bury/suspend state columns to `flashcard_progress`.
///
/// Additive, data-preserving migration (ENABLER — WBS 4.0.2). Adds
/// `is_suspended` (BOOLEAN NOT NULL DEFAULT 0 → existing rows become
/// not-suspended) and `buried_until` (INTEGER NULL → existing rows become
/// not-buried). No behavior reads these yet; the queue-exclusion / status-filter
/// eligibility logic lands later (WBS 4.11.1 / 2.17.1). See
/// `docs/database/migration-contract.md`, `docs/database/schema-contract.md`,
/// and `docs/business/study-actions/bury-suspend.md`.
Future<void> migrateV3ToV4(Migrator m, AppDatabase db) async {
  await m.addColumn(db.flashcardProgress, db.flashcardProgress.isSuspended);
  await m.addColumn(db.flashcardProgress, db.flashcardProgress.buriedUntil);
}
