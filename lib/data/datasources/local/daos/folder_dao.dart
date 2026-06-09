import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

part 'folder_dao.g.dart';

/// Drift accessor for folder reads (`docs/contracts/repository-contracts/folder-repository.md`).
///
/// All SQL lives in `drift/folder_queries.drift` (pulled in via `include`); the
/// methods here are thin wrappers that bind parameters and build the runtime
/// `ORDER BY`, then delegate to the generated, type-safe query methods. Drift
/// query builders (`select`/`update`/`delete`) cover the small single-table
/// reads/mutations.
@DriftAccessor(include: <String>{'../drift/folder_queries.drift'})
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(super.db);

  // ── Aggregate read queries (defined in folder_queries.drift) ──────

  /// Streams one row per anchor folder with subtree counts + global totals.
  ///
  /// [normalizedSearch] is an already-normalized term (or null/blank for the
  /// top-level view); it is turned into a LIKE pattern here. [sort] drives the
  /// runtime `ORDER BY`.
  Stream<List<LibraryOverviewResult>> watchLibraryOverview({
    required int nowMs,
    required ContentSortMode sort,
    String? normalizedSearch,
  }) => libraryOverview(
    _searchPattern(normalizedSearch),
    nowMs,
    _folderOrder(sort),
  ).watch();

  /// Direct child folders of [parentId] with their recursive subtree counts.
  Future<List<SubfolderItemsResult>> getSubfolderItems({
    required String parentId,
    required int nowMs,
    required ContentSortMode sort,
    String? normalizedSearch,
  }) => subfolderItems(
    parentId,
    _searchPattern(normalizedSearch),
    nowMs,
    _folderOrder(sort),
  ).get();

  /// Direct child decks of [folderId] with card + due counts.
  Future<List<DeckItemsResult>> getDeckItems({
    required String folderId,
    required int nowMs,
    required ContentSortMode sort,
    String? normalizedSearch,
  }) => deckItems(
    nowMs,
    folderId,
    _searchPattern(normalizedSearch),
    _deckOrder(sort),
  ).get();

  /// Folder ancestor chain root → [id] (inclusive), ordered for the breadcrumb.
  Future<List<FolderBreadcrumbResult>> breadcrumb(String id) =>
      folderBreadcrumb(id).get();

  /// Ids of [id] and all its descendant folders, ordered deepest-first so a
  /// caller can delete them without violating the self-referential FK (which is
  /// `RESTRICT`, not cascade).
  Future<List<String>> descendantFolderIdsDepthFirst(String id) =>
      descendantFolderIds(id).get();

  /// Fires on any content-tree change (folders/decks/flashcards/progress). Used
  /// as a reactive trigger to rebuild a folder-detail snapshot.
  Stream<void> watchContentChanges() => contentRevision().watch().map((_) {});

  // ── Single-table reads / mutations (Drift query builder) ──────────

  /// Names of the current root folders (for duplicate checks).
  Future<List<String>> rootFolderNames() {
    final JoinedSelectStatement<Folders, FolderRow> query = selectOnly(folders)
      ..addColumns(<Expression<Object>>[folders.name])
      ..where(folders.parentId.isNull());
    return query.map((TypedResult row) => row.read(folders.name)!).get();
  }

  /// Highest `sort_order` among root folders, or `-1` when there are none.
  Future<int> maxRootSortOrder() async {
    final Expression<int> maxOrder = folders.sortOrder.max();
    final JoinedSelectStatement<Folders, FolderRow> query = selectOnly(folders)
      ..addColumns(<Expression<Object>>[maxOrder])
      ..where(folders.parentId.isNull());
    final int? value = await query
        .map((TypedResult row) => row.read(maxOrder))
        .getSingleOrNull();
    return value ?? -1;
  }

  Future<void> insertFolder(FoldersCompanion folder) =>
      into(folders).insert(folder);

  Future<FolderRow?> findFolder(String id) => (select(
    folders,
  )..where((Folders t) => t.id.equals(id))).getSingleOrNull();

  /// Every folder row (id, parent, mode, name). Used to build the move-target
  /// list + breadcrumbs in the repository without per-row queries.
  Future<List<FolderRow>> allFolders() => select(folders).get();

  /// Names of folders sharing [parentId] (root when null), optionally skipping
  /// [excludeId]. Backs case-insensitive sibling-uniqueness on rename/move.
  Future<List<String>> siblingFolderNames({
    String? parentId,
    String? excludeId,
  }) {
    final JoinedSelectStatement<Folders, FolderRow> query = selectOnly(folders)
      ..addColumns(<Expression<Object>>[folders.name]);
    query.where(
      parentId == null
          ? folders.parentId.isNull()
          : folders.parentId.equals(parentId),
    );
    if (excludeId != null) {
      query.where(folders.id.equals(excludeId).not());
    }
    return query.map((TypedResult row) => row.read(folders.name)!).get();
  }

  /// Highest `sort_order` among the children of [parentId] (root when null), or
  /// `-1` when there are none.
  Future<int> maxChildSortOrder(String? parentId) async {
    final Expression<int> maxOrder = folders.sortOrder.max();
    final JoinedSelectStatement<Folders, FolderRow> query = selectOnly(folders)
      ..addColumns(<Expression<Object>>[maxOrder]);
    query.where(
      parentId == null
          ? folders.parentId.isNull()
          : folders.parentId.equals(parentId),
    );
    final int? value = await query
        .map((TypedResult row) => row.read(maxOrder))
        .getSingleOrNull();
    return value ?? -1;
  }

  /// Number of direct child folders under [parentId] (root when null). Used to
  /// decide whether an emptied parent reverts to `unlocked`.
  Future<int> childFolderCount(String? parentId) async {
    final Expression<int> total = folders.id.count();
    final JoinedSelectStatement<Folders, FolderRow> query = selectOnly(folders)
      ..addColumns(<Expression<Object>>[total]);
    query.where(
      parentId == null
          ? folders.parentId.isNull()
          : folders.parentId.equals(parentId),
    );
    final int? value = await query
        .map((TypedResult row) => row.read(total))
        .getSingleOrNull();
    return value ?? 0;
  }

  Future<void> updateFolderName(String id, String name, int updatedAt) =>
      (update(folders)..where((Folders t) => t.id.equals(id))).write(
        FoldersCompanion(
          name: Value<String>(name),
          updatedAt: Value<int>(updatedAt),
        ),
      );

  Future<void> updateFolderParent(
    String id,
    String? newParentId,
    int sortOrder,
    int updatedAt,
  ) => (update(folders)..where((Folders t) => t.id.equals(id))).write(
    FoldersCompanion(
      parentId: Value<String?>(newParentId),
      sortOrder: Value<int>(sortOrder),
      updatedAt: Value<int>(updatedAt),
    ),
  );

  Future<void> updateFolderContentMode(String id, String mode, int updatedAt) =>
      (update(folders)..where((Folders t) => t.id.equals(id))).write(
        FoldersCompanion(
          contentMode: Value<String>(mode),
          updatedAt: Value<int>(updatedAt),
        ),
      );

  /// Deletes a single folder row. Decks → flashcards → progress under it cascade
  /// via their FKs; descendant folders MUST be deleted first (see
  /// [descendantFolderIdsDepthFirst]).
  Future<void> deleteFolderById(String id) =>
      (delete(folders)..where((Folders t) => t.id.equals(id))).go();

  // ── Child mutations (folder-detail FAB) ──────────────────────────

  /// Names of the direct child folders under [parentId] (for duplicate checks).
  Future<List<String>> childFolderNames(String parentId) {
    final JoinedSelectStatement<Folders, FolderRow> query = selectOnly(folders)
      ..addColumns(<Expression<Object>>[folders.name])
      ..where(folders.parentId.equals(parentId));
    return query.map((TypedResult row) => row.read(folders.name)!).get();
  }

  /// Highest `sort_order` among child folders of [parentId], or `-1`.
  Future<int> maxChildFolderSortOrder(String parentId) async {
    final Expression<int> maxOrder = folders.sortOrder.max();
    final JoinedSelectStatement<Folders, FolderRow> query = selectOnly(folders)
      ..addColumns(<Expression<Object>>[maxOrder])
      ..where(folders.parentId.equals(parentId));
    final int? value = await query
        .map((TypedResult row) => row.read(maxOrder))
        .getSingleOrNull();
    return value ?? -1;
  }

  Future<void> setFolderContentMode(String id, String mode) =>
      (update(folders)..where((Folders t) => t.id.equals(id))).write(
        FoldersCompanion(contentMode: Value<String>(mode)),
      );

  /// Names of the decks directly under [folderId] (for duplicate checks).
  Future<List<String>> deckNames(String folderId) {
    final JoinedSelectStatement<Decks, DeckRow> query = selectOnly(decks)
      ..addColumns(<Expression<Object>>[decks.name])
      ..where(decks.folderId.equals(folderId));
    return query.map((TypedResult row) => row.read(decks.name)!).get();
  }

  /// Highest `sort_order` among decks of [folderId], or `-1`.
  Future<int> maxDeckSortOrder(String folderId) async {
    final Expression<int> maxOrder = decks.sortOrder.max();
    final JoinedSelectStatement<Decks, DeckRow> query = selectOnly(decks)
      ..addColumns(<Expression<Object>>[maxOrder])
      ..where(decks.folderId.equals(folderId));
    final int? value = await query
        .map((TypedResult row) => row.read(maxOrder))
        .getSingleOrNull();
    return value ?? -1;
  }

  Future<void> insertDeck(DecksCompanion deck) => into(decks).insert(deck);

  Future<DeckRow?> findDeck(String id) =>
      (select(decks)..where((Decks t) => t.id.equals(id))).getSingleOrNull();

  /// Number of decks directly under [folderId]. Used to decide whether an
  /// emptied `decks`-mode folder reverts to `unlocked`.
  Future<int> childDeckCount(String folderId) async {
    final Expression<int> total = decks.id.count();
    final JoinedSelectStatement<Decks, DeckRow> query = selectOnly(decks)
      ..addColumns(<Expression<Object>>[total])
      ..where(decks.folderId.equals(folderId));
    final int? value = await query
        .map((TypedResult row) => row.read(total))
        .getSingleOrNull();
    return value ?? 0;
  }

  /// Deletes a single deck row. Its flashcards → progress cascade via FKs.
  Future<void> deleteDeckById(String id) =>
      (delete(decks)..where((Decks t) => t.id.equals(id))).go();

  // ── ORDER BY builders for the `$order` query placeholder ──────────
  //
  // Mirror the previous trusted SQL fragments. `name` ordering is binary
  // (case-sensitive); the old `LOWER(name)` form is functionally equivalent for
  // the V1 data and there is no sort UI exposed yet.

  LibraryOverview$order _folderOrder(ContentSortMode sort) =>
      (Folders f) => switch (sort) {
        ContentSortMode.name => OrderBy(<OrderingTerm>[
          OrderingTerm(expression: f.name),
          OrderingTerm(expression: f.sortOrder),
        ]),
        ContentSortMode.newest => OrderBy(<OrderingTerm>[
          OrderingTerm(expression: f.createdAt, mode: OrderingMode.desc),
          OrderingTerm(expression: f.sortOrder),
        ]),
        ContentSortMode.lastStudied ||
        ContentSortMode.manual => OrderBy(<OrderingTerm>[
          OrderingTerm(expression: f.sortOrder),
          OrderingTerm(expression: f.createdAt),
        ]),
      };

  DeckItems$order _deckOrder(ContentSortMode sort) =>
      (Decks d) => switch (sort) {
        ContentSortMode.name => OrderBy(<OrderingTerm>[
          OrderingTerm(expression: d.name),
          OrderingTerm(expression: d.sortOrder),
        ]),
        ContentSortMode.newest => OrderBy(<OrderingTerm>[
          OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc),
          OrderingTerm(expression: d.sortOrder),
        ]),
        ContentSortMode.lastStudied ||
        ContentSortMode.manual => OrderBy(<OrderingTerm>[
          OrderingTerm(expression: d.sortOrder),
          OrderingTerm(expression: d.createdAt),
        ]),
      };

  static String _searchPattern(String? normalized) =>
      (normalized == null || normalized.isEmpty) ? '' : '%$normalized%';
}
