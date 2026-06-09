import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Domain-safe behavior contract for one study mode.
///
/// V1 only needs the reveal/self-grade path used by recall, but the contract
/// stays narrow enough to support future modes without leaking UI copy.
abstract class StudyModeStrategy {
  const StudyModeStrategy(this.mode);

  /// The mode identity resolved for this session.
  final StudyMode mode;

  /// Whether this mode uses the reveal/self-grade flow.
  bool get usesRevealSelfGradeFlow;

  /// Maps the user's "Forgot" action to the attempt result recorded today.
  AttemptResult mapForgotAction();

  /// Maps the user's "Got it" action to the attempt result recorded today.
  AttemptResult mapGotItAction();
}
