import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/types/import_row_issue_type.dart';

/// Parses pasted CSV text into a [FlashcardImportPreview] (WBS 6.2.1).
///
/// Pure, synchronous transform (no repository): splits [rawCsv] into records
/// using RFC-4180 quoting (double-quoted fields may contain the separator,
/// embedded newlines, and `""`-escaped quotes), skips fully blank lines, detects
/// and drops an optional `front,back` header. A record with two or more columns
/// maps to a trimmed [FlashcardImportRow] using the first two columns as
/// front/back (extra columns are ignored — decision row C7); a record with fewer
/// than two columns becomes a `malformedRow` [ImportValidationIssue] (excluded
/// from `rows`). Per-row CONTENT validation (missing/too-long front/back) lands
/// in WBS 6.2.2; the separator option (tab/colon/…) in WBS 6.9.1.
/// See `docs/business/flashcard/flashcard-management.md` §Import,
/// `docs/contracts/usecase-contracts/flashcard.md` §Import.
class ParseDeckImportCsvUseCase {
  const ParseDeckImportCsvUseCase();

  /// The V1 CSV column count (front, back).
  static const int _columnCount = 2;

  FlashcardImportPreview call({
    required String rawCsv,
    String separator = ',',
  }) {
    final List<_CsvRecord> records = _parseRecords(rawCsv, separator);

    final List<FlashcardImportRow> rows = <FlashcardImportRow>[];
    final List<ImportValidationIssue> issues = <ImportValidationIssue>[];
    bool headerChecked = false;

    for (final _CsvRecord record in records) {
      final List<String> fields = record.fields
          .map(StringUtils.trimmed)
          .toList();

      // A truly blank line (one empty field) carries no data — skip it.
      if (fields.length == 1 && fields.first.isEmpty) {
        continue;
      }

      // Drop a single leading `front,back` header if present.
      if (!headerChecked) {
        headerChecked = true;
        if (_isHeader(fields)) {
          continue;
        }
      }

      // Fewer than two columns can't form a front/back pair → malformed. Two or
      // more columns map to the first two; extra columns are ignored (C7).
      if (fields.length < _columnCount) {
        issues.add(
          ImportValidationIssue(
            kind: ImportRowIssueType.malformedRow,
            lineNumber: record.lineNumber,
            message:
                'Line ${record.lineNumber}: expected at least 2 columns '
                '(front, back), found ${fields.length}.',
          ),
        );
        continue;
      }

      rows.add(
        FlashcardImportRow(
          lineNumber: record.lineNumber,
          front: fields[0],
          back: fields[1],
        ),
      );
    }

    return FlashcardImportPreview(rows: rows, issues: issues);
  }

  /// A leading `front,back` header (case-insensitive). Tolerates extra trailing
  /// columns for symmetry with the C7 "ignore extra columns" rule, so a
  /// `Front,Back,Notes` header is dropped, not treated as a data row.
  bool _isHeader(List<String> fields) =>
      fields.length >= _columnCount &&
      StringUtils.caseFold(fields[0]) == 'front' &&
      StringUtils.caseFold(fields[1]) == 'back';

  /// Splits [raw] into RFC-4180 records, tracking the 1-based source line each
  /// record starts on (a quoted field may embed newlines, so a record can span
  /// several source lines).
  List<_CsvRecord> _parseRecords(String raw, String separator) {
    final String sep = separator.isEmpty ? ',' : separator[0];
    final List<_CsvRecord> records = <_CsvRecord>[];
    final int n = raw.length;
    int i = 0;
    int line = 1;

    while (i < n) {
      final int recordStartLine = line;
      final List<String> fields = <String>[];
      final StringBuffer field = StringBuffer();

      while (true) {
        // Dual `if (quoted) / if (!quoted)` rather than if/else: the `no_else`
        // guard forbids `else` here. `quoted` is final, so the branches are
        // mutually exclusive.
        final bool quoted = i < n && raw[i] == '"';
        if (quoted) {
          // Quoted field: consume until the closing (non-doubled) quote.
          i++;
          while (i < n) {
            final String c = raw[i];
            if (c == '"') {
              if (i + 1 < n && raw[i + 1] == '"') {
                field.write('"');
                i += 2;
                continue;
              }
              i++;
              break;
            }
            if (c == '\r') {
              field.write('\n');
              i += (i + 1 < n && raw[i + 1] == '\n') ? 2 : 1;
              line++;
              continue;
            }
            if (c == '\n') {
              field.write('\n');
              i++;
              line++;
              continue;
            }
            field.write(c);
            i++;
          }
        }
        if (!quoted) {
          // Unquoted field: read until separator or row delimiter.
          while (i < n && raw[i] != sep && raw[i] != '\n' && raw[i] != '\r') {
            field.write(raw[i]);
            i++;
          }
        }

        fields.add(field.toString());
        field.clear();

        if (i < n && raw[i] == sep) {
          i++;
          continue;
        }
        break;
      }

      // Consume the row delimiter and advance the line counter. A `\r` branch
      // eats an immediate `\n` (CRLF), so the standalone-`\n` check below only
      // fires for an LF-only delimiter — never double-counting.
      if (i < n && raw[i] == '\r') {
        i += (i + 1 < n && raw[i + 1] == '\n') ? 2 : 1;
        line++;
      }
      if (i < n && raw[i] == '\n') {
        i++;
        line++;
      }

      records.add(_CsvRecord(lineNumber: recordStartLine, fields: fields));
    }

    return records;
  }
}

/// One parsed CSV record: the source [lineNumber] it started on and its raw
/// (un-trimmed) [fields].
class _CsvRecord {
  const _CsvRecord({required this.lineNumber, required this.fields});

  final int lineNumber;
  final List<String> fields;
}
