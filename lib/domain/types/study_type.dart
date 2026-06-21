/// The intent of a study session (`docs/contracts/types-catalog.md` §StudyType,
/// `docs/business/study/study-flow.md` §Study types).
enum StudyType {
  /// New learning — studies cards regardless of due status (excludes only
  /// suspended / buried).
  newCards,

  /// Due-card review — studies only cards whose `due_at` has passed.
  srsReview;

  /// Canonical persisted token (`docs/contracts/types-catalog.md` §StudyType:
  /// snake_case `new_cards` / `srs_review`). Also the `study_type` URL-query
  /// value at the study entry gate.
  String get storageValue => switch (this) {
    StudyType.newCards => 'new_cards',
    StudyType.srsReview => 'srs_review',
  };

  /// Parse a [storageValue]; `null` for an unrecognized token (callers decide
  /// whether that is a hard error — the data layer throws, the entry gate
  /// surfaces it as an error state).
  static StudyType? fromStorage(String raw) => switch (raw) {
    'new_cards' => StudyType.newCards,
    'srs_review' => StudyType.srsReview,
    _ => null,
  };
}
