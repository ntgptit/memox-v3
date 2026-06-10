import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/target_language.dart';

class RenameDeckCall {
  const RenameDeckCall({required this.deckId, required this.name});

  final DeckId deckId;
  final String name;
}

class MoveDeckCall {
  const MoveDeckCall({required this.deckId, required this.newParentId});

  final DeckId deckId;
  final FolderId newParentId;
}

class ReorderFoldersCall {
  const ReorderFoldersCall({required this.parentId, required this.orderedIds});

  final FolderId? parentId;
  final List<FolderId> orderedIds;
}

class ReorderDecksCall {
  const ReorderDecksCall({required this.parentId, required this.orderedIds});

  final FolderId parentId;
  final List<DeckId> orderedIds;
}

class FolderRepositoryTestDouble implements FolderRepository {
  FolderRepositoryTestDouble({
    Result<Deck>? renameDeckResult,
    Result<Deck>? moveDeckResult,
    Result<void>? reorderFoldersResult,
    Result<void>? reorderDecksResult,
  }) : renameDeckResult = renameDeckResult ?? Result<Deck>.ok(_deck()),
       moveDeckResult = moveDeckResult ?? Result<Deck>.ok(_deck()),
       reorderFoldersResult =
           reorderFoldersResult ?? const Result<void>.ok(null),
       reorderDecksResult = reorderDecksResult ?? const Result<void>.ok(null);

  final Result<Deck> renameDeckResult;
  final Result<Deck> moveDeckResult;
  final Result<void> reorderFoldersResult;
  final Result<void> reorderDecksResult;

  RenameDeckCall? lastRenameDeckCall;
  MoveDeckCall? lastMoveDeckCall;
  ReorderFoldersCall? lastReorderFoldersCall;
  ReorderDecksCall? lastReorderDecksCall;

  @override
  Future<Result<Deck>> renameDeck({
    required DeckId deckId,
    required String name,
  }) async {
    lastRenameDeckCall = RenameDeckCall(deckId: deckId, name: name);
    return renameDeckResult;
  }

  @override
  Future<Result<Deck>> moveDeck({
    required DeckId deckId,
    required FolderId newParentId,
  }) async {
    lastMoveDeckCall = MoveDeckCall(deckId: deckId, newParentId: newParentId);
    return moveDeckResult;
  }

  @override
  Future<Result<void>> reorderFolders({
    required FolderId? parentId,
    required List<FolderId> orderedIds,
  }) async {
    lastReorderFoldersCall = ReorderFoldersCall(
      parentId: parentId,
      orderedIds: orderedIds,
    );
    return reorderFoldersResult;
  }

  @override
  Future<Result<void>> reorderDecks({
    required FolderId parentId,
    required List<DeckId> orderedIds,
  }) async {
    lastReorderDecksCall = ReorderDecksCall(
      parentId: parentId,
      orderedIds: orderedIds,
    );
    return reorderDecksResult;
  }

  @override
  Future<Result<Deck>> createDeck({
    required FolderId parentFolderId,
    required String name,
    required TargetLanguage targetLanguage,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Folder>> createRootFolder({required String name}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Folder>> createSubfolder({
    required FolderId parentId,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteDeck({required DeckId deckId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFolder({required FolderId folderId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<FolderMoveTarget>>> getFolderMoveTargets({
    required FolderId folderId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Folder>> moveFolder({
    required FolderId folderId,
    required FolderId? newParentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Folder>> renameFolder({
    required FolderId folderId,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<Result<FolderDetail>> watchFolderDetail(
    String folderId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<Result<LibraryOverviewReadModel>> watchLibraryOverview({
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
  }) {
    throw UnimplementedError();
  }

  static Deck _deck() => Deck(
    id: 'd1',
    folderId: 'f1',
    name: 'Deck',
    targetLanguage: TargetLanguage.korean,
    sortOrder: 0,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}
