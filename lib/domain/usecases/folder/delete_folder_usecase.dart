import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Deletes a folder and its whole subtree
/// (`docs/contracts/usecase-contracts/folder.md` §DeleteFolderUseCase).
///
/// Destructive: the caller MUST confirm via the §delete-confirm dialog before
/// invoking. The repository performs the recursive cascade (descendant folders,
/// their decks, flashcards, and progress) atomically and reverts an emptied
/// parent to `unlocked`.
class DeleteFolderUseCase {
  const DeleteFolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<void>> call({required FolderId id}) =>
      _repository.deleteFolder(folderId: id);
}
