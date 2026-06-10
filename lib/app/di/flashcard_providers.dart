import 'package:memox/app/di/database_providers.dart';
import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/usecases/flashcard/commit_deck_import_usecase.dart';
import 'package:memox/domain/usecases/flashcard/create_flashcard_usecase.dart';
import 'package:memox/domain/usecases/flashcard/delete_flashcard_usecase.dart';
import 'package:memox/domain/usecases/flashcard/export_deck_csv_usecase.dart';
import 'package:memox/domain/usecases/flashcard/get_flashcard_detail_usecase.dart';
import 'package:memox/domain/usecases/flashcard/parse_deck_import_csv_usecase.dart';
import 'package:memox/domain/usecases/flashcard/prepare_deck_import_usecase.dart';
import 'package:memox/domain/usecases/flashcard/reorder_flashcards_usecase.dart';
import 'package:memox/domain/usecases/flashcard/update_flashcard_usecase.dart';
import 'package:memox/domain/usecases/flashcard/watch_flashcard_list_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flashcard_providers.g.dart';

/// Composition root for the flashcard slice (data → domain wiring).
///
/// Lives in `lib/app/di` because it imports the data layer; presentation
/// depends only on the use-case providers, never on the repository or DAO. The
/// repository reuses [folderDaoProvider] for the deck row + breadcrumb + the
/// content-revision change stream.

@Riverpod(keepAlive: true)
FlashcardDao flashcardDao(Ref ref) =>
    FlashcardDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
FlashcardRepository flashcardRepository(Ref ref) => FlashcardRepositoryImpl(
  ref.watch(flashcardDaoProvider),
  ref.watch(folderDaoProvider),
);

@Riverpod(keepAlive: true)
CreateFlashcardUseCase createFlashcardUseCase(Ref ref) =>
    CreateFlashcardUseCase(ref.watch(flashcardRepositoryProvider));

@Riverpod(keepAlive: true)
GetFlashcardDetailUseCase getFlashcardDetailUseCase(Ref ref) =>
    GetFlashcardDetailUseCase(ref.watch(flashcardRepositoryProvider));

@Riverpod(keepAlive: true)
WatchFlashcardListUseCase watchFlashcardListUseCase(Ref ref) =>
    WatchFlashcardListUseCase(ref.watch(flashcardRepositoryProvider));

@Riverpod(keepAlive: true)
DeleteFlashcardUseCase deleteFlashcardUseCase(Ref ref) =>
    DeleteFlashcardUseCase(ref.watch(flashcardRepositoryProvider));

@Riverpod(keepAlive: true)
ReorderFlashcardsUseCase reorderFlashcardsUseCase(Ref ref) =>
    ReorderFlashcardsUseCase(ref.watch(flashcardRepositoryProvider));

@Riverpod(keepAlive: true)
UpdateFlashcardUseCase updateFlashcardUseCase(Ref ref) =>
    UpdateFlashcardUseCase(ref.watch(flashcardRepositoryProvider));

@Riverpod(keepAlive: true)
ParseDeckImportCsvUseCase parseDeckImportCsvUseCase(Ref ref) =>
    const ParseDeckImportCsvUseCase();

@Riverpod(keepAlive: true)
PrepareDeckImportUseCase prepareDeckImportUseCase(Ref ref) =>
    PrepareDeckImportUseCase(ref.watch(flashcardRepositoryProvider));

@Riverpod(keepAlive: true)
CommitDeckImportUseCase commitDeckImportUseCase(Ref ref) =>
    CommitDeckImportUseCase(ref.watch(flashcardRepositoryProvider));

@Riverpod(keepAlive: true)
ExportDeckCsvUseCase exportDeckCsvUseCase(Ref ref) =>
    ExportDeckCsvUseCase(ref.watch(flashcardRepositoryProvider));
