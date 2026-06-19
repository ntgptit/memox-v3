import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Create a deck-owned flashcard (WBS 2.11.1). Trim/required validation, the
/// parent-deck existence check (WBS 2.16.1), and the atomic insert live in
/// [FlashcardRepository.createFlashcard].
///
/// Contract: `docs/contracts/usecase-contracts/flashcard.md`
/// §CreateFlashcardUseCase. Decision rows C1, C2, C3, C8, C41.
class CreateFlashcardUseCase {
  const CreateFlashcardUseCase({required this.repository});

  final FlashcardRepository repository;

  Future<Result<Flashcard>> call({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    String? partOfSpeech,
  }) => repository.createFlashcard(
    deckId: deckId,
    front: front,
    back: back,
    exampleSentence: exampleSentence,
    pronunciation: pronunciation,
    hint: hint,
    partOfSpeech: partOfSpeech,
  );
}
