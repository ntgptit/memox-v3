import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'deck_csv_export.freezed.dart';

/// The result of a deck CSV export (WBS 8.7.1). Read-only: the backend returns
/// the rendered CSV text + a sanitized file name; the presentation layer owns
/// share/save (`docs/business/export/export.md` §Output delivery). [csvText] is
/// always at least the `front,back` header row, even for an empty deck.
@freezed
sealed class DeckCsvExport with _$DeckCsvExport {
  const factory DeckCsvExport({
    required DeckId deckId,
    required String deckName,
    required String fileName,
    required String csvText,
    required int exportedRowCount,
  }) = _DeckCsvExport;
}
