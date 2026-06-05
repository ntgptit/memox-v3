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
}
