import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/study/guess/guess_option.dart';
import 'package:memox/domain/study/guess/guess_option_builder.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Guess mode (V1): front prompt, **deterministic multiple choice**.
///
/// The user picks the correct back among option cards built by
/// [buildOptions]. The grade is system-derived, not self-graded: the caller
/// maps a correct selection through [mapGotItAction]
/// ([AttemptResult.perfect]) and a wrong selection through
/// [mapForgotAction] ([AttemptResult.forgot]) — decision row S47.
///
/// [buildOptions] is intentionally declared here (not on the family):
/// option building is guess-specific, and callers already hold the concrete
/// type after pattern-matching.
final class GuessStudyModeStrategy extends BinaryGradeStudyModeStrategy {
  const GuessStudyModeStrategy() : super(StudyMode.guess);

  @override
  AttemptResult mapForgotAction() => AttemptResult.forgot;

  @override
  AttemptResult mapGotItAction() => AttemptResult.perfect;

  /// Builds the deterministic option list for the current card.
  ///
  /// Delegates to [GuessOptionBuilder] so the seeding/distractor rules stay
  /// in one testable place; the strategy only routes the call.
  List<GuessOption> buildOptions({
    required String sessionId,
    required Flashcard current,
    required Iterable<Flashcard> scopeCards,
  }) => GuessOptionBuilder.build(
    sessionId: sessionId,
    current: current,
    scopeCards: scopeCards,
  );
}
