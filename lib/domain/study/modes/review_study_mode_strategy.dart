import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Review mode (V1): both sides rendered together, **swipe to grade**.
///
/// There is no reveal step (both sides are already visible), so
/// [usesRevealSelfGradeFlow] stays `false`; the binary outcome comes from the
/// swipe direction: right = pass → [AttemptResult.perfect], left = fail →
/// [AttemptResult.forgot] (decision row S46).
final class ReviewStudyModeStrategy extends BinaryGradeStudyModeStrategy {
  const ReviewStudyModeStrategy() : super(StudyMode.review);

  @override
  AttemptResult mapForgotAction() => AttemptResult.forgot;

  @override
  AttemptResult mapGotItAction() => AttemptResult.perfect;
}
