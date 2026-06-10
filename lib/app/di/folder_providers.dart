import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/usecases/deck/create_deck_usecase.dart';
import 'package:memox/domain/usecases/deck/delete_deck_usecase.dart';
import 'package:memox/domain/usecases/deck/move_deck_usecase.dart';
import 'package:memox/domain/usecases/deck/rename_deck_usecase.dart';
import 'package:memox/domain/usecases/deck/reorder_decks_usecase.dart';
import 'package:memox/domain/usecases/folder/create_root_folder_usecase.dart';
import 'package:memox/domain/usecases/folder/create_subfolder_usecase.dart';
import 'package:memox/domain/usecases/folder/delete_folder_usecase.dart';
import 'package:memox/domain/usecases/folder/get_folder_move_targets_usecase.dart';
import 'package:memox/domain/usecases/folder/move_folder_usecase.dart';
import 'package:memox/domain/usecases/folder/rename_folder_usecase.dart';
import 'package:memox/domain/usecases/folder/reorder_folders_usecase.dart';
import 'package:memox/domain/usecases/folder/watch_folder_detail_usecase.dart';
import 'package:memox/domain/usecases/folder/watch_library_overview_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_providers.g.dart';

/// Composition root for the folder slice (data → domain wiring).
///
/// Lives in `lib/app/di` because it imports the data layer; presentation
/// depends only on the use-case provider, never on the repository or DAO.

@Riverpod(keepAlive: true)
FolderDao folderDao(Ref ref) => FolderDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) =>
    FolderRepositoryImpl(ref.watch(folderDaoProvider));

@Riverpod(keepAlive: true)
LibraryOverviewUseCase watchLibraryOverviewUseCase(Ref ref) =>
    LibraryOverviewUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
CreateRootFolderUseCase createRootFolderUseCase(Ref ref) =>
    CreateRootFolderUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
WatchFolderDetailUseCase watchFolderDetailUseCase(Ref ref) =>
    WatchFolderDetailUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
CreateSubfolderUseCase createSubfolderUseCase(Ref ref) =>
    CreateSubfolderUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
CreateDeckUseCase createDeckUseCase(Ref ref) =>
    CreateDeckUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
DeleteDeckUseCase deleteDeckUseCase(Ref ref) =>
    DeleteDeckUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
MoveDeckUseCase moveDeckUseCase(Ref ref) =>
    MoveDeckUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
RenameDeckUseCase renameDeckUseCase(Ref ref) =>
    RenameDeckUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
RenameFolderUseCase renameFolderUseCase(Ref ref) =>
    RenameFolderUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
MoveFolderUseCase moveFolderUseCase(Ref ref) =>
    MoveFolderUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
ReorderFoldersUseCase reorderFoldersUseCase(Ref ref) =>
    ReorderFoldersUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
ReorderDecksUseCase reorderDecksUseCase(Ref ref) =>
    ReorderDecksUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
DeleteFolderUseCase deleteFolderUseCase(Ref ref) =>
    DeleteFolderUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
FolderMoveTargetsUseCase getFolderMoveTargetsUseCase(Ref ref) =>
    FolderMoveTargetsUseCase(ref.watch(folderRepositoryProvider));
