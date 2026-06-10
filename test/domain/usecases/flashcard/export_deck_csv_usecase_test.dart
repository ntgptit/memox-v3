import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/deck_csv_export.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/flashcard_status_filter.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/usecases/flashcard/export_deck_csv_usecase.dart';

void main() {
  group('ExportDeckCsvUseCase', () {
    test('rejects a blank deck id before calling the repository', () async {
      final _RecordingFlashcardRepository repository =
          _RecordingFlashcardRepository();
      final ExportDeckCsvUseCase useCase = ExportDeckCsvUseCase(repository);

      final Result<DeckCsvExport> result = await useCase.call(deckId: '   ');

      expect(result, isA<Err<DeckCsvExport>>());
      expect((result as Err<DeckCsvExport>).failure, isA<ValidationFailure>());
      expect(repository.lastExportDeckId, isNull);
    });

    test('trims the deck id before delegating', () async {
      final _RecordingFlashcardRepository repository =
          _RecordingFlashcardRepository();
      final ExportDeckCsvUseCase useCase = ExportDeckCsvUseCase(repository);

      final Result<DeckCsvExport> result = await useCase.call(
        deckId: '  deck-1  ',
      );

      expect(result, isA<Ok<DeckCsvExport>>());
      expect(repository.lastExportDeckId, 'deck-1');
    });
  });
}

final class _RecordingFlashcardRepository implements FlashcardRepository {
  _RecordingFlashcardRepository({Result<DeckCsvExport>? exportResult})
    : exportResult =
          exportResult ??
          const Result<DeckCsvExport>.ok(
            DeckCsvExport(
              deckId: 'deck-1',
              deckName: 'N5',
              fileName: 'N5.csv',
              csvText: 'front,back',
              exportedRowCount: 0,
            ),
          );

  final Result<DeckCsvExport> exportResult;

  DeckId? lastExportDeckId;

  @override
  Future<Result<DeckCsvExport>> exportDeckCsv({required DeckId deckId}) async {
    lastExportDeckId = deckId;
    return exportResult;
  }

  @override
  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<FlashcardDetail>> getFlashcardDetail({
    required FlashcardId flashcardId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Flashcard>>> existingByFrontBackPairs(
    DeckId deckId,
    List<({String front, String back})> pairs,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Result<int>> commitDeckImport({
    required DeckId deckId,
    required List<DeckImportPreviewRow> rows,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Flashcard>> updateFlashcard({
    required FlashcardId flashcardId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    DeckId deckId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
    FlashcardStatusFilter statusFilter = FlashcardStatusFilter.all,
    List<String> selectedTags = const <String>[],
    DateTime? now,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFlashcard({required FlashcardId flashcardId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> reorderFlashcards({
    required DeckId deckId,
    required List<FlashcardId> orderedIds,
  }) {
    throw UnimplementedError();
  }
}
