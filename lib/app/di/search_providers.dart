import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/search_dao.dart';
import 'package:memox/data/repositories/search_repository_impl.dart';
import 'package:memox/domain/repositories/search_repository.dart';
import 'package:memox/domain/usecases/search/global_search_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_providers.g.dart';

/// Dependency-injection wiring for global search (WBS 3.5.1): DAO → repository →
/// use case. Presentation depends only on the use-case provider
/// (`docs/contracts/code-style.md` §Providers).

@riverpod
SearchDao searchDao(Ref ref) => SearchDao(ref.watch(appDatabaseProvider));

@riverpod
SearchRepository searchRepository(Ref ref) =>
    SearchRepositoryImpl(dao: ref.watch(searchDaoProvider));

@riverpod
GlobalSearchUseCase globalSearchUseCase(Ref ref) =>
    GlobalSearchUseCase(repository: ref.watch(searchRepositoryProvider));
