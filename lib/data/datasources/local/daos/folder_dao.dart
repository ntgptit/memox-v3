import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'folder_dao.g.dart';

/// Thin Drift accessor for the `folders` table.
///
/// Recursive / aggregate reads come from `drift/folder_queries.drift` (generated
/// `Selectable` methods); single-table mutations and lookups use the query
/// builder, both per `docs/database/drift-guide.md`. No business logic lives
/// here — validation, content-mode locks and cascades are orchestrated in
/// `FolderRepositoryImpl`.
@DriftAccessor(include: <String>{'../drift/folder_queries.drift'})
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(super.db);

  // ---- Reads (streams power the Library / Folder-detail screens) ----

  /// Root folders + counts, as a live stream. [nowMs] is the UTC epoch-ms
  /// reference used to decide which scheduled cards count as due. WBS 3.1.1 /
  /// 3.7.1.
  Stream<List<RootFolderSummariesResult>> watchRootFolderSummaries(int nowMs) =>
      rootFolderSummaries(nowMs).watch();

  /// Direct child folders of [parentId] + counts, as a live stream. [nowMs] is
  /// the due-reference epoch-ms. WBS 3.2.1 / 3.7.1.
  Stream<List<ChildFolderSummariesResult>> watchChildFolderSummaries(
    String parentId,
    int nowMs,
    // Drift orders generated params by first appearance in the SQL text, so
    // `:now` (in the counts CTE) precedes `:parentId` — pass nowMs first.
  ) => childFolderSummaries(nowMs, parentId).watch();

  /// Aggregate counts for [id] itself (direct deck count + recursive subtree
  /// card/due counts). [nowMs] is the due-reference epoch-ms. WBS 3.7.1.
  Future<FolderSubtreeCountsResult> folderSubtreeCountsFor(
    String id,
    int nowMs,
  ) => folderSubtreeCounts(id, nowMs).getSingle();

  /// Ancestor chain root -> leaf (inclusive) for the breadcrumb header.
  Future<List<FolderRow>> getBreadcrumb(String id) async {
    final List<BreadcrumbResult> rows = await breadcrumb(id).get();
    return rows.map((BreadcrumbResult r) => r.folders).toList();
  }

  /// [id] plus every descendant folder id, deepest first (delete order).
  Future<List<String>> getDescendantFolderIdsDeepestFirst(String id) =>
      descendantFolderIdsDeepestFirst(id).get();

  /// Single folder row, or `null` if it does not exist.
  Future<FolderRow?> findFolderById(String id) => (select(
    folders,
  )..where((Folders t) => t.id.equals(id))).getSingleOrNull();

  /// Every folder in a deterministic order (`sort_order`, then `created_at`,
  /// then `id`). Used to build the flat move-target list and resolve each
  /// folder's breadcrumb in Dart.
  Future<List<FolderRow>> listAllFolders() =>
      (select(folders)..orderBy(<OrderClauseGenerator<Folders>>[
            (Folders t) => OrderingTerm(expression: t.sortOrder),
            (Folders t) => OrderingTerm(expression: t.createdAt),
            (Folders t) => OrderingTerm(expression: t.id),
          ]))
          .get();

  /// Siblings under [parentId] (root siblings when `null`). Used for
  /// case-insensitive duplicate checks and next `sort_order` in Dart.
  Future<List<FolderRow>> siblingFolders(String? parentId) =>
      (select(folders)..where(
            (Folders t) => parentId == null
                ? t.parentId.isNull()
                : t.parentId.equals(parentId),
          ))
          .get();

  /// Number of direct children of [id]. Used to decide whether a parent reverts
  /// to `unlocked` after a delete.
  Future<int> childFolderCount(String id) async {
    final Expression<int> count = folders.id.count();
    final TypedResult row =
        await (selectOnly(folders)
              ..addColumns(<Expression<Object>>[count])
              ..where(folders.parentId.equals(id)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  // ---- Mutations (single-table; called inside repository transactions) ----

  Future<void> insertFolder(FoldersCompanion folder) =>
      into(folders).insert(folder);

  Future<void> updateFolderColumns(String id, FoldersCompanion changes) =>
      (update(folders)..where((Folders t) => t.id.equals(id))).write(changes);

  Future<void> deleteFolderById(String id) =>
      (delete(folders)..where((Folders t) => t.id.equals(id))).go();

  /// Run [action] in a single database transaction.
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      transaction(action);
}
