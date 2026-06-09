import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';

/// Parses pasted CSV for deck import preview.
///
/// Preserves current CSV behavior: optional `front,back` header detection,
/// quoted values, escaped quotes, blank row handling, and row-level front/back
/// validation.
class ParseDeckImportCsvUseCase {
  const ParseDeckImportCsvUseCase();

  DeckImportPreview call({required String rawCsv}) {
    final List<_CsvRecord> records = _parseCsvRecords(rawCsv);
    if (records.isEmpty) {
      return const DeckImportPreview(
        rows: <DeckImportPreviewRow>[],
        issues: <DeckImportIssue>[],
      );
    }

    int startIndex = 0;
    if (_looksLikeHeader(records.first.cells)) {
      startIndex = 1;
    }

    final List<DeckImportPreviewRow> rows = <DeckImportPreviewRow>[];
    final List<DeckImportIssue> issues = <DeckImportIssue>[];
    for (int index = startIndex; index < records.length; index++) {
      final _CsvRecord record = records[index];
      final List<String> trimmedCells = record.cells
          .map(StringUtils.trimmed)
          .toList(growable: false);
      final bool isBlankRow = trimmedCells.every((String cell) => cell.isEmpty);
      if (isBlankRow) {
        continue;
      }

      final String front = trimmedCells.isNotEmpty ? trimmedCells.first : '';
      final String back = trimmedCells.length > 1 ? trimmedCells[1] : '';

      if (front.isEmpty && back.isEmpty) {
        issues.add(
          DeckImportIssue(
            lineNumber: record.lineNumber,
            code: DeckImportIssueCode.frontAndBackRequired,
          ),
        );
        continue;
      }
      if (front.isEmpty) {
        issues.add(
          DeckImportIssue(
            lineNumber: record.lineNumber,
            code: DeckImportIssueCode.frontRequired,
          ),
        );
        continue;
      }
      if (back.isEmpty) {
        issues.add(
          DeckImportIssue(
            lineNumber: record.lineNumber,
            code: DeckImportIssueCode.backRequired,
          ),
        );
        continue;
      }

      rows.add(
        DeckImportPreviewRow(
          lineNumber: record.lineNumber,
          front: front,
          back: back,
        ),
      );
    }

    return DeckImportPreview(rows: rows, issues: issues);
  }
}

class _CsvRecord {
  const _CsvRecord({required this.lineNumber, required this.cells});

  final int lineNumber;
  final List<String> cells;
}

List<_CsvRecord> _parseCsvRecords(String rawCsv) {
  final String normalized = rawCsv
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  final List<_CsvRecord> records = <_CsvRecord>[];
  List<String> currentRow = <String>[];
  StringBuffer currentField = StringBuffer();
  bool inQuotes = false;
  bool hasRecordContent = false;
  int lineNumber = 1;
  int recordStartLine = 1;

  void finishField() {
    currentRow = <String>[...currentRow, currentField.toString()];
    currentField = StringBuffer();
  }

  void finishRecord() {
    records.add(
      _CsvRecord(
        lineNumber: recordStartLine,
        cells: List<String>.unmodifiable(currentRow),
      ),
    );
    currentRow = <String>[];
    currentField = StringBuffer();
    hasRecordContent = false;
  }

  for (int index = 0; index < normalized.length; index++) {
    final String char = normalized[index];

    if (!hasRecordContent) {
      recordStartLine = lineNumber;
      if (char != '\n') {
        hasRecordContent = true;
      }
    }

    if (inQuotes) {
      if (char == '"') {
        final bool isEscapedQuote =
            index + 1 < normalized.length && normalized[index + 1] == '"';
        if (isEscapedQuote) {
          currentField.write('"');
          index++;
          continue;
        }
        inQuotes = false;
        continue;
      }

      currentField.write(char);
      if (char == '\n') {
        lineNumber++;
      }
      continue;
    }

    if (char == '"') {
      if (currentField.isEmpty) {
        inQuotes = true;
        continue;
      }
      currentField.write(char);
      continue;
    }
    if (char == ',') {
      finishField();
      continue;
    }
    if (char == '\n') {
      finishField();
      finishRecord();
      lineNumber++;
      continue;
    }

    currentField.write(char);
  }

  if (normalized.isNotEmpty &&
      (hasRecordContent || currentField.isNotEmpty || currentRow.isNotEmpty)) {
    finishField();
    finishRecord();
  }

  return records;
}

bool _looksLikeHeader(List<String> cells) {
  if (cells.length < 2) {
    return false;
  }
  return StringUtils.equalsIgnoreCase(StringUtils.trimmed(cells[0]), 'front') &&
      StringUtils.equalsIgnoreCase(StringUtils.trimmed(cells[1]), 'back');
}
