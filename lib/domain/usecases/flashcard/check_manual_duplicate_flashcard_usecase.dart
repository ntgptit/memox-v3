import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_detail.dart';
import 'package:memox/domain/models/flashcard_duplicate_check_result.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Checks whether a manual save would duplicate an existing card in the same
/// deck.
class CheckManualDuplicateFlashcardUseCase {
  const CheckManualDuplicateFlashcardUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<FlashcardDuplicateCheckResult>> call({
    required DeckId deckId,
    required String front,
    required String back,
    FlashcardId? flashcardId,
  }) async {
    final String trimmedDeckId = StringUtils.trimmed(deckId);
    if (trimmedDeckId.isEmpty) {
      return Future<Result<FlashcardDuplicateCheckResult>>.value(
        const Result<FlashcardDuplicateCheckResult>.err(
          Failure.validation(field: 'deckId', code: ValidationCode.empty),
        ),
      );
    }

    final String trimmedFront = StringUtils.trimmed(front);
    if (trimmedFront.isEmpty) {
      return Future<Result<FlashcardDuplicateCheckResult>>.value(
        const Result<FlashcardDuplicateCheckResult>.err(
          Failure.validation(field: 'front', code: ValidationCode.empty),
        ),
      );
    }

    final String trimmedBack = StringUtils.trimmed(back);
    if (trimmedBack.isEmpty) {
      return Future<Result<FlashcardDuplicateCheckResult>>.value(
        const Result<FlashcardDuplicateCheckResult>.err(
          Failure.validation(field: 'back', code: ValidationCode.empty),
        ),
      );
    }

    if (flashcardId != null && StringUtils.trimmed(flashcardId).isEmpty) {
      return Future<Result<FlashcardDuplicateCheckResult>>.value(
        const Result<FlashcardDuplicateCheckResult>.err(
          Failure.validation(field: 'flashcardId', code: ValidationCode.empty),
        ),
      );
    }

    if (flashcardId != null) {
      final Result<FlashcardDetail> detailResult = await _repository
          .getFlashcardDetail(flashcardId: flashcardId);
      if (detailResult is Err<FlashcardDetail>) {
        return Result<FlashcardDuplicateCheckResult>.err(detailResult.failure);
      }
      if ((detailResult as Ok<FlashcardDetail>).value.deck.id !=
          trimmedDeckId) {
        return Result<FlashcardDuplicateCheckResult>.err(
          Failure.notFound(entity: 'flashcard', id: flashcardId),
        );
      }
    }

    final Result<List<Flashcard>> existingResult = await _repository
        .existingByFrontBackPairs(
          trimmedDeckId,
          <({String front, String back})>[
            (front: trimmedFront, back: trimmedBack),
          ],
        );
    if (existingResult is Err<List<Flashcard>>) {
      return Result<FlashcardDuplicateCheckResult>.err(existingResult.failure);
    }

    final List<Flashcard> candidates = (existingResult as Ok<List<Flashcard>>)
        .value
        .where((Flashcard card) => card.id != flashcardId)
        .toList(growable: false);
    if (candidates.isEmpty) {
      return const Result<FlashcardDuplicateCheckResult>.ok(
        FlashcardDuplicateCheckResult(hasDuplicate: false),
      );
    }

    return Result<FlashcardDuplicateCheckResult>.ok(
      FlashcardDuplicateCheckResult(
        hasDuplicate: true,
        duplicateFlashcardId: candidates.first.id,
      ),
    );
  }
}
