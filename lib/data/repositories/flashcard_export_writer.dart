/// Pure CSV-format helpers for deck export (WBS 8.7.1), kept separate so the CSV
/// rules live in one place (`docs/business/export/export.md` §CSV format
/// details). No I/O — the repository calls these to build the export payload.
class FlashcardExportWriter {
  const FlashcardExportWriter();

  /// The V1 deck CSV header (front/back only, in this order).
  static const String header = 'front,back';

  /// Escapes one CSV cell per RFC 4180: a cell containing a comma, double quote,
  /// or line break is wrapped in double quotes with inner quotes doubled;
  /// everything else passes through unchanged.
  String escapeCsvCell(String cell) {
    final bool needsQuoting =
        cell.contains(',') ||
        cell.contains('"') ||
        cell.contains('\n') ||
        cell.contains('\r');
    if (!needsQuoting) {
      return cell;
    }
    return '"${cell.replaceAll('"', '""')}"';
  }

  /// Builds the full CSV text: the header row followed by one `front,back` row
  /// per entry, joined with `\n` (Unix line ending, no trailing newline, no BOM).
  /// An empty [rows] list yields the header row alone.
  String buildCsv(List<({String front, String back})> rows) {
    final StringBuffer buffer = StringBuffer(header);
    for (final ({String front, String back}) row in rows) {
      buffer.write('\n');
      buffer.write(escapeCsvCell(row.front));
      buffer.write(',');
      buffer.write(escapeCsvCell(row.back));
    }
    return buffer.toString();
  }

  /// Sanitizes a deck title into a safe base file name (no extension): trims
  /// whitespace, replaces path separators / control / unsafe characters with
  /// `_`, collapses repeated `_`, strips leading/trailing `_`, and falls back to
  /// a deterministic `deck_{id}` when the title sanitizes to blank.
  String sanitizeFileName(String name, {required String fallbackId}) {
    final String collapsed = name
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (collapsed.isEmpty) {
      return 'deck_$fallbackId';
    }
    return collapsed;
  }
}
