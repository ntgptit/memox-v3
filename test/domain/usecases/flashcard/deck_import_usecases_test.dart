import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/models/flashcard_import_preview.dart';
import 'package:memox/domain/types/import_row_issue_type.dart';
import 'package:memox/domain/usecases/flashcard/parse_deck_import_csv_usecase.dart';

void main() {
  // ParseDeckImportCsvUseCase (WBS 6.2.1 parse + 6.2.2 row validation): RFC-4180
  // CSV parse → preview rows + malformedRow (structural) + missingFront/
  // missingBack (content) issues.
  group('ParseDeckImportCsvUseCase', () {
    const ParseDeckImportCsvUseCase parse = ParseDeckImportCsvUseCase();

    test('parses simple two-column rows, trimmed, with line numbers', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'eat, 먹다\n drink ,마시다',
      );

      expect(preview.issues, isEmpty);
      expect(preview.canCommit, isTrue);
      expect(preview.rows, hasLength(2));
      expect(preview.rows[0].front, 'eat');
      expect(preview.rows[0].back, '먹다');
      expect(preview.rows[0].lineNumber, 1);
      expect(preview.rows[1].front, 'drink', reason: 'trimmed');
      expect(preview.rows[1].lineNumber, 2);
    });

    test('drops a leading front,back header (case-insensitive)', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'Front,Back\na,b',
      );

      expect(preview.rows, hasLength(1));
      expect(preview.rows.single.front, 'a');
      expect(preview.rows.single.lineNumber, 2);
    });

    test('preserves quoted commas and escaped quotes', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: '"a, b","say ""hi"""',
      );

      expect(preview.issues, isEmpty);
      expect(preview.rows.single.front, 'a, b');
      expect(preview.rows.single.back, 'say "hi"');
    });

    test('a quoted field may embed a newline (single record)', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: '"line1\nline2",back',
      );

      expect(preview.rows, hasLength(1));
      expect(preview.rows.single.front, 'line1\nline2');
      expect(preview.rows.single.back, 'back');
    });

    test(
      'a quoted field may embed a CRLF (normalised to LF), line counted',
      () {
        final FlashcardImportPreview preview = parse.call(
          rawCsv: '"line1\r\nline2",back\nc,d',
        );

        expect(preview.rows, hasLength(2));
        expect(preview.rows[0].front, 'line1\nline2', reason: 'CRLF → LF');
        expect(
          preview.rows[1].lineNumber,
          3,
          reason: 'embedded CRLF advances the source line counter',
        );
      },
    );

    test('a header with extra columns is still dropped (C7-consistent)', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'Front,Back,Notes\na,b',
      );

      expect(preview.rows, hasLength(1));
      expect(preview.rows.single.front, 'a');
    });

    test('header-only input yields an empty preview', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: 'front,back\n');

      expect(preview.rows, isEmpty);
      expect(preview.issues, isEmpty);
      expect(preview.canCommit, isFalse);
    });

    test('skips fully blank lines but keeps line numbers', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'a,b\n\n   \nc,d',
      );

      expect(preview.rows, hasLength(2));
      expect(preview.rows[1].front, 'c');
      expect(preview.rows[1].lineNumber, 4, reason: 'blank lines counted');
    });

    test('handles CRLF line endings', () {
      final FlashcardImportPreview preview = parse.call(
        rawCsv: 'a,b\r\nc,d\r\n',
      );

      expect(preview.rows, hasLength(2));
      expect(preview.rows[1].back, 'd');
    });

    test('extra columns are ignored; take the first two (C7)', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: 'a,b\nx,y,z');

      expect(preview.issues, isEmpty);
      expect(preview.rows, hasLength(2));
      expect(preview.rows[1].front, 'x');
      expect(preview.rows[1].back, 'y', reason: 'third column ignored');
    });

    test('a single-column row is malformed and excluded', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: 'a,b\nonlyone');

      expect(preview.rows, hasLength(1), reason: 'only the valid row');
      expect(preview.rows.single.front, 'a');
      expect(preview.issues, hasLength(1));
      expect(preview.issues.single.kind, ImportRowIssueType.malformedRow);
      expect(preview.issues.single.lineNumber, 2);
      expect(preview.canCommit, isFalse, reason: 'issue blocks commit');
    });

    test(
      'an empty front is a missingFront issue, row excluded (6.2.2/C30)',
      () {
        final FlashcardImportPreview preview = parse.call(rawCsv: 'a,b\n,back');

        expect(preview.rows, hasLength(1), reason: 'only the valid row');
        expect(preview.rows.single.front, 'a');
        expect(preview.issues, hasLength(1));
        expect(preview.issues.single.kind, ImportRowIssueType.missingFront);
        expect(preview.issues.single.lineNumber, 2);
        expect(preview.canCommit, isFalse);
      },
    );

    test('an empty back is a missingBack issue (6.2.2/C30)', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: 'front,   ');

      expect(preview.rows, isEmpty);
      expect(preview.issues.single.kind, ImportRowIssueType.missingBack);
      expect(preview.issues.single.lineNumber, 1);
      expect(preview.canCommit, isFalse);
    });

    test('a row empty on both sides reports both issues', () {
      // A bare separator → two empty columns (not a blank line) → both issues.
      final FlashcardImportPreview preview = parse.call(rawCsv: ',');

      expect(preview.rows, isEmpty);
      expect(preview.issues, hasLength(2));
      expect(preview.issues.map((i) => i.kind).toSet(), <ImportRowIssueType>{
        ImportRowIssueType.missingFront,
        ImportRowIssueType.missingBack,
      });
      expect(preview.issues.every((i) => i.lineNumber == 1), isTrue);
    });

    test('empty input yields an empty preview', () {
      final FlashcardImportPreview preview = parse.call(rawCsv: '');
      expect(preview.rows, isEmpty);
      expect(preview.issues, isEmpty);
      expect(preview.canCommit, isFalse);
    });
  });
}
