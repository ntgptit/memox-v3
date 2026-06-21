import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flashcard_list_viewmodel.g.dart';

/// Streams the flashcard-list read model (deck + breadcrumb + cards +
/// totalCount) for [deckId], wrapped in a [Result] so a missing deck surfaces as
/// an error. Re-subscribes with the active search term (server-side front/back
/// filter) so search results stay in sync. WBS 3.4.2.
@riverpod
Stream<Result<FlashcardListDetail>> flashcardListStream(
  Ref ref,
  String deckId,
) {
  final String term = StringUtils.trimmed(
    ref.watch(flashcardSearchQueryProvider(deckId)),
  );
  return ref
      .watch(watchFlashcardListUseCaseProvider)
      .call(deckId, searchTerm: term.isEmpty ? null : term);
}

/// The active inline-search term for one flashcard-list screen (scope-local),
/// keyed by [deckId]. WBS 3.4.2.
@riverpod
class FlashcardSearchQuery extends _$FlashcardSearchQuery {
  @override
  String build(String deckId) => '';

  void setTerm(String term) => state = term;

  void clear() => state = '';
}

/// Whether one flashcard-list screen is in **reorder mode** (deck overflow →
/// Reorder cards). Keyed by [deckId]. WBS 2.14.2.
@riverpod
class FlashcardReorderActive extends _$FlashcardReorderActive {
  @override
  bool build(String deckId) => false;

  void enter() => state = true;

  void exit() => state = false;
}
