import 'package:memox/domain/srs/srs_box.dart';

/// The Leitner box → review-interval ladder (`docs/business/srs/srs-review.md`
/// §Interval table, `docs/contracts/usecase-contracts/srs.md` §BoxIntervals).
///
/// Boxes 1..5 step linearly by one day; boxes 6/7/8 jump to 12/30/60 days. The
/// single authoritative owner of the ladder — callers must not hardcode interval
/// days elsewhere (`docs/contracts/usecase-contracts/srs.md` §Forbidden).
abstract final class BoxIntervals {
  /// The review interval, in days, for [box] (1..8); boxes 1..5 step by one day,
  /// then 12 / 30 / 60. An out-of-range [box] is a programmer error (asserted);
  /// it is also clamped so release builds never crash
  /// (`docs/contracts/usecase-contracts/srs.md` §BoxIntervals).
  static int daysFor(int box) {
    assert(
      box >= SrsBox.min && box <= SrsBox.max,
      'box out of range (1..8): $box',
    );
    return switch (box.clamp(SrsBox.min, SrsBox.max)) {
      1 => 1,
      2 => 2,
      3 => 3,
      4 => 4,
      5 => 5,
      6 => 12,
      7 => 30,
      _ => 60,
    };
  }
}
