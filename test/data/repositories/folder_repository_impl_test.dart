import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/types/target_language.dart';

/// Real in-memory Drift coverage for the folder action-sheet mutations
/// (`docs/contracts/repository-contracts/folder-repository.md` §Test contract,
/// rows F8-F12).
void main() {
  late AppDatabase db;
  late FolderRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FolderRepositoryImpl(FolderDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  Future<Folder> createRoot(String name) async {
    final Result<Folder> result = await repo.createRootFolder(name: name);
    return (result as Ok<Folder>).value;
  }

  Future<Folder> createSub(String parentId, String name) async {
    final Result<Folder> result = await repo.createSubfolder(
      parentId: parentId,
      name: name,
    );
    return (result as Ok<Folder>).value;
  }

  group('renameFolder (F8)', () {
    test('renames and reports the updated folder', () async {
      final Folder korean = await createRoot('Korean');

      final Result<Folder> result = await repo.renameFolder(
        folderId: korean.id,
        name: 'Korean II',
      );

      expect(result, isA<Ok<Folder>>());
      expect((result as Ok<Folder>).value.name, 'Korean II');
    });

    test('rejects a duplicate sibling name', () async {
      await createRoot('Korean');
      final Folder english = await createRoot('English');

      final Result<Folder> result = await repo.renameFolder(
        folderId: english.id,
        name: 'korean',
      );

      expect(result, isA<Err<Folder>>());
      expect(
        (result as Err<Folder>).failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );
    });

    test('an unchanged name is a no-op success', () async {
      final Folder korean = await createRoot('Korean');

      final Result<Folder> result = await repo.renameFolder(
        folderId: korean.id,
        name: 'Korean',
      );

      expect((result as Ok<Folder>).value.name, 'Korean');
    });
  });

  group('moveFolder (F9-F11)', () {
    test('moves under a new parent and locks the destination', () async {
      final Folder a = await createRoot('A');
      final Folder b = await createRoot('B');

      final Result<Folder> result = await repo.moveFolder(
        folderId: a.id,
        newParentId: b.id,
      );

      expect((result as Ok<Folder>).value.parentId, b.id);
      // Destination flips unlocked → subfolders.
      final Result<List<FolderMoveTarget>> targets = await repo
          .getFolderMoveTargets(folderId: a.id);
      final FolderMoveTarget bTarget = (targets as Ok<List<FolderMoveTarget>>)
          .value
          .firstWhere((FolderMoveTarget t) => t.id == b.id);
      // B now holds A, so B is a valid (non-blocked) destination still.
      expect(bTarget.isCurrentParent, isTrue);
    });

    test('rejects a move that would create a cycle', () async {
      final Folder a = await createRoot('A');
      final Folder b = await createRoot('B');
      await repo.moveFolder(folderId: a.id, newParentId: b.id);

      // B → under A would form B→A→B.
      final Result<Folder> result = await repo.moveFolder(
        folderId: b.id,
        newParentId: a.id,
      );

      expect(
        (result as Err<Folder>).failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.cycleDetected,
        ),
      );
    });

    test('rejects a move into a decks-locked folder', () async {
      final Folder a = await createRoot('A');
      final Folder c = await createRoot('C');
      await repo.createDeck(
        parentFolderId: c.id,
        name: 'Deck',
        targetLanguage: TargetLanguage.korean,
      );

      final Result<Folder> result = await repo.moveFolder(
        folderId: a.id,
        newParentId: c.id,
      );

      expect((result as Err<Folder>).failure, isA<UnsupportedActionFailure>());
    });

    test('reverts an emptied old parent to unlocked', () async {
      final Folder parent = await createRoot('Parent');
      final Folder child = await createSub(parent.id, 'Child');

      await repo.moveFolder(folderId: child.id, newParentId: null);

      final Result<List<FolderMoveTarget>> targets = await repo
          .getFolderMoveTargets(folderId: child.id);
      final FolderMoveTarget parentTarget =
          (targets as Ok<List<FolderMoveTarget>>).value.firstWhere(
            (FolderMoveTarget t) => t.id == parent.id,
          );
      // Reverted to unlocked ⇒ no longer blocked as a decks-locked target.
      expect(parentTarget.block, isNull);
    });
  });

  group('deleteFolder (F12)', () {
    test('deletes the folder and its whole subtree', () async {
      final Folder parent = await createRoot('Parent');
      final Folder child = await createSub(parent.id, 'Child');

      final Result<void> result = await repo.deleteFolder(folderId: parent.id);

      expect(result, isA<Ok<void>>());
      final FolderDao dao = FolderDao(db);
      expect(await dao.findFolder(parent.id), isNull);
      expect(await dao.findFolder(child.id), isNull);
    });
  });

  group('getFolderMoveTargets', () {
    test('returns root plus folders with cycle/locked reasons', () async {
      final Folder a = await createRoot('A');
      final Folder aChild = await createSub(a.id, 'A-child');
      final Folder b = await createRoot('B');
      await repo.createDeck(
        parentFolderId: b.id,
        name: 'Deck',
        targetLanguage: TargetLanguage.korean,
      );

      final Result<List<FolderMoveTarget>> result = await repo
          .getFolderMoveTargets(folderId: a.id);
      final List<FolderMoveTarget> targets =
          (result as Ok<List<FolderMoveTarget>>).value;

      // Root is always offered and is the current parent of A.
      final FolderMoveTarget root = targets.firstWhere(
        (FolderMoveTarget t) => t.id == null,
      );
      expect(root.isCurrentParent, isTrue);

      // The folder itself and its descendants are blocked as cycles.
      expect(
        targets.firstWhere((FolderMoveTarget t) => t.id == a.id).block,
        FolderMoveBlock.cycle,
      );
      expect(
        targets.firstWhere((FolderMoveTarget t) => t.id == aChild.id).block,
        FolderMoveBlock.cycle,
      );
      // A decks-locked folder is blocked with its reason, not hidden.
      expect(
        targets.firstWhere((FolderMoveTarget t) => t.id == b.id).block,
        FolderMoveBlock.lockedToDecks,
      );
    });
  });
}
