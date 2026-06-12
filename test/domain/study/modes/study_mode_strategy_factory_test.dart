import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/study/fill/fill_answer_evaluator.dart';
import 'package:memox/domain/study/modes/fill_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/guess_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/match_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/recall_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/review_study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy_factory.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

void main() {
  test('returns the recall strategy for StudyMode.recall', () {
    final strategy = StudyModeStrategyFactory.resolve(
      studyMode: StudyMode.recall,
    );

    expect(strategy, isA<RecallStudyModeStrategy>());
    expect(strategy, isA<BinaryGradeStudyModeStrategy>());
    expect(strategy.mode, StudyMode.recall);
    expect(strategy.usesRevealSelfGradeFlow, isTrue);
    final BinaryGradeStudyModeStrategy recallStrategy =
        strategy as BinaryGradeStudyModeStrategy;
    expect(recallStrategy.mapForgotAction(), AttemptResult.forgot);
    expect(recallStrategy.mapGotItAction(), AttemptResult.perfect);
  });

  test('returns the match strategy for StudyMode.match', () {
    final strategy = StudyModeStrategyFactory.resolve(
      studyMode: StudyMode.match,
    );

    expect(strategy, isA<MatchStudyModeStrategy>());
    // Board family: no per-card grading API exists to call by design.
    expect(strategy, isA<BoardStudyModeStrategy>());
    expect(strategy, isNot(isA<BinaryGradeStudyModeStrategy>()));
    expect(strategy.mode, StudyMode.match);
    expect(strategy.usesRevealSelfGradeFlow, isFalse);
  });

  test('returns the review strategy for StudyMode.review', () {
    final strategy = StudyModeStrategyFactory.resolve(
      studyMode: StudyMode.review,
    );

    expect(strategy, isA<ReviewStudyModeStrategy>());
    expect(strategy, isA<BinaryGradeStudyModeStrategy>());
    expect(strategy.mode, StudyMode.review);
    expect(strategy.usesRevealSelfGradeFlow, isFalse);
    final BinaryGradeStudyModeStrategy reviewStrategy =
        strategy as BinaryGradeStudyModeStrategy;
    expect(reviewStrategy.mapForgotAction(), AttemptResult.forgot);
    expect(reviewStrategy.mapGotItAction(), AttemptResult.perfect);
  });

  test('returns the guess strategy for StudyMode.guess', () {
    final strategy = StudyModeStrategyFactory.resolve(
      studyMode: StudyMode.guess,
    );

    expect(strategy, isA<GuessStudyModeStrategy>());
    expect(strategy, isA<BinaryGradeStudyModeStrategy>());
    expect(strategy.mode, StudyMode.guess);
    expect(strategy.usesRevealSelfGradeFlow, isFalse);
    final BinaryGradeStudyModeStrategy guessStrategy =
        strategy as BinaryGradeStudyModeStrategy;
    expect(guessStrategy.mapForgotAction(), AttemptResult.forgot);
    expect(guessStrategy.mapGotItAction(), AttemptResult.perfect);
  });

  test('returns the fill strategy for StudyMode.fill', () {
    final strategy = StudyModeStrategyFactory.resolve(
      studyMode: StudyMode.fill,
    );

    expect(strategy, isA<FillStudyModeStrategy>());
    // Typed-answer family: graded by the evaluator, no Forgot/Got-it API.
    expect(strategy, isA<TypedAnswerStudyModeStrategy>());
    expect(strategy, isNot(isA<BinaryGradeStudyModeStrategy>()));
    expect(strategy.mode, StudyMode.fill);
    expect(strategy.usesRevealSelfGradeFlow, isFalse);
    final FillStudyModeStrategy fillStrategy =
        strategy as FillStudyModeStrategy;
    expect(
      fillStrategy
          .evaluateAnswer(
            typedInput: '  웃기다  ',
            expectedFront: '웃기다',
            hintUsed: false,
          )
          .result,
      AttemptResult.perfect,
    );
    expect(
      fillStrategy
          .evaluateAnswer(
            typedInput: '웃기다',
            expectedFront: '웃기다',
            hintUsed: false,
          )
          .result,
      isNot(AttemptResult.initialPassed),
    );
    expect(fillStrategy.isAvailable('  가나다  '), isTrue);
  });

  test('every study mode resolves into exactly one interaction family', () {
    for (final StudyMode mode in StudyMode.values) {
      final StudyModeStrategy strategy = StudyModeStrategyFactory.resolve(
        studyMode: mode,
      );

      expect(strategy.mode, mode);
      // Sealed base: this switch is compile-time exhaustive. Adding a new
      // interaction family without classifying it here will not compile.
      final bool isClassified = switch (strategy) {
        BinaryGradeStudyModeStrategy() => true,
        TypedAnswerStudyModeStrategy() => true,
        BoardStudyModeStrategy() => true,
      };
      expect(isClassified, isTrue);
    }
  });

  test('fill availability rejects trivial fronts', () {
    final fillStrategy =
        StudyModeStrategyFactory.resolve(studyMode: StudyMode.fill)
            as FillStudyModeStrategy;

    expect(fillStrategy.isAvailable('  Hi  '), isFalse);
    expect(fillStrategy.isAvailable('  123  '), isFalse);
    expect(fillStrategy.isAvailable('  !@#  '), isFalse);
  });

  test('fill availability accepts normal target-language text', () {
    final fillStrategy =
        StudyModeStrategyFactory.resolve(studyMode: StudyMode.fill)
            as FillStudyModeStrategy;

    expect(fillStrategy.isAvailable('  웃기다  '), isTrue);
    expect(fillStrategy.isAvailable('  palabra  '), isTrue);
  });

  test('fill evaluator returns typed result metadata', () {
    final FillAnswerEvaluation exactNoHint = FillAnswerEvaluator.evaluate(
      typedInput: '  웃기다  ',
      expectedFront: '웃기다',
      hintUsed: false,
    );
    final FillAnswerEvaluation exactWithHint = FillAnswerEvaluator.evaluate(
      typedInput: '웃기다',
      expectedFront: '웃기다',
      hintUsed: true,
    );
    final FillAnswerEvaluation mismatch = FillAnswerEvaluator.evaluate(
      typedInput: '우겨다',
      expectedFront: '웃기다',
      hintUsed: false,
    );

    expect(exactNoHint.result, AttemptResult.perfect);
    expect(exactNoHint.isExactMatch, isTrue);
    expect(exactNoHint.hintUsed, isFalse);
    expect(exactWithHint.result, AttemptResult.recovered);
    expect(mismatch.result, AttemptResult.forgot);
    expect(exactNoHint.result, isNot(AttemptResult.initialPassed));
  });

  test('fill evaluator trims both sides before comparing', () {
    final FillAnswerEvaluation evaluation = FillAnswerEvaluator.evaluate(
      typedInput: '  웃기다',
      expectedFront: '웃기다  ',
      hintUsed: false,
    );

    expect(evaluation.result, AttemptResult.perfect);
    expect(evaluation.isExactMatch, isTrue);
  });

  test('fill evaluator does not case-fold', () {
    final FillAnswerEvaluation evaluation = FillAnswerEvaluator.evaluate(
      typedInput: 'Abc',
      expectedFront: 'abc',
      hintUsed: false,
    );

    expect(evaluation.result, AttemptResult.forgot);
    expect(evaluation.isExactMatch, isFalse);
  });

  test('fill evaluator does not strip diacritics', () {
    final FillAnswerEvaluation evaluation = FillAnswerEvaluator.evaluate(
      typedInput: 'cafe',
      expectedFront: 'café',
      hintUsed: false,
    );

    expect(evaluation.result, AttemptResult.forgot);
    expect(evaluation.isExactMatch, isFalse);
  });
}
