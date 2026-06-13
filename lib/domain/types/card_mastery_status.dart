/// A card's learning maturity, derived from its SRS progress — the status dot /
/// label on the Flashcard List and the deck-progress breakdown
/// (`docs/wireframes/06-flashcard-list.md`, `docs/business/srs/srs-review.md`).
///
/// Derived, never stored: classify from the Leitner box + review count.
enum CardMasteryStatus { newCard, learning, reviewing, mastered }

/// Inclusive upper box for the "learning" band (boxes 1–2).
const int kLearningMaxBox = 2;

/// Inclusive upper box for the "reviewing" band (boxes 3–6); 7–8 = mastered.
const int kReviewingMaxBox = 6;

abstract final class CardMasteryClassifier {
  CardMasteryClassifier._();

  /// Classifies a card from its progress snapshot. A card that has never been
  /// answered (`reviewCount == 0`) is [CardMasteryStatus.newCard] regardless of
  /// box; otherwise the Leitner box decides the band.
  static CardMasteryStatus classify({
    required int reviewCount,
    required int boxNumber,
  }) {
    if (reviewCount <= 0) {
      return CardMasteryStatus.newCard;
    }
    if (boxNumber <= kLearningMaxBox) {
      return CardMasteryStatus.learning;
    }
    if (boxNumber <= kReviewingMaxBox) {
      return CardMasteryStatus.reviewing;
    }
    return CardMasteryStatus.mastered;
  }
}
