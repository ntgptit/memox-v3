import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/migrations/v5_add_folder_color_icon.dart';

void main() {
  // Migration contract (`docs/database/migration-contract.md`): open a database
  // shaped like the previous version with data, run the migration, assert data
  // is preserved and the new schema works. The v4→v5 step is additive (two
  // nullable `folders` columns), so we drop the new columns to recreate the
  // pre-v5 `folders` shape, seed a folder, then run `migrateV4ToV5`. WBS 2.22.1.
  group('v4 → v5 migration (add folders.color + folders.icon)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    // Rebuild the `folders` table without `color`/`icon` (its pre-v5 shape) and
    // re-seed the surviving row, so the migration runs against a true pre-v5
    // table.
    Future<void> reduceFoldersToPreV5(int ts) async {
      await db.customStatement('PRAGMA foreign_keys = OFF');
      await db.customStatement('DROP INDEX IF EXISTS idx_folders_parent');
      await db.customStatement('DROP TABLE folders');
      await db.customStatement(
        'CREATE TABLE folders ('
        'id TEXT NOT NULL PRIMARY KEY, '
        'parent_id TEXT REFERENCES folders (id) ON DELETE RESTRICT, '
        'name TEXT NOT NULL, '
        'content_mode TEXT NOT NULL, '
        'sort_order INTEGER NOT NULL, '
        'created_at INTEGER NOT NULL, '
        'updated_at INTEGER NOT NULL)',
      );
      await db.customStatement(
        'CREATE INDEX idx_folders_parent ON folders (parent_id)',
      );
      await db.customStatement(
        'INSERT INTO folders '
        '(id, parent_id, name, content_mode, sort_order, created_at, updated_at) '
        "VALUES ('folder', NULL, 'Korean', 'unlocked', 0, $ts, $ts)",
      );
      await db.customStatement('PRAGMA foreign_keys = ON');
    }

    test('adds the columns and preserves existing folder data', () async {
      final int ts = now();
      await reduceFoldersToPreV5(ts);

      await migrateV4ToV5(db.createMigrator(), db);

      // Existing row survives; the new columns default to NULL.
      final FolderRow row = await db.select(db.folders).getSingle();
      expect(row.name, 'Korean');
      expect(row.color, isNull, reason: 'new column defaults to NULL');
      expect(row.icon, isNull, reason: 'new column defaults to NULL');

      // The migrated table accepts the optional tokens.
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'styled',
              name: 'Styled',
              contentMode: 'unlocked',
              color: const Value('coral'),
              icon: const Value('book'),
              sortOrder: 1,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      final FolderRow styled = await (db.select(
        db.folders,
      )..where((t) => t.id.equals('styled'))).getSingle();
      expect(styled.color, 'coral');
      expect(styled.icon, 'book');
    });
  });
}
