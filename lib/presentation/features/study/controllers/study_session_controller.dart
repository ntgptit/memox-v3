import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/presentation/features/study/controllers/study_session_review_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_controller.g.dart';

/// The current position within a loaded review session (WP-SR3).
///
/// Items are graded in order, so everything before [currentIndex] is answered:
/// [answeredCount] == [currentIndex], and the session is [isFinished] once the
/// index passes the last item. A fresh session starts at index 0; a resumed one
/// at the first unanswered item.
class StudySessionView {
  const StudySessionView({required this.review, required this.currentIndex});

  final StudySessionReview review;
  final int currentIndex;

  int get total => review.total;
  int get answeredCount => currentIndex.clamp(0, total);
  bool get isFinished => currentIndex >= total;

  /// The card to show, or `null` when the session is finished.
  StudySessionReviewItem? get currentItem =>
      isFinished ? null : review.items[currentIndex];

  StudySessionView copyWith({int? currentIndex}) => StudySessionView(
    review: review,
    currentIndex: currentIndex ?? this.currentIndex,
  );
}

/// Drives a Review session (WP-SR3): loads the review (via
/// `studySessionReviewProvider`), tracks the current card, and grades by swipe.
///
/// [grade] follows the wireframe order — it advances the card **immediately**
/// (optimistic), then records the terminal attempt in the background
/// (`RecordStudySessionAnswerUseCase`); the SRS box transition is applied only
/// at finalize (WP-SR5), so a not-yet-recorded answer simply leaves the session
/// resumable. WBS 4.5.3.
@riverpod
class StudySessionController extends _$StudySessionController {
  @override
  Future<StudySessionView> build(SessionId sessionId) async {
    final StudySessionReview review = await ref.watch(
      studySessionReviewProvider(sessionId).future,
    );
    return StudySessionView(
      review: review,
      currentIndex: review.firstUnansweredIndex ?? review.total,
    );
  }

  /// Grade the current card (swipe right → [AttemptResult.perfect], left →
  /// [AttemptResult.forgot]) and advance.
  Future<void> grade(AttemptResult result) async {
    final StudySessionView? view = state.asData?.value;
    if (view == null || view.isFinished) return;
    final StudySessionReviewItem item = view.review.items[view.currentIndex];
    // Advance the UI first (gesture → next card), then persist in the background.
    state = AsyncData<StudySessionView>(
      view.copyWith(currentIndex: view.currentIndex + 1),
    );
    final Result<void> recorded = await ref
        .read(recordStudySessionAnswerUseCaseProvider)
        .call(
          sessionId: sessionId,
          sessionItemId: item.sessionItemId,
          result: result,
          studyMode: StudyMode.review,
        );
    // A persist failure is **tolerated** in V1, not silently dropped: the item
    // simply stays unrecorded, so the session remains resumable and finalize
    // (WP-SR5) re-requires it. The explicit save-failed surface is deferred
    // (decision S38) — there is no app logger yet to trace to.
    if (recorded.failure != null) return;
  }

  /// Bury the current card until tomorrow (`BuryStudySessionCardUseCase`) and
  /// re-queue (WP-SR4b). The card is removed from the session by the use case,
  /// so invalidating the review reload excludes it and the controller rebuilds.
  Future<void> buryCurrent() => _cardAction(bury: true);

  /// Suspend the current card (`SuspendStudySessionCardUseCase`) and re-queue.
  Future<void> suspendCurrent() => _cardAction(bury: false);

  Future<void> _cardAction({required bool bury}) async {
    final StudySessionView? view = state.asData?.value;
    if (view == null || view.isFinished) return;
    final StudySessionReviewItem item = view.review.items[view.currentIndex];
    final Result<void> result = bury
        ? await ref
              .read(buryStudySessionCardUseCaseProvider)
              .call(sessionId: sessionId, flashcardId: item.flashcardId)
        : await ref
              .read(suspendStudySessionCardUseCaseProvider)
              .call(sessionId: sessionId, flashcardId: item.flashcardId);
    // Tolerated like grade: on failure the card simply stays in the queue.
    // The 5s undo toast (§undo-toast / WBS 4.11.3) is deferred — not wired here.
    if (result.failure != null) return;
    // Re-queue: the use case removed the session item, so the review reload now
    // excludes it; invalidating it rebuilds this controller from the new queue.
    ref.invalidate(studySessionReviewProvider(sessionId));
  }
}
