import 'dart:async';

import 'package:memox/app/di/card_history_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_history_viewmodel.g.dart';

/// Card History header (preview + SRS state + lifetime counters). Unwraps the
/// repository [Result]: a [Failure] surfaces as `AsyncError` for the screen's
/// error / card-not-found state.
@riverpod
Future<CardHistoryHeader> cardHistoryHeader(Ref ref, String flashcardId) async {
  final Result<CardHistoryHeader> result = await ref
      .watch(getCardHistoryHeaderUseCaseProvider)
      .call(flashcardId: flashcardId);
  return result.fold(
    // ignore: only_throw_errors -- reason: Riverpod surfaces repository Failure as AsyncError.
    (Failure failure) => throw failure,
    (CardHistoryHeader header) => header,
  );
}

/// Paginated timeline state: loaded attempts (newest first), the next-page
/// cursor, and inline load-more status.
class CardHistoryTimelineState {
  const CardHistoryTimelineState({
    required this.attempts,
    required this.nextCursor,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<CardHistoryAttempt> attempts;
  final CardHistoryCursor? nextCursor;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  bool get hasMore => nextCursor != null;
  bool get isEmpty => attempts.isEmpty;

  CardHistoryTimelineState copyWith({
    List<CardHistoryAttempt>? attempts,
    CardHistoryCursor? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) => CardHistoryTimelineState(
    attempts: attempts ?? this.attempts,
    nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );
}

/// Loads the first attempt page on build and appends further pages on demand.
/// First-page failures surface as `AsyncError`; load-more failures are kept
/// inline so the already-loaded timeline stays visible.
@riverpod
class CardHistoryTimeline extends _$CardHistoryTimeline {
  @override
  Future<CardHistoryTimelineState> build(String flashcardId) async {
    final Result<CardHistoryPage> result = await ref
        .watch(getCardHistoryPageUseCaseProvider)
        .call(flashcardId: flashcardId);
    return result.fold(
      // ignore: only_throw_errors -- reason: Riverpod surfaces repository Failure as AsyncError.
      (Failure failure) => throw failure,
      (CardHistoryPage page) => CardHistoryTimelineState(
        attempts: page.attempts,
        nextCursor: page.nextCursor,
      ),
    );
  }

  Future<void> loadMore() async {
    final CardHistoryTimelineState? current = state.asData?.value;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }
    state = AsyncData<CardHistoryTimelineState>(
      current.copyWith(isLoadingMore: true, loadMoreFailed: false),
    );
    final Result<CardHistoryPage> result = await ref
        .read(getCardHistoryPageUseCaseProvider)
        .call(flashcardId: flashcardId, before: current.nextCursor);
    if (!ref.mounted) {
      return;
    }
    state = AsyncData<CardHistoryTimelineState>(
      result.fold(
        (Failure _) =>
            current.copyWith(isLoadingMore: false, loadMoreFailed: true),
        (CardHistoryPage page) => current.copyWith(
          attempts: <CardHistoryAttempt>[...current.attempts, ...page.attempts],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
          loadMoreFailed: false,
        ),
      ),
    );
  }
}

/// Executes Card History mutations (reset progress, delete card). The screen
/// refreshes the header/timeline after a successful reset.
@riverpod
class CardHistoryController extends _$CardHistoryController {
  @override
  FutureOr<void> build() {}

  Future<Result<void>> resetProgress(String flashcardId) async {
    state = const AsyncValue<void>.loading();
    final Result<void> result = await ref
        .read(resetFlashcardProgressUseCaseProvider)
        .call(flashcardId: flashcardId);
    _settle(result);
    if (result.isOk && ref.mounted) {
      ref
        ..invalidate(cardHistoryHeaderProvider(flashcardId))
        ..invalidate(cardHistoryTimelineProvider(flashcardId));
    }
    return result;
  }

  void _settle(Result<void> result) {
    if (!ref.mounted) {
      return;
    }
    state = result.fold(
      (Failure failure) => AsyncValue<void>.error(failure, StackTrace.current),
      (_) => const AsyncValue<void>.data(null),
    );
  }
}
