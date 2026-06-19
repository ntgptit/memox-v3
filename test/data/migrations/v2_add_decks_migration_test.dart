import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/migrations/v2_add_decks.dart';

void main() {
  // Migration contract (`docs/database/migration-contract.md`): open a database
  // shaped like the previous version with data, run the migration, assert data
  // is preserved and the new schema works. The v1→v2 step is additive (decks
  // table + index), so we drop `decks` to recreate the v1 shape, seed a folder,
  // then run `migrateV1ToV2`.
  group('v1 → v2 migration (add decks)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    Future<void> reduceToV1() async {
      await db.customStatement('DROP INDEX IF EXISTS idx_decks_folder');
      await db.customStatement('DROP TABLE IF EXISTS decks');
    }

    test('recreates the decks table and preserves folder data', () async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'folder',
              name: 'Korean',
              contentMode: 'unlocked',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      await reduceToV1();

      await migrateV1ToV2(db.createMigrator(), db);

      // Folder data survives the additive migration.
      final FolderRow folder = await db.select(db.folders).getSingle();
      expect(folder.name, 'Korean');

      // The recreated decks table accepts a folder-owned deck.
      await db.customStatement('PRAGMA foreign_keys = ON');
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'folder',
              name: 'Verbs',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
      expect(await db.select(db.decks).get(), hasLength(1));
    });
  });
}
