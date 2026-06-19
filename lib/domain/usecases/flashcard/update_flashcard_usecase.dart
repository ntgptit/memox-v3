import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Update an existing flashcard's content (WBS 2.12.1). Trim/required
/// validation and the not-found guard live in
/// [FlashcardRepository.updateFlashcard]; deck ownership and `sort_order` are
/// preserved.
///
/// Contract: `docs/contracts/usecase-contracts/flashcard.md`
/// §UpdateFlashcardUseCase. Decision rows C2, C3, C41.
class UpdateFlashcardUseCase {
  const UpdateFlashcardUseCase({required this.repository});

  final FlashcardRepository repository;

  Future<Result<Flashcard>> call({
    required FlashcardId id,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    String? partOfSpeech,
  }) => repository.updateFlashcard(
    id: id,
    front: front,
    back: back,
    exampleSentence: exampleSentence,
    pronunciation: pronunciation,
    hint: hint,
    partOfSpeech: partOfSpeech,
  );
}
