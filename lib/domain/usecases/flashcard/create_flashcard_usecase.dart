import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Creates a single flashcard
/// (`docs/contracts/usecase-contracts/flashcard.md` §CreateFlashcardUseCase).
///
/// Front/back are validated here so the repository only sees save-ready input.
/// Optional example text is trimmed and collapsed to `null` when empty; the
/// repository stores the raw front/back strings as typed.
class CreateFlashcardUseCase {
  const CreateFlashcardUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<Flashcard>> call({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
  }) {
    final String trimmedFront = StringUtils.trimmed(front);
    if (trimmedFront.isEmpty) {
      return Future<Result<Flashcard>>.value(
        const Result<Flashcard>.err(
          Failure.validation(field: 'front', code: ValidationCode.empty),
        ),
      );
    }

    final String trimmedBack = StringUtils.trimmed(back);
    if (trimmedBack.isEmpty) {
      return Future<Result<Flashcard>>.value(
        const Result<Flashcard>.err(
          Failure.validation(field: 'back', code: ValidationCode.empty),
        ),
      );
    }

    final String? normalizedExample = _optionalText(exampleSentence);
    final String? normalizedPronunciation = _optionalText(pronunciation);
    final String? normalizedHint = _optionalText(hint);
    return _repository.createFlashcard(
      deckId: deckId,
      front: trimmedFront,
      back: trimmedBack,
      exampleSentence: normalizedExample,
      pronunciation: normalizedPronunciation,
      hint: normalizedHint,
    );
  }

  static String? _optionalText(String? value) {
    if (value == null) {
      return null;
    }
    final String trimmed = StringUtils.trimmed(value);
    return trimmed.isEmpty ? null : trimmed;
  }
}
