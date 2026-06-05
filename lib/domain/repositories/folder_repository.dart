import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

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
}
