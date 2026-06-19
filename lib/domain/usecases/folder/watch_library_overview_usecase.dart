import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/repositories/folder_repository.dart';

/// Watch the Library root read model (root folders + counts, stable order).
///
/// Contract: `docs/contracts/usecase-contracts/folder.md` §WatchRootChildrenUseCase.
/// Read model: [LibraryOverview]. Decision row F13 (recursive counts) deferred
/// until the decks/flashcards tables ship.
class WatchLibraryOverviewUseCase {
  const WatchLibraryOverviewUseCase({required this.repository});

  final FolderRepository repository;

  Stream<LibraryOverview> call() => repository.watchLibraryOverview();
}
