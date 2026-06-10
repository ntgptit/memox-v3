import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/tag/tag_validator.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
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
    FlashcardStatusFilter statusFilter = FlashcardStatusFilter.all,
    List<String> selectedTags = const <String>[],
    DateTime? now,
  }) {
    final Object normalizedTags = _normalizeTags(selectedTags);
    if (normalizedTags is _InvalidTags) {
      return Stream<Result<FlashcardListDetail>>.value(
        Result<FlashcardListDetail>.err(normalizedTags.failure),
      );
    }

    return _repository.watchFlashcardList(
      deckId,
      searchTerm: searchTerm,
      sort: sort,
      statusFilter: statusFilter,
      selectedTags: normalizedTags as List<String>,
      now: now,
    );
  }

  static Object _normalizeTags(List<String> tags) {
    final Set<String> seen = <String>{};
    final List<String> normalized = <String>[];
    for (final String tag in tags) {
      final Failure? validationFailure = TagValidator.validate(tag);
      if (validationFailure != null) {
        return _InvalidTags(validationFailure);
      }
      final String normalizedTag = TagValidator.storageValue(tag);
      if (seen.add(normalizedTag)) {
        normalized.add(normalizedTag);
      }
    }
    return normalized;
  }
}

final class _InvalidTags {
  const _InvalidTags(this.failure);

  final Failure failure;
}
