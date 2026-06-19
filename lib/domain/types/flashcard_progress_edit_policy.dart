/// How a flashcard update treats the card's existing SRS progress.
///
/// The V1 editor passes [keepProgress] by default and only switches to
/// [resetProgress] after the user confirms the explicit progress-policy dialog
/// (shown when learned front/back content changes on a progressed card). See
/// `docs/contracts/usecase-contracts/flashcard.md` §UpdateFlashcardUseCase and
/// `docs/business/flashcard/flashcard-management.md`.
enum FlashcardProgressEditPolicy {
  /// Preserve the existing `flashcard_progress` row.
  keepProgress,

  /// Reset `flashcard_progress` to the fresh-card state (box 1, unscheduled,
  /// zero counters) through the repository update path.
  resetProgress,
}
