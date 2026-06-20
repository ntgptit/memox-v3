import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_move_target.dart';
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
        deckDao: DeckDao(db),
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

    // ---- WBS 2.22.1: color/icon presentation tokens ----

    test('2.22.1: createRootFolder persists the color/icon tokens', () async {
      final result = await repo.createRootFolder(
        name: 'Korean',
        color: 'coral',
        icon: 'book',
      );

      expect(result.data!.color, 'coral');
      expect(result.data!.icon, 'book');
      final FolderRow row = (await dao.findFolderById(result.data!.id))!;
      expect(row.color, 'coral');
      expect(row.icon, 'book');
    });

    test('2.22.1: color/icon default to null when omitted', () async {
      final result = await repo.createRootFolder(name: 'Plain');

      expect(result.data!.color, isNull);
      expect(result.data!.icon, isNull);
    });

    test('2.22.1: createSubfolder carries the color/icon tokens', () async {
      final parent = await repo.createRootFolder(name: 'Parent');
      final child = await repo.createSubfolder(
        parentId: parent.data!.id,
        name: 'Child',
        color: 'teal',
        icon: 'star',
      );

      final FolderRow row = (await dao.findFolderById(child.data!.id))!;
      expect(row.color, 'teal');
      expect(row.icon, 'star');
    });

    test('2.22.1: renameFolder overwrites the color/icon tokens', () async {
      final folder = await repo.createRootFolder(
        name: 'Old',
        color: 'coral',
        icon: 'book',
      );
      final renamed = await repo.renameFolder(
        id: folder.data!.id,
        newName: 'New',
        color: 'teal',
        icon: 'star',
      );

      expect(renamed.data!.name, 'New');
      expect(renamed.data!.color, 'teal');
      expect(renamed.data!.icon, 'star');
      final FolderRow row = (await dao.findFolderById(folder.data!.id))!;
      expect(row.color, 'teal');
      expect(row.icon, 'star');
    });

    test('2.22.1: renameFolder leaves tokens untouched when omitted', () async {
      final folder = await repo.createRootFolder(
        name: 'Keep',
        color: 'coral',
        icon: 'book',
      );
      final renamed = await repo.renameFolder(
        id: folder.data!.id,
        newName: 'Kept',
      );

      expect(renamed.data!.color, 'coral');
      expect(renamed.data!.icon, 'book');
      final FolderRow row = (await dao.findFolderById(folder.data!.id))!;
      expect(row.color, 'coral');
      expect(row.icon, 'book');
    });

    test('2.22.1: renameFolder updates only the supplied token', () async {
      final folder = await repo.createRootFolder(
        name: 'Half',
        color: 'coral',
        icon: 'book',
      );
      // Only icon is supplied; color must stay untouched (independent
      // Value.absent() per token).
      final renamed = await repo.renameFolder(
        id: folder.data!.id,
        newName: 'Half',
        icon: 'star',
      );

      expect(renamed.data!.color, 'coral');
      expect(renamed.data!.icon, 'star');
      final FolderRow row = (await dao.findFolderById(folder.data!.id))!;
      expect(row.color, 'coral');
      expect(row.icon, 'star');
    });

    test(
      '2.22.1: renameFolder restyles even when the name is unchanged',
      () async {
        final folder = await repo.createRootFolder(name: 'Same');
        final restyled = await repo.renameFolder(
          id: folder.data!.id,
          newName: 'Same',
          color: 'teal',
        );

        expect(restyled.isSuccess, isTrue);
        expect(restyled.data!.color, 'teal');
        final FolderRow row = (await dao.findFolderById(folder.data!.id))!;
        expect(row.color, 'teal');
      },
    );

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

    // ---- Move (WBS 2.4.1, decision rows F7, F14-F17) ----

    Future<FolderRow> rowOf(String id) async => (await dao.findFolderById(id))!;

    test('F14: moves a folder into an unlocked parent and locks it', () async {
      final source = await repo.createRootFolder(name: 'Source');
      final dest = await repo.createRootFolder(name: 'Dest');

      final moved = await repo.moveFolder(
        id: source.data!.id,
        newParentId: dest.data!.id,
      );

      expect(moved.isSuccess, isTrue);
      expect(moved.data!.parentId, dest.data!.id);
      expect(moved.data!.sortOrder, 0); // first child of Dest
      expect((await rowOf(source.data!.id)).parentId, dest.data!.id);
      expect(await modeOf(dest.data!.id), ContentMode.subfolders);
    });

    test(
      'F14: moving the last child reverts the old parent to unlocked',
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
        final dest = await repo.createRootFolder(name: 'Dest');

        await repo.moveFolder(id: c1.data!.id, newParentId: dest.data!.id);
        expect(
          await modeOf(parent.data!.id),
          ContentMode.subfolders,
        ); // C2 left

        await repo.moveFolder(id: c2.data!.id, newParentId: dest.data!.id);
        expect(await modeOf(parent.data!.id), ContentMode.unlocked); // emptied
      },
    );

    test('F19: move to the current parent is a no-op', () async {
      final folder = await repo.createRootFolder(name: 'Root');

      final moved = await repo.moveFolder(
        id: folder.data!.id,
        newParentId: null,
      );

      expect(moved.isSuccess, isTrue);
      expect(moved.data!.parentId, isNull);
      expect(moved.data!.sortOrder, folder.data!.sortOrder); // unchanged
    });

    test('F7: rejects moving a folder into itself (cycle)', () async {
      final folder = await repo.createRootFolder(name: 'Self');

      final moved = await repo.moveFolder(
        id: folder.data!.id,
        newParentId: folder.data!.id,
      );

      expect(
        moved.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.cycleDetected,
        ),
      );
    });

    test('F7: rejects moving a folder into a descendant (cycle)', () async {
      final parent = await repo.createRootFolder(name: 'Parent');
      final child = await repo.createSubfolder(
        parentId: parent.data!.id,
        name: 'Child',
      );

      final moved = await repo.moveFolder(
        id: parent.data!.id,
        newParentId: child.data!.id,
      );

      expect(
        moved.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.cycleDetected,
        ),
      );
      expect((await rowOf(parent.data!.id)).parentId, isNull); // unchanged
    });

    test(
      'F7: a decks-locked descendant is a cycle, not a decks-lock',
      () async {
        final parent = await repo.createRootFolder(name: 'Parent');
        final child = await repo.createSubfolder(
          parentId: parent.data!.id,
          name: 'Child',
        );
        // Force the descendant into decks mode to exercise guard ordering.
        await dao.updateFolderColumns(
          child.data!.id,
          const FoldersCompanion(contentMode: Value('decks')),
        );

        final moved = await repo.moveFolder(
          id: parent.data!.id,
          newParentId: child.data!.id,
        );

        expect(
          moved.failure,
          isA<ValidationFailure>().having(
            (ValidationFailure f) => f.code,
            'code',
            ValidationCode.cycleDetected,
          ),
        );
      },
    );

    test('F15: rejects moving into a decks-locked parent (typed)', () async {
      const String decksId = 'decks-parent';
      await dao.insertFolder(
        FoldersCompanion.insert(
          id: decksId,
          name: 'Decks',
          contentMode: 'decks',
          sortOrder: 0,
          createdAt: 0,
          updatedAt: 0,
        ),
      );
      final folder = await repo.createRootFolder(name: 'Movable');

      final moved = await repo.moveFolder(
        id: folder.data!.id,
        newParentId: decksId,
      );

      expect(
        moved.failure,
        isA<UnsupportedActionFailure>().having(
          (UnsupportedActionFailure f) => f.message,
          'message',
          'folder_contains_decks',
        ),
      );
    });

    test('F16: rejects a move that duplicates a destination sibling', () async {
      final parent = await repo.createRootFolder(name: 'Parent');
      await repo.createSubfolder(parentId: parent.data!.id, name: 'Dup');
      final mover = await repo.createRootFolder(name: 'dup'); // root, same name

      final moved = await repo.moveFolder(
        id: mover.data!.id,
        newParentId: parent.data!.id,
      );

      expect(
        moved.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );
    });

    test('F17: rejects a move to a missing parent', () async {
      final folder = await repo.createRootFolder(name: 'Movable');
      final moved = await repo.moveFolder(
        id: folder.data!.id,
        newParentId: 'ghost',
      );
      expect(moved.failure, isA<NotFoundFailure>());
    });

    test('move rejects a missing folder', () async {
      final moved = await repo.moveFolder(id: 'ghost', newParentId: null);
      expect(moved.failure, isA<NotFoundFailure>());
    });

    // ---- Move targets (WBS 2.4.1, decision row F18) ----

    FolderMoveTarget targetFor(List<FolderMoveTarget> targets, String? id) =>
        targets.firstWhere((FolderMoveTarget t) => t.id == id);

    test('F18: annotates root, cycle, decks-lock and current parent', () async {
      final a = await repo.createRootFolder(name: 'A');
      final a1 = await repo.createSubfolder(parentId: a.data!.id, name: 'A1');
      final b = await repo.createRootFolder(name: 'B');
      const String decksId = 'decks-folder';
      await dao.insertFolder(
        FoldersCompanion.insert(
          id: decksId,
          name: 'Decks',
          contentMode: 'decks',
          sortOrder: 5,
          createdAt: 0,
          updatedAt: 0,
        ),
      );

      final result = await repo.getFolderMoveTargets(folderId: a.data!.id);

      expect(result.isSuccess, isTrue);
      final List<FolderMoveTarget> targets = result.data!;

      // Library root: selectable, current parent of root folder A.
      final FolderMoveTarget root = targetFor(targets, null);
      expect(root.block, isNull);
      expect(root.isCurrentParent, isTrue);
      expect(root.breadcrumb, isEmpty);

      // A itself and descendant A1 are cycle-blocked.
      expect(targetFor(targets, a.data!.id).block, FolderMoveBlock.cycle);
      expect(targetFor(targets, a1.data!.id).block, FolderMoveBlock.cycle);
      expect(targetFor(targets, a1.data!.id).breadcrumb, <String>['A', 'A1']);

      // Unrelated unlocked folder B is selectable.
      expect(targetFor(targets, b.data!.id).block, isNull);

      // Decks-locked folder is blocked but still listed.
      expect(targetFor(targets, decksId).block, FolderMoveBlock.lockedToDecks);
    });

    test(
      'F18: marks the immediate parent as current for a subfolder',
      () async {
        final a = await repo.createRootFolder(name: 'A');
        final a1 = await repo.createSubfolder(parentId: a.data!.id, name: 'A1');

        final result = await repo.getFolderMoveTargets(folderId: a1.data!.id);

        final List<FolderMoveTarget> targets = result.data!;
        expect(targetFor(targets, a.data!.id).isCurrentParent, isTrue);
        expect(targetFor(targets, null).isCurrentParent, isFalse);
      },
    );

    // ---- Reorder (WBS 2.5.1, decision rows F10, F11) ----

    test(
      'F10: reorders siblings and persists deterministic sort_order',
      () async {
        final a = await repo.createRootFolder(name: 'A');
        final b = await repo.createRootFolder(name: 'B');
        final c = await repo.createRootFolder(name: 'C');

        final result = await repo.reorderFolders(
          parentId: null,
          orderedIds: <String>[c.data!.id, a.data!.id, b.data!.id],
        );

        expect(result.isSuccess, isTrue);
        expect((await rowOf(c.data!.id)).sortOrder, 0);
        expect((await rowOf(a.data!.id)).sortOrder, 1);
        expect((await rowOf(b.data!.id)).sortOrder, 2);
      },
    );

    test('F11: rejects a duplicate id and preserves the order', () async {
      final a = await repo.createRootFolder(name: 'A');
      final b = await repo.createRootFolder(name: 'B');
      await repo.createRootFolder(name: 'C');

      final result = await repo.reorderFolders(
        parentId: null,
        orderedIds: <String>[a.data!.id, a.data!.id, b.data!.id],
      );

      expect(
        result.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.invalidFormat,
        ),
      );
      expect((await rowOf(a.data!.id)).sortOrder, 0); // unchanged
    });

    test('F11: rejects a partial sibling list', () async {
      final a = await repo.createRootFolder(name: 'A');
      final b = await repo.createRootFolder(name: 'B');
      await repo.createRootFolder(name: 'C');

      final result = await repo.reorderFolders(
        parentId: null,
        orderedIds: <String>[a.data!.id, b.data!.id], // missing C
      );

      expect(result.failure, isA<ValidationFailure>());
    });

    test('F11: rejects a cross-parent id', () async {
      final a = await repo.createRootFolder(name: 'A');
      final b = await repo.createRootFolder(name: 'B');
      final sub = await repo.createSubfolder(parentId: a.data!.id, name: 'Sub');

      final result = await repo.reorderFolders(
        parentId: null,
        orderedIds: <String>[a.data!.id, b.data!.id, sub.data!.id],
      );

      expect(result.failure, isA<ValidationFailure>());
    });
  });
}
