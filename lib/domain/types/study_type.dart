/// The intent of a study session
/// (`docs/contracts/types-catalog.md` §StudyType).
///
/// Storage: `study_sessions.study_type` TEXT, snake_case
/// (`new_cards`, `srs_review`).
enum StudyType {
  /// New learning (cards never studied or in box 1).
  newCards,

  /// Due-card review.
  srsReview,
}
