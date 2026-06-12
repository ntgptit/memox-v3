import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/study/modes/guess_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/recall_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/review_study_mode_strategy.dart';
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

  test('returns the review strategy for StudyMode.review', () {
    final strategy = StudyModeStrategyFactory.resolve(
      studyMode: StudyMode.review,
    );

    expect(strategy, isA<ReviewStudyModeStrategy>());
    expect(strategy.mode, StudyMode.review);
    expect(strategy.usesRevealSelfGradeFlow, isFalse);
    expect(strategy.mapForgotAction(), AttemptResult.forgot);
    expect(strategy.mapGotItAction(), AttemptResult.perfect);
  });

  test('returns the guess strategy for StudyMode.guess', () {
    final strategy = StudyModeStrategyFactory.resolve(
      studyMode: StudyMode.guess,
    );

    expect(strategy, isA<GuessStudyModeStrategy>());
    expect(strategy.mode, StudyMode.guess);
    expect(strategy.usesRevealSelfGradeFlow, isFalse);
    expect(strategy.mapForgotAction(), AttemptResult.forgot);
    expect(strategy.mapGotItAction(), AttemptResult.perfect);
  });

  test('returns controlled unsupported strategies for match and fill', () {
    for (final StudyMode mode in <StudyMode>[StudyMode.match, StudyMode.fill]) {
      final strategy = StudyModeStrategyFactory.resolve(studyMode: mode);

      expect(strategy.mode, mode);
      expect(strategy.usesRevealSelfGradeFlow, isFalse);
      expect(strategy.mapForgotAction, throwsUnsupportedError);
      expect(strategy.mapGotItAction, throwsUnsupportedError);
    }
  });
}
