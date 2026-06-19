import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/ids.dart';

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
  /// > V1 scope: cascades descendant **folders** only. Deck/flashcard/progress/
  /// > session cleanup is added when those tables ship (WBS 2.7.x onward) — see
  /// > `docs/contracts/repository-contracts/folder-repository.md`.
  Future<Result<void>> deleteFolder({required FolderId id});
}
