import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// v10 — Study mode chaining (per-phase flow):
/// - `study_sessions.study_flow TEXT NOT NULL DEFAULT 'srs_recall_review'`
///   (the ordered phase plan; existing rows migrate to the single-phase recall
///   review flow).
/// - `study_sessions.current_mode TEXT NULL` (the active phase pointer; NULL on
///   existing rows resolves through the recall fallback).
/// Both additive. See `docs/database/migration-contract.md` and
/// `docs/business/study/study-flow.md` §Study flows.
Future<void> addStudyFlowAndCurrentMode(Migrator m, AppDatabase db) async {
  await m.addColumn(db.studySessions, db.studySessions.studyFlow);
  await m.addColumn(db.studySessions, db.studySessions.currentMode);
}
