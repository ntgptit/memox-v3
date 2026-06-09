import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/study/modes/recall_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy_factory.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

void main() {
  test('returns the recall strategy for StudyMode.recall', () {
    final strategy = StudyModeStrategyFactory.resolve(
      studyMode: StudyMode.recall,
    );

    expect(strategy, isA<RecallStudyModeStrategy>());
    expect(strategy.mode, StudyMode.recall);
    expect(strategy.usesRevealSelfGradeFlow, isTrue);
    expect(strategy.mapForgotAction(), AttemptResult.forgot);
    expect(strategy.mapGotItAction(), AttemptResult.perfect);
  });

  test('returns a controlled unsupported strategy for non-recall modes', () {
    for (final StudyMode mode in StudyMode.values) {
      if (mode == StudyMode.recall) {
        continue;
      }

      final strategy = StudyModeStrategyFactory.resolve(studyMode: mode);

      expect(strategy.mode, mode);
      expect(strategy.usesRevealSelfGradeFlow, isFalse);
      expect(strategy.mapForgotAction, throwsUnsupportedError);
      expect(strategy.mapGotItAction, throwsUnsupportedError);
    }
  });
}
