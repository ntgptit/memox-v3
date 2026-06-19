import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_summary.dart';

part 'folder_detail.freezed.dart';

/// The Folder-detail read model — one folder plus its breadcrumb path, child
/// folders, and aggregate counts (`docs/wireframes/05-folder-detail.md`).
///
/// - [folder] — the folder being viewed.
/// - [breadcrumb] — ancestor chain from the root down to and **including**
///   [folder] (root → leaf), used to render the path header.
/// - [subfolders] — direct child folders with their own [FolderSummary] counts,
///   in stable order.
/// - [deckCount] / [cardCount] / [dueCount] — subtree counts for [folder],
///   same semantics as [FolderSummary].
///
/// > V1 scope (WBS 3.2.1): the `decks` / `flashcards` tables do not exist yet,
/// > so child **decks** are not listed and [deckCount]/[cardCount]/[dueCount]
/// > are structurally `0`. Both land with WBS 2.7.x / 2.11.x.
@freezed
sealed class FolderDetail with _$FolderDetail {
  const factory FolderDetail({
    required Folder folder,
    required List<Folder> breadcrumb,
    required List<FolderSummary> subfolders,
    required int deckCount,
    required int cardCount,
    required int dueCount,
  }) = _FolderDetail;
}
