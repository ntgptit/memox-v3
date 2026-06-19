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
/// - [dueCount] — recursive due flashcards; **excludes** suspended and
///   currently-buried cards, still counts expired-buried cards (F13).
///
/// > V1 scope (WBS 3.1.1/3.2.1): the `decks` and `flashcards` tables do not
/// > exist yet (they land with WBS 2.7.x / 2.11.x), so [deckCount], [cardCount]
/// > and [dueCount] are structurally `0` for now. [subfolderCount] is the only
/// > live count. Decision rows F12/F13 (non-zero counts) are deferred until
/// > those tables ship.
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
