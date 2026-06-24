import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/card_history_dao.dart';
import 'package:memox/data/repositories/card_history_repository_impl.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/usecases/history/get_card_history_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_history_providers.g.dart';

/// Dependency-injection wiring for Card History reads (WBS 7.6.1–7.6.2):
/// DAO → repository → use case.

@Riverpod(keepAlive: true)
CardHistoryDao cardHistoryDao(Ref ref) =>
    CardHistoryDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
CardHistoryRepository cardHistoryRepository(Ref ref) =>
    CardHistoryRepositoryImpl(dao: ref.watch(cardHistoryDaoProvider));

@riverpod
GetCardHistoryUseCase getCardHistoryUseCase(Ref ref) =>
    GetCardHistoryUseCase(repository: ref.watch(cardHistoryRepositoryProvider));
