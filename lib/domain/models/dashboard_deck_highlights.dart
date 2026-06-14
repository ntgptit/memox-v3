import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'dashboard_deck_highlights.freezed.dart';

/// One row of the Dashboard "Recent decks" section
/// (`docs/wireframes/01-dashboard.md` §Recent decks list).
///
/// Ordered by `decks.updated_at DESC` and capped at the top few. [cardCount]
/// is the deck's total flashcards, [dueCount] the cards due now (same
/// suspended/buried exclusions as Progress/Library), and [lastStudiedAt] the
/// most recent study time across the deck's cards (`null` = never studied).
@freezed
abstract class DashboardRecentDeck with _$DashboardRecentDeck {
  const factory DashboardRecentDeck({
    required DeckId deckId,
    required String deckName,
    required int cardCount,
    required int dueCount,
    required DateTime? lastStudiedAt,
  }) = _DashboardRecentDeck;
}

/// Deck-derived Dashboard highlights: the recent-decks list plus the
/// library-wide count of brand-new (never-studied) cards that backs the
/// "Start new learning" badge.
@freezed
abstract class DashboardDeckHighlights with _$DashboardDeckHighlights {
  const factory DashboardDeckHighlights({
    required List<DashboardRecentDeck> recentDecks,
    required int newCardCount,
  }) = _DashboardDeckHighlights;
}
