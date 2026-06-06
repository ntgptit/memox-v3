import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/ids.dart';

/// Streams a deck's Flashcard List (`docs/wireframes/06-flashcard-list.md`,
/// `docs/contracts/usecase-contracts/flashcard.md` §WatchFlashcardListUseCase).
///
/// Thin orchestration over [FlashcardRepository]; the viewmodel depends on this,
/// never on the repository directly.
class WatchFlashcardListUseCase {
  const WatchFlashcardListUseCase(this._repository);

  final FlashcardRepository _repository;

  Stream<Result<FlashcardListDetail>> call(
    DeckId deckId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
  }) => _repository.watchFlashcardList(
    deckId,
    searchTerm: searchTerm,
    sort: sort,
  );
}
