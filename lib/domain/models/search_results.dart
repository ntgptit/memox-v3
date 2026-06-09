import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'search_results.freezed.dart';

/// A folder match in global Library search (`docs/wireframes/11-library-search.md`).
@freezed
abstract class FolderSearchHit with _$FolderSearchHit {
  const factory FolderSearchHit({required FolderId id, required String name}) =
      _FolderSearchHit;
}

/// A deck match in global Library search.
@freezed
abstract class DeckSearchHit with _$DeckSearchHit {
  const factory DeckSearchHit({required DeckId id, required String name}) =
      _DeckSearchHit;
}

/// A flashcard match in global Library search. [deckId] is the owning deck the
/// result navigates into (per-card scroll/select is a Future refinement).
@freezed
abstract class FlashcardSearchHit with _$FlashcardSearchHit {
  const factory FlashcardSearchHit({
    required FlashcardId id,
    required DeckId deckId,
    required String front,
    required String back,
  }) = _FlashcardSearchHit;
}

/// Grouped global-search read model (`docs/contracts/usecase-contracts/search.md`).
///
/// V1 promoted scope covers three sections — folders, decks, flashcards. The
/// tags section is deferred until the tag subsystem ships. Each section is
/// capped (see `GlobalSearchUseCase.sectionCap`); the `*Total` fields carry the
/// full match count so the UI can show a "+N more" affordance.
@freezed
abstract class SearchResults with _$SearchResults {
  const factory SearchResults({
    required List<FolderSearchHit> folders,
    required List<DeckSearchHit> decks,
    required List<FlashcardSearchHit> flashcards,
    required int folderTotal,
    required int deckTotal,
    required int flashcardTotal,
  }) = _SearchResults;

  const SearchResults._();

  /// No matches in any section.
  bool get isEmpty => folders.isEmpty && decks.isEmpty && flashcards.isEmpty;

  /// Total matches across every section (un-capped).
  int get totalCount => folderTotal + deckTotal + flashcardTotal;
}
