import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Commits a prepared deck import atomically as one DB unit (WBS 6.4.1).
///
/// Rejects a blank [DeckId] (`ValidationFailure(field: deckId, code: empty)`) and
/// an empty `previewItems` set
/// (`ValidationFailure(field: previewItems, code: insufficientContent)`) before
/// delegating to [FlashcardRepository.commitDeckImport], which inserts the rows +
/// default SRS progress atomically (no silent partial import — WBS 6.4.2). A
/// missing deck is a `NotFoundFailure`; a write error a `StorageFailure`. Returns
/// the committed count (`docs/contracts/usecase-contracts/flashcard.md` §Import).
///
/// Precondition: [preparation] MUST come from `PrepareDeckImportUseCase` over a
/// `canCommit` preview — its `previewItems` are the deduped, validated, clean
/// rows. This use case does not re-validate row content.
class CommitDeckImportUseCase {
  const CommitDeckImportUseCase({required this.repository});

  final FlashcardRepository repository;

  Future<Result<int>> call({
    required DeckId deckId,
    required FlashcardImportPreparation preparation,
  }) {
    if (StringUtils.trimmed(deckId).isEmpty) {
      return Future<Result<int>>.value((
        failure: const Failure.validation(
          field: 'deckId',
          code: ValidationCode.empty,
          message: 'A deck id is required to import.',
        ),
        data: null,
      ));
    }
    if (preparation.previewItems.isEmpty) {
      return Future<Result<int>>.value((
        failure: const Failure.validation(
          field: 'previewItems',
          code: ValidationCode.insufficientContent,
          message: 'There are no cards to import.',
        ),
        data: null,
      ));
    }

    return repository.commitDeckImport(
      deckId: deckId,
      rows: <({String front, String back})>[
        for (final FlashcardImportRow row in preparation.previewItems)
          (front: row.front, back: row.back),
      ],
    );
  }
}
