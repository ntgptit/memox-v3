import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'deck_move_target.freezed.dart';

/// Why a folder cannot accept a moved deck (decision rows D9, D10).
///
/// The picker disables — never hides — blocked rows so the rule is taught in
/// place (`docs/wireframes/25-shared-bottom-sheets.md` §folder-picker).
enum DeckMoveBlock {
  /// The destination folder is locked to [ContentMode.subfolders] and cannot
  /// hold a deck (decision row D9, typed `folder_contains_subfolders`).
  lockedToSubfolders,
}

/// A candidate destination for moving a deck, as shown in the deck §folder-picker
/// sheet (kit `04-folder-detail--move-sheet`).
///
/// Unlike [FolderMoveTarget] there is **no Library-root option** — a deck always
/// belongs to a folder (`decks.folder_id` is non-null), so every target is a real
/// folder ([id] non-null). `GetDeckMoveTargetsUseCase` returns every folder, each
/// annotated so the picker can render and disable rows up front; it performs the
/// same content-mode check `MoveDeckUseCase` enforces.
///
/// Contract: `docs/contracts/usecase-contracts/deck.md` §GetDeckMoveTargetsUseCase.
@freezed
sealed class DeckMoveTarget with _$DeckMoveTarget {
  const factory DeckMoveTarget({
    /// Destination folder id.
    required FolderId id,

    /// The folder's own name.
    required String name,

    /// Ancestor names root -> leaf (inclusive of this folder), for the picker
    /// breadcrumb path.
    required List<String> breadcrumb,

    /// `true` when this is the deck's current folder — the picker pre-selects it.
    required bool isCurrentParent,

    /// Why the move is blocked, or `null` when the folder can accept the deck.
    required DeckMoveBlock? block,
  }) = _DeckMoveTarget;

  const DeckMoveTarget._();

  /// Whether this target can accept the deck (no blocking reason).
  bool get isSelectable => block == null;
}
