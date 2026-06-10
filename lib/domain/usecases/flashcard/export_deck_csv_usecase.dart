import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/deck_csv_export.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Exports one deck to CSV.
///
/// Front/back are the only V1 export columns; the repository builds the CSV
/// payload and safe file name.
class ExportDeckCsvUseCase {
  const ExportDeckCsvUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<DeckCsvExport>> call({required DeckId deckId}) {
    final String trimmedDeckId = StringUtils.trimmed(deckId);
    if (trimmedDeckId.isEmpty) {
      return Future<Result<DeckCsvExport>>.value(
        const Result<DeckCsvExport>.err(
          Failure.validation(field: 'deckId', code: ValidationCode.empty),
        ),
      );
    }
    return _repository.exportDeckCsv(deckId: trimmedDeckId);
  }
}
