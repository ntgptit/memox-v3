import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/types/content_mode.dart';

void main() {
  // Folder mutation contract: WBS 2.1.1 (create), 2.2.1 (rename), 2.3.1
  // (delete cascade), 2.6.1 (content-mode guard). Decision rows F1-F4, F8, F9
  // (`docs/decision-tables/folder.md`).
  group('FolderRepositoryImpl mutations', () {
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
        idGenerator: IdGenerator(Random(42)),
        nowMs: () => clock++,
      );
    });
    tearDown(() => db.close());

    Future<ContentMode> modeOf(String id) async {
      final FolderRow row = (await dao.findFolderById(id))!;
      return FolderMapper.contentModeFromStorage(row.contentMode);
    }

    test('F1: creates an unlocked root folder with sort_order 0', () async {
      final result = await repo.createRootFolder(name: '  Korean  ');

      expect(result.isSuccess, isTrue);
      final Folder folder = result.data!;
      expect(folder.name, 'Korean'); // trimmed
      expect(folder.parentId, isNull);
      expect(folder.contentMode, ContentMode.unlocked);
      expect(folder.sortOrder, 0);
      expect(await dao.findFolderById(folder.id), isNotNull);
    });

    test('F1: appends sort_order for subsequent root folders', () async {
      final a = await repo.createRootFolder(name: 'A');
      final b = await repo.createRootFolder(name: 'B');

      expect(a.data!.sortOrder, 0);
      expect(b.data!.sortOrder, 1);
    });

    test('F2: rejects an empty/whitespace name and persists nothing', () async {
      final result = await repo.createRootFolder(name: '   ');

      expect(result.isFailure, isTrue);
      expect(
        result.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.empty,
        ),
      );
      expect(await dao.siblingFolders(null), isEmpty);
    });

    test('rejects a case-insensitive duplicate root name', () async {
      await repo.createRootFolder(name: 'Box');
      final dup = await repo.createRootFolder(name: 'box');

      expect(
        dup.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );
    });

    test(
      'F3: creating a subfolder locks an unlocked parent to subfolders',
      () async {
        final parent = await repo.createRootFolder(name: 'Parent');
        final child = await repo.createSubfolder(
          parentId: parent.data!.id,
          name: 'Child',
        );

        expect(child.isSuccess, isTrue);
        expect(child.data!.parentId, parent.data!.id);
        expect(child.data!.contentMode, ContentMode.unlocked);
        expect(await modeOf(parent.data!.id), ContentMode.subfolders);
      },
    );

    test(
      'F3: a second subfolder keeps the parent in subfolders mode',
      () async {
        final parent = await repo.createRootFolder(name: 'Parent');
        await repo.createSubfolder(parentId: parent.data!.id, name: 'C1');
        final c2 = await repo.createSubfolder(
          parentId: parent.data!.id,
          name: 'C2',
        );

        expect(c2.isSuccess, isTrue);
        expect(await modeOf(parent.data!.id), ContentMode.subfolders);
      },
    );

    test('F4: a decks-locked parent rejects a subfolder (typed)', () async {
      const String parentId = 'decks-parent';
      await dao.insertFolder(
        FoldersCompanion.insert(
          id: parentId,
          name: 'Decks',
          contentMode: 'decks',
          sortOrder: 0,
          createdAt: 0,
          updatedAt: 0,
        ),
      );

      final result = await repo.createSubfolder(
        parentId: parentId,
        name: 'Nope',
      );

      expect(
        result.failure,
        isA<UnsupportedActionFailure>().having(
          (UnsupportedActionFailure f) => f.message,
          'message',
          'folder_contains_decks',
        ),
      );
      expect(await dao.childFolderCount(parentId), 0);
    });

    test('rejects a subfolder under a missing parent', () async {
      final result = await repo.createSubfolder(
        parentId: 'ghost',
        name: 'Child',
      );
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('rejects a duplicate sibling subfolder name', () async {
      final parent = await repo.createRootFolder(name: 'Parent');
      await repo.createSubfolder(parentId: parent.data!.id, name: 'Dup');
      final dup = await repo.createSubfolder(
        parentId: parent.data!.id,
        name: 'dup',
      );

      expect(
        dup.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );
    });

    test('F8: renames a folder', () async {
      final folder = await repo.createRootFolder(name: 'Old');
      final renamed = await repo.renameFolder(
        id: folder.data!.id,
        newName: '  New  ',
      );

      expect(renamed.data!.name, 'New');
      expect((await dao.findFolderById(folder.data!.id))!.name, 'New');
    });

    test('rename is a no-op when the trimmed name is unchanged', () async {
      final folder = await repo.createRootFolder(name: 'Same');
      final renamed = await repo.renameFolder(
        id: folder.data!.id,
        newName: ' Same ',
      );

      expect(renamed.isSuccess, isTrue);
      expect(renamed.data!.name, 'Same');
    });

    test('rename rejects empty and duplicate names', () async {
      final a = await repo.createRootFolder(name: 'A');
      await repo.createRootFolder(name: 'B');

      final empty = await repo.renameFolder(id: a.data!.id, newName: '  ');
      expect(empty.failure, isA<ValidationFailure>());

      final dup = await repo.renameFolder(id: a.data!.id, newName: 'b');
      expect(
        dup.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );
    });

    test('rename rejects a missing folder', () async {
      final result = await repo.renameFolder(id: 'ghost', newName: 'X');
      expect(result.failure, isA<NotFoundFailure>());
    });

    test('F8: delete cascades to descendant folders', () async {
      final root = await repo.createRootFolder(name: 'Root');
      final child = await repo.createSubfolder(
        parentId: root.data!.id,
        name: 'Child',
      );
      final grandchild = await repo.createSubfolder(
        parentId: child.data!.id,
        name: 'Grandchild',
      );

      final result = await repo.deleteFolder(id: root.data!.id);

      expect(result.isSuccess, isTrue);
      expect(await dao.findFolderById(root.data!.id), isNull);
      expect(await dao.findFolderById(child.data!.id), isNull);
      expect(await dao.findFolderById(grandchild.data!.id), isNull);
    });

    test(
      'F9: deleting the last child reverts the parent to unlocked',
      () async {
        final parent = await repo.createRootFolder(name: 'Parent');
        final c1 = await repo.createSubfolder(
          parentId: parent.data!.id,
          name: 'C1',
        );
        final c2 = await repo.createSubfolder(
          parentId: parent.data!.id,
          name: 'C2',
        );

        await repo.deleteFolder(id: c1.data!.id);
        expect(
          await modeOf(parent.data!.id),
          ContentMode.subfolders,
        ); // still 1

        await repo.deleteFolder(id: c2.data!.id);
        expect(await modeOf(parent.data!.id), ContentMode.unlocked); // emptied
      },
    );

    test('delete rejects a missing folder', () async {
      final result = await repo.deleteFolder(id: 'ghost');
      expect(result.failure, isA<NotFoundFailure>());
    });
  });
}
