import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Persist a manual card order within [deckId]. [orderedIds] must be the full
/// post-drag set of the deck's cards; the full-list validation and the
/// transactional `sort_order` write live in
/// [FlashcardRepository.reorderFlashcards].
///
/// Contract: `docs/contracts/usecase-contracts/flashcard.md` §ReorderFlashcardsUseCase.
/// Decision rows C33, C34 (`docs/decision-tables/flashcard.md`).
class ReorderFlashcardsUseCase {
  const ReorderFlashcardsUseCase({required this.repository});

  final FlashcardRepository repository;

  Future<Result<void>> call({
    required DeckId deckId,
    required List<FlashcardId> orderedIds,
  }) => repository.reorderFlashcards(deckId: deckId, orderedIds: orderedIds);
}
