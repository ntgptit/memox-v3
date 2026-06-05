/// The 4 SRS grading outcomes — pass/fail only (no Hard/Easy)
/// (`docs/contracts/types-catalog.md` §AttemptResult,
/// `docs/business/srs/srs-review.md`).
///
/// Target storage: `study_attempts.result` TEXT, snake_case
/// (`perfect`, `initial_passed`, `recovered`, `forgot`).
enum AttemptResult {
  /// Exact match, first attempt, no recovery needed.
  perfect,

  /// Correct on first attempt (multi-attempt flows).
  initialPassed,

  /// Missed initially but corrected (typo override, close match).
  recovered,

  /// Wrong answer.
  forgot,
}
