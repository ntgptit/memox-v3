import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Delete a flashcard. The atomic cascade (`flashcard_progress` +
/// `flashcard_tags` + `flashcards`) and the missing-card guard live in
/// [FlashcardRepository.deleteFlashcard].
///
/// Destructive — the caller confirms via the shared delete-confirm flow.
///
/// Contract: `docs/contracts/usecase-contracts/flashcard.md` §DeleteFlashcardUseCase.
/// Decision rows C6, C27 (`docs/decision-tables/flashcard.md`).
class DeleteFlashcardUseCase {
  const DeleteFlashcardUseCase({required this.repository});

  final FlashcardRepository repository;

  Future<Result<void>> call({required FlashcardId flashcardId}) =>
      repository.deleteFlashcard(flashcardId: flashcardId);
}
