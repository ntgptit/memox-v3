import 'package:memox/domain/study/fill/fill_answer_evaluator.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Fill-mode strategy: strict typed front production.
final class FillStudyModeStrategy extends StudyModeStrategy {
  const FillStudyModeStrategy() : super(StudyMode.fill);

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

  FillAnswerEvaluation evaluateAnswer({
    required String typedInput,
    required String expectedFront,
    required bool hintUsed,
    bool overrideApplied = false,
  }) => FillAnswerEvaluator.evaluate(
    typedInput: typedInput,
    expectedFront: expectedFront,
    hintUsed: hintUsed,
    overrideApplied: overrideApplied,
  );

  bool isAvailable(String front) => FillAnswerEvaluator.isAvailable(front);
}
