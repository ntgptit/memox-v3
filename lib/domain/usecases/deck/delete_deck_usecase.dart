import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Delete a deck and its dependent data. The transactional cascade (flashcards →
/// progress + tags via the schema FKs) and the source-folder mode revert live in
/// [FolderRepository.deleteDeck].
///
/// Highly destructive — the caller MUST confirm via the delete-confirm dialog
/// (`docs/wireframes/24-shared-dialogs.md`) before invoking.
///
/// Contract: `docs/contracts/usecase-contracts/deck.md` §DeleteDeckUseCase.
/// Decision row D3.
class DeleteDeckUseCase {
  const DeleteDeckUseCase({required this.repository});

  final FolderRepository repository;

  Future<Result<void>> call({required DeckId id}) =>
      repository.deleteDeck(deckId: id);
}
