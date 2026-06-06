import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/ids.dart';

part 'folder_detail.freezed.dart';

/// One breadcrumb segment from Library root down to (and including) the current
/// folder (`docs/wireframes/05-folder-detail.md` §Breadcrumb).
@freezed
abstract class FolderBreadcrumbSegment with _$FolderBreadcrumbSegment {
  const factory FolderBreadcrumbSegment({
    required FolderId id,
    required String name,
  }) = _FolderBreadcrumbSegment;
}

/// A deck row with its card aggregates (`docs/wireframes/05-folder-detail.md`
/// §Deck row).
@freezed
abstract class DeckWithCount with _$DeckWithCount {
  const factory DeckWithCount({
    required Deck deck,
    required int cardCount,
    required int dueCount,
    required DateTime? lastStudiedAt,
  }) = _DeckWithCount;
}

/// Folder Detail read model — the folder, its breadcrumb path, and its direct
/// children. A folder holds **either** subfolders **or** decks (never both),
/// gated by `content_mode`; the unused list is empty.
@freezed
abstract class FolderDetail with _$FolderDetail {
  const factory FolderDetail({
    required Folder folder,
    required List<FolderBreadcrumbSegment> breadcrumb,
    required List<FolderWithCount> subfolders,
    required List<DeckWithCount> decks,
  }) = _FolderDetail;
}
