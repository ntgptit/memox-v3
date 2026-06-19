import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'folder_move_target.freezed.dart';

/// Why a folder cannot accept a move (decision rows F7, F15).
///
/// The picker disables — never hides — blocked rows so the rule is taught
/// in place (`docs/wireframes/25-shared-bottom-sheets.md` §folder-picker
/// §Forbidden).
enum FolderMoveBlock {
  /// The destination is the moved folder itself or one of its descendants —
  /// the move would create a cycle (decision row F7).
  cycle,

  /// The destination is locked to [ContentMode.decks] and cannot take a
  /// subfolder (decision row F15, typed `folder_contains_decks`).
  lockedToDecks,
}

/// A candidate destination for moving a folder, as shown in the
/// §folder-picker sheet.
///
/// `GetFolderMoveTargetsUseCase` returns the Library root ([id] `== null`) plus
/// every folder, each annotated so the picker can render and disable rows
/// up front — it performs the same descendant + content-mode checks that
/// `MoveFolderUseCase` enforces.
/// Contract: `docs/contracts/usecase-contracts/folder.md` §GetFolderMoveTargetsUseCase.
@freezed
sealed class FolderMoveTarget with _$FolderMoveTarget {
  const factory FolderMoveTarget({
    /// Destination folder id, or `null` for the Library root.
    required FolderId? id,

    /// The folder's own name; empty for the Library root (the picker supplies
    /// the localized root label).
    required String name,

    /// Ancestor names root -> leaf (inclusive of this folder); empty for the
    /// Library root. Used to render the breadcrumb path in the picker.
    required List<String> breadcrumb,

    /// `true` when this target is the moved folder's current parent — the
    /// picker pre-selects it.
    required bool isCurrentParent,

    /// Why the move is blocked, or `null` when the target can accept the move.
    required FolderMoveBlock? block,
  }) = _FolderMoveTarget;

  const FolderMoveTarget._();

  /// Whether this target can accept the move (no blocking reason).
  bool get isSelectable => block == null;
}
