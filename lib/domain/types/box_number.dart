/// Leitner SRS box number (`docs/contracts/types-catalog.md` §BoxNumber).
///
/// Valid range is 1..8 inclusive. Kept a typedef (not a freezed class) for
/// ergonomics; validity is asserted at boundaries via [assertBoxNumber].
library;

typedef BoxNumber = int;

/// Lowest box (a freshly reset / new card).
const BoxNumber kMinBox = 1;

/// Highest box (mastered).
const BoxNumber kMaxBox = 8;

/// Asserts [box] is within `1..8`. Returns it for fluent use at boundaries.
BoxNumber assertBoxNumber(BoxNumber box) {
  assert(
    box >= kMinBox && box <= kMaxBox,
    'BoxNumber must be in $kMinBox..$kMaxBox, got $box.',
  );
  return box;
}
