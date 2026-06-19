import 'package:memox/data/datasources/local/daos/example_dao.dart';
import 'package:memox/data/datasources/local/daos/example_stub_dao.dart';
import 'package:memox/data/repositories/example_repository_impl.dart';
import 'package:memox/domain/repositories/example_repository.dart';
import 'package:memox/domain/usecases/example_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Dependency-injection providers for the Clean Architecture baseline.
///
/// Demonstrates the canonical wiring direction for every feature:
/// DAO (data source) → repository implementation → use case. Widgets/notifiers
/// depend only on the use-case provider; the lower layers stay encapsulated.
///
/// All providers use Riverpod Annotation v3 codegen (`@riverpod`). Manual
/// `Provider`/`ProviderContainer` wiring is forbidden — see
/// `docs/contracts/code-style.md` §Providers.
@riverpod
ExampleDao exampleDao(Ref ref) => const ExampleStubDao();

@riverpod
ExampleRepository exampleRepository(Ref ref) =>
    ExampleRepositoryImpl(exampleDao: ref.watch(exampleDaoProvider));

@riverpod
ExampleUseCase exampleUseCase(Ref ref) =>
    ExampleUseCase(repository: ref.watch(exampleRepositoryProvider));
