import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/repositories/flashcard_export_writer.dart';

void main() {
  // FlashcardExportWriter (WBS 8.7.1): pure CSV-format helpers
  // (docs/business/export/export.md §CSV format details).
  const FlashcardExportWriter writer = FlashcardExportWriter();

  group('escapeCsvCell', () {
    test('passes plain text through unchanged', () {
      expect(writer.escapeCsvCell('hello'), 'hello');
    });

    test('quotes a cell containing a comma', () {
      expect(writer.escapeCsvCell('a,b'), '"a,b"');
    });

    test('quotes and doubles inner quotes', () {
      expect(writer.escapeCsvCell('say "hi"'), '"say ""hi"""');
    });

    test('quotes a cell containing a newline', () {
      expect(writer.escapeCsvCell('line1\nline2'), '"line1\nline2"');
    });
  });

  group('buildCsv', () {
    test('empty rows → header only, no trailing newline', () {
      expect(writer.buildCsv(const []), 'front,back');
    });

    test('renders header + escaped rows joined with \\n', () {
      final csv = writer.buildCsv(const [
        (front: 'hello', back: 'xin chào'),
        (front: 'a,b', back: 'c"d'),
      ]);
      expect(csv, 'front,back\nhello,xin chào\n"a,b","c""d"');
    });
  });

  group('sanitizeFileName', () {
    test('keeps a clean name', () {
      expect(writer.sanitizeFileName('My Deck', fallbackId: 'd1'), 'My Deck');
    });

    test('replaces path separators and unsafe characters', () {
      expect(
        writer.sanitizeFileName('a/b:c*?<>|"d', fallbackId: 'd1'),
        'a_b_c_d',
      );
    });

    test('collapses repeats and trims leading/trailing underscores', () {
      expect(
        writer.sanitizeFileName('  //weird//  ', fallbackId: 'd1'),
        'weird',
      );
    });

    test('falls back to deck id when the name sanitizes to blank', () {
      expect(writer.sanitizeFileName('///', fallbackId: 'd42'), 'deck_d42');
    });
  });
}
