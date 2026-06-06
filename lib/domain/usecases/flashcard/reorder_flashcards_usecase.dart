import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Persists a manual reorder of a deck's flashcards
/// (`docs/contracts/usecase-contracts/flashcard.md` §ReorderFlashcardsUseCase).
///
/// [orderedIds] is the full, post-drag order of the deck's cards; the repository
/// writes `sort_order` by list position in one transaction.
class ReorderFlashcardsUseCase {
  const ReorderFlashcardsUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<void>> call({
    required DeckId deckId,
    required List<FlashcardId> orderedIds,
  }) => _repository.reorderFlashcards(deckId: deckId, orderedIds: orderedIds);
}
