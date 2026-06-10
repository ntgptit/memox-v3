/// Result of a manual duplicate check before saving a flashcard.
class FlashcardDuplicateCheckResult {
  const FlashcardDuplicateCheckResult({
    required this.hasDuplicate,
    this.duplicateFlashcardId,
  });

  final bool hasDuplicate;
  final String? duplicateFlashcardId;
}
