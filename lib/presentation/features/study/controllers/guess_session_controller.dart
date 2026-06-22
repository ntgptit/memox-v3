import 'dart:async';
import 'dart:math';

import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/app_motion.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/models/guess_option.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guess_session_controller.g.dart';

/// The current position in a Guess session + the option set for the shown card.
///
/// Cards are answered in order (like Review): everything before [currentIndex]
/// is answered, so [answeredCount] == [currentIndex] and the session is
/// [isFinished] once the index passes the last card. [options] is the
/// multiple-choice set for [currentItem] (empty when finished).
class GuessView {
  const GuessView({
    required this.review,
    required this.currentIndex,
    required this.options,
    this.selectedBack,
    this.finished = false,
  });

  final StudySessionReview review;
  final int currentIndex;
  final List<GuessOption> options;

  /// The back of the option the user picked for the current card — non-null once
  /// answered (the screen then reveals correct/wrong + the countdown footer). WP-SG2.
  final String? selectedBack;

  /// True once the last card is answered + advanced — the screen finalizes +
  /// routes to the result.
  final bool finished;

  int get total => review.total;
  int get answeredCount => currentIndex.clamp(0, total);
  bool get isFinished => currentIndex >= total;
  bool get revealed => selectedBack != null;
  StudySessionReviewItem? get currentItem =>
      isFinished ? null : review.items[currentIndex];

  GuessView copyWith({String? selectedBack, bool? finished}) => GuessView(
    review: review,
    currentIndex: currentIndex,
    options: options,
    selectedBack: selectedBack ?? this.selectedBack,
    finished: finished ?? this.finished,
  );
}

/// Drives a Guess session (WP-SG1): loads the review, tracks the current card,
/// and builds its multiple-choice option set via `GuessStudyModeStrategy`
/// (the correct back + distractors drawn from the session's other cards), and
/// (WP-SG2) grades a pick (binary record), reveals correct/wrong, then
/// auto-advances (the countdown timer) or finalizes the last card. WBS 4.5.7.
@riverpod
class GuessSessionController extends _$GuessSessionController {
  static const GuessStudyModeStrategy _strategy = GuessStudyModeStrategy();

  /// The pending auto-advance timer for the revealed card (cancelled if the
  /// user taps to skip, or on dispose).
  Timer? _advanceTimer;

  @override
  Future<GuessView> build(SessionId sessionId) async {
    ref.onDispose(() => _advanceTimer?.cancel());
    final StudySessionReview review = await ref.watch(
      studySessionReviewProvider(sessionId).future,
    );
    return _viewFor(
      review,
      review.firstUnansweredIndex ?? review.total,
      sessionId,
    );
  }

  GuessView _viewFor(
    StudySessionReview review,
    int index,
    SessionId sessionId,
  ) {
    if (index >= review.total) {
      return GuessView(
        review: review,
        currentIndex: index,
        options: const <GuessOption>[],
      );
    }
    final StudySessionReviewItem target = review.items[index];
    // The distractor pool is the session's other cards' backs.
    final List<({FlashcardId id, String back})> pool =
        <({FlashcardId id, String back})>[
          for (final StudySessionReviewItem item in review.items)
            if (item.flashcardId != target.flashcardId)
              (id: item.flashcardId, back: item.back),
        ];
    final List<GuessOption> options = _strategy.buildOptions(
      targetId: target.flashcardId,
      targetBack: target.back,
      pool: pool,
      // Seeded per card so the option order is stable (resume + golden).
      random: Random(sessionId.hashCode ^ (index + 1)),
    );
    return GuessView(review: review, currentIndex: index, options: options);
  }

  /// Answer the current card by picking [option] (WP-SG2): reveal correct/wrong,
  /// schedule the auto-advance countdown (0.8s correct / 1.5s wrong — wireframe
  /// `15`), then record the binary grade (correct → `perfect`, wrong → `forgot`)
  /// via `RecordStudySessionAnswerUseCase`. A second pick is ignored; the persist
  /// failure is tolerated like Review's grade (the session stays resumable).
  Future<void> grade(GuessOption option) async {
    final GuessView? view = state.asData?.value;
    if (view == null || view.isFinished || view.revealed) return;
    final StudySessionReviewItem? item = view.currentItem;
    if (item == null) return;
    // Reveal first (the user sees the result), then auto-advance + persist.
    state = AsyncData<GuessView>(view.copyWith(selectedBack: option.back));
    _scheduleAdvance(
      view.currentIndex,
      option.isCorrect
          ? AppMotion.guessRevealCorrect
          : AppMotion.guessRevealWrong,
    );
    final Result<void> recorded = await ref
        .read(recordStudySessionAnswerUseCaseProvider)
        .call(
          sessionId: sessionId,
          sessionItemId: item.sessionItemId,
          result: option.isCorrect
              ? AttemptResult.perfect
              : AttemptResult.forgot,
          studyMode: StudyMode.guess,
        );
    if (recorded.failure != null) return;
  }

  /// Auto-advance once the reveal countdown elapses, unless the user already
  /// advanced (tap-to-skip) or moved on — re-guarded by the still-revealed card
  /// index so a stale timer never skips a later card.
  void _scheduleAdvance(int gradedIndex, Duration delay) {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(delay, () {
      final GuessView? view = state.asData?.value;
      if (view == null || !view.revealed || view.currentIndex != gradedIndex) {
        return;
      }
      next();
    });
  }

  /// Advance to the next card after answering (WP-SG2) — the auto-advance timer
  /// fires this, and the countdown footer taps it to skip ahead. Rebuilds the
  /// next card's option set, or marks the view `finished` after the last card so
  /// the screen finalizes + routes to the result.
  void next() {
    _advanceTimer?.cancel();
    final GuessView? view = state.asData?.value;
    if (view == null || view.isFinished || !view.revealed) return;
    final int nextIndex = view.currentIndex + 1;
    if (nextIndex >= view.total) {
      state = AsyncData<GuessView>(view.copyWith(finished: true));
      return;
    }
    state = AsyncData<GuessView>(_viewFor(view.review, nextIndex, sessionId));
  }
}
