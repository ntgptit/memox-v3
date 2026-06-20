import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_action_controller.g.dart';

/// Stateless presentation controller for Library folder mutations. Methods
/// delegate to the folder use cases and return the [Result] so the screen can
/// branch on success / typed failure inline (snackbar copy) — the Drift watch
/// stream refreshes the list automatically, so no manual invalidation is needed.
///
/// WBS 2.2.2 (rename), 2.3.2 (delete), 2.4.2 (move).
@riverpod
class LibraryActionController extends _$LibraryActionController {
  @override
  void build() {}

  /// Create a root folder with [name] and optional opaque color/icon tokens
  /// (trim / empty / duplicate rules live in the use case). Decision rows F1,
  /// F2, F20-F22.
  Future<Result<Folder>> create({
    required String name,
    String? color,
    String? icon,
  }) => ref
      .read(createRootFolderUseCaseProvider)
      .call(name: name, color: color, icon: icon);

  /// Create a subfolder of [parentId] with optional color/icon tokens. The
  /// content-mode lock (parent must not hold decks) lives in the use case.
  Future<Result<Folder>> createSubfolder({
    required FolderId parentId,
    required String name,
    String? color,
    String? icon,
  }) => ref
      .read(createSubfolderUseCaseProvider)
      .call(parentId: parentId, name: name, color: color, icon: icon);

  /// Create a deck in [folderId] (the folder must allow decks — enforced in the
  /// use case).
  Future<Result<Deck>> createDeck({
    required FolderId folderId,
    required String name,
    required TargetLanguage targetLanguage,
  }) => ref
      .read(createDeckUseCaseProvider)
      .call(
        parentFolderId: folderId,
        name: name,
        targetLanguage: targetLanguage,
      );

  /// Rename deck [deckId] (trim / empty / duplicate rules in the use case).
  Future<Result<Deck>> renameDeck({
    required DeckId deckId,
    required String newName,
  }) => ref.read(renameDeckUseCaseProvider).call(deckId: deckId, name: newName);

  /// Delete deck [deckId] and its cards (cascade). Caller MUST confirm first.
  Future<Result<void>> deleteDeck({required DeckId deckId}) =>
      ref.read(deleteDeckUseCaseProvider).call(id: deckId);

  /// Rename [id] to [newName] (trim / empty / duplicate rules live in the use
  /// case; no-op when unchanged). Decision rows F20-F22.
  Future<Result<Folder>> rename({
    required FolderId id,
    required String newName,
  }) => ref.read(renameFolderUseCaseProvider).call(id: id, newName: newName);

  /// Recursively delete [id] and its subtree (cascade). Highly destructive —
  /// the caller MUST confirm first. Decision rows F8, F9.
  Future<Result<void>> delete({required FolderId id}) =>
      ref.read(deleteFolderUseCaseProvider).call(id: id);

  /// Candidate destinations for moving [folderId] (Library root + every folder,
  /// blocked rows annotated). Decision row F18.
  Future<Result<List<FolderMoveTarget>>> moveTargets({
    required FolderId folderId,
  }) => ref.read(getFolderMoveTargetsUseCaseProvider).call(folderId: folderId);

  /// Move [id] under [newParentId] (or the Library root when `null`). Decision
  /// rows F7, F14-F17, F19.
  Future<Result<Folder>> move({
    required FolderId id,
    required FolderId? newParentId,
  }) => ref
      .read(moveFolderUseCaseProvider)
      .call(id: id, newParentId: newParentId);
}
