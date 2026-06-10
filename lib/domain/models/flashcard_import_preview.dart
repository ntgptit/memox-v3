/// Deck import preview models (`docs/business/flashcard/flashcard-management.md`).
///
/// These are pure domain models so the CSV parser/use case stays testable
/// without widget tests or localization wiring.
library;

enum DeckImportIssueCode {
  frontAndBackRequired,
  frontRequired,
  backRequired,
  invalidFormat,
}

enum DeckImportDuplicateSource { importFile, deck }

class DeckImportPreview {
  const DeckImportPreview({
    this.totalRowCount = 0,
    required this.rows,
    required this.issues,
    this.skippedDuplicates = const <DeckImportSkippedDuplicate>[],
  });

  final int totalRowCount;
  final List<DeckImportPreviewRow> rows;
  final List<DeckImportIssue> issues;
  final List<DeckImportSkippedDuplicate> skippedDuplicates;

  bool get hasValidationIssues => issues.isNotEmpty;

  bool get hasValidRows => rows.isNotEmpty;

  int get validCount => rows.length;

  int get invalidCount => issues.length;

  int get duplicateCount => skippedDuplicates.length;

  bool get canCommit => hasValidRows && !hasValidationIssues;
}

class DeckImportPreviewRow {
  const DeckImportPreviewRow({
    required this.lineNumber,
    required this.front,
    required this.back,
  });

  final int lineNumber;
  final String front;
  final String back;
}

class DeckImportIssue {
  const DeckImportIssue({required this.lineNumber, required this.code});

  final int lineNumber;
  final DeckImportIssueCode code;
}

class DeckImportSkippedDuplicate {
  const DeckImportSkippedDuplicate({
    required this.lineNumber,
    required this.front,
    required this.back,
    required this.source,
  });

  final int lineNumber;
  final String front;
  final String back;
  final DeckImportDuplicateSource source;
}
