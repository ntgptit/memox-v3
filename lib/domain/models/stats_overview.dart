import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/models/deck_mastery.dart';
import 'package:memox/domain/models/week_activity.dart';

part 'stats_overview.freezed.dart';

/// The full read model for the Stats screen (`docs/wireframes/18-stats.md`):
/// the current week's review activity plus per-deck mastery, composed in one
/// repository read so the screen renders from a single async value.
///
/// Both parts are zero-safe: [weekActivity] always has seven day buckets, and
/// [deckMastery] is empty when no deck has cards.
@freezed
sealed class StatsOverview with _$StatsOverview {
  const factory StatsOverview({
    required WeekActivity weekActivity,
    required List<DeckMastery> deckMastery,
  }) = _StatsOverview;
  const StatsOverview._();

  /// Whether there is any deck mastery to list.
  bool get hasDecks => deckMastery.isNotEmpty;
}
