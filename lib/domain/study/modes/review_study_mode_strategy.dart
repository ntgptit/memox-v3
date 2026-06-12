import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Review-mode strategy: both sides visible, swipe to grade.
final class ReviewStudyModeStrategy extends StudyModeStrategy {
  const ReviewStudyModeStrategy() : super(StudyMode.review);

  @override
  bool get usesRevealSelfGradeFlow => false;

  @override
  AttemptResult mapForgotAction() => AttemptResult.forgot;

  @override
  AttemptResult mapGotItAction() => AttemptResult.perfect;
}
