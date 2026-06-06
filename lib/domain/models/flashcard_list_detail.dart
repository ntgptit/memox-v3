import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/folder_detail.dart';

part 'flashcard_list_detail.freezed.dart';

/// Flashcard List read model (`docs/wireframes/06-flashcard-list.md`).
///
/// Carries the owning [deck], the folder [breadcrumb] chain (Library root → the
/// deck's parent folder), the (search-filtered) [cards], and [totalCount] — the
/// deck's full card count **regardless of any active search term**. The screen
/// uses [totalCount] to tell the empty-deck state (`totalCount == 0`) apart from
/// no-results-on-search (`cards.isEmpty && totalCount > 0`).
@freezed
abstract class FlashcardListDetail with _$FlashcardListDetail {
  const factory FlashcardListDetail({
    required Deck deck,
    required List<FolderBreadcrumbSegment> breadcrumb,
    required List<Flashcard> cards,
    required int totalCount,
  }) = _FlashcardListDetail;
}
