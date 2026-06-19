import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
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

/// Dependency-injection wiring for the folder feature: DAO → repository → use
/// cases. Presentation depends only on the use-case providers
/// (`docs/contracts/code-style.md` §Providers).

@riverpod
FolderDao folderDao(Ref ref) => FolderDao(ref.watch(appDatabaseProvider));

@riverpod
FolderRepository folderRepository(Ref ref) =>
    FolderRepositoryImpl(dao: ref.watch(folderDaoProvider));

@riverpod
CreateRootFolderUseCase createRootFolderUseCase(Ref ref) =>
    CreateRootFolderUseCase(repository: ref.watch(folderRepositoryProvider));

@riverpod
CreateSubfolderUseCase createSubfolderUseCase(Ref ref) =>
    CreateSubfolderUseCase(repository: ref.watch(folderRepositoryProvider));

@riverpod
RenameFolderUseCase renameFolderUseCase(Ref ref) =>
    RenameFolderUseCase(repository: ref.watch(folderRepositoryProvider));

@riverpod
DeleteFolderUseCase deleteFolderUseCase(Ref ref) =>
    DeleteFolderUseCase(repository: ref.watch(folderRepositoryProvider));

@riverpod
MoveFolderUseCase moveFolderUseCase(Ref ref) =>
    MoveFolderUseCase(repository: ref.watch(folderRepositoryProvider));

@riverpod
GetFolderMoveTargetsUseCase getFolderMoveTargetsUseCase(Ref ref) =>
    GetFolderMoveTargetsUseCase(
      repository: ref.watch(folderRepositoryProvider),
    );

@riverpod
ReorderFoldersUseCase reorderFoldersUseCase(Ref ref) =>
    ReorderFoldersUseCase(repository: ref.watch(folderRepositoryProvider));

@riverpod
WatchLibraryOverviewUseCase watchLibraryOverviewUseCase(Ref ref) =>
    WatchLibraryOverviewUseCase(
      repository: ref.watch(folderRepositoryProvider),
    );

@riverpod
WatchFolderDetailUseCase watchFolderDetailUseCase(Ref ref) =>
    WatchFolderDetailUseCase(repository: ref.watch(folderRepositoryProvider));
