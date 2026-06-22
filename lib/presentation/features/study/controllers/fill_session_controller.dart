import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fill_session_controller.g.dart';

/// The per-card phase of a Fill session: typing the answer, or the post-check
/// feedback (a clean match → [correct]; a mismatch → [wrong]).
enum FillPhase { typing, correct, wrong }

/// The current position in a Fill session + the current card's check phase.
///
/// Cards are answered in order (like Review): everything before [currentIndex]
/// is answered, so [answeredCount] == [currentIndex] and the session is
/// [isFinished] once the index passes the last card. [phase] drives the screen
/// (typing field → correct/wrong feedback); [result] is the held grade once
/// checked, recorded on advance. WP-FI1.
class FillView {
  const FillView({
    required this.review,
    required this.currentIndex,
    this.phase = FillPhase.typing,
    this.result,
    this.hintRevealed = 0,
    this.finished = false,
  });

  final StudySessionReview review;
  final int currentIndex;
  final FillPhase phase;

  /// The grade computed by the last check — held until the card advances, then
  /// persisted. Null while typing. `perfect` on a clean match, otherwise `forgot`;
  /// `recovered` once **Mark correct** overrides a wrong answer (WP-FI2a) or a
  /// **Hint** taints a clean match (WP-FI2b).
  final AttemptResult? result;

  /// How many leading characters of the front the Hint has revealed for the
  /// current card (WP-FI2b). Any reveal taints the grade — a clean match caps at
  /// `recovered` instead of `perfect` (decision S69). Resets per card.
  final int hintRevealed;

  /// True once the last card is graded + advanced — the screen finalizes +
  /// routes to the result.
  final bool finished;

  int get total => review.total;
  int get answeredCount => currentIndex.clamp(0, total);
  bool get isFinished => currentIndex >= total;
  bool get hintUsed => hintRevealed > 0;
  StudySessionReviewItem? get currentItem =>
      isFinished ? null : review.items[currentIndex];
}

/// Drives a Fill session (WP-FI1) — the typed-production mode: show the back as a
/// hint, type the front, **Check** grades a strict trim-only match via
/// `FillStudyModeStrategy.evaluate` (`studyMode: fill`) → `perfect` (clean match)
/// or `forgot` (mismatch). Correct → advance; wrong → show the answer + Retry
/// (re-type) / Next (advance). The last card finalizes → the result. The Hint
/// char-reveal (→ `recovered`), the auto-advance countdown, and the edit / TTS
/// affordances are deferred (WP-FI2); **Mark correct → `recovered` is built
/// (WP-FI2a, see [markCorrect]).** WBS 4.5.9.
@riverpod
class FillSessionController extends _$FillSessionController {
  static const FillStudyModeStrategy _strategy = FillStudyModeStrategy();

  @override
  Future<FillView> build(SessionId sessionId) async {
    final StudySessionReview review = await ref.watch(
      studySessionReviewProvider(sessionId).future,
    );
    return FillView(
      review: review,
      currentIndex: review.firstUnansweredIndex ?? review.total,
    );
  }

  /// Grade the typed [input] against the current card's front (the documented
  /// strict trim-only match — `docs/wireframes/17-study-session-fill.md`). A
  /// clean match → `perfect` (or `recovered` when a Hint tainted the card,
  /// WP-FI2b), otherwise `forgot` (the answer is shown). The `recovered`-via-
  /// override also comes from [markCorrect] (WP-FI2a). Empty input / non-typing
  /// phase is ignored.
  void check(String input) {
    final FillView? view = state.asData?.value;
    if (view == null || view.isFinished || view.phase != FillPhase.typing) {
      return;
    }
    final StudySessionReviewItem? item = view.currentItem;
    if (item == null || StringUtils.trimmed(input).isEmpty) return;
    final AttemptResult result = _strategy.evaluate(
      input: input,
      expected: item.front,
      hintUsed: view.hintUsed,
    );
    state = AsyncData<FillView>(
      FillView(
        review: view.review,
        currentIndex: view.currentIndex,
        phase: result == AttemptResult.forgot
            ? FillPhase.wrong
            : FillPhase.correct,
        result: result,
        hintRevealed: view.hintRevealed,
      ),
    );
  }

  /// Reveal one more leading character of the front as a Hint (WP-FI2b, S69):
  /// up to half the front length. Any reveal taints the grade — a subsequent
  /// clean match caps at `recovered` (`evaluate(hintUsed: true)`). A no-op once
  /// the cap is reached or outside the typing phase.
  void hint() {
    final FillView? view = state.asData?.value;
    if (view == null || view.phase != FillPhase.typing) return;
    final StudySessionReviewItem? item = view.currentItem;
    if (item == null) return;
    final int maxHint = StringUtils.trimmed(item.front).length ~/ 2;
    if (view.hintRevealed >= maxHint) return;
    state = AsyncData<FillView>(
      FillView(
        review: view.review,
        currentIndex: view.currentIndex,
        hintRevealed: view.hintRevealed + 1,
      ),
    );
  }

  /// Return to typing from the wrong-feedback state (the Retry affordance):
  /// clear the held result so the user re-types. The **Hint taint is retained**
  /// (wireframe `17` §States — a re-type after a hint still caps at `recovered`).
  /// One retry per card is enforced by the screen clearing its input; the BE
  /// still persists one terminal attempt on advance.
  void retry() {
    final FillView? view = state.asData?.value;
    if (view == null || view.phase != FillPhase.wrong) return;
    state = AsyncData<FillView>(
      FillView(
        review: view.review,
        currentIndex: view.currentIndex,
        hintRevealed: view.hintRevealed,
      ),
    );
  }

  /// Override a wrong answer to `recovered` (the **Mark correct** affordance —
  /// decision S72 / WP-FI2a): the documented `evaluate(markCorrect: true)`
  /// outcome on a mismatch. Transition to the correct-feedback state holding
  /// `recovered`; the card records it on advance (never demoted to `forgot`).
  void markCorrect() {
    final FillView? view = state.asData?.value;
    if (view == null || view.phase != FillPhase.wrong) return;
    state = AsyncData<FillView>(
      FillView(
        review: view.review,
        currentIndex: view.currentIndex,
        phase: FillPhase.correct,
        result: AttemptResult.recovered,
      ),
    );
  }

  /// Record the checked card's held grade (`studyMode: fill`) and advance — or
  /// mark the last card `finished` so the screen finalizes + routes. A no-op
  /// before the card has been checked. The persist failure is tolerated like
  /// Review's grade (the session stays resumable).
  Future<void> next() async {
    final FillView? view = state.asData?.value;
    if (view == null || view.isFinished || view.phase == FillPhase.typing) {
      return;
    }
    final StudySessionReviewItem? item = view.currentItem;
    final AttemptResult? result = view.result;
    if (item == null || result == null) return;
    final int nextIndex = view.currentIndex + 1;
    state = nextIndex >= view.total
        ? AsyncData<FillView>(
            FillView(
              review: view.review,
              currentIndex: view.currentIndex,
              phase: view.phase,
              result: result,
              finished: true,
            ),
          )
        : AsyncData<FillView>(
            FillView(review: view.review, currentIndex: nextIndex),
          );
    final Result<void> recorded = await ref
        .read(recordStudySessionAnswerUseCaseProvider)
        .call(
          sessionId: sessionId,
          sessionItemId: item.sessionItemId,
          result: result,
          studyMode: StudyMode.fill,
        );
    if (recorded.failure != null) return;
  }
}
