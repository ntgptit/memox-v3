/// Deck import preview models (`docs/business/flashcard/flashcard-management.md`).
///
/// These are pure domain models so the CSV parser/use case stays testable
/// without widget tests or localization wiring.
library;

enum DeckImportIssueCode { frontAndBackRequired, frontRequired, backRequired }

class DeckImportPreview {
  const DeckImportPreview({required this.rows, required this.issues});

  final List<DeckImportPreviewRow> rows;
  final List<DeckImportIssue> issues;

  bool get hasValidationIssues => issues.isNotEmpty;

  bool get hasValidRows => rows.isNotEmpty;

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
