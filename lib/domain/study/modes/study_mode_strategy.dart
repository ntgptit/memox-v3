import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// The interaction strategy for one study mode (WBS 4.5.1).
///
/// A **sealed** base with three interaction families as its direct subtypes, so
/// callers pattern-match on the family (an exhaustive `switch`) instead of
/// branching on [StudyMode] (`docs/business/study/study-flow.md` §study modes):
///
/// - [BinaryGradeStudyModeStrategy] — review / recall / guess: one card
///   collapses to a binary pass/fail mapped to an [AttemptResult] via
///   [BinaryGradeStudyModeStrategy.mapGotItAction] /
///   [BinaryGradeStudyModeStrategy.mapForgotAction].
/// - [TypedAnswerStudyModeStrategy] — fill: the terminal result is computed by a
///   strict typed-answer evaluator; there is no Forgot / Got-it API.
/// - [BoardStudyModeStrategy] — match: append-only pair evaluations with terminal
///   attempts derived at finalization; no per-card grading API at all.
///
/// The mode → strategy mapping lives only in `StudyModeStrategyFactory.resolve`.
/// Concrete leaves (one per [StudyMode]) report their resolved [mode].
sealed class StudyModeStrategy {
  const StudyModeStrategy(this.mode);

  /// The study mode this strategy was resolved for.
  final StudyMode mode;
}

/// Binary pass/fail family (review / recall / guess): a single card maps a
/// Got-it / Forgot action to an [AttemptResult]. V1 maps Got-it → [perfect] and
/// Forgot → [forgot] (`docs/contracts/usecase-contracts/study.md`
/// §RecordStudySessionAnswerUseCase).
sealed class BinaryGradeStudyModeStrategy extends StudyModeStrategy {
  const BinaryGradeStudyModeStrategy(super.mode);

  /// The result recorded when the user grades the card as known.
  AttemptResult mapGotItAction() => AttemptResult.perfect;

  /// The result recorded when the user grades the card as forgotten.
  AttemptResult mapForgotAction() => AttemptResult.forgot;
}

/// Typed-answer family (fill): the terminal result comes from a strict evaluator,
/// not a Got-it / Forgot action.
sealed class TypedAnswerStudyModeStrategy extends StudyModeStrategy {
  const TypedAnswerStudyModeStrategy(super.mode);

  /// Strict trim-only comparison of the typed [input] against [expected]
  /// (V1: exact after trimming → [perfect], else [forgot]). The mark-correct
  /// override and hint-taint refinements land with the Fill mode BE (WBS 4.5.8).
  AttemptResult evaluate({required String input, required String expected}) =>
      StringUtils.trimmed(input) == StringUtils.trimmed(expected)
      ? AttemptResult.perfect
      : AttemptResult.forgot;
}

/// Board family (match): no per-card grading API. Match persists append-only
/// pair evaluations and derives terminal attempts at finalization; it never
/// emits `initial_passed`.
sealed class BoardStudyModeStrategy extends StudyModeStrategy {
  const BoardStudyModeStrategy(super.mode);
}

/// Review mode: both sides shown, swipe-graded (binary).
final class ReviewStudyModeStrategy extends BinaryGradeStudyModeStrategy {
  const ReviewStudyModeStrategy() : super(StudyMode.review);
}

/// Recall mode: flip-card reveal + self-grade (binary).
final class RecallStudyModeStrategy extends BinaryGradeStudyModeStrategy {
  const RecallStudyModeStrategy() : super(StudyMode.recall);
}

/// Guess mode: pick the back from 5 options (binary pass/fail on the choice).
final class GuessStudyModeStrategy extends BinaryGradeStudyModeStrategy {
  const GuessStudyModeStrategy() : super(StudyMode.guess);
}

/// Fill mode: typed front, strict-match evaluator (TypedAnswer family).
final class FillStudyModeStrategy extends TypedAnswerStudyModeStrategy {
  const FillStudyModeStrategy() : super(StudyMode.fill);
}

/// Match mode: 5-pair board, no per-card grading API (Board family).
final class MatchStudyModeStrategy extends BoardStudyModeStrategy {
  const MatchStudyModeStrategy() : super(StudyMode.match);
}
