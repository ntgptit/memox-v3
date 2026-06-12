import 'dart:async';

import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flashcard_list_viewmodel.g.dart';

/// Per-deck toolbar state: inline search term, sort mode, and the ephemeral
/// reorder-mode toggle. Reorder is only meaningful under manual sort.
class FlashcardListToolbarState {
  const FlashcardListToolbarState({
    this.searchTerm = '',
    this.sort = ContentSortMode.manual,
    this.isReordering = false,
  });

  final String searchTerm;
  final ContentSortMode sort;
  final bool isReordering;

  bool get isSearching => StringUtils.trimmed(searchTerm).isNotEmpty;

  FlashcardListToolbarState copyWith({
    String? searchTerm,
    ContentSortMode? sort,
    bool? isReordering,
  }) => FlashcardListToolbarState(
    searchTerm: searchTerm ?? this.searchTerm,
    sort: sort ?? this.sort,
    isReordering: isReordering ?? this.isReordering,
  );
}

/// Ephemeral search / sort / reorder selections, scoped per deck so stacked
/// flashcard-list screens don't share state.
@riverpod
class FlashcardListToolbar extends _$FlashcardListToolbar {
  @override
  FlashcardListToolbarState build(String deckId) =>
      const FlashcardListToolbarState();

  void setSearch(String term) => state = state.copyWith(searchTerm: term);

  void clearSearch() => state = state.copyWith(searchTerm: '');

  /// Reorder requires manual sort; entering it forces [ContentSortMode.manual].
  void startReorder() =>
      state = state.copyWith(sort: ContentSortMode.manual, isReordering: true);

  void stopReorder() => state = state.copyWith(isReordering: false);
}

/// Streams a deck's Flashcard List, reacting to its toolbar. `keepAlive`
/// (deliberate lifecycle, per `memox.state_management.query_provider_keep_alive`) so
/// popping back does not refetch-flicker. Unwraps the [Result]: a [Failure]
/// (e.g. NotFound) surfaces as `AsyncError` for the screen's error state.
@Riverpod(keepAlive: true)
Stream<FlashcardListDetail> flashcardListQuery(Ref ref, String deckId) {
  final FlashcardListToolbarState toolbar = ref.watch(
    flashcardListToolbarProvider(deckId),
  );
  final useCase = ref.watch(watchFlashcardListUseCaseProvider);
  return useCase
      .call(deckId, searchTerm: toolbar.searchTerm, sort: toolbar.sort)
      .map(
        (Result<FlashcardListDetail> result) => result.fold(
          // ignore: only_throw_errors -- reason: Riverpod stream query surfaces repository Failure as AsyncError.
          (Failure failure) => throw failure,
          (FlashcardListDetail detail) => detail,
        ),
      );
}

/// Executes flashcard-list mutations (delete card, reorder cards, delete deck).
/// The Drift content-revision stream refreshes the list automatically on
/// success, so there is no manual state push.
@riverpod
class FlashcardListController extends _$FlashcardListController {
  @override
  FutureOr<void> build() {}

  void _setSettledState(Result<void> result) {
    if (!ref.mounted) {
      return;
    }
    state = result.fold(
      (Failure failure) => AsyncValue<void>.error(failure, StackTrace.current),
      (_) => const AsyncValue<void>.data(null),
    );
  }

  Future<Result<void>> deleteFlashcard(String flashcardId) async {
    state = const AsyncValue<void>.loading();
    final Result<void> result = await ref
        .read(deleteFlashcardUseCaseProvider)
        .call(flashcardId);
    _setSettledState(result);
    return result;
  }

  Future<Result<void>> reorderFlashcards({
    required String deckId,
    required List<String> orderedIds,
  }) async {
    state = const AsyncValue<void>.loading();
    final Result<void> result = await ref
        .read(reorderFlashcardsUseCaseProvider)
        .call(deckId: deckId, orderedIds: orderedIds);
    _setSettledState(result);
    return result;
  }

  Future<Result<void>> deleteDeck(String deckId) async {
    state = const AsyncValue<void>.loading();
    final Result<void> result = await ref
        .read(deleteDeckUseCaseProvider)
        .call(deckId);
    _setSettledState(result);
    return result;
  }
}
