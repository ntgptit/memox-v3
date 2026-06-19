import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';

void main() {
  // Folder read models: WBS 3.1.1 (library overview) + 3.2.1 (folder detail).
  // Deck/card counts are 0 until those tables ship (WBS 2.7.x / 2.11.x), so
  // decision rows F12/F13 (non-zero counts) are deferred.
  group('FolderRepositoryImpl read models', () {
    late AppDatabase db;
    late FolderDao dao;
    late FolderRepositoryImpl repo;
    late int clock;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      dao = FolderDao(db);
      clock = 1000;
      repo = FolderRepositoryImpl(
        dao: dao,
        deckDao: DeckDao(db),
        idGenerator: IdGenerator(Random(7)),
        nowMs: () => clock++,
      );
    });
    tearDown(() => db.close());

    test(
      'watchLibraryOverview lists root folders in stable order with counts',
      () async {
        final a = await repo.createRootFolder(name: 'A');
        final b = await repo.createRootFolder(name: 'B');
        await repo.createSubfolder(parentId: a.data!.id, name: 'A1');
        await repo.createSubfolder(parentId: a.data!.id, name: 'A2');

        final LibraryOverview overview = await repo
            .watchLibraryOverview()
            .first;

        expect(
          overview.folders.map((f) => f.folder.name).toList(),
          <String>['A', 'B'], // sort_order ascending
        );
        final aSummary = overview.folders.first;
        expect(aSummary.subfolderCount, 2);
        expect(aSummary.deckCount, 0);
        expect(aSummary.cardCount, 0);
        expect(aSummary.dueCount, 0);
        expect(overview.folders[1].subfolderCount, 0);
        // B sorts after A even though A's id sorts arbitrarily.
        expect(b.data!.sortOrder, 1);
      },
    );

    test(
      'watchFolderDetail returns folder, breadcrumb and child folders',
      () async {
        final root = await repo.createRootFolder(name: 'Root');
        final child1 = await repo.createSubfolder(
          parentId: root.data!.id,
          name: 'C1',
        );
        await repo.createSubfolder(parentId: root.data!.id, name: 'C2');
        // Nested grandchild to exercise the breadcrumb chain.
        await repo.createSubfolder(parentId: child1.data!.id, name: 'C1a');

        final FolderDetail detail = (await repo
            .watchFolderDetail(root.data!.id)
            .first)!;

        expect(detail.folder.name, 'Root');
        expect(
          detail.breadcrumb.map((f) => f.name).toList(),
          <String>['Root'], // root folder: breadcrumb is just itself
        );
        expect(detail.subfolders.map((s) => s.folder.name).toList(), <String>[
          'C1',
          'C2',
        ]);
        // C1 has one subfolder (C1a); C2 has none.
        expect(detail.subfolders.first.subfolderCount, 1);
        expect(detail.subfolders[1].subfolderCount, 0);
        expect(detail.deckCount, 0);
      },
    );

    test(
      'watchFolderDetail breadcrumb runs root -> leaf for nested folders',
      () async {
        final root = await repo.createRootFolder(name: 'Root');
        final mid = await repo.createSubfolder(
          parentId: root.data!.id,
          name: 'Mid',
        );
        final leaf = await repo.createSubfolder(
          parentId: mid.data!.id,
          name: 'Leaf',
        );

        final FolderDetail detail = (await repo
            .watchFolderDetail(leaf.data!.id)
            .first)!;

        expect(detail.breadcrumb.map((f) => f.name).toList(), <String>[
          'Root',
          'Mid',
          'Leaf',
        ]);
      },
    );

    test('watchFolderDetail emits null for a missing folder', () async {
      final FolderDetail? detail = await repo.watchFolderDetail('ghost').first;
      expect(detail, isNull);
    });
  });
}
