import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/study/guess/guess_option.dart';
import 'package:memox/domain/study/guess/guess_option_builder.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Guess-mode strategy: front prompt, deterministic multiple-choice selection.
final class GuessStudyModeStrategy extends StudyModeStrategy {
  const GuessStudyModeStrategy() : super(StudyMode.guess);

  @override
  bool get usesRevealSelfGradeFlow => false;

  @override
  AttemptResult mapForgotAction() => AttemptResult.forgot;

  @override
  AttemptResult mapGotItAction() => AttemptResult.perfect;

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
