import 'package:freezed_annotation/freezed_annotation.dart';

part 'deck_mastery.freezed.dart';

/// A deck's Leitner-box mastery, for the Stats "Per-deck mastery" list
/// (`docs/wireframes/18-stats.md`).
///
/// [masteryFraction] is the deck's average Leitner box mapped onto `0..1`:
/// `(avgBox - SrsBox.min) / (SrsBox.max - SrsBox.min)`, so a deck whose cards
/// all sit in box 1 reads `0.0` and a deck fully graduated to box 8 reads `1.0`.
/// A snapshot over `flashcard_progress` (every flashcard has a progress row from
/// creation), not range-filtered. Only decks with at least one card are
/// represented.
@freezed
sealed class DeckMastery with _$DeckMastery {
  const factory DeckMastery({
    required String deckId,
    required String deckName,
    required double masteryFraction,
  }) = _DeckMastery;
  const DeckMastery._();

  /// Mastery as a whole-number percent (0..100) for the trailing label.
  int get masteryPercent => (masteryFraction.clamp(0.0, 1.0) * 100).round();
}
