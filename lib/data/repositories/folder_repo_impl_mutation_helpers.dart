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
  /// > with `folder_contains_subfolders`, F6) is [_deckParentGuard], used by
  /// > deck create/move (WBS 2.7.1 / 2.19.1).
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
  /// `parent_id` RESTRICT FK is never violated (F8). Each removed folder's decks
  /// are cleaned up by the `decks.folder_id` ON DELETE CASCADE FK (schema v2).
  ///
  /// > V1 scope: folders + their decks. Flashcard/progress/session cleanup is
  /// > added when those tables ship (WBS 2.11.x onward).
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

  // ---- Deck helpers (WBS 2.7.1 / 2.8.1 / 2.10.1 / 2.19.1) ----
  //
  // Decks are folder-owned, so their mutations live on the folder repository.
  // Spec: `docs/business/deck/deck-management.md` §Rules; decision rows D1, D2,
  // D4, D6-D10 (`docs/decision-tables/deck.md`).

  /// Deck-parent content-mode guard: a folder locked to subfolders cannot take a
  /// deck (the symmetric counterpart of [_subfolderGuard], F6). Typed so Folder
  /// Detail can localize it rather than show the generic error. Decision rows
  /// D1, D9/D10.
  Failure? _deckParentGuard(ContentMode folderMode) =>
      folderMode == ContentMode.subfolders
      ? const Failure.unsupportedAction(message: 'folder_contains_subfolders')
      : null;

  /// Reject a case-insensitive duplicate deck name among [siblings] (a rename or
  /// move excludes the deck itself via [excludeId]). Decision rows D6, D10.
  Failure? _duplicateDeckAmong(
    List<DeckRow> siblings,
    String trimmedName, {
    String? excludeId,
  }) {
    final String lowered = trimmedName.toLowerCase();
    final bool clash = siblings.any(
      (DeckRow d) => d.id != excludeId && d.name.toLowerCase() == lowered,
    );
    return clash
        ? const Failure.validation(
            field: 'name',
            code: ValidationCode.duplicate,
          )
        : null;
  }

  /// Next `sort_order` among deck [siblings]: append after the current max
  /// (0 when there are none).
  int _nextDeckSortOrder(List<DeckRow> siblings) {
    if (siblings.isEmpty) return 0;
    return siblings
            .map((DeckRow d) => d.sortOrder)
            .reduce((int a, int b) => a > b ? a : b) +
        1;
  }

  /// Build a fresh [Deck] with a generated id, appended `sort_order`, and
  /// current timestamps.
  Deck _buildNewDeck({
    required FolderId folderId,
    required String name,
    required TargetLanguage targetLanguage,
    required List<DeckRow> siblings,
  }) {
    final int now = _nowMs();
    final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
      now,
      isUtc: true,
    );
    return Deck(
      id: _idGenerator.newId(),
      folderId: folderId,
      name: name,
      targetLanguage: targetLanguage,
      sortOrder: _nextDeckSortOrder(siblings),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  DecksCompanion _deckInsertCompanion(Deck deck) => DecksCompanion.insert(
    id: deck.id,
    folderId: deck.folderId,
    name: deck.name,
    targetLanguage: Value(
      DeckMapper.targetLanguageToStorage(deck.targetLanguage),
    ),
    sortOrder: deck.sortOrder,
    createdAt: deck.createdAt.toUtc().millisecondsSinceEpoch,
    updatedAt: deck.updatedAt.toUtc().millisecondsSinceEpoch,
  );

  /// Reject a deck reorder whose [orderedIds] is not exactly the [siblings] set:
  /// duplicates, or any missing/extra/cross-folder id. Validated before any
  /// write, so the previous order is preserved on rejection (D8).
  Failure? _validateDeckReorder(
    List<DeckRow> siblings,
    List<DeckId> orderedIds,
  ) {
    final Set<String> orderedSet = orderedIds.toSet();
    final bool hasDuplicates = orderedSet.length != orderedIds.length;
    final Set<String> siblingIds = siblings.map((DeckRow d) => d.id).toSet();
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

  /// Revert a source folder to `unlocked` once it has no decks left (D9). A
  /// decks-mode folder never holds subfolders, so a zero deck count is enough.
  Future<void> _revertFolderIfNoDecks(FolderId folderId) async {
    final int remaining = await _deckDao.deckCountInFolder(folderId);
    if (remaining != 0) return;
    await _dao.updateFolderColumns(
      folderId,
      FoldersCompanion(
        contentMode: Value(
          FolderMapper.contentModeToStorage(ContentMode.unlocked),
        ),
        updatedAt: Value(_nowMs()),
      ),
    );
  }

  /// Storage write failure wrapper for caught exceptions on the `decks` table.
  Failure _storageWriteDecks(Object error) => Failure.storage(
    operation: StorageOp.write,
    table: 'decks',
    cause: error.toString(),
  );

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
