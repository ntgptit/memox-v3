import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/usecases/folder/create_root_folder_usecase.dart';
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
WatchLibraryOverviewUseCase watchLibraryOverviewUseCase(Ref ref) =>
    WatchLibraryOverviewUseCase(ref.watch(folderRepositoryProvider));

@Riverpod(keepAlive: true)
CreateRootFolderUseCase createRootFolderUseCase(Ref ref) =>
    CreateRootFolderUseCase(ref.watch(folderRepositoryProvider));
