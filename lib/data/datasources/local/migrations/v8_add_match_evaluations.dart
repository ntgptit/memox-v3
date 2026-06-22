import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v7 → v8: the Match-mode evaluation enabler (WBS 4.5.4, WP-SM1a).
///
/// Purely additive: creates the append-only `study_match_evaluations` table
/// (+ its `idx_study_match_evaluations_session` / `_session_item` indexes). No
/// existing data is touched (fresh table, no back-fill) and no behavior reads or
/// writes it yet — the repository/use-case persistence lands in WP-SM1b and the
/// finalization derivation in WP-SM2. See `docs/database/migration-contract.md`,
/// `docs/database/schema-contract.md` §study_match_evaluations, and
/// `docs/contracts/repository-contracts/study-repository.md` §Match.
Future<void> migrateV7ToV8(Migrator m, AppDatabase db) async {
  await m.createTable(db.studyMatchEvaluations);
  await m.create(db.idxStudyMatchEvaluationsSession);
  await m.create(db.idxStudyMatchEvaluationsSessionItem);
}
