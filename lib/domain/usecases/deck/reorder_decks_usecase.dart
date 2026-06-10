import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Reorders the decks in a folder.
///
/// [orderedIds] must be the full sibling list. The repository validates the
/// ids against the current folder scope and writes deterministic `sort_order`
/// values in one transaction.
class ReorderDecksUseCase {
  const ReorderDecksUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<void>> call({
    required FolderId parentId,
    required List<DeckId> orderedIds,
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
    return _repository.reorderDecks(parentId: parentId, orderedIds: orderedIds);
  }
}
