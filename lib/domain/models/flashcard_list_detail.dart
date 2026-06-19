import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/folder.dart';

part 'flashcard_list_detail.freezed.dart';

/// The Flashcard-list read model — the deck being viewed, its folder breadcrumb
/// path, the (optionally search-filtered) cards, and the deck's full card count.
///
/// - [deck] — the deck whose cards are listed.
/// - [breadcrumb] — ancestor folder chain root → leaf for the path header.
/// - [cards] — the deck's flashcards in `sort_order`, filtered by the search
///   term when one is supplied.
/// - [totalCount] — the deck's full card count, **independent of the search
///   term**, so the UI can tell empty-deck (`totalCount == 0`) apart from
///   no-results-on-search (`cards.isEmpty && totalCount > 0`).
///
/// See `docs/contracts/usecase-contracts/flashcard.md` §WatchFlashcardListUseCase
/// and `docs/wireframes/06-flashcard-list.md`.
@freezed
sealed class FlashcardListDetail with _$FlashcardListDetail {
  const factory FlashcardListDetail({
    required Deck deck,
    required List<Folder> breadcrumb,
    required List<Flashcard> cards,
    required int totalCount,
  }) = _FlashcardListDetail;
}
