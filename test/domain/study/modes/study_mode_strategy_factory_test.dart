import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy_factory.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

void main() {
  // StudyModeStrategyFactory (WBS 4.5.1): the mode → strategy dispatch matrix.
  // Decision rows S48 (match → Board), S49 (fill → TypedAnswer), S58 (every
  // mode resolves to exactly one family and reports its mode).
  group('StudyModeStrategyFactory.resolve', () {
    test('review / recall / guess resolve to the BinaryGrade family', () {
      for (final StudyMode mode in <StudyMode>[
        StudyMode.review,
        StudyMode.recall,
        StudyMode.guess,
      ]) {
        final StudyModeStrategy strategy = StudyModeStrategyFactory.resolve(
          mode,
        );
        expect(strategy, isA<BinaryGradeStudyModeStrategy>());
        expect(strategy.mode, mode, reason: 'reports its resolved mode (S58)');
      }
    });

    test('fill resolves to the TypedAnswer family (S49)', () {
      final StudyModeStrategy strategy = StudyModeStrategyFactory.resolve(
        StudyMode.fill,
      );
      expect(strategy, isA<TypedAnswerStudyModeStrategy>());
      expect(strategy, isA<FillStudyModeStrategy>());
      expect(strategy.mode, StudyMode.fill);
    });

    test('match resolves to the Board family (S48)', () {
      final StudyModeStrategy strategy = StudyModeStrategyFactory.resolve(
        StudyMode.match,
      );
      expect(strategy, isA<BoardStudyModeStrategy>());
      expect(strategy, isA<MatchStudyModeStrategy>());
      expect(strategy.mode, StudyMode.match);
    });

    test('every StudyMode resolves to exactly one sealed family (S58)', () {
      for (final StudyMode mode in StudyMode.values) {
        final StudyModeStrategy strategy = StudyModeStrategyFactory.resolve(
          mode,
        );
        final int familyMatches = <bool>[
          strategy is BinaryGradeStudyModeStrategy,
          strategy is TypedAnswerStudyModeStrategy,
          strategy is BoardStudyModeStrategy,
        ].where((bool b) => b).length;
        expect(familyMatches, 1, reason: '$mode belongs to one family');
      }
    });

    test('BinaryGrade V1 maps Got-it → perfect and Forgot → forgot', () {
      final strategy =
          StudyModeStrategyFactory.resolve(StudyMode.review)
              as BinaryGradeStudyModeStrategy;
      expect(strategy.mapGotItAction(), AttemptResult.perfect);
      expect(strategy.mapForgotAction(), AttemptResult.forgot);
    });

    test('Fill evaluator strict-matches after trimming', () {
      final strategy =
          StudyModeStrategyFactory.resolve(StudyMode.fill)
              as TypedAnswerStudyModeStrategy;
      expect(
        strategy.evaluate(input: '  먹다 ', expected: '먹다'),
        AttemptResult.perfect,
      );
      expect(
        strategy.evaluate(input: 'wrong', expected: '먹다'),
        AttemptResult.forgot,
      );
    });

    test('Fill evaluator is case-sensitive in V1 (strict match)', () {
      final strategy =
          StudyModeStrategyFactory.resolve(StudyMode.fill)
              as TypedAnswerStudyModeStrategy;
      // Case-folding / mark-correct override land with the Fill mode BE (4.5.8).
      expect(
        strategy.evaluate(input: 'Eat', expected: 'eat'),
        AttemptResult.forgot,
      );
    });
  });
}
