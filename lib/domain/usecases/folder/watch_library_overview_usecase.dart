import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

/// Streams the Library Overview read model (`docs/wireframes/02-library.md`,
/// `docs/contracts/usecase-contracts/folder.md`).
///
/// Thin orchestration over [FolderRepository]; notifiers depend on this, never
/// on the repository directly.
class LibraryOverviewUseCase {
  const LibraryOverviewUseCase(this._repository);

  final FolderRepository _repository;

  Stream<Result<LibraryOverviewReadModel>> call({
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
  }) => _repository.watchLibraryOverview(searchTerm: searchTerm, sort: sort);
}
