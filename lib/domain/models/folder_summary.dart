import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/folder.dart';

part 'folder_summary.freezed.dart';

/// A folder plus the aggregate counts shown on its Library / Folder-detail row.
///
/// Counts come from the database source of truth, never the widget
/// (`docs/business/folder/folder-management.md` §Screen behavior):
/// - [subfolderCount] — direct child folders.
/// - [deckCount] — direct child decks.
/// - [cardCount] — recursive flashcards in the subtree; **includes** suspended
///   and buried cards (decision row F13).
/// - [dueCount] — recursive due flashcards (`due_at IS NOT NULL AND
///   due_at <= now`); NEW cards (`due_at IS NULL`) are not due (F13).
///
/// > Counts are live (WBS 3.7.1): [deckCount] is the folder's direct decks;
/// > [cardCount] / [dueCount] aggregate over the folder subtree. The
/// > suspend/bury columns do not exist yet, so the F13 "exclude
/// > suspended/buried" clause is trivially satisfied; it is added to the count
/// > queries when those columns ship.
@freezed
sealed class FolderSummary with _$FolderSummary {
  const factory FolderSummary({
    required Folder folder,
    required int subfolderCount,
    required int deckCount,
    required int cardCount,
    required int dueCount,
  }) = _FolderSummary;
}
