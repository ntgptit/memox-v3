import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/types/study_flow.dart';
import 'package:memox/domain/types/study_mode.dart';

void main() {
  group('StudyFlowPlan.orderedModes', () {
    test('new_full_cycle chains all five modes in order', () {
      expect(StudyFlow.newFullCycle.orderedModes, <StudyMode>[
        StudyMode.review,
        StudyMode.match,
        StudyMode.guess,
        StudyMode.recall,
        StudyMode.fill,
      ]);
    });

    test('every flow has a non-empty plan', () {
      for (final StudyFlow flow in StudyFlow.values) {
        expect(flow.orderedModes, isNotEmpty, reason: flow.name);
      }
    });

    test('single-mode flows map to their one mode', () {
      expect(StudyFlow.newReviewOnly.orderedModes, <StudyMode>[
        StudyMode.review,
      ]);
      expect(StudyFlow.srsRecallReview.orderedModes, <StudyMode>[
        StudyMode.recall,
      ]);
      expect(StudyFlow.srsFillReview.orderedModes, <StudyMode>[StudyMode.fill]);
    });
  });

  group('StudyFlowPlan.firstMode', () {
    test('is review for the full cycle', () {
      expect(StudyFlow.newFullCycle.firstMode, StudyMode.review);
    });

    test('is the only mode for a single-mode flow', () {
      expect(StudyFlow.newGuessOnly.firstMode, StudyMode.guess);
    });
  });

  group('StudyFlowPlan.nextModeAfter', () {
    test('walks the full cycle to its terminal phase', () {
      expect(
        StudyFlow.newFullCycle.nextModeAfter(StudyMode.review),
        StudyMode.match,
      );
      expect(
        StudyFlow.newFullCycle.nextModeAfter(StudyMode.match),
        StudyMode.guess,
      );
      expect(
        StudyFlow.newFullCycle.nextModeAfter(StudyMode.guess),
        StudyMode.recall,
      );
      expect(
        StudyFlow.newFullCycle.nextModeAfter(StudyMode.recall),
        StudyMode.fill,
      );
      expect(StudyFlow.newFullCycle.nextModeAfter(StudyMode.fill), isNull);
    });

    test('returns null for the only phase of a single-mode flow', () {
      expect(StudyFlow.srsRecallReview.nextModeAfter(StudyMode.recall), isNull);
    });

    test('returns null for a mode outside the plan', () {
      expect(StudyFlow.newReviewOnly.nextModeAfter(StudyMode.fill), isNull);
    });
  });

  group('StudyFlowPlan.isLastMode', () {
    test('only fill is terminal in the full cycle', () {
      expect(StudyFlow.newFullCycle.isLastMode(StudyMode.review), isFalse);
      expect(StudyFlow.newFullCycle.isLastMode(StudyMode.fill), isTrue);
    });

    test('a single mode is its own terminal phase', () {
      expect(StudyFlow.newRecallOnly.isLastMode(StudyMode.recall), isTrue);
    });

    test('an out-of-plan mode is treated as terminal', () {
      expect(StudyFlow.newReviewOnly.isLastMode(StudyMode.guess), isTrue);
    });
  });
}
