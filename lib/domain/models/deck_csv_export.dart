import 'package:memox/domain/types/ids.dart';

/// Result of exporting one deck to CSV.
///
/// The repository returns the safe file name and CSV payload together so the
/// presentation layer can hand the content to a later save/share flow without
/// rebuilding the export text.
class DeckCsvExport {
  const DeckCsvExport({
    required this.deckId,
    required this.deckName,
    required this.fileName,
    required this.csvText,
    required this.exportedRowCount,
  });

  final DeckId deckId;
  final String deckName;
  final String fileName;
  final String csvText;
  final int exportedRowCount;
}
