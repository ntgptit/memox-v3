import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recall_session_controller.g.dart';

/// The current position in a Recall session + whether the back is revealed.
///
/// Cards are answered in order (like Review): everything before [currentIndex]
/// is answered, so [answeredCount] == [currentIndex] and the session is
/// [isFinished] once the index passes the last card. [revealed] flips on
/// **Show answer** (the hidden placeholder → the back + the grade row). WP-RC1.
class RecallView {
  const RecallView({
    required this.review,
    required this.currentIndex,
    this.revealed = false,
    this.finished = false,
  });

  final StudySessionReview review;
  final int currentIndex;

  /// True once the user tapped **Show answer** for the current card — the back
  /// and the Missed / Got it grade row replace the hidden placeholder + CTA.
  final bool revealed;

  /// True once the last card is graded — the screen finalizes + routes to the
  /// result.
  final bool finished;

  int get total => review.total;
  int get answeredCount => currentIndex.clamp(0, total);
  bool get isFinished => currentIndex >= total;
  StudySessionReviewItem? get currentItem =>
      isFinished ? null : review.items[currentIndex];

  RecallView copyWith({bool? revealed, bool? finished}) => RecallView(
    review: review,
    currentIndex: currentIndex,
    revealed: revealed ?? this.revealed,
    finished: finished ?? this.finished,
  );
}

/// Drives a Recall session (WP-RC1) — the flip-card self-grade family: show the
/// front, reveal the back on demand, then record a **binary** self-grade
/// (Got it → `perfect`, Missed → `forgot`) via `RecordStudySessionAnswerUseCase`
/// and advance. The grade granularity is binary per decision S66 (the `recovered`
/// result is Fill-only). The Show-answer countdown + auto-reveal-on-timeout
/// (S63/S64) + edit affordance (S65) are deferred. WBS 4.5.9.
@riverpod
class RecallSessionController extends _$RecallSessionController {
  static const RecallStudyModeStrategy _strategy = RecallStudyModeStrategy();

  @override
  Future<RecallView> build(SessionId sessionId) async {
    final StudySessionReview review = await ref.watch(
      studySessionReviewProvider(sessionId).future,
    );
    return RecallView(
      review: review,
      currentIndex: review.firstUnansweredIndex ?? review.total,
    );
  }

  /// Reveal the current card's back (the **Show answer** CTA). A no-op once
  /// already revealed or finished.
  void reveal() {
    final RecallView? view = state.asData?.value;
    if (view == null || view.isFinished || view.revealed) return;
    state = AsyncData<RecallView>(view.copyWith(revealed: true));
  }

  /// Self-grade the revealed card (WP-RC1): map the Got-it / Missed action to a
  /// binary `AttemptResult` via the strategy, record it (`studyMode: recall`),
  /// then advance — or mark the last card `finished` so the screen finalizes +
  /// routes to the result. Grading before reveal is ignored. The persist failure
  /// is tolerated like Review's grade (the session stays resumable).
  Future<void> grade({required bool gotIt}) async {
    final RecallView? view = state.asData?.value;
    if (view == null || view.isFinished || !view.revealed) return;
    final StudySessionReviewItem? item = view.currentItem;
    if (item == null) return;
    final AttemptResult result = gotIt
        ? _strategy.mapGotItAction()
        : _strategy.mapForgotAction();
    // Advance the UI first (grade → next card), then persist in the background.
    final int nextIndex = view.currentIndex + 1;
    state = nextIndex >= view.total
        ? AsyncData<RecallView>(view.copyWith(finished: true))
        : AsyncData<RecallView>(
            RecallView(review: view.review, currentIndex: nextIndex),
          );
    final Result<void> recorded = await ref
        .read(recordStudySessionAnswerUseCaseProvider)
        .call(
          sessionId: sessionId,
          sessionItemId: item.sessionItemId,
          result: result,
          studyMode: StudyMode.recall,
        );
    if (recorded.failure != null) return;
  }
}
