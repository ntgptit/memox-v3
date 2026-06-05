import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'folder_move_target.freezed.dart';

/// Why a candidate folder cannot accept the folder being moved
/// (`docs/wireframes/25-shared-bottom-sheets.md` §folder-picker). Invalid
/// destinations are shown **disabled with a reason**, never hidden.
enum FolderMoveBlock {
  /// The folder being moved itself, or one of its descendants — picking it
  /// would create a cycle.
  cycle,

  /// The candidate is locked to `decks` mode and cannot hold subfolders.
  lockedToDecks,
}

/// A candidate destination when moving a folder
/// (`docs/contracts/usecase-contracts/folder.md` §GetFolderMoveTargetsUseCase).
///
/// [id] is `null` for the Library root. [breadcrumb] is the root→leaf folder
/// names (empty for root). [block] is non-null when the row must render disabled
/// with its reason; [isCurrentParent] marks the folder's present location (the
/// default selection — a no-op if chosen).
@freezed
abstract class FolderMoveTarget with _$FolderMoveTarget {
  const factory FolderMoveTarget({
    required FolderId? id,
    required List<String> breadcrumb,
    required bool isCurrentParent,
    FolderMoveBlock? block,
  }) = _FolderMoveTarget;

  const FolderMoveTarget._();

  /// Selectable in the picker list (a reason-blocked row is not).
  bool get isSelectable => block == null;
}
