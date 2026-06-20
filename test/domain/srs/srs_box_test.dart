import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/srs/srs_box.dart';
import 'package:memox/domain/types/attempt_result.dart';

void main() {
  // SrsBox.nextBox (WBS 4.4.1): the Leitner transition
  // (docs/business/srs/srs-review.md §Box transition table).
  group('SrsBox.nextBox', () {
    test('perfect advances one box, capped at 8', () {
      expect(SrsBox.nextBox(1, AttemptResult.perfect), 2);
      expect(SrsBox.nextBox(7, AttemptResult.perfect), 8);
      expect(SrsBox.nextBox(8, AttemptResult.perfect), 8, reason: 'cap');
    });

    test('initialPassed advances like perfect', () {
      expect(SrsBox.nextBox(2, AttemptResult.initialPassed), 3);
    });

    test('recovered keeps the current box', () {
      expect(SrsBox.nextBox(4, AttemptResult.recovered), 4);
    });

    test('forgot resets to box 1', () {
      expect(SrsBox.nextBox(6, AttemptResult.forgot), 1);
      expect(SrsBox.nextBox(1, AttemptResult.forgot), 1);
    });

    test('clamps an out-of-range current box defensively', () {
      expect(SrsBox.nextBox(0, AttemptResult.perfect), 2);
      expect(SrsBox.nextBox(99, AttemptResult.recovered), 8);
    });
  });
}
