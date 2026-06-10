import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/repositories/flashcard_repository.dart';
import 'package:memox/domain/types/ids.dart';

enum DeckImportSourceFormat { csv, structuredText }

enum DeckImportStructuredTextSeparator {
  auto,
  tab,
  comma,
  colon,
  slash,
  semicolon,
  pipe,
}

/// Prepares deck-import preview rows with duplicate detection.
///
/// This is the backend preparation stage for import source formats that share
/// the same preview/validation/commit pipeline.
class PrepareDeckImportUseCase {
  const PrepareDeckImportUseCase(this._repository);

  final FlashcardRepository _repository;

  Future<Result<DeckImportPreview>> call({
    required DeckId deckId,
    required String rawContent,
    DeckImportSourceFormat sourceFormat = DeckImportSourceFormat.csv,
    DeckImportStructuredTextSeparator structuredTextSeparator =
        DeckImportStructuredTextSeparator.auto,
  }) async {
    final String trimmedDeckId = StringUtils.trimmed(deckId);
    if (trimmedDeckId.isEmpty) {
      return Future<Result<DeckImportPreview>>.value(
        const Result<DeckImportPreview>.err(
          Failure.validation(field: 'deckId', code: ValidationCode.empty),
        ),
      );
    }

    final _ParsedImportInput parsed = switch (sourceFormat) {
      DeckImportSourceFormat.csv => _parseCsv(rawContent),
      DeckImportSourceFormat.structuredText => _parseStructuredText(
        rawContent: rawContent,
        separator: structuredTextSeparator,
      ),
    };

    if (parsed.totalRowCount == 0 &&
        parsed.rows.isEmpty &&
        parsed.parseIssue == null) {
      return const Result<DeckImportPreview>.ok(
        DeckImportPreview(
          totalRowCount: 0,
          rows: <DeckImportPreviewRow>[],
          issues: <DeckImportIssue>[],
          skippedDuplicates: <DeckImportSkippedDuplicate>[],
        ),
      );
    }

    final List<DeckImportPreviewRow> validRows = <DeckImportPreviewRow>[];
    final List<DeckImportIssue> issues = <DeckImportIssue>[];

    if (parsed.parseIssue != null) {
      issues.add(parsed.parseIssue!);
    }

    for (final _ParsedImportRow row in parsed.rows) {
      if (row.malformed) {
        issues.add(
          DeckImportIssue(
            lineNumber: row.lineNumber,
            code: DeckImportIssueCode.invalidFormat,
          ),
        );
        continue;
      }

      if (row.front.isEmpty && row.back.isEmpty) {
        issues.add(
          DeckImportIssue(
            lineNumber: row.lineNumber,
            code: DeckImportIssueCode.frontAndBackRequired,
          ),
        );
        continue;
      }
      if (row.front.isEmpty) {
        issues.add(
          DeckImportIssue(
            lineNumber: row.lineNumber,
            code: DeckImportIssueCode.frontRequired,
          ),
        );
        continue;
      }
      if (row.back.isEmpty) {
        issues.add(
          DeckImportIssue(
            lineNumber: row.lineNumber,
            code: DeckImportIssueCode.backRequired,
          ),
        );
        continue;
      }

      validRows.add(
        DeckImportPreviewRow(
          lineNumber: row.lineNumber,
          front: row.front,
          back: row.back,
        ),
      );
    }

    if (validRows.isEmpty) {
      return Result<DeckImportPreview>.ok(
        DeckImportPreview(
          totalRowCount: parsed.totalRowCount,
          rows: const <DeckImportPreviewRow>[],
          issues: issues,
          skippedDuplicates: const <DeckImportSkippedDuplicate>[],
        ),
      );
    }

    final Set<String> candidateKeys = <String>{
      for (final DeckImportPreviewRow row in validRows)
        _pairKey(row.front, row.back),
    };
    final Result<List<Flashcard>> existingResult = await _repository
        .existingByFrontBackPairs(trimmedDeckId, <
          ({String front, String back})
        >[
          for (final String key in candidateKeys)
            (front: key.split('\u0000').first, back: key.split('\u0000').last),
        ]);
    if (existingResult is Err<List<Flashcard>>) {
      return Result<DeckImportPreview>.err(existingResult.failure);
    }

    final Set<String> existingKeys = <String>{
      for (final Flashcard card
          in (existingResult as Ok<List<Flashcard>>).value)
        _pairKey(card.front, card.back),
    };
    final Set<String> keptKeys = <String>{};
    final List<DeckImportPreviewRow> importableRows = <DeckImportPreviewRow>[];
    final List<DeckImportSkippedDuplicate> skippedDuplicates =
        <DeckImportSkippedDuplicate>[];

    for (final DeckImportPreviewRow row in validRows) {
      final String key = _pairKey(row.front, row.back);
      if (existingKeys.contains(key)) {
        skippedDuplicates.add(
          DeckImportSkippedDuplicate(
            lineNumber: row.lineNumber,
            front: row.front,
            back: row.back,
            source: DeckImportDuplicateSource.deck,
          ),
        );
        continue;
      }
      if (!keptKeys.add(key)) {
        skippedDuplicates.add(
          DeckImportSkippedDuplicate(
            lineNumber: row.lineNumber,
            front: row.front,
            back: row.back,
            source: DeckImportDuplicateSource.importFile,
          ),
        );
        continue;
      }

      importableRows.add(row);
    }

    return Result<DeckImportPreview>.ok(
      DeckImportPreview(
        totalRowCount: parsed.totalRowCount,
        rows: importableRows,
        issues: issues,
        skippedDuplicates: skippedDuplicates,
      ),
    );
  }
}

class _ParsedImportInput {
  const _ParsedImportInput({
    required this.rows,
    required this.totalRowCount,
    this.parseIssue,
  });

  final List<_ParsedImportRow> rows;
  final int totalRowCount;
  final DeckImportIssue? parseIssue;
}

class _ParsedImportRow {
  const _ParsedImportRow({
    required this.lineNumber,
    required this.front,
    required this.back,
    this.malformed = false,
  });

  final int lineNumber;
  final String front;
  final String back;
  final bool malformed;
}

_ParsedImportInput _parseCsv(String rawCsv) {
  final List<_CsvRecord> records = _parseCsvRecords(rawCsv);
  if (records.isEmpty) {
    return const _ParsedImportInput(
      rows: <_ParsedImportRow>[],
      totalRowCount: 0,
    );
  }

  int startIndex = 0;
  if (_looksLikeHeader(records.first.cells)) {
    startIndex = 1;
  }

  final List<_ParsedImportRow> rows = <_ParsedImportRow>[];
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

    rows.add(
      _ParsedImportRow(lineNumber: record.lineNumber, front: front, back: back),
    );
  }

  return _ParsedImportInput(rows: rows, totalRowCount: rows.length);
}

_ParsedImportInput _parseStructuredText({
  required String rawContent,
  required DeckImportStructuredTextSeparator separator,
}) {
  final String normalized = rawContent
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  final List<String> lines = normalized.split('\n');
  int? firstNonEmptyLineNumber;
  String? firstNonEmptyLine;
  int totalRowCount = 0;

  for (int index = 0; index < lines.length; index++) {
    final int lineNumber = index + 1;
    final String trimmedLine = StringUtils.trimmed(lines[index]);
    if (trimmedLine.isEmpty) {
      continue;
    }
    firstNonEmptyLineNumber ??= lineNumber;
    firstNonEmptyLine ??= lines[index];
    totalRowCount += 1;
  }

  if (totalRowCount == 0) {
    return const _ParsedImportInput(
      rows: <_ParsedImportRow>[],
      totalRowCount: 0,
    );
  }

  final DeckImportStructuredTextSeparator resolvedSeparator =
      switch (separator) {
        DeckImportStructuredTextSeparator.auto =>
          _detectStructuredSeparator(firstNonEmptyLine!) ??
              DeckImportStructuredTextSeparator.auto,
        _ => separator,
      };

  if (separator == DeckImportStructuredTextSeparator.auto &&
      resolvedSeparator == DeckImportStructuredTextSeparator.auto) {
    return _ParsedImportInput(
      rows: const <_ParsedImportRow>[],
      totalRowCount: totalRowCount,
      parseIssue: DeckImportIssue(
        lineNumber: firstNonEmptyLineNumber ?? 1,
        code: DeckImportIssueCode.invalidFormat,
      ),
    );
  }

  final List<_ParsedImportRow> parsedRows = <_ParsedImportRow>[];
  for (int index = 0; index < lines.length; index++) {
    final int lineNumber = index + 1;
    final String line = lines[index];
    final String trimmedLine = StringUtils.trimmed(line);
    if (trimmedLine.isEmpty) {
      continue;
    }
    parsedRows.add(
      _parseStructuredTextLine(
        lineNumber: lineNumber,
        line: line,
        separator: resolvedSeparator,
      ),
    );
  }

  return _ParsedImportInput(rows: parsedRows, totalRowCount: totalRowCount);
}

_ParsedImportRow _parseStructuredTextLine({
  required int lineNumber,
  required String line,
  required DeckImportStructuredTextSeparator separator,
}) {
  final String separatorChar = switch (separator) {
    DeckImportStructuredTextSeparator.auto => '',
    DeckImportStructuredTextSeparator.tab => '\t',
    DeckImportStructuredTextSeparator.comma => ',',
    DeckImportStructuredTextSeparator.colon => ':',
    DeckImportStructuredTextSeparator.slash => '/',
    DeckImportStructuredTextSeparator.semicolon => ';',
    DeckImportStructuredTextSeparator.pipe => '|',
  };

  if (separatorChar.isEmpty) {
    return _ParsedImportRow(
      lineNumber: lineNumber,
      front: '',
      back: '',
      malformed: true,
    );
  }

  final int separatorIndex = line.indexOf(separatorChar);
  if (separatorIndex < 0) {
    return _ParsedImportRow(
      lineNumber: lineNumber,
      front: StringUtils.trimmed(line),
      back: '',
      malformed: true,
    );
  }

  final String front = StringUtils.trimmed(line.substring(0, separatorIndex));
  final String back = StringUtils.trimmed(
    line.substring(separatorIndex + separatorChar.length),
  );
  return _ParsedImportRow(lineNumber: lineNumber, front: front, back: back);
}

DeckImportStructuredTextSeparator? _detectStructuredSeparator(
  String firstLine,
) {
  if (firstLine.isEmpty) {
    return null;
  }

  final Map<DeckImportStructuredTextSeparator, int> counts =
      <DeckImportStructuredTextSeparator, int>{
        for (final DeckImportStructuredTextSeparator separator
            in DeckImportStructuredTextSeparator.values.where(
              (DeckImportStructuredTextSeparator value) =>
                  value != DeckImportStructuredTextSeparator.auto,
            ))
          separator: _countOccurrences(firstLine, _separatorChar(separator)),
      };
  final int maxCount = counts.values.fold<int>(
    0,
    (int max, int value) => value > max ? value : max,
  );
  if (maxCount == 0) {
    return null;
  }
  final List<DeckImportStructuredTextSeparator> winners = counts.entries
      .where(
        (MapEntry<DeckImportStructuredTextSeparator, int> entry) =>
            entry.value == maxCount,
      )
      .map(
        (MapEntry<DeckImportStructuredTextSeparator, int> entry) => entry.key,
      )
      .toList(growable: false);
  if (winners.length != 1) {
    return null;
  }
  return winners.single;
}

String _separatorChar(DeckImportStructuredTextSeparator separator) =>
    switch (separator) {
      DeckImportStructuredTextSeparator.tab => '\t',
      DeckImportStructuredTextSeparator.comma => ',',
      DeckImportStructuredTextSeparator.colon => ':',
      DeckImportStructuredTextSeparator.slash => '/',
      DeckImportStructuredTextSeparator.semicolon => ';',
      DeckImportStructuredTextSeparator.pipe => '|',
      DeckImportStructuredTextSeparator.auto => '',
    };

int _countOccurrences(String value, String needle) {
  if (needle.isEmpty) {
    return 0;
  }
  int count = 0;
  int index = value.indexOf(needle);
  while (index >= 0) {
    count += 1;
    index = value.indexOf(needle, index + needle.length);
  }
  return count;
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

String _pairKey(String front, String back) =>
    '${StringUtils.normalize(front)}\u0000${StringUtils.normalize(back)}';
