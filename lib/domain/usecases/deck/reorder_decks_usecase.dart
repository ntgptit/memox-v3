import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Persist a manual deck order within [parentId]. The list must be the full
/// deck set — validation and the transactional `sort_order` write live in
/// [FolderRepository.reorderDecks].
///
/// Contract: `docs/contracts/usecase-contracts/deck.md` §ReorderDecksUseCase.
/// Decision rows D4, D8.
class ReorderDecksUseCase {
  const ReorderDecksUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<void>> call({
    required FolderId parentId,
    required List<DeckId> orderedIds,
  }) => repository.reorderDecks(folderId: parentId, orderedIds: orderedIds);
}
