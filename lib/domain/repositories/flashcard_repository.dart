import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/ids.dart';

/// Flashcard data access contract
/// (`docs/contracts/repository-contracts/flashcard-repository.md`).
///
/// Implemented by `FlashcardRepositoryImpl` over Drift. Uses the existing
/// [Result] pattern (the contract's `Either<Failure, T>` is the fpdart target,
/// not yet adopted). This slice covers the Flashcard List read path plus the
/// V1 single-card mutations (delete, manual reorder).
abstract interface class FlashcardRepository {
  /// Streams a deck's Flashcard List read model: the deck, its folder
  /// breadcrumb, the (search-filtered) cards, and the deck's full card total.
  ///
  /// A missing/deleted deck yields `NotFoundFailure`. [searchTerm] filters the
  /// cards by front/back/example (`docs/wireframes/06-flashcard-list.md`); it
  /// never affects `totalCount`. [sort] drives the row order.
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    DeckId deckId, {
    String? searchTerm,
    ContentSortMode sort,
  });

  /// Deletes a single flashcard (its `flashcard_progress` row cascades via FK).
  ///
  /// Errors: `NotFoundFailure` (card missing), `StorageFailure`.
  Future<Result<void>> deleteFlashcard({required FlashcardId flashcardId});

  /// Persists a manual reorder of [deckId]'s cards: assigns `sort_order` by the
  /// position of each id in [orderedIds], in one transaction.
  ///
  /// Errors: `StorageFailure`.
  Future<Result<void>> reorderFlashcards({
    required DeckId deckId,
    required List<FlashcardId> orderedIds,
  });
}
