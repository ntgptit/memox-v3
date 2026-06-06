import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Deletes a single flashcard
/// (`docs/contracts/usecase-contracts/flashcard.md` §DeleteFlashcardUseCase).
///
/// Thin orchestration over [FlashcardRepository]; the confirm dialog is the
/// presentation layer's responsibility.
class DeleteFlashcardUseCase {
  const DeleteFlashcardUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<void>> call(FlashcardId flashcardId) =>
      _repository.deleteFlashcard(flashcardId: flashcardId);
}
