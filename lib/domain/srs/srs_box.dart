import 'package:memox/domain/types/attempt_result.dart';

/// The Leitner box ladder and its per-attempt transition
/// (`docs/business/srs/srs-review.md` §Box transition table).
///
/// Boxes run [min]..[max] (1..8). The transition is a pure function of the
/// current box and the attempt result; it is recorded on `study_attempts`
/// (`box_before` → `box_after`) at answer time and applied to
/// `flashcard_progress` at finalization. `due_at` intervals are a separate
/// concern (the interval table / finalization).
abstract final class SrsBox {
  /// Lowest box (a brand-new or just-lapsed card).
  static const int min = 1;

  /// Highest box (cards graduate here and stay).
  static const int max = 8;

  /// The box a card moves to after an attempt graded [result] from [current]:
  /// `perfect` (and the compatibility-only `initialPassed`) advance one box,
  /// capped at [max]; `recovered` keeps the current box; `forgot` resets to
  /// [min]. [current] is clamped into range defensively.
  static int nextBox(int current, AttemptResult result) {
    final int box = current.clamp(min, max);
    return switch (result) {
      AttemptResult.perfect ||
      AttemptResult.initialPassed => (box + 1).clamp(min, max),
      AttemptResult.recovered => box,
      AttemptResult.forgot => min,
    };
  }
}
