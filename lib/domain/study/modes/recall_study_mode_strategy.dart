import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Recall-mode V1 strategy: reveal, then self-grade.
final class RecallStudyModeStrategy extends StudyModeStrategy {
  const RecallStudyModeStrategy() : super(StudyMode.recall);

  @override
  bool get usesRevealSelfGradeFlow => true;

  @override
  AttemptResult mapForgotAction() => AttemptResult.forgot;

  @override
  AttemptResult mapGotItAction() => AttemptResult.perfect;
}
