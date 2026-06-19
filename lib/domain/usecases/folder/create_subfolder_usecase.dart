import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Create a subfolder under a parent, locking the parent to `subfolders` mode
/// when it was `unlocked` (enforced atomically in the repository).
///
/// Contract: `docs/contracts/usecase-contracts/folder.md` §CreateSubfolderUseCase.
/// Decision rows F3, F4.
class CreateSubfolderUseCase {
  const CreateSubfolderUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<Folder>> call({
    required FolderId parentId,
    required String name,
  }) => repository.createSubfolder(parentId: parentId, name: name);
}
