import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Move a deck into another folder. Destination content-mode validation,
/// duplicate-name rejection, sort-order append, destination lock, source
/// unlock, and the no-op on the same folder live in
/// [FolderRepository.moveDeck].
///
/// Contract: `docs/contracts/usecase-contracts/deck.md` §MoveDeckUseCase.
/// Decision rows D9, D10.
class MoveDeckUseCase {
  const MoveDeckUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<Deck>> call({
    required DeckId id,
    required FolderId newParentId,
  }) => repository.moveDeck(deckId: id, newFolderId: newParentId);
}
