import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/types/flashcard_import_duplicate.dart';
import 'package:memox/domain/types/import_row_issue_type.dart';

void main() {
  // Contract-only enabler (WBS 6.0.1): lock the derived-getter semantics of the
  // pinned import preview/preparation models so the parse/prepare/commit rows
  // (6.2.x–6.9.1) share one shape. No parsing logic is exercised here.
  const FlashcardImportRow row = FlashcardImportRow(
    lineNumber: 1,
    front: 'eat',
    back: 'an',
  );
  const ImportValidationIssue issue = ImportValidationIssue(
    kind: ImportRowIssueType.missingFront,
    lineNumber: 2,
    message: 'Line 2: front is required.',
  );

  group('FlashcardImportPreview', () {
    test('empty preview cannot commit and has no issues', () {
      expect(FlashcardImportPreview.empty.canCommit, isFalse);
      expect(FlashcardImportPreview.empty.hasIssues, isFalse);
    });

    test('rows + no issues → canCommit, no issues', () {
      const FlashcardImportPreview preview = FlashcardImportPreview(
        rows: <FlashcardImportRow>[row],
      );
      expect(preview.canCommit, isTrue);
      expect(preview.hasIssues, isFalse);
    });

    test('any validation issue blocks commit (no silent partial import)', () {
      const FlashcardImportPreview preview = FlashcardImportPreview(
        rows: <FlashcardImportRow>[row],
        issues: <ImportValidationIssue>[issue],
      );
      expect(preview.hasIssues, isTrue);
      expect(preview.canCommit, isFalse);
    });
  });

  group('FlashcardImportPreparation', () {
    test('empty preparation has zero import/skipped counts', () {
      expect(FlashcardImportPreparation.empty.importCount, 0);
      expect(FlashcardImportPreparation.empty.skippedCount, 0);
    });

    test('counts reflect committable rows and skipped duplicates', () {
      const FlashcardImportPreparation prep = FlashcardImportPreparation(
        previewItems: <FlashcardImportRow>[row],
        skippedDuplicates: <FlashcardImportSkippedDuplicate>[
          FlashcardImportSkippedDuplicate(
            lineNumber: 3,
            front: 'eat',
            back: 'an',
            source: FlashcardImportDuplicateSource.importFile,
          ),
        ],
      );
      expect(prep.importCount, 1);
      expect(prep.skippedCount, 1);
    });
  });
}
