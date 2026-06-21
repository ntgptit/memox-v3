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
///   due_at <= now`); NEW cards (`due_at IS NULL`) are not due, and **suspended
///   or currently-buried cards are excluded** (decision row F13).
///
/// > Counts are live (WBS 3.7.1): [deckCount] is the folder's direct decks;
/// > [cardCount] / [dueCount] aggregate over the folder subtree. [dueCount]
/// > applies the F13 active-eligibility exclusion (`COALESCE(is_suspended,0)=0
/// > AND (buried_until IS NULL OR buried_until <= now)`), mirroring the
/// > `study_scope_queries.drift` queue predicate so count ↔ queue cannot
/// > diverge. [cardCount] still includes suspended/buried cards (F13).
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
