import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Match mode (V1): 5-pair **board**, append-only evaluation persistence.
///
/// Pair taps are recorded one by one via `RecordMatchEvaluationUseCase`; the
/// terminal per-card attempt is derived only at session finalization
/// (decision row S48). Match therefore never grades a single card
/// mid-session and deliberately exposes no per-card grading API — that is
/// the defining trait of the [BoardStudyModeStrategy] family. The board
/// itself is built by `MatchBoardBuilder` (`lib/domain/study/match/`), which
/// the Match session flow consumes directly.
final class MatchStudyModeStrategy extends BoardStudyModeStrategy {
  const MatchStudyModeStrategy() : super(StudyMode.match);
}
