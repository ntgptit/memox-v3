import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Commits validated deck-import preview rows into the target deck.
class CommitDeckImportUseCase {
  const CommitDeckImportUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<int>> call({
    required DeckId deckId,
    required DeckImportPreview preview,
  }) {
    final String trimmedDeckId = StringUtils.trimmed(deckId);
    if (trimmedDeckId.isEmpty) {
      return Future<Result<int>>.value(
        const Result<int>.err(
          Failure.validation(field: 'deckId', code: ValidationCode.empty),
        ),
      );
    }
    if (preview.hasValidationIssues) {
      return Future<Result<int>>.value(
        const Result<int>.err(
          Failure.validation(
            field: 'preview',
            code: ValidationCode.invalidFormat,
          ),
        ),
      );
    }
    if (!preview.hasValidRows) {
      return Future<Result<int>>.value(
        const Result<int>.err(
          Failure.validation(
            field: 'preview',
            code: ValidationCode.insufficientContent,
          ),
        ),
      );
    }
    return _repository.commitDeckImport(
      deckId: trimmedDeckId,
      rows: preview.rows,
    );
  }
}
