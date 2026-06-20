/// The intent of a study session (`docs/contracts/types-catalog.md` §StudyType,
/// `docs/business/study/study-flow.md` §Study types).
enum StudyType {
  /// New learning — studies cards regardless of due status (excludes only
  /// suspended / buried).
  newCards,

  /// Due-card review — studies only cards whose `due_at` has passed.
  srsReview,
}
