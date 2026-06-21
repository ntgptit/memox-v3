import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';
import 'package:memox/domain/study/modes/study_mode_strategy_factory.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/study_mode.dart';

void main() {
  // FillStudyModeStrategy.evaluate (WBS 4.5.8): strict character match +
  // mark-correct override + hint taint. Decision rows S68 (match no hint →
  // perfect), S69 (match after hint → recovered), S72 (mark correct → recovered),
  // plus the strict-wrong → forgot path.
  final TypedAnswerStudyModeStrategy fill =
      StudyModeStrategyFactory.resolve(StudyMode.fill)
          as TypedAnswerStudyModeStrategy;

  group('FillStudyModeStrategy.evaluate', () {
    test('exact match without hint → perfect (S68)', () {
      expect(
        fill.evaluate(input: '  먹다 ', expected: '먹다'),
        AttemptResult.perfect,
        reason: 'trim-only strict match, no taint',
      );
    });

    test('exact match after a hint → recovered (S69)', () {
      expect(
        fill.evaluate(input: '먹다', expected: '먹다', hintUsed: true),
        AttemptResult.recovered,
        reason: 'hint caps the best result at recovered',
      );
    });

    test('wrong answer without override → forgot', () {
      expect(
        fill.evaluate(input: 'wrong', expected: '먹다'),
        AttemptResult.forgot,
      );
    });

    test('mark-correct override on a wrong answer → recovered (S72)', () {
      expect(
        fill.evaluate(input: 'wrong', expected: '먹다', markCorrect: true),
        AttemptResult.recovered,
        reason: 'self-marked passing answer is never perfect',
      );
    });

    test('mark-correct takes precedence over hint taint', () {
      expect(
        fill.evaluate(
          input: 'wrong',
          expected: '먹다',
          hintUsed: true,
          markCorrect: true,
        ),
        AttemptResult.recovered,
      );
    });

    test('markCorrect is ignored on a correct answer (no demotion)', () {
      // The "Mark correct" affordance only appears on wrong feedback, so a
      // correct input must keep its earned result rather than drop to recovered.
      expect(
        fill.evaluate(input: '먹다', expected: '먹다', markCorrect: true),
        AttemptResult.perfect,
      );
      expect(
        fill.evaluate(
          input: '먹다',
          expected: '먹다',
          hintUsed: true,
          markCorrect: true,
        ),
        AttemptResult.recovered,
        reason: 'a correct answer with a hint is still hint-tainted recovered',
      );
    });

    test('stays case-sensitive in V1 (strict match)', () {
      expect(
        fill.evaluate(input: 'Eat', expected: 'eat'),
        AttemptResult.forgot,
      );
    });
  });
}
