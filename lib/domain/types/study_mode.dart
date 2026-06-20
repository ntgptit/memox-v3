/// The five modes of card interaction (`docs/contracts/types-catalog.md`
/// §StudyMode, `docs/business/study/study-flow.md` §Study modes).
enum StudyMode {
  /// Both sides on one card; swipe-to-grade (right = perfect, left = forgot).
  review,

  /// 5-pair board (10 cells); tap-pair to match; append-only evaluation.
  match,

  /// Front shown; pick the correct back from 5 rich option cards.
  guess,

  /// Front shown; tap Show answer to reveal; self-grade Forgot / Got it.
  recall,

  /// Back shown as a hint; type the front in plain text; strict match.
  fill,
}
