import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/card_history_dao.dart';
import 'package:memox/data/repositories/card_history_repository_impl.dart';
import 'package:memox/domain/repositories/card_history_repository.dart';
import 'package:memox/domain/usecases/history/get_card_history_header_usecase.dart';
import 'package:memox/domain/usecases/history/get_card_history_page_usecase.dart';
import 'package:memox/domain/usecases/history/reset_flashcard_progress_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_history_providers.g.dart';

/// Composition root for the Card History slice (data → domain wiring).
/// Presentation depends only on the use-case providers.

@Riverpod(keepAlive: true)
CardHistoryDao cardHistoryDao(Ref ref) =>
    CardHistoryDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
CardHistoryRepository cardHistoryRepository(Ref ref) =>
    CardHistoryRepositoryImpl(ref.watch(cardHistoryDaoProvider));

@Riverpod(keepAlive: true)
GetCardHistoryHeaderUseCase getCardHistoryHeaderUseCase(Ref ref) =>
    GetCardHistoryHeaderUseCase(ref.watch(cardHistoryRepositoryProvider));

@Riverpod(keepAlive: true)
GetCardHistoryPageUseCase getCardHistoryPageUseCase(Ref ref) =>
    GetCardHistoryPageUseCase(ref.watch(cardHistoryRepositoryProvider));

@Riverpod(keepAlive: true)
ResetFlashcardProgressUseCase resetFlashcardProgressUseCase(Ref ref) =>
    ResetFlashcardProgressUseCase(ref.watch(cardHistoryRepositoryProvider));
