import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/flashcard_import_duplicate.dart';
import 'package:memox/domain/types/ids.dart';

/// Applies duplicate detection to a clean import preview (WBS 6.6.1).
///
/// Implements [FlashcardImportDuplicatePolicy.skipExactDuplicates]: a row whose
/// `front`+`back` (trimmed, case-insensitive) match an existing card in [deckId]
/// is dropped as a [FlashcardImportDuplicateSource.deck] duplicate; a row that
/// repeats an earlier kept row in the same file is dropped as a
/// [FlashcardImportDuplicateSource.importFile] duplicate (first occurrence kept).
/// Existing-deck clashes take precedence over file clashes. Returns the
/// committable [FlashcardImportPreparation.previewItems] plus the
/// [FlashcardImportPreparation.skippedDuplicates] breakdown — never silently
/// importing duplicates (decision row I7). A read error propagates as
/// `StorageFailure` (`docs/contracts/usecase-contracts/flashcard.md` §Import).
class PrepareDeckImportUseCase {
  const PrepareDeckImportUseCase({required this.repository});

  final FlashcardRepository repository;

  Future<Result<FlashcardImportPreparation>> call({
    required DeckId deckId,
    required FlashcardImportPreview preview,
  }) async {
    final Result<List<({String front, String back})>> existing =
        await repository.loadDeckCardContents(deckId: deckId);
    final List<({String front, String back})>? existingCards = existing.data;
    if (existing.failure != null || existingCards == null) {
      return (failure: existing.failure, data: null);
    }

    final Set<String> deckKeys = <String>{
      for (final ({String front, String back}) card in existingCards)
        _key(card.front, card.back),
    };

    final List<FlashcardImportRow> previewItems = <FlashcardImportRow>[];
    final List<FlashcardImportSkippedDuplicate> skipped =
        <FlashcardImportSkippedDuplicate>[];
    final Set<String> seenInFile = <String>{};

    for (final FlashcardImportRow row in preview.rows) {
      final String key = _key(row.front, row.back);
      // Existing-deck clash takes precedence over an in-file repeat.
      if (deckKeys.contains(key)) {
        skipped.add(_skip(row, FlashcardImportDuplicateSource.deck));
        continue;
      }
      if (seenInFile.contains(key)) {
        skipped.add(_skip(row, FlashcardImportDuplicateSource.importFile));
        continue;
      }
      seenInFile.add(key);
      previewItems.add(row);
    }

    return (
      failure: null,
      data: FlashcardImportPreparation(
        previewItems: previewItems,
        skippedDuplicates: skipped,
      ),
    );
  }

  /// Trimmed, case-insensitive `front`+`back` identity key (matches the manual
  /// duplicate check). The NUL separator avoids cross-field collisions.
  String _key(String front, String back) {
    final String f = StringUtils.caseFold(StringUtils.trimmed(front));
    final String b = StringUtils.caseFold(StringUtils.trimmed(back));
    return '$f\u0000$b';
  }

  FlashcardImportSkippedDuplicate _skip(
    FlashcardImportRow row,
    FlashcardImportDuplicateSource source,
  ) => FlashcardImportSkippedDuplicate(
    lineNumber: row.lineNumber,
    front: row.front,
    back: row.back,
    source: source,
  );
}
