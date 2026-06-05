import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

/// Folder data access contract (`docs/contracts/repository-contracts/folder-repository.md`).
///
/// Implemented by `FolderRepositoryImpl` over Drift. Uses the existing
/// [Result] pattern (the contract's `Either<Failure, T>` is the fpdart target,
/// not yet adopted). Mutations and additional queries are added per feature
/// slice; this slice covers the Library Overview read path.
abstract interface class FolderRepository {
  /// Streams the Library Overview read model.
  ///
  /// When [searchTerm] is null/blank the rows are the **top-level** folders.
  /// When a term is active the query broadens to **any folder across the tree**
  /// whose name contains the normalized term (`docs/wireframes/02-library.md`),
  /// each still carrying its recursive subtree counts.
  Stream<Result<LibraryOverviewReadModel>> watchLibraryOverview({
    String? searchTerm,
    ContentSortMode sort,
  });

  /// Creates a root folder (`parent_id = NULL`, `content_mode = unlocked`,
  /// next `sort_order`). Enforces case-insensitive sibling-name uniqueness;
  /// a clash returns `ValidationFailure(code: duplicate)`. [name] is assumed
  /// already trimmed by the use case.
  Future<Result<Folder>> createRootFolder({required String name});

  /// Streams a folder's detail: the folder, its breadcrumb path, and its direct
  /// children (subfolders **or** decks per `content_mode`), each with counts.
  /// A missing/deleted folder yields `NotFoundFailure`. [searchTerm] filters
  /// the direct children by name (`docs/wireframes/05-folder-detail.md`).
  Stream<Result<FolderDetail>> watchFolderDetail(
    String folderId, {
    String? searchTerm,
    ContentSortMode sort,
  });

  /// Creates a subfolder under [parentId] in one transaction: inserts the child
  /// (`content_mode = unlocked`, next `sort_order`) and locks the parent to
  /// `subfolders` if it was `unlocked`. [name] is assumed trimmed.
  ///
  /// Errors: `NotFoundFailure` (parent missing), `UnsupportedActionFailure`
  /// (parent locked to decks), `ValidationFailure(duplicate)`, `StorageFailure`.
  Future<Result<Folder>> createSubfolder({
    required FolderId parentId,
    required String name,
  });

  /// Creates a deck under [parentFolderId] in one transaction: inserts the deck
  /// and locks the parent to `decks` if it was `unlocked`. [name] is assumed
  /// trimmed.
  ///
  /// Errors: `NotFoundFailure`, `UnsupportedActionFailure` (parent locked to
  /// subfolders), `ValidationFailure(duplicate)`, `StorageFailure`.
  Future<Result<Deck>> createDeck({
    required FolderId parentFolderId,
    required String name,
    required TargetLanguage targetLanguage,
  });

  /// Renames [folderId] to [name] (assumed trimmed). Enforces case-insensitive
  /// sibling-name uniqueness; an unchanged name is a no-op that returns the
  /// folder unchanged.
  ///
  /// Errors: `NotFoundFailure`, `ValidationFailure(duplicate)`, `StorageFailure`.
  Future<Result<Folder>> renameFolder({
    required FolderId folderId,
    required String name,
  });

  /// Moves [folderId] under [newParentId] (`null` = Library root) in one
  /// transaction: recomputes `sort_order`, locks the destination to
  /// `subfolders` if it was `unlocked`, and reverts an emptied old parent to
  /// `unlocked`. An unchanged parent is a no-op.
  ///
  /// Errors: `NotFoundFailure`, `ValidationFailure(cycleDetected)`,
  /// `ValidationFailure(duplicate)`, `UnsupportedActionFailure` (destination
  /// locked to decks), `StorageFailure`.
  Future<Result<Folder>> moveFolder({
    required FolderId folderId,
    required FolderId? newParentId,
  });

  /// Deletes [folderId] and its whole subtree (descendant folders, their decks,
  /// flashcards, and progress cascade via FKs) in one transaction, reverting an
  /// emptied parent to `unlocked`.
  ///
  /// Errors: `NotFoundFailure`, `StorageFailure`.
  Future<Result<void>> deleteFolder({required FolderId folderId});

  /// Lists every candidate destination for moving [folderId]: the Library root
  /// plus all folders, each annotated as current-parent / blocked. Blocked rows
  /// (the folder itself, its descendants, or `decks`-locked folders) are
  /// returned with a reason, never omitted (`docs/wireframes/25-shared-bottom-sheets.md`
  /// §folder-picker).
  Future<Result<List<FolderMoveTarget>>> getFolderMoveTargets({
    required FolderId folderId,
  });
}
