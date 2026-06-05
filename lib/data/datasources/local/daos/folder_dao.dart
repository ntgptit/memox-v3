import 'package:drift/drift.dart';

import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/tables/decks.dart';
import 'package:memox/data/datasources/local/tables/flashcard_progress.dart';
import 'package:memox/data/datasources/local/tables/flashcards.dart';
import 'package:memox/data/datasources/local/tables/folders.dart';

part 'folder_dao.g.dart';

/// Drift accessor for folder reads (`docs/contracts/repository-contracts/folder-repository.md`).
///
/// The Library Overview query is a single recursive-CTE statement that, for
/// each *anchor* folder (top-level, or any name match when searching), computes
/// its subtree aggregates plus the global folder/due totals — so the screen
/// renders without per-row count queries.
@DriftAccessor(
  tables: <Type>[Folders, Decks, Flashcards, FlashcardProgress],
)
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(super.db);

  /// Streams one row per anchor folder with subtree counts + global totals.
  ///
  /// [nowMs] (a trusted int) is inlined; [normalizedSearch] (user input) is a
  /// bound variable. [orderClause] is a trusted, controlled SQL fragment.
  Stream<List<QueryRow>> watchLibraryOverview({
    required int nowMs,
    required String orderClause,
    String? normalizedSearch,
  }) {
    final bool searching = normalizedSearch != null && normalizedSearch.isNotEmpty;
    final String anchorPredicate =
        searching ? "LOWER(f.name) LIKE ? ESCAPE '\\'" : 'f.parent_id IS NULL';
    final String dueCondition =
        'p.is_suspended = 0 '
        'AND (p.buried_until IS NULL OR p.buried_until <= $nowMs) '
        'AND p.due_at IS NOT NULL AND p.due_at <= $nowMs';

    final String sql =
        '''
WITH RECURSIVE subtree(anchor_id, folder_id) AS (
  SELECT f.id, f.id FROM folders f WHERE $anchorPredicate
  UNION ALL
  SELECT st.anchor_id, c.id
  FROM folders c JOIN subtree st ON c.parent_id = st.folder_id
)
SELECT
  f.id            AS id,
  f.parent_id     AS parent_id,
  f.name          AS name,
  f.content_mode  AS content_mode,
  f.sort_order    AS sort_order,
  f.created_at    AS created_at,
  f.updated_at    AS updated_at,
  (SELECT COUNT(*) FROM subtree s
     WHERE s.anchor_id = f.id AND s.folder_id <> f.id) AS subfolder_count,
  (SELECT COUNT(*) FROM decks d
     JOIN subtree s ON d.folder_id = s.folder_id
     WHERE s.anchor_id = f.id) AS deck_count,
  (SELECT COUNT(*) FROM flashcards fc
     JOIN decks d ON fc.deck_id = d.id
     JOIN subtree s ON d.folder_id = s.folder_id
     WHERE s.anchor_id = f.id) AS card_count,
  (SELECT COUNT(*) FROM flashcards fc
     JOIN decks d ON fc.deck_id = d.id
     JOIN subtree s ON d.folder_id = s.folder_id
     JOIN flashcard_progress p ON p.flashcard_id = fc.id
     WHERE s.anchor_id = f.id AND $dueCondition) AS due_count,
  (SELECT COUNT(*) FROM folders) AS total_folder_count,
  (SELECT COUNT(*) FROM flashcards fc
     JOIN flashcard_progress p ON p.flashcard_id = fc.id
     WHERE $dueCondition) AS due_today_total
FROM folders f
WHERE $anchorPredicate
ORDER BY $orderClause
''';

    final List<Variable<Object>> variables = <Variable<Object>>[
      if (searching) Variable<String>('%$normalizedSearch%'),
    ];

    return customSelect(
      sql,
      variables: variables,
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
        folders,
        decks,
        flashcards,
        flashcardProgress,
      },
    ).watch();
  }

  /// Names of the current root folders (for duplicate checks).
  Future<List<String>> rootFolderNames() {
    final JoinedSelectStatement<$FoldersTable, FolderRow> query =
        selectOnly(folders)
          ..addColumns(<Expression<Object>>[folders.name])
          ..where(folders.parentId.isNull());
    return query.map((TypedResult row) => row.read(folders.name)!).get();
  }

  /// Highest `sort_order` among root folders, or `-1` when there are none.
  Future<int> maxRootSortOrder() async {
    final Expression<int> maxOrder = folders.sortOrder.max();
    final JoinedSelectStatement<$FoldersTable, FolderRow> query =
        selectOnly(folders)
          ..addColumns(<Expression<Object>>[maxOrder])
          ..where(folders.parentId.isNull());
    final int? value =
        await query.map((TypedResult row) => row.read(maxOrder)).getSingleOrNull();
    return value ?? -1;
  }

  Future<void> insertFolder(FoldersCompanion folder) =>
      into(folders).insert(folder);

  Future<FolderRow?> findFolder(String id) =>
      (select(folders)..where(($FoldersTable t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Every folder row (id, parent, mode, name). Used to build the move-target
  /// list + breadcrumbs in the repository without per-row queries.
  Future<List<FolderRow>> allFolders() => select(folders).get();

  /// Names of folders sharing [parentId] (root when null), optionally skipping
  /// [excludeId]. Backs case-insensitive sibling-uniqueness on rename/move.
  Future<List<String>> siblingFolderNames({
    String? parentId,
    String? excludeId,
  }) {
    final JoinedSelectStatement<$FoldersTable, FolderRow> query =
        selectOnly(folders)..addColumns(<Expression<Object>>[folders.name]);
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
    final JoinedSelectStatement<$FoldersTable, FolderRow> query =
        selectOnly(folders)..addColumns(<Expression<Object>>[maxOrder]);
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
    final JoinedSelectStatement<$FoldersTable, FolderRow> query =
        selectOnly(folders)..addColumns(<Expression<Object>>[total]);
    query.where(
      parentId == null
          ? folders.parentId.isNull()
          : folders.parentId.equals(parentId),
    );
    final int? value =
        await query.map((TypedResult row) => row.read(total)).getSingleOrNull();
    return value ?? 0;
  }

  /// Ids of [id] and all its descendant folders, ordered deepest-first so a
  /// caller can delete them without violating the self-referential FK (which is
  /// `RESTRICT`, not cascade).
  Future<List<String>> descendantFolderIdsDepthFirst(String id) async {
    const String sql = '''
WITH RECURSIVE subtree(folder_id, depth) AS (
  SELECT id, 0 FROM folders WHERE id = ?
  UNION ALL
  SELECT f.id, st.depth + 1
  FROM folders f JOIN subtree st ON f.parent_id = st.folder_id
)
SELECT folder_id FROM subtree ORDER BY depth DESC
''';
    final List<QueryRow> rows = await customSelect(
      sql,
      variables: <Variable<Object>>[Variable<String>(id)],
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{folders},
    ).get();
    return rows.map((QueryRow row) => row.read<String>('folder_id')).toList();
  }

  Future<void> updateFolderName(String id, String name, int updatedAt) =>
      (update(folders)..where(($FoldersTable t) => t.id.equals(id))).write(
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
  ) => (update(folders)..where(($FoldersTable t) => t.id.equals(id))).write(
    FoldersCompanion(
      parentId: Value<String?>(newParentId),
      sortOrder: Value<int>(sortOrder),
      updatedAt: Value<int>(updatedAt),
    ),
  );

  Future<void> updateFolderContentMode(String id, String mode, int updatedAt) =>
      (update(folders)..where(($FoldersTable t) => t.id.equals(id))).write(
        FoldersCompanion(
          contentMode: Value<String>(mode),
          updatedAt: Value<int>(updatedAt),
        ),
      );

  /// Deletes a single folder row. Decks → flashcards → progress under it cascade
  /// via their FKs; descendant folders MUST be deleted first (see
  /// [descendantFolderIdsDepthFirst]).
  Future<void> deleteFolderById(String id) =>
      (delete(folders)..where(($FoldersTable t) => t.id.equals(id))).go();

  /// Fires on any content-tree change (folders/decks/flashcards/progress). Used
  /// as a reactive trigger to rebuild a folder-detail snapshot.
  Stream<void> watchContentChanges() => customSelect(
    'SELECT 1',
    readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
      folders,
      decks,
      flashcards,
      flashcardProgress,
    },
  ).watch().map((_) {});

  /// Folder ancestor chain root → [id] (inclusive), ordered for the breadcrumb.
  Future<List<QueryRow>> breadcrumb(String id) {
    const String sql = '''
WITH RECURSIVE chain(id, name, parent_id, depth) AS (
  SELECT id, name, parent_id, 0 FROM folders WHERE id = ?
  UNION ALL
  SELECT f.id, f.name, f.parent_id, chain.depth + 1
  FROM folders f JOIN chain ON f.id = chain.parent_id
)
SELECT id, name FROM chain ORDER BY depth DESC
''';
    return customSelect(
      sql,
      variables: <Variable<Object>>[Variable<String>(id)],
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{folders},
    ).get();
  }

  /// Direct child folders of [parentId] with their recursive subtree counts.
  Future<List<QueryRow>> getSubfolderItems({
    required String parentId,
    required int nowMs,
    required String orderClause,
    String? normalizedSearch,
  }) {
    final bool searching =
        normalizedSearch != null && normalizedSearch.isNotEmpty;
    final String searchClause =
        searching ? "AND LOWER(f.name) LIKE ? ESCAPE '\\'" : '';
    final String dueCondition =
        'p.is_suspended = 0 '
        'AND (p.buried_until IS NULL OR p.buried_until <= $nowMs) '
        'AND p.due_at IS NOT NULL AND p.due_at <= $nowMs';

    final String sql =
        '''
WITH RECURSIVE subtree(anchor_id, folder_id) AS (
  SELECT f.id, f.id FROM folders f WHERE f.parent_id = ? $searchClause
  UNION ALL
  SELECT st.anchor_id, c.id
  FROM folders c JOIN subtree st ON c.parent_id = st.folder_id
)
SELECT
  f.id, f.parent_id, f.name, f.content_mode, f.sort_order,
  f.created_at, f.updated_at,
  (SELECT COUNT(*) FROM subtree s
     WHERE s.anchor_id = f.id AND s.folder_id <> f.id) AS subfolder_count,
  (SELECT COUNT(*) FROM decks d
     JOIN subtree s ON d.folder_id = s.folder_id
     WHERE s.anchor_id = f.id) AS deck_count,
  (SELECT COUNT(*) FROM flashcards fc
     JOIN decks d ON fc.deck_id = d.id
     JOIN subtree s ON d.folder_id = s.folder_id
     WHERE s.anchor_id = f.id) AS card_count,
  (SELECT COUNT(*) FROM flashcards fc
     JOIN decks d ON fc.deck_id = d.id
     JOIN subtree s ON d.folder_id = s.folder_id
     JOIN flashcard_progress p ON p.flashcard_id = fc.id
     WHERE s.anchor_id = f.id AND $dueCondition) AS due_count
FROM folders f
WHERE f.id IN (SELECT anchor_id FROM subtree)
ORDER BY $orderClause
''';

    final List<Variable<Object>> variables = <Variable<Object>>[
      Variable<String>(parentId),
      if (searching) Variable<String>('%$normalizedSearch%'),
    ];

    return customSelect(
      sql,
      variables: variables,
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
        folders,
        decks,
        flashcards,
        flashcardProgress,
      },
    ).get();
  }

  /// Direct child decks of [folderId] with card + due counts.
  Future<List<QueryRow>> getDeckItems({
    required String folderId,
    required int nowMs,
    required String orderClause,
    String? normalizedSearch,
  }) {
    final bool searching =
        normalizedSearch != null && normalizedSearch.isNotEmpty;
    final String searchClause =
        searching ? "AND LOWER(d.name) LIKE ? ESCAPE '\\'" : '';
    final String dueCondition =
        'p.is_suspended = 0 '
        'AND (p.buried_until IS NULL OR p.buried_until <= $nowMs) '
        'AND p.due_at IS NOT NULL AND p.due_at <= $nowMs';

    final String sql =
        '''
SELECT
  d.id, d.folder_id, d.name, d.target_language, d.sort_order,
  d.created_at, d.updated_at,
  (SELECT COUNT(*) FROM flashcards fc WHERE fc.deck_id = d.id) AS card_count,
  (SELECT COUNT(*) FROM flashcards fc
     JOIN flashcard_progress p ON p.flashcard_id = fc.id
     WHERE fc.deck_id = d.id AND $dueCondition) AS due_count
FROM decks d
WHERE d.folder_id = ? $searchClause
ORDER BY $orderClause
''';

    final List<Variable<Object>> variables = <Variable<Object>>[
      Variable<String>(folderId),
      if (searching) Variable<String>('%$normalizedSearch%'),
    ];

    return customSelect(
      sql,
      variables: variables,
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
        decks,
        flashcards,
        flashcardProgress,
      },
    ).get();
  }

  // ── Child mutations (folder-detail FAB) ──────────────────────────

  /// Names of the direct child folders under [parentId] (for duplicate checks).
  Future<List<String>> childFolderNames(String parentId) {
    final JoinedSelectStatement<$FoldersTable, FolderRow> query =
        selectOnly(folders)
          ..addColumns(<Expression<Object>>[folders.name])
          ..where(folders.parentId.equals(parentId));
    return query.map((TypedResult row) => row.read(folders.name)!).get();
  }

  /// Highest `sort_order` among child folders of [parentId], or `-1`.
  Future<int> maxChildFolderSortOrder(String parentId) async {
    final Expression<int> maxOrder = folders.sortOrder.max();
    final JoinedSelectStatement<$FoldersTable, FolderRow> query =
        selectOnly(folders)
          ..addColumns(<Expression<Object>>[maxOrder])
          ..where(folders.parentId.equals(parentId));
    final int? value =
        await query.map((TypedResult row) => row.read(maxOrder)).getSingleOrNull();
    return value ?? -1;
  }

  Future<void> setFolderContentMode(String id, String mode) =>
      (update(folders)..where(($FoldersTable t) => t.id.equals(id)))
          .write(FoldersCompanion(contentMode: Value<String>(mode)));

  /// Names of the decks directly under [folderId] (for duplicate checks).
  Future<List<String>> deckNames(String folderId) {
    final JoinedSelectStatement<$DecksTable, DeckRow> query = selectOnly(decks)
      ..addColumns(<Expression<Object>>[decks.name])
      ..where(decks.folderId.equals(folderId));
    return query.map((TypedResult row) => row.read(decks.name)!).get();
  }

  /// Highest `sort_order` among decks of [folderId], or `-1`.
  Future<int> maxDeckSortOrder(String folderId) async {
    final Expression<int> maxOrder = decks.sortOrder.max();
    final JoinedSelectStatement<$DecksTable, DeckRow> query = selectOnly(decks)
      ..addColumns(<Expression<Object>>[maxOrder])
      ..where(decks.folderId.equals(folderId));
    final int? value =
        await query.map((TypedResult row) => row.read(maxOrder)).getSingleOrNull();
    return value ?? -1;
  }

  Future<void> insertDeck(DecksCompanion deck) => into(decks).insert(deck);

  Future<DeckRow?> findDeck(String id) =>
      (select(decks)..where(($DecksTable t) => t.id.equals(id)))
          .getSingleOrNull();
}
