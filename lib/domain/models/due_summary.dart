import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'due_summary.freezed.dart';

/// One deck that currently has due cards (WBS 7.1.1). [dueCount] excludes
/// suspended and currently-buried cards.
@freezed
sealed class DeckDueCount with _$DeckDueCount {
  const factory DeckDueCount({
    required DeckId deckId,
    required String deckName,
    required int dueCount,
  }) = _DeckDueCount;
}

/// Aggregate due-card counts across the library (WBS 7.1.1): the global
/// [totalDueCount] plus the per-deck breakdown [decksWithDue] (only decks with
/// at least one due card). "Due" means `due_at <= now` with suspended and
/// currently-buried cards excluded, matching the study queue / eligibility rules
/// (`docs/business/study-actions/bury-suspend.md`,
/// `docs/business/engagement/dashboard-engagement.md`). Backs the dashboard
/// due-today snapshot and the Progress due summary.
@freezed
sealed class DueSummary with _$DueSummary {
  const factory DueSummary({
    required int totalDueCount,
    required List<DeckDueCount> decksWithDue,
  }) = _DueSummary;
  const DueSummary._();

  /// Whether anything is due right now (drives the caught-up empty state).
  bool get hasDue => totalDueCount > 0;

  /// How many distinct decks have at least one due card.
  int get decksWithDueCount => decksWithDue.length;
}
