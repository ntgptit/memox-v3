import 'package:memox/domain/study/modes/match_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/recall_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Creates the mode strategy for the current study session.
abstract final class StudyModeStrategyFactory {
  /// Resolves the active mode strategy.
  ///
  /// V1 fallback: when the session mode is not yet persisted, use recall.
  static StudyModeStrategy resolve({StudyMode? studyMode}) {
    final StudyMode resolvedMode = studyMode ?? StudyMode.recall;
    if (resolvedMode == StudyMode.recall) {
      return const RecallStudyModeStrategy();
    }
    if (resolvedMode == StudyMode.match) {
      return const MatchStudyModeStrategy();
    }
    return _UnsupportedStudyModeStrategy(resolvedMode);
  }
}

final class _UnsupportedStudyModeStrategy extends StudyModeStrategy {
  const _UnsupportedStudyModeStrategy(super.mode);

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
