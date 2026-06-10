import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/library_overview.dart';
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

  Future<Deck> createDeck(String parentFolderId, String name) async {
    final Result<Deck> result = await repo.createDeck(
      parentFolderId: parentFolderId,
      name: name,
      targetLanguage: TargetLanguage.korean,
    );
    return (result as Ok<Deck>).value;
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

  group('content mode guard (2.6.1)', () {
    test(
      'rejects deck creation inside a subfolders-mode folder and keeps data unchanged',
      () async {
        final Folder parent = await createRoot('Parent');
        await createSub(parent.id, 'Child');

        final Result<Deck> result = await repo.createDeck(
          parentFolderId: parent.id,
          name: 'Deck',
          targetLanguage: TargetLanguage.korean,
        );

        expect(result, isA<Err<Deck>>());
        expect((result as Err<Deck>).failure, isA<UnsupportedActionFailure>());

        final FolderDao dao = FolderDao(db);
        final FolderRow? parentRow = await dao.findFolder(parent.id);
        expect(parentRow?.contentMode, 'subfolders');
        expect(await dao.childFolderCount(parent.id), 1);
        expect(await dao.childDeckCount(parent.id), 0);
      },
    );

    test(
      'rejects subfolder creation inside a decks-mode folder and keeps data unchanged',
      () async {
        final Folder parent = await createRoot('Parent');
        await createDeck(parent.id, 'Deck');

        final Result<Folder> result = await repo.createSubfolder(
          parentId: parent.id,
          name: 'Child',
        );

        expect(result, isA<Err<Folder>>());
        expect(
          (result as Err<Folder>).failure,
          isA<UnsupportedActionFailure>(),
        );

        final FolderDao dao = FolderDao(db);
        final FolderRow? parentRow = await dao.findFolder(parent.id);
        expect(parentRow?.contentMode, 'decks');
        expect(await dao.childFolderCount(parent.id), 0);
        expect(await dao.childDeckCount(parent.id), 1);
      },
    );

    test(
      'valid mode remains locked after successful sibling creation',
      () async {
        final Folder subfoldersParent = await createRoot('Subfolders');
        await createSub(subfoldersParent.id, 'Child 1');
        await createSub(subfoldersParent.id, 'Child 2');

        final Folder decksParent = await createRoot('Decks');
        await createDeck(decksParent.id, 'Deck 1');
        await createDeck(decksParent.id, 'Deck 2');

        final FolderDao dao = FolderDao(db);
        expect(
          (await dao.findFolder(subfoldersParent.id))?.contentMode,
          'subfolders',
        );
        expect((await dao.findFolder(decksParent.id))?.contentMode, 'decks');
      },
    );
  });

  group('reorderFolders (2.5.1)', () {
    test('rejects an empty reorder list', () async {
      final Result<void> result = await repo.reorderFolders(
        parentId: null,
        orderedIds: const <String>[],
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<ValidationFailure>());
      expect(
        (result.failure as ValidationFailure).code,
        ValidationCode.insufficientContent,
      );
    });

    test(
      'reorders root folders and persists deterministic sort_order',
      () async {
        final Folder a = await createRoot('A');
        final Folder b = await createRoot('B');
        final Folder c = await createRoot('C');

        final Result<void> result = await repo.reorderFolders(
          parentId: null,
          orderedIds: <String>[c.id, a.id, b.id],
        );

        expect(result, isA<Ok<void>>());

        final Result<LibraryOverviewReadModel> overviewResult = await repo
            .watchLibraryOverview()
            .first;
        final LibraryOverviewReadModel overview =
            (overviewResult as Ok<LibraryOverviewReadModel>).value;
        expect(
          overview.folders.map((FolderWithCount row) => row.folder.id),
          <String>[c.id, a.id, b.id],
        );

        final FolderDao dao = FolderDao(db);
        expect((await dao.findFolder(c.id))?.sortOrder, 0);
        expect((await dao.findFolder(a.id))?.sortOrder, 1);
        expect((await dao.findFolder(b.id))?.sortOrder, 2);
      },
    );

    test('reorders subfolders under the same parent', () async {
      final Folder parent = await createRoot('Parent');
      final Folder a = await createSub(parent.id, 'A');
      final Folder b = await createSub(parent.id, 'B');
      final Folder c = await createSub(parent.id, 'C');

      final Result<void> result = await repo.reorderFolders(
        parentId: parent.id,
        orderedIds: <String>[c.id, a.id, b.id],
      );

      expect(result, isA<Ok<void>>());

      final Result<FolderDetail> detailResult = await repo
          .watchFolderDetail(parent.id)
          .first;
      final FolderDetail detail = (detailResult as Ok<FolderDetail>).value;
      expect(
        detail.subfolders.map((FolderWithCount row) => row.folder.id),
        <String>[c.id, a.id, b.id],
      );

      final FolderDao dao = FolderDao(db);
      expect((await dao.findFolder(c.id))?.sortOrder, 0);
      expect((await dao.findFolder(a.id))?.sortOrder, 1);
      expect((await dao.findFolder(b.id))?.sortOrder, 2);
    });

    test('rejects duplicate folder ids and preserves the old order', () async {
      final Folder a = await createRoot('A');
      final Folder b = await createRoot('B');
      final Folder c = await createRoot('C');

      final Result<void> result = await repo.reorderFolders(
        parentId: null,
        orderedIds: <String>[c.id, a.id, a.id],
      );

      expect(result, isA<Err<void>>());
      expect(
        (result as Err<void>).failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );

      final Result<LibraryOverviewReadModel> overviewResult = await repo
          .watchLibraryOverview()
          .first;
      final LibraryOverviewReadModel overview =
          (overviewResult as Ok<LibraryOverviewReadModel>).value;
      expect(
        overview.folders.map((FolderWithCount row) => row.folder.id),
        <String>[a.id, b.id, c.id],
      );
    });

    test('rejects missing folder ids', () async {
      final Folder a = await createRoot('A');
      final Folder b = await createRoot('B');

      final Result<void> result = await repo.reorderFolders(
        parentId: null,
        orderedIds: <String>['missing', a.id],
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<NotFoundFailure>());
      final Result<LibraryOverviewReadModel> overviewResult = await repo
          .watchLibraryOverview()
          .first;
      final LibraryOverviewReadModel overview =
          (overviewResult as Ok<LibraryOverviewReadModel>).value;
      expect(
        overview.folders.map((FolderWithCount row) => row.folder.id),
        <String>[a.id, b.id],
      );
    });

    test('rejects folder ids from another parent scope', () async {
      final Folder parentA = await createRoot('Parent A');
      final Folder a1 = await createSub(parentA.id, 'A1');
      final Folder a2 = await createSub(parentA.id, 'A2');
      final Folder parentB = await createRoot('Parent B');
      final Folder b1 = await createSub(parentB.id, 'B1');

      final Result<void> result = await repo.reorderFolders(
        parentId: parentA.id,
        orderedIds: <String>[b1.id, a1.id, a2.id],
      );

      expect(result, isA<Err<void>>());
      expect(
        (result as Err<void>).failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.invalidFormat,
        ),
      );

      final Result<FolderDetail> detailResult = await repo
          .watchFolderDetail(parentA.id)
          .first;
      final FolderDetail detail = (detailResult as Ok<FolderDetail>).value;
      expect(
        detail.subfolders.map((FolderWithCount row) => row.folder.id),
        <String>[a1.id, a2.id],
      );
    });

    test(
      'rejects partial reorder lists and leaves the previous order unchanged',
      () async {
        final Folder a = await createRoot('A');
        final Folder b = await createRoot('B');
        final Folder c = await createRoot('C');

        final Result<void> result = await repo.reorderFolders(
          parentId: null,
          orderedIds: <String>[c.id, a.id],
        );

        expect(result, isA<Err<void>>());
        expect(
          (result as Err<void>).failure,
          isA<ValidationFailure>().having(
            (ValidationFailure f) => f.code,
            'code',
            ValidationCode.insufficientContent,
          ),
        );

        final Result<LibraryOverviewReadModel> overviewResult = await repo
            .watchLibraryOverview()
            .first;
        final LibraryOverviewReadModel overview =
            (overviewResult as Ok<LibraryOverviewReadModel>).value;
        expect(
          overview.folders.map((FolderWithCount row) => row.folder.id),
          <String>[a.id, b.id, c.id],
        );
      },
    );
  });

  group('renameDeck (2.8.1)', () {
    test(
      'renames a deck and preserves folder ownership and sort_order',
      () async {
        final Folder parent = await createRoot('Parent');
        final Deck deck = await createDeck(parent.id, 'Deck');
        final FolderDao dao = FolderDao(db);
        final DeckRow? before = await dao.findDeck(deck.id);

        final Result<Deck> result = await repo.renameDeck(
          deckId: deck.id,
          name: 'Deck Renamed',
        );

        expect(result, isA<Ok<Deck>>());
        final Deck renamed = (result as Ok<Deck>).value;
        expect(renamed.name, 'Deck Renamed');
        expect(renamed.folderId, parent.id);
        expect(renamed.sortOrder, before!.sortOrder);

        final DeckRow? after = await dao.findDeck(deck.id);
        expect(after?.name, 'Deck Renamed');
        expect(after?.folderId, parent.id);
        expect(after?.sortOrder, before.sortOrder);
      },
    );

    test('rejects duplicate sibling deck names', () async {
      final Folder parent = await createRoot('Parent');
      final Deck first = await createDeck(parent.id, 'First');
      final Deck second = await createDeck(parent.id, 'Second');

      final Result<Deck> result = await repo.renameDeck(
        deckId: second.id,
        name: 'first',
      );

      expect(result, isA<Err<Deck>>());
      expect(
        (result as Err<Deck>).failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );

      final FolderDao dao = FolderDao(db);
      expect((await dao.findDeck(first.id))?.name, 'First');
      expect((await dao.findDeck(second.id))?.name, 'Second');
    });

    test('rejects a missing deck id', () async {
      final Result<Deck> result = await repo.renameDeck(
        deckId: 'missing',
        name: 'Deck Renamed',
      );

      expect(result, isA<Err<Deck>>());
      expect((result as Err<Deck>).failure, isA<NotFoundFailure>());
    });
  });

  group('reorderDecks (2.10.1)', () {
    test('rejects an empty reorder list', () async {
      final Folder parent = await createRoot('Parent');

      final Result<void> result = await repo.reorderDecks(
        parentId: parent.id,
        orderedIds: const <String>[],
      );

      expect(result, isA<Err<void>>());
      expect(
        (result as Err<void>).failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.insufficientContent,
        ),
      );
    });

    test(
      'reorders decks in the same folder and persists deterministic order',
      () async {
        final Folder parent = await createRoot('Parent');
        final Deck a = await createDeck(parent.id, 'A');
        final Deck b = await createDeck(parent.id, 'B');
        final Deck c = await createDeck(parent.id, 'C');

        final Result<void> result = await repo.reorderDecks(
          parentId: parent.id,
          orderedIds: <String>[c.id, a.id, b.id],
        );

        expect(result, isA<Ok<void>>());

        final Result<FolderDetail> detailResult = await repo
            .watchFolderDetail(parent.id)
            .first;
        final FolderDetail detail = (detailResult as Ok<FolderDetail>).value;
        expect(detail.decks.map((DeckWithCount row) => row.deck.id), <String>[
          c.id,
          a.id,
          b.id,
        ]);

        final FolderDao dao = FolderDao(db);
        expect((await dao.findDeck(c.id))?.sortOrder, 0);
        expect((await dao.findDeck(a.id))?.sortOrder, 1);
        expect((await dao.findDeck(b.id))?.sortOrder, 2);
      },
    );

    test('rejects duplicate deck ids and preserves the old order', () async {
      final Folder parent = await createRoot('Parent');
      final Deck a = await createDeck(parent.id, 'A');
      final Deck b = await createDeck(parent.id, 'B');
      final Deck c = await createDeck(parent.id, 'C');

      final Result<void> result = await repo.reorderDecks(
        parentId: parent.id,
        orderedIds: <String>[c.id, a.id, a.id],
      );

      expect(result, isA<Err<void>>());
      expect(
        (result as Err<void>).failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );

      final Result<FolderDetail> detailResult = await repo
          .watchFolderDetail(parent.id)
          .first;
      final FolderDetail detail = (detailResult as Ok<FolderDetail>).value;
      expect(detail.decks.map((DeckWithCount row) => row.deck.id), <String>[
        a.id,
        b.id,
        c.id,
      ]);
    });

    test('rejects missing deck ids', () async {
      final Folder parent = await createRoot('Parent');
      final Deck a = await createDeck(parent.id, 'A');
      final Deck b = await createDeck(parent.id, 'B');

      final Result<void> result = await repo.reorderDecks(
        parentId: parent.id,
        orderedIds: <String>['missing', a.id],
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<NotFoundFailure>());

      final Result<FolderDetail> detailResult = await repo
          .watchFolderDetail(parent.id)
          .first;
      final FolderDetail detail = (detailResult as Ok<FolderDetail>).value;
      expect(detail.decks.map((DeckWithCount row) => row.deck.id), <String>[
        a.id,
        b.id,
      ]);
    });

    test('rejects deck ids from another folder scope', () async {
      final Folder parentA = await createRoot('Parent A');
      final Deck a1 = await createDeck(parentA.id, 'A1');
      final Deck a2 = await createDeck(parentA.id, 'A2');
      final Folder parentB = await createRoot('Parent B');
      final Deck b1 = await createDeck(parentB.id, 'B1');

      final Result<void> result = await repo.reorderDecks(
        parentId: parentA.id,
        orderedIds: <String>[b1.id, a1.id, a2.id],
      );

      expect(result, isA<Err<void>>());
      expect(
        (result as Err<void>).failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.invalidFormat,
        ),
      );

      final Result<FolderDetail> detailResult = await repo
          .watchFolderDetail(parentA.id)
          .first;
      final FolderDetail detail = (detailResult as Ok<FolderDetail>).value;
      expect(detail.decks.map((DeckWithCount row) => row.deck.id), <String>[
        a1.id,
        a2.id,
      ]);
    });

    test(
      'rejects partial reorder lists and leaves the previous order unchanged',
      () async {
        final Folder parent = await createRoot('Parent');
        final Deck a = await createDeck(parent.id, 'A');
        final Deck b = await createDeck(parent.id, 'B');
        final Deck c = await createDeck(parent.id, 'C');

        final Result<void> result = await repo.reorderDecks(
          parentId: parent.id,
          orderedIds: <String>[c.id, a.id],
        );

        expect(result, isA<Err<void>>());
        expect(
          (result as Err<void>).failure,
          isA<ValidationFailure>().having(
            (ValidationFailure f) => f.code,
            'code',
            ValidationCode.insufficientContent,
          ),
        );

        final Result<FolderDetail> detailResult = await repo
            .watchFolderDetail(parent.id)
            .first;
        final FolderDetail detail = (detailResult as Ok<FolderDetail>).value;
        expect(detail.decks.map((DeckWithCount row) => row.deck.id), <String>[
          a.id,
          b.id,
          c.id,
        ]);
      },
    );
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
