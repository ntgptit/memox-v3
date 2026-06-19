import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Watch the Folder-detail read model for [FolderId] (folder + breadcrumb +
/// child folders + counts). Emits `null` once the folder no longer exists.
///
/// Contract: `docs/contracts/usecase-contracts/folder.md` §WatchFolderChildrenUseCase.
/// Read model: [FolderDetail]. Decision row F12 (deck counts) deferred until the
/// decks/flashcards tables ship.
class WatchFolderDetailUseCase {
  const WatchFolderDetailUseCase({required this.repository});

  final FolderRepository repository;

  Stream<FolderDetail?> call({required FolderId id}) =>
      repository.watchFolderDetail(id);
}
