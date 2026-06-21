import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/deck_csv_export.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Exports one deck as a CSV payload (WBS 8.7.1).
///
/// Thin delegation to [FlashcardRepository.exportDeckCsv]; the FE share/save
/// wiring is deferred (`docs/business/export/export.md` §Output delivery). A
/// missing deck is a `NotFoundFailure`; an empty deck yields a valid header-only
/// CSV. A blank [deckId] is rejected up front with a `ValidationFailure`
/// (`docs/contracts/usecase-contracts/flashcard.md` §ExportDeckCsvUseCase).
class ExportDeckCsvUseCase {
  const ExportDeckCsvUseCase({required this.repository});

  final FlashcardRepository repository;

  Future<Result<DeckCsvExport>> call({required DeckId deckId}) {
    if (StringUtils.trimmed(deckId).isEmpty) {
      return Future<Result<DeckCsvExport>>.value((
        failure: const Failure.validation(
          field: 'deckId',
          code: ValidationCode.empty,
          message: 'A deck id is required to export.',
        ),
        data: null,
      ));
    }
    return repository.exportDeckCsv(deckId: deckId);
  }
}
