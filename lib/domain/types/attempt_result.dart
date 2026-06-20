/// The SRS grading outcomes — pass/fail only, no Hard/Easy
/// (`docs/contracts/types-catalog.md` §AttemptResult, `docs/business/srs/srs-review.md`).
///
/// Storage tokens are snake_case (`perfect`, `initial_passed`, `recovered`,
/// `forgot`). [initialPassed] is a compatibility-only legacy value that current
/// study modes never emit.
enum AttemptResult {
  /// Exact match, clean attempt. Box advances.
  perfect,

  /// Compatibility-only legacy value; never emitted by current modes.
  initialPassed,

  /// Missed initially but corrected (typo override / close match). Box stays.
  recovered,

  /// Wrong answer. Box resets to 1, lapse counter increments.
  forgot,
}
