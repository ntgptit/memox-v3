import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/types/ids.dart';
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
