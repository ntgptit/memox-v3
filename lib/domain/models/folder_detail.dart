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
/// - [deckCount] / [cardCount] / [dueCount] — counts for [folder], same
///   semantics as [FolderSummary] ([deckCount] direct; [cardCount]/[dueCount]
///   recursive over the subtree). Live as of WBS 3.7.1.
///
/// > V1 scope (WBS 3.2.1): child **decks** are not listed as tiles yet — that
/// > read model lands with the Folder-detail FE/deck-tile work. The aggregate
/// > counts above are populated.
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
