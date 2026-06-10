import 'package:memox/app/di/database_providers.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/repositories/flashcard_bulk_repository_impl.dart';
import 'package:memox/domain/repositories/flashcard_bulk_repository.dart';
import 'package:memox/domain/usecases/bulk/delete_flashcards_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bulk_providers.g.dart';

@Riverpod(keepAlive: true)
FlashcardDao bulkFlashcardDao(Ref ref) =>
    FlashcardDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
FlashcardBulkRepository flashcardBulkRepository(Ref ref) =>
    FlashcardBulkRepositoryImpl(ref.watch(bulkFlashcardDaoProvider));

@Riverpod(keepAlive: true)
DeleteFlashcardsUseCase deleteFlashcardsUseCase(Ref ref) =>
    DeleteFlashcardsUseCase(ref.watch(flashcardBulkRepositoryProvider));
