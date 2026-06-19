import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/flashcard_progress_edit_policy.dart';
import 'package:memox/domain/types/ids.dart';

/// Update a flashcard's content + tags, optionally resetting SRS progress.
/// Validation, tag-replace semantics, and the optional progress reset live in
/// [FlashcardRepository.updateFlashcard]. The editor passes
/// [FlashcardProgressEditPolicy.keepProgress] by default and only switches to
/// [FlashcardProgressEditPolicy.resetProgress] after the explicit
/// progress-policy dialog.
///
/// Contract: `docs/contracts/usecase-contracts/flashcard.md` §UpdateFlashcardUseCase.
/// Decision row C5 (`docs/decision-tables/flashcard.md`).
class UpdateFlashcardUseCase {
  const UpdateFlashcardUseCase({required this.repository});

  final FlashcardRepository repository;

  Future<Result<Flashcard>> call({
    required FlashcardId flashcardId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    List<String> tags = const <String>[],
    FlashcardProgressEditPolicy progressPolicy =
        FlashcardProgressEditPolicy.keepProgress,
  }) => repository.updateFlashcard(
    flashcardId: flashcardId,
    front: front,
    back: back,
    exampleSentence: exampleSentence,
    pronunciation: pronunciation,
    hint: hint,
    tags: tags,
    progressPolicy: progressPolicy,
  );
}
