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
import 'package:memox/domain/usecases/flashcard/update_flashcard_usecase.dart';

Flashcard _flashcard() => Flashcard(
  id: 'c1',
  deckId: 'd1',
  front: '안녕하세요',
  back: 'Hello',
  exampleSentence: 'Example sentence',
  pronunciation: 'annyeonghaseyo',
  hint: 'Greeting root',
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 2),
);

class _UpdateCall {
  const _UpdateCall({
    required this.flashcardId,
    required this.front,
    required this.back,
    required this.exampleSentence,
    required this.pronunciation,
    required this.hint,
    required this.tags,
    required this.progressPolicy,
  });

  final FlashcardId flashcardId;
  final String front;
  final String back;
  final String? exampleSentence;
  final String? pronunciation;
  final String? hint;
  final List<String> tags;
  final FlashcardProgressEditPolicy progressPolicy;
}

class _RecordingFlashcardRepository implements FlashcardRepository {
  _RecordingFlashcardRepository({Result<Flashcard>? updateResult})
    : updateResult = updateResult ?? Result<Flashcard>.ok(_flashcard());

  final Result<Flashcard> updateResult;

  _UpdateCall? lastUpdateCall;

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
  }) async {
    lastUpdateCall = _UpdateCall(
      flashcardId: flashcardId,
      front: front,
      back: back,
      exampleSentence: exampleSentence,
      pronunciation: pronunciation,
      hint: hint,
      tags: tags,
      progressPolicy: progressPolicy,
    );
    return updateResult;
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

  @override
  Future<Result<DeckCsvExport>> exportDeckCsv({required DeckId deckId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<int>> commitDeckImport({
    required DeckId deckId,
    required List<DeckImportPreviewRow> rows,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('UpdateFlashcardUseCase', () {
    test('rejects a blank front before calling the repository', () async {
      final _RecordingFlashcardRepository repository =
          _RecordingFlashcardRepository();
      final UpdateFlashcardUseCase useCase = UpdateFlashcardUseCase(repository);

      final Result<Flashcard> result = await useCase.call(
        flashcardId: 'c1',
        front: '   ',
        back: 'Hello',
      );

      expect(result, isA<Err<Flashcard>>());
      expect((result as Err<Flashcard>).failure, isA<ValidationFailure>());
      expect(repository.lastUpdateCall, isNull);
    });

    test('normalizes tags and forwards the reset progress policy', () async {
      final _RecordingFlashcardRepository repository =
          _RecordingFlashcardRepository();
      final UpdateFlashcardUseCase useCase = UpdateFlashcardUseCase(repository);

      final Result<Flashcard> result = await useCase.call(
        flashcardId: 'c1',
        front: '  안녕  ',
        back: '  Hello there  ',
        exampleSentence: '  Example sentence  ',
        pronunciation: '  annyeonghaseyo  ',
        hint: '  Greeting root  ',
        tags: <String>['verb', 'verb', 'noun'],
        progressPolicy: FlashcardProgressEditPolicy.resetProgress,
      );

      expect(result, isA<Ok<Flashcard>>());
      expect(repository.lastUpdateCall, isNotNull);
      expect(repository.lastUpdateCall!.flashcardId, 'c1');
      expect(repository.lastUpdateCall!.front, '안녕');
      expect(repository.lastUpdateCall!.back, 'Hello there');
      expect(repository.lastUpdateCall!.exampleSentence, 'Example sentence');
      expect(repository.lastUpdateCall!.pronunciation, 'annyeonghaseyo');
      expect(repository.lastUpdateCall!.hint, 'Greeting root');
      expect(repository.lastUpdateCall!.tags, <String>['verb', 'noun']);
      expect(
        repository.lastUpdateCall!.progressPolicy,
        FlashcardProgressEditPolicy.resetProgress,
      );
    });
  });
}
