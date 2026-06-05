import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Moves a folder under a new parent (`null` = Library root)
/// (`docs/contracts/usecase-contracts/folder.md` §MoveFolderUseCase).
///
/// All structural validation — existence, the destination's content-mode lock,
/// cycle detection, sibling-name uniqueness, and the atomic mode updates — lives
/// in the repository. An unchanged parent is a no-op there.
class MoveFolderUseCase {
  const MoveFolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<Folder>> call({
    required FolderId id,
    required FolderId? newParentId,
  }) => _repository.moveFolder(folderId: id, newParentId: newParentId);
}
