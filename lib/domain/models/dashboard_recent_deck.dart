import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'dashboard_recent_deck.freezed.dart';

/// One row of the Dashboard "Recent decks" list (engagement; WBS 5.x): a deck the
/// user has studied, with its card count, current due count, and when it was last
/// studied. The repository returns these most-recently-studied first. The FE
/// renders the relative "last studied" label and a due badge. See
/// `docs/business/engagement/dashboard-engagement.md`.
@freezed
sealed class DashboardRecentDeck with _$DashboardRecentDeck {
  const factory DashboardRecentDeck({
    required DeckId deckId,
    required String name,
    required int cardCount,
    required int dueCount,
    required DateTime lastStudiedAt,
  }) = _DashboardRecentDeck;
  const DashboardRecentDeck._();

  /// True when the deck has cards due right now (drives the due badge).
  bool get hasDue => dueCount > 0;
}
