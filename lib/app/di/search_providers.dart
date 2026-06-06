import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/search_dao.dart';
import 'package:memox/data/repositories/search_repository_impl.dart';
import 'package:memox/domain/repositories/search_repository.dart';
import 'package:memox/domain/usecases/search/global_search_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_providers.g.dart';

/// Composition root for the global-search slice (data → domain wiring).
///
/// Lives in `lib/app/di` because it imports the data layer; presentation
/// depends only on [globalSearchUseCaseProvider], never on the repository/DAO.

@Riverpod(keepAlive: true)
SearchDao searchDao(Ref ref) => SearchDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) =>
    SearchRepositoryImpl(ref.watch(searchDaoProvider));

@Riverpod(keepAlive: true)
GlobalSearchUseCase globalSearchUseCase(Ref ref) =>
    GlobalSearchUseCase(ref.watch(searchRepositoryProvider));
