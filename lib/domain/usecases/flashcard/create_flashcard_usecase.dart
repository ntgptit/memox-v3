import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Create a flashcard. Front/back required-after-trim validation, optional-note
/// trimming, tag normalization, and the atomic insert (`flashcards` +
/// `flashcard_progress` + `flashcard_tags`) live in
/// [FlashcardRepository.createFlashcard].
///
/// Contract: `docs/contracts/usecase-contracts/flashcard.md` §CreateFlashcardUseCase.
/// Decision rows C1, C2, C3, C8 (`docs/decision-tables/flashcard.md`).
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
    List<String> tags = const <String>[],
  }) => repository.createFlashcard(
    deckId: deckId,
    front: front,
    back: back,
    exampleSentence: exampleSentence,
    pronunciation: pronunciation,
    hint: hint,
    tags: tags,
  );
}
