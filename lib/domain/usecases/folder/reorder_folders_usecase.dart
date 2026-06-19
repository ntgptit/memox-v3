import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Persist a manual sibling order for the folders under [parentId] (root
/// siblings when `null`). The list must be the full sibling set — validation
/// and the transactional `sort_order` write live in
/// [FolderRepository.reorderFolders].
///
/// Contract: `docs/contracts/usecase-contracts/folder.md` §ReorderFoldersUseCase.
/// Decision rows F10, F11.
class ReorderFoldersUseCase {
  const ReorderFoldersUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<void>> call({
    required FolderId? parentId,
    required List<FolderId> orderedIds,
  }) => repository.reorderFolders(parentId: parentId, orderedIds: orderedIds);
}
