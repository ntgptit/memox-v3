import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Lists every candidate destination for moving a folder
/// (`docs/contracts/usecase-contracts/folder.md` §GetFolderMoveTargetsUseCase,
/// `docs/wireframes/25-shared-bottom-sheets.md` §folder-picker).
///
/// Returns the Library root plus all folders, each annotated with whether it is
/// the current parent and why it is blocked (cycle / locked-to-decks). Invalid
/// destinations are returned **disabled with a reason**, never omitted — the
/// picker renders them greyed so the rule is visible.
class GetFolderMoveTargetsUseCase {
  const GetFolderMoveTargetsUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<List<FolderMoveTarget>>> call({required FolderId folderId}) =>
      _repository.getFolderMoveTargets(folderId: folderId);
}
