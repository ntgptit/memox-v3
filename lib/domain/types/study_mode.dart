/// The 5 modes of card interaction
/// (`docs/contracts/types-catalog.md` §StudyMode,
/// `docs/business/study/study-flow.md`).
///
/// Mode belongs to session planning / session-item / queue context — not a
/// required `study_attempts` column unless a migration adds it.
enum StudyMode {
  /// Both sides on one card; swipe-to-grade (right = perfect, left = forgot).
  review,

  /// 5-pair board (10 cells); tap-pair to match; per-pair persistence.
  match,

  /// Front shown; pick the correct back from 5 rich option cards.
  guess,

  /// Front shown; reveal then self-grade Forgot / Got it (no text input in v1).
  recall,

  /// Back shown as hint; type the front in a plain text input; strict match.
  fill,
}
