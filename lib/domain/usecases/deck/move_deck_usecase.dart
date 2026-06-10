import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Moves a deck under a new folder
/// (`docs/contracts/usecase-contracts/deck.md` §MoveDeckUseCase).
///
/// All structural validation lives in [FolderRepository]: existence, sibling
/// duplicate checks, target folder mode, and the transactional folder-mode
/// updates.
class MoveDeckUseCase {
  const MoveDeckUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<Deck>> call({
    required DeckId id,
    required FolderId newParentId,
  }) => _repository.moveDeck(deckId: id, newParentId: newParentId);
}
