import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

/// Schema v1 → v2: add the `decks` table and its `idx_decks_folder` index.
///
/// Additive migration — no existing rows are touched. Decks are folder-owned
/// (`folder_id` NOT NULL, FK→folders ON DELETE CASCADE) and carry a
/// `target_language` defaulting to `'korean'`. See
/// `docs/database/migration-contract.md` and
/// `docs/business/deck/deck-management.md`.
Future<void> migrateV1ToV2(Migrator m, AppDatabase db) async {
  await m.createTable(db.decks);
  await m.create(db.idxDecksFolder);
}
