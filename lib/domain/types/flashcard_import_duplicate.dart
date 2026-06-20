/// Duplicate handling for deck import (WBS 6.0.1 contract; detection logic in
/// WBS 6.6.1).
///
/// See `docs/business/flashcard/flashcard-management.md` §Duplicate policy and
/// `docs/contracts/types-catalog.md` §FlashcardImportDuplicatePolicy.
library;

/// How the import pipeline treats duplicate rows.
enum FlashcardImportDuplicatePolicy {
  /// Skip rows whose `front` + `back` match (after trim, case-insensitive)
  /// another row already kept — either earlier in the same file or an existing
  /// card in the target deck. The only policy supported in V1.
  skipExactDuplicates,
}

/// Where a skipped duplicate row clashed.
enum FlashcardImportDuplicateSource {
  /// Duplicate WITHIN the imported file (only the first occurrence is kept).
  importFile,

  /// Duplicate against an EXISTING card in the target deck.
  deck,
}
