import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Delete a folder and its descendants (recursive cascade), reverting the old
/// parent to `unlocked` when emptied. Transaction lives in
/// [FolderRepository.deleteFolder].
///
/// **Caution:** destructive. The caller MUST confirm via the delete-confirm
/// dialog before invoking (`docs/wireframes/24-shared-dialogs.md` §delete-confirm).
///
/// Contract: `docs/contracts/usecase-contracts/folder.md` §DeleteFolderUseCase.
/// Decision rows F8, F9.
class DeleteFolderUseCase {
  const DeleteFolderUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<void>> call({required FolderId id}) =>
      repository.deleteFolder(id: id);
}
