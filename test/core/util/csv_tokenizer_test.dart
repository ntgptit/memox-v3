import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/util/csv_tokenizer.dart';

void main() {
  // CsvTokenizer (WBS 6.2.1): core/util wrapper over the `csv` package. Records
  // of trimmed string cells; RFC-4180 quoting; LF/CRLF/CR normalized.
  group('CsvTokenizer.tokenize', () {
    test('splits rows and trims cells', () {
      expect(CsvTokenizer.tokenize('a, b\nc ,d'), <List<String>>[
        <String>['a', 'b'],
        <String>['c', 'd'],
      ]);
    });

    test('handles quoted separators and escaped quotes', () {
      expect(CsvTokenizer.tokenize('"a, b","say ""hi"""'), <List<String>>[
        <String>['a, b', 'say "hi"'],
      ]);
    });

    test('normalizes CRLF and preserves quoted embedded newline as LF', () {
      expect(CsvTokenizer.tokenize('"l1\r\nl2",b\r\nc,d'), <List<String>>[
        <String>['l1\nl2', 'b'],
        <String>['c', 'd'],
      ]);
    });

    test('blank/empty input returns no records', () {
      expect(CsvTokenizer.tokenize(''), isEmpty);
      expect(CsvTokenizer.tokenize('   '), isEmpty);
    });

    test('respects a custom single-character separator', () {
      expect(
        CsvTokenizer.tokenize('a\tb', fieldDelimiter: '\t'),
        <List<String>>[
          <String>['a', 'b'],
        ],
      );
    });
  });
}
