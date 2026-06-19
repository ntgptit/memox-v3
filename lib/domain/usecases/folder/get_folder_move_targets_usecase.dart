import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// List every move destination for the folder [folderId]: the Library root plus
/// all folders, each annotated with `isCurrentParent` and a `block` reason when
/// it cannot accept the move. Pure read — see
/// [FolderRepository.getFolderMoveTargets].
///
/// Contract: `docs/contracts/usecase-contracts/folder.md` §GetFolderMoveTargetsUseCase.
/// Decision row F18.
class GetFolderMoveTargetsUseCase {
  const GetFolderMoveTargetsUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<List<FolderMoveTarget>>> call({required FolderId folderId}) =>
      repository.getFolderMoveTargets(folderId: folderId);
}
