import 'package:memox/core/util/csv_tokenizer.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/types/import_row_issue_type.dart';
import 'package:memox/domain/types/import_text_separator.dart';

/// Parses pasted CSV text into a [FlashcardImportPreview] (WBS 6.2.1 + 6.2.2).
///
/// Field tokenizing (quoted separators, embedded newlines, `""`-escaped quotes)
/// is delegated to [CsvTokenizer] — a `core/util` wrapper over the battle-tested
/// `csv` package — so the bug-prone RFC-4180 logic is not hand-rolled and the
/// domain layer stays free of the third-party parser. This use case keeps only
/// the thin domain rules on top: drop an optional `front,back` header, skip blank
/// lines, map a record with ≥2 columns to the first two (extra columns ignored —
/// decision row C7) or report `malformedRow` for <2 columns, and validate the
/// trimmed front/back as required-after-trim (WBS 6.2.2 → `missingFront`/
/// `missingBack`; no max-length exists so `*TooLong` stays reserved). A row with
/// any issue is excluded from the committable `rows` (decision row C30).
///
/// `lineNumber` is the 1-based index of the record in the source (equals the
/// physical line for files without embedded newlines; a quoted field spanning
/// lines counts as one record). [separator] selects the column delimiter for
/// structured-text import (WBS 6.9.1): `comma` (default), `tab`, `colon`,
/// `slash`, `semicolon`, `pipe`, or `auto` — which infers it by frequency
/// analysis of the first non-empty line and **fails closed** on a tie (decision
/// row I8): the preview surfaces a single `malformedRow` issue and no rows. See
/// `docs/business/flashcard/flashcard-management.md` §Import,
/// `docs/contracts/usecase-contracts/flashcard.md` §Import.
class ParseDeckImportCsvUseCase {
  const ParseDeckImportCsvUseCase();

  /// The V1 CSV column count (front, back).
  static const int _columnCount = 2;

  FlashcardImportPreview call({
    required String rawCsv,
    ImportTextSeparator separator = ImportTextSeparator.comma,
  }) {
    if (StringUtils.trimmed(rawCsv).isEmpty) {
      return FlashcardImportPreview.empty;
    }

    // Resolve the column delimiter; `auto` returns null on an ambiguous tie.
    final String? delimiter = _delimiterFor(separator, rawCsv);
    if (delimiter == null) {
      return const FlashcardImportPreview(
        issues: <ImportValidationIssue>[
          ImportValidationIssue(
            kind: ImportRowIssueType.malformedRow,
            lineNumber: 1,
            message:
                'Could not determine the column separator (ambiguous); choose '
                'one explicitly.',
          ),
        ],
      );
    }

    final List<List<String>> records = CsvTokenizer.tokenize(
      rawCsv,
      fieldDelimiter: delimiter,
    );

    final List<FlashcardImportRow> rows = <FlashcardImportRow>[];
    final List<ImportValidationIssue> issues = <ImportValidationIssue>[];
    bool headerChecked = false;

    for (final (int index, List<String> fields) in records.indexed) {
      final int lineNumber = index + 1;

      // A blank line surfaces as a single empty field — skip it.
      if (fields.isEmpty || (fields.length == 1 && fields.first.isEmpty)) {
        continue;
      }

      // Drop a single leading `front,back` header (tolerant of extra columns).
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
            lineNumber: lineNumber,
            message:
                'Line $lineNumber: expected at least 2 columns (front, back), '
                'found ${fields.length}.',
          ),
        );
        continue;
      }

      // Per-row content validation (WBS 6.2.2): front/back required after trim,
      // mirroring manual card creation. A row with any issue is reported and
      // excluded from committable `rows` (decision row C30).
      final String front = fields[0];
      final String back = fields[1];
      final List<ImportValidationIssue> rowIssues = <ImportValidationIssue>[];
      if (front.isEmpty) {
        rowIssues.add(
          ImportValidationIssue(
            kind: ImportRowIssueType.missingFront,
            lineNumber: lineNumber,
            message: 'Line $lineNumber: front is required.',
          ),
        );
      }
      if (back.isEmpty) {
        rowIssues.add(
          ImportValidationIssue(
            kind: ImportRowIssueType.missingBack,
            lineNumber: lineNumber,
            message: 'Line $lineNumber: back is required.',
          ),
        );
      }
      if (rowIssues.isNotEmpty) {
        issues.addAll(rowIssues);
        continue;
      }

      rows.add(
        FlashcardImportRow(lineNumber: lineNumber, front: front, back: back),
      );
    }

    return FlashcardImportPreview(rows: rows, issues: issues);
  }

  /// The single delimiter character for [separator], or `null` when `auto` can't
  /// decide (ambiguous tie → fail closed, decision row I8).
  String? _delimiterFor(ImportTextSeparator separator, String rawCsv) =>
      switch (separator) {
        ImportTextSeparator.tab => '\t',
        ImportTextSeparator.comma => ',',
        ImportTextSeparator.colon => ':',
        ImportTextSeparator.slash => '/',
        ImportTextSeparator.semicolon => ';',
        ImportTextSeparator.pipe => '|',
        ImportTextSeparator.auto => _autoDetect(rawCsv),
      };

  /// Infers the delimiter by frequency analysis of the first non-empty line: the
  /// candidate with the strictly-highest count wins; no candidate present or a
  /// tie at the top → `null` (ambiguous; the caller fails closed).
  String? _autoDetect(String rawCsv) {
    const List<String> candidates = <String>['\t', ',', ':', '/', ';', '|'];
    final String firstLine = rawCsv
        .split(RegExp(r'\r\n|\r|\n'))
        .firstWhere(
          (String line) => StringUtils.trimmed(line).isNotEmpty,
          orElse: () => '',
        );

    int maxCount = 0;
    String? best;
    bool tie = false;
    for (final String candidate in candidates) {
      final int count = candidate.allMatches(firstLine).length;
      if (count == 0) {
        continue;
      }
      if (count > maxCount) {
        maxCount = count;
        best = candidate;
        tie = false;
        continue;
      }
      if (count == maxCount) {
        tie = true;
      }
    }
    if (best == null || tie) {
      return null;
    }
    return best;
  }

  /// A leading `front,back` header (case-insensitive). Tolerates extra trailing
  /// columns for symmetry with the C7 "ignore extra columns" rule.
  bool _isHeader(List<String> fields) =>
      fields.length >= _columnCount &&
      StringUtils.caseFold(fields[0]) == 'front' &&
      StringUtils.caseFold(fields[1]) == 'back';
}
