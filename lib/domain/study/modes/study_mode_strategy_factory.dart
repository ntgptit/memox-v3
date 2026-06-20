import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Resolves a [StudyMode] to its concrete [StudyModeStrategy] (WBS 4.5.1).
///
/// The single home of the mode → strategy mapping (decision rows S48/S49/S58).
/// The `switch` is exhaustive, so wiring a new [StudyMode] without a strategy
/// fails at compile time rather than throwing at runtime.
abstract final class StudyModeStrategyFactory {
  const StudyModeStrategyFactory._();

  /// The strategy for [mode]. Review / recall / guess resolve to the
  /// BinaryGrade family, fill to the TypedAnswer family, and match to the Board
  /// family; every result reports its resolved [StudyModeStrategy.mode].
  static StudyModeStrategy resolve(StudyMode mode) => switch (mode) {
    StudyMode.review => const ReviewStudyModeStrategy(),
    StudyMode.recall => const RecallStudyModeStrategy(),
    StudyMode.guess => const GuessStudyModeStrategy(),
    StudyMode.fill => const FillStudyModeStrategy(),
    StudyMode.match => const MatchStudyModeStrategy(),
  };
}
