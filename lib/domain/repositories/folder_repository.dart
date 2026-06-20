import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

/// Port for all folder persistence. Use cases depend on this interface;
/// `FolderRepositoryImpl` (data layer) implements it.
///
/// Result/error style uses the project's current record-based [Result] (not
/// `Either`/`fpdart` — see the target-architecture note in
/// `docs/contracts/repository-contracts/folder-repository.md`). Streams emit the
/// read model directly (no [Result] wrapper); load/empty/error UI states are
/// derived by the presentation layer from `AsyncValue`.
///
/// Mutation rules (validation, content-mode locks, cascade) live behind these
/// methods, never in the UI — `docs/business/folder/folder-management.md`
/// §Agent rule.
abstract interface class FolderRepository {
  /// Library root read model: root folders (stable order) + their counts.
  Stream<LibraryOverview> watchLibraryOverview();

  /// Folder-detail read model for [id]: folder + breadcrumb + child folders +
  /// counts. Emits `null` when the folder does not exist (e.g. just deleted).
  Stream<FolderDetail?> watchFolderDetail(FolderId id);

  /// Create a root folder (`parent_id = NULL`, `content_mode = unlocked`).
  ///
  /// Rejects empty-after-trim ([ValidationCode.empty]) and case-insensitive
  /// duplicate among root folders ([ValidationCode.duplicate]). Decision rows
  /// F1, F2.
  Future<Result<Folder>> createRootFolder({required String name});

  /// Create a subfolder under [parentId] and lock the parent to
  /// [ContentMode.subfolders] when it was [ContentMode.unlocked] — one
  /// transaction.
  ///
  /// Rejects: missing parent ([NotFoundFailure]); parent locked to decks
  /// ([UnsupportedActionFailure] `folder_contains_decks`); empty-after-trim;
  /// duplicate among siblings. Decision rows F3, F4.
  Future<Result<Folder>> createSubfolder({
    required FolderId parentId,
    required String name,
  });

  /// Rename [id] to [newName].
  ///
  /// Trims; rejects empty and case-insensitive duplicate among siblings; no-op
  /// (returns the unchanged folder) when the trimmed name equals the current
  /// name. Decision row F8.
  Future<Result<Folder>> renameFolder({
    required FolderId id,
    required String newName,
  });

  /// Recursively delete [id] and its descendant folders in one transaction,
  /// then revert the old parent to [ContentMode.unlocked] when it has no
  /// remaining children. Decision rows F8, F9.
  ///
  /// > V1 scope: deletes descendant **folders**; each removed folder's **decks**
  /// > go with it via the `decks.folder_id` ON DELETE CASCADE FK (schema v2).
  /// > Flashcard/progress/session cleanup is added when those tables ship
  /// > (WBS 2.11.x onward) — see
  /// > `docs/contracts/repository-contracts/folder-repository.md`.
  Future<Result<void>> deleteFolder({required FolderId id});

  /// Move [id] under [newParentId] (or to the Library root when `null`) in one
  /// transaction: recompute its `sort_order`, lock an unlocked destination to
  /// [ContentMode.subfolders], and revert the old parent to
  /// [ContentMode.unlocked] when emptied.
  ///
  /// No-op (returns the unchanged folder) when [newParentId] equals the current
  /// parent. Rejects: missing folder or destination ([NotFoundFailure]);
  /// destination locked to decks ([UnsupportedActionFailure]
  /// `folder_contains_decks`); a destination that is the folder itself or a
  /// descendant ([ValidationCode.cycleDetected]); a duplicate name among the
  /// destination siblings ([ValidationCode.duplicate]). Decision rows F7,
  /// F14-F17.
  ///
  /// > V1 scope: folders only — deck/flashcard subtree relocation lands with
  /// > those tables (WBS 2.7.x onward).
  Future<Result<Folder>> moveFolder({
    required FolderId id,
    required FolderId? newParentId,
  });

  /// List every move destination for [folderId]: the Library root (`id == null`)
  /// plus all folders, each annotated with `isCurrentParent` and a non-null
  /// `block` reason when it cannot accept the move (the folder itself and its
  /// descendants are [FolderMoveBlock.cycle]; decks-locked folders are
  /// [FolderMoveBlock.lockedToDecks]). Pure read. Decision row F18.
  Future<Result<List<FolderMoveTarget>>> getFolderMoveTargets({
    required FolderId folderId,
  });

  /// Persist a manual sibling order: [orderedIds] must be the full set of
  /// folders under [parentId] (root siblings when `null`). Writes `sort_order`
  /// by list position in one transaction.
  ///
  /// Rejects ([ValidationCode.invalidFormat], preserving the previous order)
  /// when [orderedIds] has duplicates or does not match the sibling set
  /// exactly (missing, extra, cross-parent or partial). Decision rows F10, F11.
  Future<Result<void>> reorderFolders({
    required FolderId? parentId,
    required List<FolderId> orderedIds,
  });

  // ---- Deck mutations ----
  //
  // Decks are folder-owned, so their mutations live on the folder repository
  // (no separate `DeckRepository`) — `docs/business/deck/deck-management.md`
  // §Source files to inspect. Deck delete (WBS 2.9.1) is implemented below;
  // due/card counts (WBS 3.7.x) remain deferred until the recursive count read
  // model ships; see `docs/project-management/wbs.md`.

  /// Create a deck inside [folderId] and lock the parent to [ContentMode.decks]
  /// when it was [ContentMode.unlocked] — one transaction. The deck is appended
  /// at the end of the folder's `sort_order`.
  ///
  /// Rejects: missing folder ([NotFoundFailure]); folder locked to subfolders
  /// ([UnsupportedActionFailure] `folder_contains_subfolders`); empty-after-trim
  /// name ([ValidationCode.empty]); case-insensitive duplicate among sibling
  /// decks ([ValidationCode.duplicate]). Decision rows D1, D2.
  Future<Result<Deck>> createDeck({
    required FolderId folderId,
    required String name,
    required TargetLanguage targetLanguage,
  });

  /// Rename [deckId] to [newName], preserving folder ownership and `sort_order`.
  ///
  /// Trims; rejects empty and case-insensitive duplicate among sibling decks;
  /// no-op (returns the unchanged deck) when the trimmed name equals the current
  /// name. Decision rows D6, D7.
  Future<Result<Deck>> renameDeck({
    required DeckId deckId,
    required String newName,
  });

  /// Persist a manual deck order: [orderedIds] must be the full set of decks
  /// under [folderId]. Writes `sort_order` by list position in one transaction.
  ///
  /// Rejects ([ValidationCode.invalidFormat], preserving the previous order)
  /// when [orderedIds] has duplicates or does not match the deck set exactly
  /// (missing, extra, cross-folder or partial). Decision rows D4, D8.
  Future<Result<void>> reorderDecks({
    required FolderId folderId,
    required List<DeckId> orderedIds,
  });

  /// Move [deckId] into [newFolderId] in one transaction: append it at the end
  /// of the destination's `sort_order`, lock an unlocked destination to
  /// [ContentMode.decks], and revert the source folder to [ContentMode.unlocked]
  /// when it loses its last deck. Never touches flashcards/progress/tags.
  ///
  /// No-op (returns the unchanged deck) when [newFolderId] equals the current
  /// folder. Rejects: missing deck or destination ([NotFoundFailure]);
  /// destination locked to subfolders ([UnsupportedActionFailure]
  /// `folder_contains_subfolders`); a duplicate name among destination decks
  /// ([ValidationCode.duplicate]). Decision rows D9, D10.
  Future<Result<Deck>> moveDeck({
    required DeckId deckId,
    required FolderId newFolderId,
  });

  /// Delete [deckId] and its dependent data in one transaction, then revert the
  /// source folder to [ContentMode.unlocked] when it loses its last deck.
  ///
  /// The deck's flashcards (and, through the schema cascade chain, their
  /// `flashcard_progress` + `flashcard_tags` rows) are removed by the
  /// `flashcards.deck_id` ON DELETE CASCADE FK — see
  /// `docs/database/schema-contract.md` §flashcards. Rejects a missing deck
  /// ([NotFoundFailure]). Highly destructive: the caller MUST confirm first.
  /// Decision row D3.
  ///
  /// > V1 scope: deck row + flashcards/progress/tags. Study attempt/session
  /// > cleanup is added when those tables ship (WBS 4.x) — see
  /// > `docs/contracts/repository-contracts/deck-repository.md`.
  Future<Result<void>> deleteDeck({required DeckId deckId});
}
