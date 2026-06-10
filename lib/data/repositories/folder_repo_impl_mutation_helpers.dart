import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/deck_mapper.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

/// Transaction bodies for the Library folder action-sheet mutations, kept out of
/// `folder_repository_impl.dart` so the repository class stays within the file
/// size budget (mirrors `study_repo_impl_helpers.dart`).
///
/// Each function maps a thrown [_RuleViolation] (business rule) to a `Result`
/// `Err` and rolls the transaction back; any other error becomes a
/// `StorageFailure` (`docs/contracts/repository-contracts/folder-repository.md`).

int _nowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

/// Renames [folderId] to [name] (assumed trimmed). Sibling-name uniqueness is
/// case-insensitive; an unchanged name is a no-op.
Future<Result<Folder>> renameFolderTxn(
  FolderDao dao,
  String folderId,
  String name,
) async {
  try {
    final FolderRow updated = await dao.transaction(() async {
      final FolderRow? row = await dao.findFolder(folderId);
      if (row == null) {
        throw _RuleViolation(Failure.notFound(entity: 'folder', id: folderId));
      }
      if (row.name == name) {
        return row;
      }
      final String normalized = StringUtils.normalize(name);
      final List<String> siblings = await dao.siblingFolderNames(
        parentId: row.parentId,
        excludeId: folderId,
      );
      if (siblings.any((String n) => StringUtils.normalize(n) == normalized)) {
        throw const _RuleViolation(
          Failure.validation(field: 'name', code: ValidationCode.duplicate),
        );
      }
      await dao.updateFolderName(folderId, name, _nowMs());
      return (await dao.findFolder(folderId))!;
    });
    return Result<Folder>.ok(FolderMapper.fromRow(updated));
  } on _RuleViolation catch (violation) {
    return Result<Folder>.err(violation.failure);
  } catch (error) {
    return _writeStorageErr<Folder>(error);
  }
}

/// Renames [deckId] to [name] (assumed trimmed). Sibling-name uniqueness is
/// case-insensitive; an unchanged name is a no-op.
Future<Result<Deck>> renameDeckTxn(
  FolderDao dao,
  String deckId,
  String name,
) async {
  try {
    final DeckRow updated = await dao.transaction(() async {
      final DeckRow? row = await dao.findDeck(deckId);
      if (row == null) {
        throw _RuleViolation(Failure.notFound(entity: 'deck', id: deckId));
      }
      if (row.name == name) {
        return row;
      }
      final String normalized = StringUtils.normalize(name);
      final List<String> siblings = await dao.deckNames(
        row.folderId,
        excludeId: deckId,
      );
      if (siblings.any((String n) => StringUtils.normalize(n) == normalized)) {
        throw const _RuleViolation(
          Failure.validation(field: 'name', code: ValidationCode.duplicate),
        );
      }
      await dao.updateDeckName(deckId, name, _nowMs());
      return (await dao.findDeck(deckId))!;
    });
    return Result<Deck>.ok(DeckMapper.fromRow(updated));
  } on _RuleViolation catch (violation) {
    return Result<Deck>.err(violation.failure);
  } catch (error) {
    return _writeStorageErr<Deck>(error);
  }
}

/// Moves [folderId] under [newParentId] (`null` = root): cycle + decks-lock +
/// sibling-name checks, then recomputes `sort_order`, locks the destination,
/// and reverts an emptied old parent. An unchanged parent is a no-op.
Future<Result<Folder>> moveFolderTxn(
  FolderDao dao,
  String folderId,
  String? newParentId,
) async {
  try {
    final FolderRow moved = await dao.transaction(() async {
      final FolderRow? row = await dao.findFolder(folderId);
      if (row == null) {
        throw _RuleViolation(Failure.notFound(entity: 'folder', id: folderId));
      }
      final String? oldParentId = row.parentId;
      if (newParentId == oldParentId) {
        return row;
      }
      // Includes the folder itself, so a self-move is rejected as a cycle too.
      final Set<String> subtree = (await dao.descendantFolderIdsDepthFirst(
        folderId,
      )).toSet();

      if (newParentId != null) {
        final FolderRow? newParent = await dao.findFolder(newParentId);
        if (newParent == null) {
          throw _RuleViolation(
            Failure.notFound(entity: 'folder', id: newParentId),
          );
        }
        if (subtree.contains(newParentId)) {
          throw const _RuleViolation(
            Failure.validation(
              field: 'parentId',
              code: ValidationCode.cycleDetected,
            ),
          );
        }
        if (FolderMapper.contentModeFromStorage(newParent.contentMode) ==
            ContentMode.decks) {
          throw const _RuleViolation(
            Failure.unsupportedAction(action: 'move_into_decks_folder'),
          );
        }
      }

      final String normalized = StringUtils.normalize(row.name);
      final List<String> destSiblings = await dao.siblingFolderNames(
        parentId: newParentId,
        excludeId: folderId,
      );
      if (destSiblings.any(
        (String n) => StringUtils.normalize(n) == normalized,
      )) {
        throw const _RuleViolation(
          Failure.validation(field: 'name', code: ValidationCode.duplicate),
        );
      }

      final int nowMs = _nowMs();
      await dao.updateFolderParent(
        folderId,
        newParentId,
        (await dao.maxChildSortOrder(newParentId)) + 1,
        nowMs,
      );

      if (newParentId != null) {
        final FolderRow newParent = (await dao.findFolder(newParentId))!;
        if (FolderMapper.contentModeFromStorage(newParent.contentMode) ==
            ContentMode.unlocked) {
          await dao.setFolderContentMode(
            newParentId,
            FolderMapper.contentModeToStorage(ContentMode.subfolders),
          );
        }
      }
      await _revertParentIfEmpty(dao, oldParentId);
      return (await dao.findFolder(folderId))!;
    });
    return Result<Folder>.ok(FolderMapper.fromRow(moved));
  } on _RuleViolation catch (violation) {
    return Result<Folder>.err(violation.failure);
  } catch (error) {
    return _writeStorageErr<Folder>(error);
  }
}

/// Persists a full reorder of the direct child folders under [parentId]
/// (`null` = Library root). [orderedIds] must contain the complete sibling set
/// exactly once each.
Future<Result<void>> reorderFoldersTxn(
  FolderDao dao,
  String? parentId,
  List<String> orderedIds,
) async {
  try {
    await dao.transaction(() async {
      if (orderedIds.isEmpty) {
        throw const _RuleViolation(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.insufficientContent,
          ),
        );
      }
      _rejectDuplicateIds(orderedIds);

      final List<FolderRow> all = await dao.allFolders();
      final List<FolderRow> currentChildren = all
          .where((FolderRow row) => row.parentId == parentId)
          .toList(growable: false);
      final Map<String, FolderRow> currentById = <String, FolderRow>{
        for (final FolderRow row in currentChildren) row.id: row,
      };

      for (final String id in orderedIds) {
        if (currentById.containsKey(id)) {
          continue;
        }
        final FolderRow? row = await dao.findFolder(id);
        if (row == null) {
          throw _RuleViolation(Failure.notFound(entity: 'folder', id: id));
        }
        throw const _RuleViolation(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.invalidFormat,
          ),
        );
      }

      if (orderedIds.length != currentChildren.length) {
        throw const _RuleViolation(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.insufficientContent,
          ),
        );
      }

      final int nowMs = _nowMs();
      for (int index = 0; index < orderedIds.length; index++) {
        await dao.updateFolderParent(orderedIds[index], parentId, index, nowMs);
      }
    });
    return const Result<void>.ok(null);
  } on _RuleViolation catch (violation) {
    return Result<void>.err(violation.failure);
  } catch (error) {
    return _writeStorageErr<void>(error);
  }
}

/// Persists a full reorder of the decks under [parentId]. [orderedIds] must
/// contain the complete sibling set exactly once each.
Future<Result<void>> reorderDecksTxn(
  FolderDao dao,
  String parentId,
  List<String> orderedIds,
) async {
  try {
    await dao.transaction(() async {
      if (orderedIds.isEmpty) {
        throw const _RuleViolation(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.insufficientContent,
          ),
        );
      }
      _rejectDuplicateIds(orderedIds);

      final List<DeckItemsResult> currentDecks = await dao.getDeckItems(
        folderId: parentId,
        nowMs: 0,
        sort: ContentSortMode.manual,
        normalizedSearch: null,
      );
      final Map<String, DeckItemsResult> currentById =
          <String, DeckItemsResult>{
            for (final DeckItemsResult row in currentDecks) row.id: row,
          };

      for (final String id in orderedIds) {
        if (currentById.containsKey(id)) {
          continue;
        }
        final DeckRow? row = await dao.findDeck(id);
        if (row == null) {
          throw _RuleViolation(Failure.notFound(entity: 'deck', id: id));
        }
        throw const _RuleViolation(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.invalidFormat,
          ),
        );
      }

      if (orderedIds.length != currentDecks.length) {
        throw const _RuleViolation(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.insufficientContent,
          ),
        );
      }

      final int nowMs = _nowMs();
      for (int index = 0; index < orderedIds.length; index++) {
        await dao.updateDeckSortOrder(orderedIds[index], index, nowMs);
      }
    });
    return const Result<void>.ok(null);
  } on _RuleViolation catch (violation) {
    return Result<void>.err(violation.failure);
  } catch (error) {
    return _writeStorageErr<void>(error);
  }
}

/// Deletes [folderId] and its subtree deepest-first (decks → flashcards →
/// progress cascade via FKs), reverting an emptied parent to `unlocked`.
///
/// TODO(MEMOX-UNSORTED-001): once the domain has an Unsorted destination for
/// deck cards, move the affected cards there before folder deletion instead of
/// dropping the subtree.
Future<Result<void>> deleteFolderTxn(FolderDao dao, String folderId) async {
  try {
    await dao.transaction(() async {
      final FolderRow? row = await dao.findFolder(folderId);
      if (row == null) {
        throw _RuleViolation(Failure.notFound(entity: 'folder', id: folderId));
      }
      final List<String> idsDepthFirst = await dao
          .descendantFolderIdsDepthFirst(folderId);
      for (final String id in idsDepthFirst) {
        await dao.deleteFolderById(id);
      }
      await _revertParentIfEmpty(dao, row.parentId);
    });
    return const Result<void>.ok(null);
  } on _RuleViolation catch (violation) {
    return Result<void>.err(violation.failure);
  } catch (error) {
    return _writeStorageErr<void>(error);
  }
}

/// Deletes [deckId] and its flashcards (→ progress cascade via FKs), reverting
/// the parent folder to `unlocked` once it holds no more decks.
Future<Result<void>> deleteDeckTxn(FolderDao dao, String deckId) async {
  try {
    await dao.transaction(() async {
      final DeckRow? row = await dao.findDeck(deckId);
      if (row == null) {
        throw _RuleViolation(Failure.notFound(entity: 'deck', id: deckId));
      }
      await dao.deleteDeckById(deckId);
      if ((await dao.childDeckCount(row.folderId)) == 0) {
        await dao.setFolderContentMode(
          row.folderId,
          FolderMapper.contentModeToStorage(ContentMode.unlocked),
        );
      }
    });
    return const Result<void>.ok(null);
  } on _RuleViolation catch (violation) {
    return Result<void>.err(violation.failure);
  } catch (error) {
    return _writeStorageErr<void>(error);
  }
}

/// Builds the move-destination list for [folderId]: root + all folders, each
/// annotated current-parent / blocked (cycle / decks-locked). Blocked rows are
/// kept (disabled in the picker), never omitted.
Future<Result<List<FolderMoveTarget>>> folderMoveTargets(
  FolderDao dao,
  String folderId,
) async {
  try {
    final List<FolderRow> all = await dao.allFolders();
    final Set<String> subtree = (await dao.descendantFolderIdsDepthFirst(
      folderId,
    )).toSet();
    final Map<String, FolderRow> byId = <String, FolderRow>{
      for (final FolderRow f in all) f.id: f,
    };
    final String? currentParentId = byId[folderId]?.parentId;

    List<String> breadcrumbOf(FolderRow row) {
      final List<String> names = <String>[];
      FolderRow? cursor = row;
      // Bounded by the folder count — guards against a corrupt parent cycle.
      for (int hops = 0; cursor != null && hops <= all.length; hops++) {
        names.insert(0, cursor.name);
        final String? parentId = cursor.parentId;
        cursor = parentId == null ? null : byId[parentId];
      }
      return names;
    }

    final List<FolderMoveTarget> folders =
        all
            .map(
              (FolderRow row) => FolderMoveTarget(
                id: row.id,
                breadcrumb: breadcrumbOf(row),
                isCurrentParent: row.id == currentParentId,
                block: subtree.contains(row.id)
                    ? FolderMoveBlock.cycle
                    : FolderMapper.contentModeFromStorage(row.contentMode) ==
                          ContentMode.decks
                    ? FolderMoveBlock.lockedToDecks
                    : null,
              ),
            )
            .toList()
          ..sort(
            (FolderMoveTarget a, FolderMoveTarget b) =>
                StringUtils.compareIgnoreCase(
                  a.breadcrumb.join('/'),
                  b.breadcrumb.join('/'),
                ),
          );

    return Result<List<FolderMoveTarget>>.ok(<FolderMoveTarget>[
      FolderMoveTarget(
        id: null,
        breadcrumb: const <String>[],
        isCurrentParent: currentParentId == null,
      ),
      ...folders,
    ]);
  } catch (error) {
    return Result<List<FolderMoveTarget>>.err(
      Failure.storage(
        operation: StorageOp.read,
        cause: error.toString(),
        table: 'folders',
      ),
    );
  }
}

/// Reverts [parentId] to `unlocked` once it holds no more child folders.
Future<void> _revertParentIfEmpty(FolderDao dao, String? parentId) async {
  if (parentId != null && (await dao.childFolderCount(parentId)) == 0) {
    await dao.setFolderContentMode(
      parentId,
      FolderMapper.contentModeToStorage(ContentMode.unlocked),
    );
  }
}

Result<T> _writeStorageErr<T>(Object error) => Result<T>.err(
  Failure.storage(
    operation: StorageOp.write,
    cause: error.toString(),
    table: 'folders',
  ),
);

void _rejectDuplicateIds(List<String> orderedIds) {
  final Set<String> seen = <String>{};
  for (final String id in orderedIds) {
    if (!seen.add(id)) {
      throw const _RuleViolation(
        Failure.validation(field: 'orderedIds', code: ValidationCode.duplicate),
      );
    }
  }
}

/// Carries a business [Failure] out of a Drift transaction so it converts to a
/// `Result` at the boundary (and the transaction rolls back).
class _RuleViolation implements Exception {
  const _RuleViolation(this.failure);

  final Failure failure;
}
