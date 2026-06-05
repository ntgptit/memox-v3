import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

/// Streams a folder's detail (`docs/wireframes/05-folder-detail.md`,
/// `docs/contracts/usecase-contracts/folder.md` §WatchFolderChildrenUseCase).
///
/// Thin orchestration over [FolderRepository]; the notifier depends on this,
/// never on the repository directly.
class WatchFolderDetailUseCase {
  const WatchFolderDetailUseCase(this._repository);

  final FolderRepository _repository;

  Stream<Result<FolderDetail>> call(
    String folderId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
  }) => _repository.watchFolderDetail(
    folderId,
    searchTerm: searchTerm,
    sort: sort,
  );
}
