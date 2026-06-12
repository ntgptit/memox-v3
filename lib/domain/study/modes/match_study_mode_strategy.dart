import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Match mode does not use the reveal/self-grade flow.
class MatchStudyModeStrategy extends StudyModeStrategy {
  const MatchStudyModeStrategy() : super(StudyMode.match);

  @override
  bool get usesRevealSelfGradeFlow => false;

  @override
  AttemptResult mapForgotAction() => throw UnsupportedError(
    'Study mode ${mode.name} does not support the V1 reveal/self-grade flow.',
  );

  @override
  AttemptResult mapGotItAction() => throw UnsupportedError(
    'Study mode ${mode.name} does not support the V1 reveal/self-grade flow.',
  );
}
