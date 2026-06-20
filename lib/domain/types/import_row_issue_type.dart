/// The category of a per-row validation problem found while parsing a deck
/// import (WBS 6.0.1 contract; the validation that raises these lands in
/// WBS 6.2.2 / 6.9.1).
///
/// Each detected problem becomes an `ImportValidationIssue` carrying this kind,
/// the source line number, and a localized message. Imported rows must pass the
/// same front/back validation as manual creation. See
/// `docs/business/flashcard/flashcard-management.md` §Validation issues and
/// `docs/contracts/types-catalog.md` §ImportRowIssueType.
enum ImportRowIssueType {
  /// `front` is empty after trim.
  missingFront,

  /// `back` is empty after trim.
  missingBack,

  /// `front` exceeds the field maximum length.
  frontTooLong,

  /// `back` exceeds the field maximum length.
  backTooLong,

  /// A tag is empty after trim or exceeds the maximum tag length.
  invalidTag,

  /// The row could not be split into the expected column count (e.g. an
  /// unparseable CSV row / wrong number of columns).
  malformedRow,
}
