import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/deck.dart';

part 'deck_summary.freezed.dart';

/// A deck plus the aggregate counts shown on its Folder-detail row.
///
/// Counts come from the database source of truth, never the widget
/// (`docs/business/deck/deck-management.md`):
/// - [cardCount] — flashcards in the deck; **includes** suspended and buried
///   cards (decision row F13), same as `FolderSummary`.
/// - [dueCount] — scheduled-and-due cards (`due_at IS NOT NULL AND due_at <=
///   now`); NEW cards (`due_at IS NULL`) are not due, and **suspended or
///   currently-buried cards are excluded** (F13) via `folderDeckSummaries`.
@freezed
sealed class DeckSummary with _$DeckSummary {
  const factory DeckSummary({
    required Deck deck,
    required int cardCount,
    required int dueCount,
  }) = _DeckSummary;
}
