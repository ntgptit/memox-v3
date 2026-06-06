import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
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
  });

  final DeckId deckId;
  final String front;
  final String back;
  final String? exampleSentence;
  final String? pronunciation;
  final String? hint;
}

class _RecordingFlashcardRepository implements FlashcardRepository {
  _RecordingFlashcardRepository({
    Result<Flashcard>? createResult,
  }) : createResult = createResult ?? Result<Flashcard>.ok(_flashcard());

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
  }) async {
    lastCreateCall = _CreateCall(
      deckId: deckId,
      front: front,
      back: back,
      exampleSentence: exampleSentence,
      pronunciation: pronunciation,
      hint: hint,
    );
    return createResult;
  }

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    DeckId deckId, {
    String? searchTerm,
    ContentSortMode sort = ContentSortMode.manual,
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
  });
}
