import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/models/guess_option.dart';
import 'package:memox/domain/study/modes/study_mode_strategy.dart';

void main() {
  // GuessStudyModeStrategy.buildOptions (WBS 4.5.6): the deterministic 5-option
  // selection strategy. Decision rows S47 (resolution + grading) and S80-S83
  // (the option builder behavior).
  const GuessStudyModeStrategy strategy = GuessStudyModeStrategy();

  List<({String id, String back})> pool(int count) =>
      List<({String id, String back})>.generate(
        count,
        (int i) => (id: 'd$i', back: 'distractor-$i'),
      );

  group('GuessStudyModeStrategy.buildOptions', () {
    test(
      'builds 5 options with exactly one correct from a full pool (S80)',
      () {
        final List<GuessOption> options = strategy.buildOptions(
          targetId: 't',
          targetBack: 'correct',
          pool: pool(10),
          random: Random(1),
        );

        expect(options.length, GuessStudyModeStrategy.optionCount);
        final Iterable<GuessOption> correct = options.where((o) => o.isCorrect);
        expect(correct.length, 1, reason: 'exactly one correct option');
        expect(correct.single.flashcardId, 't');
        expect(correct.single.back, 'correct');
        // No duplicate option backs, and no distractor is the target.
        expect(options.map((o) => o.back).toSet().length, options.length);
        expect(
          options.where((o) => !o.isCorrect).every((o) => o.flashcardId != 't'),
          isTrue,
        );
      },
    );

    test('degrades to fewer options when the pool is small (S81)', () {
      final List<GuessOption> options = strategy.buildOptions(
        targetId: 't',
        targetBack: 'correct',
        pool: pool(2),
        random: Random(1),
      );

      expect(options.length, 3, reason: '1 correct + 2 available distractors');
      expect(options.where((o) => o.isCorrect).length, 1);
    });

    test('returns just the correct option when the pool is empty (S81)', () {
      final List<GuessOption> options = strategy.buildOptions(
        targetId: 't',
        targetBack: 'correct',
        pool: const <({String id, String back})>[],
        random: Random(1),
      );

      expect(options.length, 1);
      expect(options.single.isCorrect, isTrue);
      expect(options.single.back, 'correct');
    });

    test('emits trimmed option backs, not the raw input (S82)', () {
      final List<GuessOption> options = strategy.buildOptions(
        targetId: 't',
        targetBack: '  correct  ',
        pool: const <({String id, String back})>[(id: 'a', back: '  alpha  ')],
        random: Random(1),
      );

      expect(
        options.map((o) => o.back).toSet(),
        <String>{'correct', 'alpha'},
        reason: 'displayed text agrees with the trimmed dedup key',
      );
    });

    test(
      'degrades to a single (blank) correct option for a blank target (S81)',
      () {
        // Card backs are required at creation, so this should not occur in
        // practice; pin the no-throw degrade behavior so it cannot silently
        // regress.
        final List<GuessOption> options = strategy.buildOptions(
          targetId: 't',
          targetBack: '   ',
          pool: const <({String id, String back})>[(id: 'a', back: 'alpha')],
          random: Random(1),
        );

        // The blank correct answer seeds the dedup set; 'alpha' survives.
        expect(options.where((o) => o.isCorrect).length, 1);
        expect(options.firstWhere((o) => o.isCorrect).back, '');
        expect(options.length, 2);
      },
    );

    test(
      'excludes the target, blank backs, and backs that duplicate the correct '
      'answer or each other (S82)',
      () {
        final List<GuessOption> options = strategy.buildOptions(
          targetId: 't',
          targetBack: 'correct',
          pool: const <({String id, String back})>[
            (id: 't', back: 'self should be excluded'),
            (id: 'a', back: '  correct  '), // trimmed == correct → excluded
            (id: 'b', back: 'dup'),
            (id: 'c', back: 'dup'), // duplicate back → excluded
            (id: 'd', back: '   '), // blank → excluded
            (id: 'e', back: 'unique'),
          ],
          random: Random(1),
        );

        final List<GuessOption> distractors = options
            .where((o) => !o.isCorrect)
            .toList();
        expect(
          distractors.map((o) => o.back).toSet(),
          <String>{'dup', 'unique'},
          reason: 'only the two distinct non-correct backs survive',
        );
        expect(options.where((o) => o.isCorrect).length, 1);
        expect(options.map((o) => o.back).toSet().length, options.length);
      },
    );

    test('is deterministic for the same seed and inputs (S83)', () {
      List<GuessOption> build() => strategy.buildOptions(
        targetId: 't',
        targetBack: 'correct',
        pool: pool(8),
        random: Random(42),
      );

      expect(build(), build(), reason: 'same seed → identical option order');
    });
  });
}
