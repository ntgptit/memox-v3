import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/deck.dart';

part 'deck_summary.freezed.dart';

/// A deck plus the aggregate counts shown on its Folder-detail row.
///
/// Counts come from the database source of truth, never the widget
/// (`docs/business/deck/deck-management.md`):
/// - [cardCount] — flashcards in the deck (includes suspended/buried until those
///   exclusions ship — same trivially-satisfied F13 note as `FolderSummary`).
/// - [dueCount] — scheduled-and-due cards (`due_at IS NOT NULL AND due_at <=
///   now`); NEW cards (`due_at IS NULL`) are not due.
@freezed
sealed class DeckSummary with _$DeckSummary {
  const factory DeckSummary({
    required Deck deck,
    required int cardCount,
    required int dueCount,
  }) = _DeckSummary;
}
