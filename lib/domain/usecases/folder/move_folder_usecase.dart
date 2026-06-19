import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Move a folder under [newParentId] (or to the Library root when `null`).
/// Existence, content-mode lock, cycle and sibling-name rules live in
/// [FolderRepository.moveFolder].
///
/// Contract: `docs/contracts/usecase-contracts/folder.md` §MoveFolderUseCase.
/// Decision rows F7, F14-F17, F19.
class MoveFolderUseCase {
  const MoveFolderUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<Folder>> call({
    required FolderId id,
    required FolderId? newParentId,
  }) => repository.moveFolder(id: id, newParentId: newParentId);
}
