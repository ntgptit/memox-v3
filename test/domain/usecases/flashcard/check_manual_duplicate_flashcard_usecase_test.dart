import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_duplicate_check_result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/usecases/flashcard/check_manual_duplicate_flashcard_usecase.dart';

/// Records the arguments forwarded to the repository and returns a canned
/// result, so the use-case test verifies pure delegation (WBS 2.20.1).
class _RecordingFlashcardRepository implements FlashcardRepository {
  FlashcardDuplicateCheckResult result = FlashcardDuplicateCheckResult.unique;
  Map<String, Object?>? lastCall;

  @override
  Future<Result<FlashcardDuplicateCheckResult>> checkManualDuplicate({
    required DeckId deckId,
    required String front,
    required String back,
    FlashcardId? excludeId,
  }) async {
    lastCall = <String, Object?>{
      'deckId': deckId,
      'front': front,
      'back': back,
      'excludeId': excludeId,
    };
    return (failure: null, data: result);
  }

  @override
  Stream<Result<FlashcardListDetail>> watchFlashcardList(
    DeckId deckId, {
    String? searchTerm,
    List<TagName> tags = const <TagName>[],
    ContentSortMode sort = ContentSortMode.manual,
  }) => throw UnimplementedError();

  @override
  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
  }) => throw UnimplementedError();

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
  }) => throw UnimplementedError();

  @override
  Future<Result<void>> deleteFlashcard({required FlashcardId flashcardId}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> reorderFlashcards({
    required DeckId deckId,
    required List<FlashcardId> orderedIds,
  }) => throw UnimplementedError();
}

void main() {
  group('CheckManualDuplicateFlashcardUseCase', () {
    test('forwards all arguments to the repository', () async {
      final _RecordingFlashcardRepository repo =
          _RecordingFlashcardRepository();
      final CheckManualDuplicateFlashcardUseCase useCase =
          CheckManualDuplicateFlashcardUseCase(repository: repo);

      await useCase.call(
        deckId: 'deck',
        front: 'apple',
        back: '사과',
        excludeId: 'self',
      );

      expect(repo.lastCall, <String, Object?>{
        'deckId': 'deck',
        'front': 'apple',
        'back': '사과',
        'excludeId': 'self',
      });
    });

    test('returns the repository duplicate result', () async {
      final _RecordingFlashcardRepository repo = _RecordingFlashcardRepository()
        ..result = const FlashcardDuplicateCheckResult(
          isDuplicate: true,
          matchingFlashcardIds: <FlashcardId>['c1'],
        );
      final CheckManualDuplicateFlashcardUseCase useCase =
          CheckManualDuplicateFlashcardUseCase(repository: repo);

      final Result<FlashcardDuplicateCheckResult> result = await useCase.call(
        deckId: 'deck',
        front: 'apple',
        back: '사과',
      );

      expect(result.data!.isDuplicate, isTrue);
      expect(result.data!.matchingFlashcardIds, <String>['c1']);
    });
  });
}
