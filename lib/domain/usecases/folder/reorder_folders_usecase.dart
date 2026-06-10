import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Reorders the direct children of a folder (`docs/contracts/usecase-contracts/
/// folder.md` §ReorderFoldersUseCase).
///
/// [orderedIds] must be the full sibling list. The repository validates the
/// ids against the current parent scope and writes deterministic `sort_order`
/// values in one transaction.
class ReorderFoldersUseCase {
  const ReorderFoldersUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<void>> call({
    required FolderId? parentId,
    required List<FolderId> orderedIds,
  }) {
    if (orderedIds.isEmpty) {
      return Future<Result<void>>.value(
        const Result<void>.err(
          Failure.validation(
            field: 'orderedIds',
            code: ValidationCode.insufficientContent,
          ),
        ),
      );
    }
    return _repository.reorderFolders(
      parentId: parentId,
      orderedIds: orderedIds,
    );
  }
}
