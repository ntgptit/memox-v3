import 'package:memox/app/di/database_providers.dart';
import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/usecases/flashcard/check_manual_duplicate_flashcard_usecase.dart';
import 'package:memox/domain/usecases/flashcard/create_flashcard_usecase.dart';
import 'package:memox/domain/usecases/flashcard/update_flashcard_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flashcard_providers.g.dart';

/// Dependency-injection wiring for the flashcard feature: DAO → repository → use
/// cases (WBS 2.11.1 / 2.12.1 / 2.16.1 / 2.20.1). Presentation depends only on
/// the use-case providers (`docs/contracts/code-style.md` §Providers).

@riverpod
FlashcardDao flashcardDao(Ref ref) =>
    FlashcardDao(ref.watch(appDatabaseProvider));

@riverpod
FlashcardRepository flashcardRepository(Ref ref) => FlashcardRepositoryImpl(
  dao: ref.watch(flashcardDaoProvider),
  deckDao: ref.watch(deckDaoProvider),
);

@riverpod
CreateFlashcardUseCase createFlashcardUseCase(Ref ref) =>
    CreateFlashcardUseCase(repository: ref.watch(flashcardRepositoryProvider));

@riverpod
UpdateFlashcardUseCase updateFlashcardUseCase(Ref ref) =>
    UpdateFlashcardUseCase(repository: ref.watch(flashcardRepositoryProvider));

@riverpod
CheckManualDuplicateFlashcardUseCase checkManualDuplicateFlashcardUseCase(
  Ref ref,
) => CheckManualDuplicateFlashcardUseCase(
  repository: ref.watch(flashcardRepositoryProvider),
);
