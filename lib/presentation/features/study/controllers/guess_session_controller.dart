import 'dart:math';

import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/models/guess_option.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/ids.dart';
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
  });

  final StudySessionReview review;
  final int currentIndex;
  final List<GuessOption> options;

  int get total => review.total;
  int get answeredCount => currentIndex.clamp(0, total);
  bool get isFinished => currentIndex >= total;
  StudySessionReviewItem? get currentItem =>
      isFinished ? null : review.items[currentIndex];
}

/// Drives a Guess session (WP-SG1): loads the review, tracks the current card,
/// and builds its multiple-choice option set via `GuessStudyModeStrategy`
/// (the correct back + distractors drawn from the session's other cards). The
/// select-to-grade + advance + finalize interaction lands in WP-SG2. WBS 4.5.7.
@riverpod
class GuessSessionController extends _$GuessSessionController {
  static const GuessStudyModeStrategy _strategy = GuessStudyModeStrategy();

  @override
  Future<GuessView> build(SessionId sessionId) async {
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
}
