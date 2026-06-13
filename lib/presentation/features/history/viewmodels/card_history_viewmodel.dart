import 'dart:async';

import 'package:memox/app/di/card_history_providers.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_history_viewmodel.g.dart';

/// Timeline filter (the "All events" pill). `all` shows attempts + lifecycle;
/// `reviews` shows graded attempts only; `lifecycle` shows create/edit/audio.
enum CardHistoryFilter { all, reviews, lifecycle }

extension CardHistoryFilterX on CardHistoryFilter {
  bool matches(CardHistoryEvent event) => switch (this) {
    CardHistoryFilter.all => true,
    CardHistoryFilter.reviews => event is CardHistoryAttemptEvent,
    CardHistoryFilter.lifecycle => event is CardHistoryLifecycleEvent,
  };
}

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

/// The full per-card activity feed (attempts + lifecycle events, newest first).
@riverpod
Future<CardHistoryTimeline> cardHistoryTimeline(
  Ref ref,
  String flashcardId,
) async {
  final Result<CardHistoryTimeline> result = await ref
      .watch(getCardTimelineUseCaseProvider)
      .call(flashcardId: flashcardId);
  return result.fold(
    // ignore: only_throw_errors -- reason: Riverpod surfaces repository Failure as AsyncError.
    (Failure failure) => throw failure,
    (CardHistoryTimeline timeline) => timeline,
  );
}

/// Selected timeline filter, scoped per flashcard.
@riverpod
class CardHistoryFilterController extends _$CardHistoryFilterController {
  @override
  CardHistoryFilter build(String flashcardId) => CardHistoryFilter.all;

  void select(CardHistoryFilter filter) => state = filter;
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
