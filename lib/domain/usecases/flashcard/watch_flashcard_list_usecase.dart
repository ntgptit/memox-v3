import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
import 'package:memox/domain/types/ids.dart';

/// Watch the flashcard-list read model for a deck (deck + breadcrumb + cards +
/// `totalCount`), with an optional front/back search term, a multi-select AND
/// [tags] filter, and a [status] filter (active/due/suspended/buried). Stream
/// composition, search/tag/status filtering, and the missing-deck guard live in
/// [FlashcardRepository.watchFlashcardList].
///
/// Contract: `docs/contracts/usecase-contracts/flashcard.md` §WatchFlashcardListUseCase.
/// Decision rows C35, C36, C37, C38, C39 (`docs/decision-tables/flashcard.md`).
class WatchFlashcardListUseCase {
  const WatchFlashcardListUseCase({required this.repository});

  final FlashcardRepository repository;

  Stream<Result<FlashcardListDetail>> call(
    DeckId deckId, {
    String? searchTerm,
    List<TagName> tags = const <TagName>[],
    FlashcardStatusFilter status = FlashcardStatusFilter.all,
    ContentSortMode sort = ContentSortMode.manual,
  }) => repository.watchFlashcardList(
    deckId,
    searchTerm: searchTerm,
    tags: tags,
    status: status,
    sort: sort,
  );
}
