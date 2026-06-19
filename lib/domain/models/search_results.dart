import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';

part 'search_results.freezed.dart';

/// Grouped global-search read model (WBS 3.5.1).
///
/// Carries up to `GlobalSearchUseCase.sectionCap` items per section plus the
/// un-capped per-section total so the UI can render a "+N more" affordance. The
/// Tags section is Future (deferred until the tag subsystem ships). See
/// `docs/business/search/global-search.md` and
/// `docs/contracts/usecase-contracts/search.md`.
@freezed
sealed class SearchResults with _$SearchResults {
  const factory SearchResults({
    @Default(<Folder>[]) List<Folder> folders,
    @Default(<Deck>[]) List<Deck> decks,
    @Default(<Flashcard>[]) List<Flashcard> flashcards,
    @Default(0) int folderTotal,
    @Default(0) int deckTotal,
    @Default(0) int flashcardTotal,
  }) = _SearchResults;
  const SearchResults._();

  /// True when every section is empty.
  bool get isEmpty => folders.isEmpty && decks.isEmpty && flashcards.isEmpty;

  /// Total shown across all sections (capped counts, not the totals).
  int get shownCount => folders.length + decks.length + flashcards.length;

  /// Total matches across all sections (un-capped).
  int get totalCount => folderTotal + deckTotal + flashcardTotal;
}
