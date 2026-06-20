import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v4 → v5: add the nullable `folders.color` and `folders.icon` columns.
///
/// Additive migration — no existing rows are touched. Both columns are nullable
/// TEXT (NULL = no custom token; the UI falls back to the theme default), so
/// existing folders need no backfill. They carry the optional colour/icon tokens
/// chosen via the folder create/edit pickers. See
/// `docs/database/migration-contract.md` and
/// `docs/business/folder/folder-management.md`. WBS 2.22.1.
Future<void> migrateV4ToV5(Migrator m, AppDatabase db) async {
  await m.addColumn(db.folders, db.folders.color);
  await m.addColumn(db.folders, db.folders.icon);
}
