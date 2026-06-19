part of 'folder_repository_impl.dart';

/// Mutation helpers for [FolderRepositoryImpl]: name validation, the
/// content-mode lock guard, sort-order/companion construction, and the
/// recursive delete cascade. Kept in a part so they share private state with
/// the impl while keeping the main file focused on the repository surface.
///
/// Spec: `docs/business/folder/folder-management.md` §Rules + §Content mode
/// transitions; decision rows F2, F4, F8, F9.
extension FolderRepositoryMutationHelpers on FolderRepositoryImpl {
  /// Reject a folder name that is empty after trimming (F2).
  Failure? _validateName(String trimmedName) => trimmedName.isEmpty
      ? const Failure.validation(field: 'name', code: ValidationCode.empty)
      : null;

  /// Reject a case-insensitive duplicate among [siblings] (a rename excludes
  /// the folder itself via [excludeId]).
  Failure? _duplicateAmong(
    List<FolderRow> siblings,
    String trimmedName, {
    String? excludeId,
  }) {
    final String lowered = trimmedName.toLowerCase();
    final bool clash = siblings.any(
      (FolderRow s) => s.id != excludeId && s.name.toLowerCase() == lowered,
    );
    return clash
        ? const Failure.validation(
            field: 'name',
            code: ValidationCode.duplicate,
          )
        : null;
  }

  /// Content-mode lock: a parent already locked to decks cannot take a
  /// subfolder. Typed so Folder Detail can map it to localized copy rather than
  /// the generic error (decision row F4).
  ///
  /// > The symmetric guard (a `subfolders`-locked parent rejecting a *deck*
  /// > with `folder_contains_subfolders`, F6) lands with deck creation
  /// > (WBS 2.7.x) once the `decks` table exists.
  Failure? _subfolderGuard(ContentMode parentMode) =>
      parentMode == ContentMode.decks
      ? const Failure.unsupportedAction(message: 'folder_contains_decks')
      : null;

  /// Next `sort_order` among [siblings]: append after the current max (0 when
  /// there are none).
  int _nextSortOrder(List<FolderRow> siblings) {
    if (siblings.isEmpty) return 0;
    return siblings
            .map((FolderRow s) => s.sortOrder)
            .reduce((int a, int b) => a > b ? a : b) +
        1;
  }

  /// Build a fresh unlocked [Folder] with a generated id and current timestamps.
  Folder _buildNewFolder({
    required FolderId? parentId,
    required String name,
    required List<FolderRow> siblings,
  }) {
    final int now = _nowMs();
    final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
      now,
      isUtc: true,
    );
    return Folder(
      id: _idGenerator.newId(),
      parentId: parentId,
      name: name,
      contentMode: ContentMode.unlocked,
      sortOrder: _nextSortOrder(siblings),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  FoldersCompanion _insertCompanion(Folder folder) => FoldersCompanion.insert(
    id: folder.id,
    parentId: Value(folder.parentId),
    name: folder.name,
    contentMode: FolderMapper.contentModeToStorage(folder.contentMode),
    sortOrder: folder.sortOrder,
    createdAt: folder.createdAt.toUtc().millisecondsSinceEpoch,
    updatedAt: folder.updatedAt.toUtc().millisecondsSinceEpoch,
  );

  /// Recursively delete [id] and its descendant folders, deepest first so the
  /// `parent_id` RESTRICT FK is never violated (F8).
  ///
  /// > V1 scope: descendant **folders** only. Deck/flashcard/progress/session
  /// > cleanup is added when those tables ship (WBS 2.7.x onward).
  Future<void> _cascadeDeleteFolder(FolderId id) async {
    final List<String> ids = await _dao.getDescendantFolderIdsDeepestFirst(id);
    for (final String folderId in ids) {
      await _dao.deleteFolderById(folderId);
    }
  }

  /// Revert an old parent to `unlocked` once it has no children left (F9).
  Future<void> _revertParentIfEmptied(FolderId? parentId) async {
    if (parentId == null) return;
    final int remaining = await _dao.childFolderCount(parentId);
    if (remaining != 0) return;
    await _dao.updateFolderColumns(
      parentId,
      FoldersCompanion(
        contentMode: Value(
          FolderMapper.contentModeToStorage(ContentMode.unlocked),
        ),
        updatedAt: Value(_nowMs()),
      ),
    );
  }

  /// Reject a reorder whose [orderedIds] is not exactly the [siblings] set:
  /// duplicates, or any missing/extra/cross-parent id (length mismatch or an id
  /// outside the sibling set). The caller validates before any write, so the
  /// previous order is preserved on rejection (F11).
  Failure? _validateReorder(
    List<FolderRow> siblings,
    List<FolderId> orderedIds,
  ) {
    final Set<String> orderedSet = orderedIds.toSet();
    final bool hasDuplicates = orderedSet.length != orderedIds.length;
    final Set<String> siblingIds = siblings.map((FolderRow s) => s.id).toSet();
    final bool sameSet =
        orderedSet.length == siblingIds.length &&
        orderedSet.containsAll(siblingIds);
    return hasDuplicates || !sameSet
        ? const Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.invalidFormat,
          )
        : null;
  }

  /// Ancestor names root -> leaf (inclusive of [row]) resolved from the
  /// in-memory [byId] map — no per-folder query. Used to label move targets.
  List<String> _breadcrumbNames(FolderRow row, Map<String, FolderRow> byId) {
    final List<String> names = <String>[];
    FolderRow? current = row;
    while (current != null) {
      names.add(current.name);
      final String? parentId = current.parentId;
      current = parentId == null ? null : byId[parentId];
    }
    return names.reversed.toList(growable: false);
  }

  /// Storage write failure wrapper for caught exceptions.
  Failure _storageWrite(Object error) => Failure.storage(
    operation: StorageOp.write,
    table: 'folders',
    cause: error.toString(),
  );

  /// Storage read failure wrapper for caught exceptions (move-target query).
  Failure _storageRead(Object error) => Failure.storage(
    operation: StorageOp.read,
    table: 'folders',
    cause: error.toString(),
  );
}
