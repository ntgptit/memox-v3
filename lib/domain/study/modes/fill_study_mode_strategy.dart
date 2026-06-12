import 'package:memox/domain/study/fill/fill_answer_evaluator.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Fill mode (V1): **strict typed front production**.
///
/// The back is shown as the prompt and the user types the front. The
/// terminal result is computed by [FillAnswerEvaluator] (trim-only exact
/// match; hint taints to `recovered`; override path supported) and then
/// persisted through the regular one-terminal-attempt path — there is no
/// self-grade step, which is why this strategy belongs to
/// [TypedAnswerStudyModeStrategy] and exposes no Forgot / Got-it mapping
/// (decision row S49).
final class FillStudyModeStrategy extends TypedAnswerStudyModeStrategy {
  const FillStudyModeStrategy() : super(StudyMode.fill);

  @override
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

  @override
  bool isAvailable(String front) => FillAnswerEvaluator.isAvailable(front);
}
