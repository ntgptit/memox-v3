import 'package:drift/drift.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/deck_mapper.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

part 'folder_repo_impl_mutation_helpers.dart';

/// Drift-backed [FolderRepository].
///
/// Reads compose the generated query results into domain read models; mutations
/// run inside [FolderDao] transactions and enforce the content-mode lock,
/// sibling-name uniqueness and recursive cascade. Mutation helpers (validation,
/// guards, cascade) live in the `folder_repo_impl_mutation_helpers.dart` part.
///
/// [idGenerator] and [nowMs] are injectable so tests get deterministic ids and
/// timestamps.
class FolderRepositoryImpl implements FolderRepository {
  FolderRepositoryImpl({
    required FolderDao dao,
    required DeckDao deckDao,
    IdGenerator? idGenerator,
    int Function()? nowMs,
  }) : _dao = dao,
       _deckDao = deckDao,
       _idGenerator = idGenerator ?? IdGenerator(),
       _nowMs = nowMs ?? _defaultNowMs;

  final FolderDao _dao;
  final DeckDao _deckDao;
  final IdGenerator _idGenerator;
  final int Function() _nowMs;

  static int _defaultNowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

  // ---- Reads ----

  @override
  Stream<LibraryOverview> watchLibraryOverview() =>
      _dao.watchRootFolderSummaries().map(
        (List<RootFolderSummariesResult> rows) => LibraryOverview(
          folders: rows
              .map(
                (RootFolderSummariesResult r) =>
                    _summary(r.folders, r.subfolderCount),
              )
              .toList(growable: false),
        ),
      );

  @override
  Stream<FolderDetail?> watchFolderDetail(FolderId id) => _dao
      .watchChildFolderSummaries(id)
      .asyncMap((List<ChildFolderSummariesResult> children) async {
        final FolderRow? row = await _dao.findFolderById(id);
        if (row == null) return null;
        final List<FolderRow> breadcrumb = await _dao.getBreadcrumb(id);
        return FolderDetail(
          folder: FolderMapper.fromRow(row),
          breadcrumb: breadcrumb
              .map(FolderMapper.fromRow)
              .toList(growable: false),
          subfolders: children
              .map(
                (ChildFolderSummariesResult r) =>
                    _summary(r.folders, r.subfolderCount),
              )
              .toList(growable: false),
          // Deck/card tables not in the schema yet (WBS 2.7.x / 2.11.x).
          deckCount: 0,
          cardCount: 0,
          dueCount: 0,
        );
      });

  FolderSummary _summary(FolderRow row, int subfolderCount) => FolderSummary(
    folder: FolderMapper.fromRow(row),
    subfolderCount: subfolderCount,
    // Deck/card tables not in the schema yet (WBS 2.7.x / 2.11.x).
    deckCount: 0,
    cardCount: 0,
    dueCount: 0,
  );

  // ---- Mutations ----

  @override
  Future<Result<Folder>> createRootFolder({required String name}) async {
    final String trimmed = name.trim();
    final Failure? invalid = _validateName(trimmed);
    if (invalid != null) return _fail<Folder>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        final List<FolderRow> siblings = await _dao.siblingFolders(null);
        final Failure? duplicate = _duplicateAmong(siblings, trimmed);
        if (duplicate != null) return _fail<Folder>(duplicate);

        final Folder folder = _buildNewFolder(
          parentId: null,
          name: trimmed,
          siblings: siblings,
        );
        await _dao.insertFolder(_insertCompanion(folder));
        return _ok(folder);
      });
    } catch (error) {
      return _fail<Folder>(_storageWrite(error));
    }
  }

  @override
  Future<Result<Folder>> createSubfolder({
    required FolderId parentId,
    required String name,
  }) async {
    final String trimmed = name.trim();
    final Failure? invalid = _validateName(trimmed);
    if (invalid != null) return _fail<Folder>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        final FolderRow? parent = await _dao.findFolderById(parentId);
        if (parent == null) {
          return _fail<Folder>(const Failure.notFound(entity: 'folder'));
        }
        final ContentMode parentMode = FolderMapper.contentModeFromStorage(
          parent.contentMode,
        );
        final Failure? guard = _subfolderGuard(parentMode);
        if (guard != null) return _fail<Folder>(guard);

        final List<FolderRow> siblings = await _dao.siblingFolders(parentId);
        final Failure? duplicate = _duplicateAmong(siblings, trimmed);
        if (duplicate != null) return _fail<Folder>(duplicate);

        final Folder child = _buildNewFolder(
          parentId: parentId,
          name: trimmed,
          siblings: siblings,
        );
        await _dao.insertFolder(_insertCompanion(child));

        if (parentMode == ContentMode.unlocked) {
          await _dao.updateFolderColumns(
            parentId,
            FoldersCompanion(
              contentMode: Value(
                FolderMapper.contentModeToStorage(ContentMode.subfolders),
              ),
              updatedAt: Value(_nowMs()),
            ),
          );
        }
        return _ok(child);
      });
    } catch (error) {
      return _fail<Folder>(_storageWrite(error));
    }
  }

  @override
  Future<Result<Folder>> renameFolder({
    required FolderId id,
    required String newName,
  }) async {
    final String trimmed = newName.trim();
    final Failure? invalid = _validateName(trimmed);
    if (invalid != null) return _fail<Folder>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        final FolderRow? row = await _dao.findFolderById(id);
        if (row == null) {
          return _fail<Folder>(const Failure.notFound(entity: 'folder'));
        }
        // No-op when the trimmed name is unchanged.
        if (row.name == trimmed) return _ok(FolderMapper.fromRow(row));

        final List<FolderRow> siblings = await _dao.siblingFolders(
          row.parentId,
        );
        final Failure? duplicate = _duplicateAmong(
          siblings,
          trimmed,
          excludeId: id,
        );
        if (duplicate != null) return _fail<Folder>(duplicate);

        final int now = _nowMs();
        await _dao.updateFolderColumns(
          id,
          FoldersCompanion(name: Value(trimmed), updatedAt: Value(now)),
        );
        return _ok(
          FolderMapper.fromRow(row).copyWith(
            name: trimmed,
            updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          ),
        );
      });
    } catch (error) {
      return _fail<Folder>(_storageWrite(error));
    }
  }

  @override
  Future<Result<void>> deleteFolder({required FolderId id}) async {
    try {
      return await _dao.runInTransaction(() async {
        final FolderRow? row = await _dao.findFolderById(id);
        if (row == null) {
          return _fail<void>(const Failure.notFound(entity: 'folder'));
        }
        await _cascadeDeleteFolder(id);
        await _revertParentIfEmptied(row.parentId);
        return _ok<void>(null);
      });
    } catch (error) {
      return _fail<void>(_storageWrite(error));
    }
  }

  @override
  Future<Result<Folder>> moveFolder({
    required FolderId id,
    required FolderId? newParentId,
  }) async {
    try {
      return await _dao.runInTransaction(() async {
        final FolderRow? row = await _dao.findFolderById(id);
        if (row == null) {
          return _fail<Folder>(const Failure.notFound(entity: 'folder'));
        }
        // No-op when the folder is already under the requested parent.
        if (row.parentId == newParentId) return _ok(FolderMapper.fromRow(row));

        ContentMode? newParentMode;
        if (newParentId != null) {
          final FolderRow? parent = await _dao.findFolderById(newParentId);
          if (parent == null) {
            return _fail<Folder>(const Failure.notFound(entity: 'folder'));
          }
          newParentMode = FolderMapper.contentModeFromStorage(
            parent.contentMode,
          );

          // Cycle takes priority over the content-mode guard: the destination
          // must not be the folder itself or any of its descendants (the
          // recursive set includes the folder id). A decks-locked descendant is
          // still a cycle (F7), not `folder_contains_decks`.
          final Set<String> subtree =
              (await _dao.getDescendantFolderIdsDeepestFirst(id)).toSet();
          if (subtree.contains(newParentId)) {
            return _fail<Folder>(
              const Failure.validation(
                field: 'newParentId',
                code: ValidationCode.cycleDetected,
              ),
            );
          }

          final Failure? guard = _subfolderGuard(newParentMode);
          if (guard != null) return _fail<Folder>(guard);
        }

        final List<FolderRow> siblings = await _dao.siblingFolders(newParentId);
        final Failure? duplicate = _duplicateAmong(
          siblings,
          row.name,
          excludeId: id,
        );
        if (duplicate != null) return _fail<Folder>(duplicate);

        final int now = _nowMs();
        final int newSortOrder = _nextSortOrder(siblings);
        await _dao.updateFolderColumns(
          id,
          FoldersCompanion(
            parentId: Value(newParentId),
            sortOrder: Value(newSortOrder),
            updatedAt: Value(now),
          ),
        );

        // Lock a previously-unlocked destination to subfolders.
        if (newParentId != null && newParentMode == ContentMode.unlocked) {
          await _dao.updateFolderColumns(
            newParentId,
            FoldersCompanion(
              contentMode: Value(
                FolderMapper.contentModeToStorage(ContentMode.subfolders),
              ),
              updatedAt: Value(now),
            ),
          );
        }

        // Revert the old parent to unlocked once it has no children left.
        await _revertParentIfEmptied(row.parentId);

        return _ok(
          FolderMapper.fromRow(row).copyWith(
            parentId: newParentId,
            sortOrder: newSortOrder,
            updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          ),
        );
      });
    } catch (error) {
      return _fail<Folder>(_storageWrite(error));
    }
  }

  @override
  Future<Result<List<FolderMoveTarget>>> getFolderMoveTargets({
    required FolderId folderId,
  }) async {
    try {
      final FolderRow? folder = await _dao.findFolderById(folderId);
      final FolderId? currentParentId = folder?.parentId;
      final Set<String> subtree =
          (await _dao.getDescendantFolderIdsDeepestFirst(folderId)).toSet();
      final List<FolderRow> all = await _dao.listAllFolders();
      final Map<String, FolderRow> byId = <String, FolderRow>{
        for (final FolderRow r in all) r.id: r,
      };

      final List<FolderMoveTarget> folderTargets =
          all.map((FolderRow r) {
            final ContentMode mode = FolderMapper.contentModeFromStorage(
              r.contentMode,
            );
            final FolderMoveBlock? block = subtree.contains(r.id)
                ? FolderMoveBlock.cycle
                : (mode == ContentMode.decks
                      ? FolderMoveBlock.lockedToDecks
                      : null);
            return FolderMoveTarget(
              id: r.id,
              name: r.name,
              breadcrumb: _breadcrumbNames(r, byId),
              isCurrentParent: r.id == currentParentId,
              block: block,
            );
          }).toList()..sort(
            // Join on NUL — never valid in a folder name — so a name that
            // contains the separator cannot corrupt the breadcrumb sort key.
            (FolderMoveTarget a, FolderMoveTarget b) => a.breadcrumb
                .join(' ')
                .toLowerCase()
                .compareTo(b.breadcrumb.join(' ').toLowerCase()),
          );

      final FolderMoveTarget root = FolderMoveTarget(
        id: null,
        name: '',
        breadcrumb: const <String>[],
        isCurrentParent: currentParentId == null,
        block: null,
      );

      return _ok(<FolderMoveTarget>[root, ...folderTargets]);
    } catch (error) {
      return _fail<List<FolderMoveTarget>>(_storageRead(error));
    }
  }

  @override
  Future<Result<void>> reorderFolders({
    required FolderId? parentId,
    required List<FolderId> orderedIds,
  }) async {
    try {
      return await _dao.runInTransaction(() async {
        final List<FolderRow> siblings = await _dao.siblingFolders(parentId);
        final Failure? invalid = _validateReorder(siblings, orderedIds);
        if (invalid != null) return _fail<void>(invalid);

        final int now = _nowMs();
        for (int i = 0; i < orderedIds.length; i++) {
          await _dao.updateFolderColumns(
            orderedIds[i],
            FoldersCompanion(sortOrder: Value(i), updatedAt: Value(now)),
          );
        }
        return _ok<void>(null);
      });
    } catch (error) {
      return _fail<void>(_storageWrite(error));
    }
  }

  // ---- Deck mutations ----

  @override
  Future<Result<Deck>> createDeck({
    required FolderId folderId,
    required String name,
    required TargetLanguage targetLanguage,
  }) async {
    final String trimmed = name.trim();
    final Failure? invalid = _validateName(trimmed);
    if (invalid != null) return _fail<Deck>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        final FolderRow? folder = await _dao.findFolderById(folderId);
        if (folder == null) {
          return _fail<Deck>(const Failure.notFound(entity: 'folder'));
        }
        final ContentMode mode = FolderMapper.contentModeFromStorage(
          folder.contentMode,
        );
        final Failure? guard = _deckParentGuard(mode);
        if (guard != null) return _fail<Deck>(guard);

        final List<DeckRow> siblings = await _deckDao.decksInFolder(folderId);
        final Failure? duplicate = _duplicateDeckAmong(siblings, trimmed);
        if (duplicate != null) return _fail<Deck>(duplicate);

        final Deck deck = _buildNewDeck(
          folderId: folderId,
          name: trimmed,
          targetLanguage: targetLanguage,
          siblings: siblings,
        );
        await _deckDao.insertDeck(_deckInsertCompanion(deck));

        if (mode == ContentMode.unlocked) {
          await _dao.updateFolderColumns(
            folderId,
            FoldersCompanion(
              contentMode: Value(
                FolderMapper.contentModeToStorage(ContentMode.decks),
              ),
              updatedAt: Value(_nowMs()),
            ),
          );
        }
        return _ok(deck);
      });
    } catch (error) {
      return _fail<Deck>(_storageWriteDecks(error));
    }
  }

  @override
  Future<Result<Deck>> renameDeck({
    required DeckId deckId,
    required String newName,
  }) async {
    final String trimmed = newName.trim();
    final Failure? invalid = _validateName(trimmed);
    if (invalid != null) return _fail<Deck>(invalid);

    try {
      return await _dao.runInTransaction(() async {
        final DeckRow? row = await _deckDao.findDeckById(deckId);
        if (row == null) {
          return _fail<Deck>(const Failure.notFound(entity: 'deck'));
        }
        // No-op when the trimmed name is unchanged.
        if (row.name == trimmed) return _ok(DeckMapper.fromRow(row));

        final List<DeckRow> siblings = await _deckDao.decksInFolder(
          row.folderId,
        );
        final Failure? duplicate = _duplicateDeckAmong(
          siblings,
          trimmed,
          excludeId: deckId,
        );
        if (duplicate != null) return _fail<Deck>(duplicate);

        final int now = _nowMs();
        await _deckDao.updateDeckColumns(
          deckId,
          DecksCompanion(name: Value(trimmed), updatedAt: Value(now)),
        );
        return _ok(
          DeckMapper.fromRow(row).copyWith(
            name: trimmed,
            updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          ),
        );
      });
    } catch (error) {
      return _fail<Deck>(_storageWriteDecks(error));
    }
  }

  @override
  Future<Result<void>> reorderDecks({
    required FolderId folderId,
    required List<DeckId> orderedIds,
  }) async {
    try {
      return await _dao.runInTransaction(() async {
        final List<DeckRow> siblings = await _deckDao.decksInFolder(folderId);
        final Failure? invalid = _validateDeckReorder(siblings, orderedIds);
        if (invalid != null) return _fail<void>(invalid);

        final int now = _nowMs();
        for (int i = 0; i < orderedIds.length; i++) {
          await _deckDao.updateDeckColumns(
            orderedIds[i],
            DecksCompanion(sortOrder: Value(i), updatedAt: Value(now)),
          );
        }
        return _ok<void>(null);
      });
    } catch (error) {
      return _fail<void>(_storageWriteDecks(error));
    }
  }

  @override
  Future<Result<Deck>> moveDeck({
    required DeckId deckId,
    required FolderId newFolderId,
  }) async {
    try {
      return await _dao.runInTransaction(() async {
        final DeckRow? row = await _deckDao.findDeckById(deckId);
        if (row == null) {
          return _fail<Deck>(const Failure.notFound(entity: 'deck'));
        }
        // No-op when the deck already lives in the requested folder.
        if (row.folderId == newFolderId) return _ok(DeckMapper.fromRow(row));

        final FolderRow? destination = await _dao.findFolderById(newFolderId);
        if (destination == null) {
          return _fail<Deck>(const Failure.notFound(entity: 'folder'));
        }
        final ContentMode destinationMode = FolderMapper.contentModeFromStorage(
          destination.contentMode,
        );
        final Failure? guard = _deckParentGuard(destinationMode);
        if (guard != null) return _fail<Deck>(guard);

        final List<DeckRow> destinationDecks = await _deckDao.decksInFolder(
          newFolderId,
        );
        final Failure? duplicate = _duplicateDeckAmong(
          destinationDecks,
          row.name,
        );
        if (duplicate != null) return _fail<Deck>(duplicate);

        final int now = _nowMs();
        final int newSortOrder = _nextDeckSortOrder(destinationDecks);
        await _deckDao.updateDeckColumns(
          deckId,
          DecksCompanion(
            folderId: Value(newFolderId),
            sortOrder: Value(newSortOrder),
            updatedAt: Value(now),
          ),
        );

        // Lock a previously-unlocked destination to decks.
        if (destinationMode == ContentMode.unlocked) {
          await _dao.updateFolderColumns(
            newFolderId,
            FoldersCompanion(
              contentMode: Value(
                FolderMapper.contentModeToStorage(ContentMode.decks),
              ),
              updatedAt: Value(now),
            ),
          );
        }

        // Revert the source folder to unlocked once it has no decks left.
        await _revertFolderIfNoDecks(row.folderId);

        return _ok(
          DeckMapper.fromRow(row).copyWith(
            folderId: newFolderId,
            sortOrder: newSortOrder,
            updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
          ),
        );
      });
    } catch (error) {
      return _fail<Deck>(_storageWriteDecks(error));
    }
  }

  @override
  Future<Result<void>> deleteDeck({required DeckId deckId}) async {
    try {
      return await _dao.runInTransaction(() async {
        final DeckRow? row = await _deckDao.findDeckById(deckId);
        if (row == null) {
          return _fail<void>(const Failure.notFound(entity: 'deck'));
        }
        // Deleting the deck row cascades to its flashcards and, through the
        // schema chain, their progress + tag rows (ON DELETE CASCADE).
        await _deckDao.deleteDeckById(deckId);
        // Revert the source folder to unlocked once it has no decks left (D3).
        await _revertFolderIfNoDecks(row.folderId);
        return _ok<void>(null);
      });
    } catch (error) {
      return _fail<void>(_storageWriteDecks(error));
    }
  }

  // ---- Result builders ----

  Result<T> _ok<T>(T data) => (failure: null, data: data);

  Result<T> _fail<T>(Failure failure) => (failure: failure, data: null);
}
