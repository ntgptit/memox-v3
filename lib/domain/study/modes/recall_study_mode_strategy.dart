import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Recall mode (V1): flip-card **reveal → self-grade**.
///
/// The user sees the front, taps "Show answer" to reveal the back, then
/// self-grades with Forgot / Got it — hence this is the only strategy with
/// [usesRevealSelfGradeFlow] `true`, and it is the documented V1 fallback
/// when a session has no persisted mode (decision row S45).
///
/// Outcome mapping: Got it → [AttemptResult.perfect], Forgot →
/// [AttemptResult.forgot]. Typed recall is a Future Proposal and would land
/// as a separate mode, not by widening this class
/// (`docs/business/study/study-flow.md` §Study modes).
final class RecallStudyModeStrategy extends BinaryGradeStudyModeStrategy {
  const RecallStudyModeStrategy() : super(StudyMode.recall);

  @override
  bool get usesRevealSelfGradeFlow => true;

  @override
  AttemptResult mapForgotAction() => AttemptResult.forgot;

  @override
  AttemptResult mapGotItAction() => AttemptResult.perfect;
}
