import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Deletes a deck and all flashcards inside it
/// (`docs/contracts/usecase-contracts/deck.md` §DeleteDeckUseCase).
///
/// Backed by [FolderRepository] (which owns deck create/delete + the parent
/// `content_mode` revert), mirroring [CreateDeckUseCase]. The confirm dialog is
/// the presentation layer's responsibility.
class DeleteDeckUseCase {
  const DeleteDeckUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<void>> call(DeckId deckId) =>
      _repository.deleteDeck(deckId: deckId);
}
