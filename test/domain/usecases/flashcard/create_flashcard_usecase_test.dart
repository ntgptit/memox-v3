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
import 'package:memox/domain/usecases/flashcard/create_flashcard_usecase.dart';

class _CreateCall {
  const _CreateCall({
    required this.deckId,
    required this.front,
    required this.back,
    required this.exampleSentence,
    required this.pronunciation,
    required this.hint,
    required this.tags,
  });

  final DeckId deckId;
  final String front;
  final String back;
  final String? exampleSentence;
  final String? pronunciation;
  final String? hint;
  final List<String> tags;
}

class _RecordingFlashcardRepository implements FlashcardRepository {
  _RecordingFlashcardRepository({Result<Flashcard>? createResult})
    : createResult = createResult ?? Result<Flashcard>.ok(_flashcard());

  final Result<Flashcard> createResult;

  _CreateCall? lastCreateCall;

  @override
  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) async {
    lastCreateCall = _CreateCall(
      deckId: deckId,
      front: front,
      back: back,
      exampleSentence: exampleSentence,
      pronunciation: pronunciation,
      hint: hint,
      tags: tags,
    );
    return createResult;
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

Flashcard _flashcard() => Flashcard(
  id: 'c1',
  deckId: 'd1',
  front: '안녕하세요',
  back: 'Hello',
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  group('CreateFlashcardUseCase', () {
    test('rejects a blank front before calling the repository', () async {
      final _RecordingFlashcardRepository repo =
          _RecordingFlashcardRepository();
      final CreateFlashcardUseCase useCase = CreateFlashcardUseCase(repo);

      final Result<Flashcard> result = await useCase.call(
        deckId: 'd1',
        front: '   ',
        back: 'Hello',
      );

      expect(result, isA<Err<Flashcard>>());
      expect((result as Err<Flashcard>).failure, isA<ValidationFailure>());
      expect(repo.lastCreateCall, isNull);
    });

    test('rejects a blank back before calling the repository', () async {
      final _RecordingFlashcardRepository repo =
          _RecordingFlashcardRepository();
      final CreateFlashcardUseCase useCase = CreateFlashcardUseCase(repo);

      final Result<Flashcard> result = await useCase.call(
        deckId: 'd1',
        front: 'Hello',
        back: '   ',
      );

      expect(result, isA<Err<Flashcard>>());
      expect((result as Err<Flashcard>).failure, isA<ValidationFailure>());
      expect(repo.lastCreateCall, isNull);
    });

    test('trims all text before delegating to the repository', () async {
      final _RecordingFlashcardRepository repo =
          _RecordingFlashcardRepository();
      final CreateFlashcardUseCase useCase = CreateFlashcardUseCase(repo);

      final Result<Flashcard> result = await useCase.call(
        deckId: 'd1',
        front: '  안녕하세요  ',
        back: '  Hello  ',
        exampleSentence: '  Example sentence  ',
        pronunciation: '  annyeonghaseyo  ',
        hint: '  Casual greeting  ',
      );

      expect(result, isA<Ok<Flashcard>>());
      expect(repo.lastCreateCall, isNotNull);
      expect(repo.lastCreateCall!.deckId, 'd1');
      expect(repo.lastCreateCall!.front, '안녕하세요');
      expect(repo.lastCreateCall!.back, 'Hello');
      expect(repo.lastCreateCall!.exampleSentence, 'Example sentence');
      expect(repo.lastCreateCall!.pronunciation, 'annyeonghaseyo');
      expect(repo.lastCreateCall!.hint, 'Casual greeting');
    });

    test('normalizes blank optional text to null', () async {
      final _RecordingFlashcardRepository repo =
          _RecordingFlashcardRepository();
      final CreateFlashcardUseCase useCase = CreateFlashcardUseCase(repo);

      await useCase.call(
        deckId: 'd1',
        front: 'Hello',
        back: 'World',
        exampleSentence: '   ',
        pronunciation: '   ',
        hint: '   ',
      );

      expect(repo.lastCreateCall, isNotNull);
      expect(repo.lastCreateCall!.exampleSentence, isNull);
      expect(repo.lastCreateCall!.pronunciation, isNull);
      expect(repo.lastCreateCall!.hint, isNull);
    });

    test('normalizes and deduplicates tags before delegating', () async {
      final _RecordingFlashcardRepository repo =
          _RecordingFlashcardRepository();
      final CreateFlashcardUseCase useCase = CreateFlashcardUseCase(repo);

      await useCase.call(
        deckId: 'd1',
        front: 'Hello',
        back: 'World',
        tags: <String>['  TOPIK II  ', '#topik ii', 'noun'],
      );

      expect(repo.lastCreateCall, isNotNull);
      expect(repo.lastCreateCall!.tags, <String>['topik ii', 'noun']);
    });

    test('rejects a comma in tags before calling the repository', () async {
      final _RecordingFlashcardRepository repo =
          _RecordingFlashcardRepository();
      final CreateFlashcardUseCase useCase = CreateFlashcardUseCase(repo);

      final Result<Flashcard> result = await useCase.call(
        deckId: 'd1',
        front: 'Hello',
        back: 'World',
        tags: <String>['bad,tag'],
      );

      expect(result, isA<Err<Flashcard>>());
      expect((result as Err<Flashcard>).failure, isA<ValidationFailure>());
      expect(repo.lastCreateCall, isNull);
    });
  });
}
