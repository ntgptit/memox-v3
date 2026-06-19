import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

void main() {
  group('AppDatabase baseline schema (v1)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    test('reports the baseline schema version', () {
      expect(AppDatabase.currentSchemaVersion, 1);
      expect(db.schemaVersion, 1);
    });

    test('creates the folders table and round-trips a root folder', () async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'f1',
              name: 'Root',
              contentMode: 'empty',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      final List<FolderRow> rows = await db.select(db.folders).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Root');
      expect(rows.single.parentId, isNull);
    });

    test('persists a subfolder self-reference', () async {
      final int ts = now();
      Future<void> insertFolder(String id, {String? parentId}) => db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: id,
              name: id,
              contentMode: 'empty',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
              parentId: Value<String?>(parentId),
            ),
          );

      await insertFolder('root');
      await insertFolder('child', parentId: 'root');

      final FolderRow child = await (db.select(
        db.folders,
      )..where((t) => t.id.equals('child'))).getSingle();
      expect(child.parentId, 'root');
    });

    test(
      'enforces the parent foreign key (RESTRICT on missing parent)',
      () async {
        await db.customStatement('PRAGMA foreign_keys = ON');
        final int ts = now();

        expect(
          () => db
              .into(db.folders)
              .insert(
                FoldersCompanion.insert(
                  id: 'orphan',
                  name: 'orphan',
                  contentMode: 'empty',
                  sortOrder: 0,
                  createdAt: ts,
                  updatedAt: ts,
                  parentId: const Value<String?>('does-not-exist'),
                ),
              ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
