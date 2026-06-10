import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/repositories/flashcard_export_writer.dart';

void main() {
  group('FlashcardExportWriter', () {
    test(
      'EX5 buildCsv writes the header and escapes commas, quotes, newlines, CRs, and spaces',
      () {
        final String csv = FlashcardExportWriter.buildCsv(
          <({String front, String back})>[
            (front: ' Hello, world ', back: 'She said "hi"\nLine 2\rLine 3'),
          ],
        );

        expect(
          csv,
          'front,back\n" Hello, world ","She said ""hi""\nLine 2\rLine 3"',
        );
      },
    );

    test('EX5 escapeCsvCell quotes the required edge cases', () {
      expect(
        FlashcardExportWriter.escapeCsvCell('Hello, world'),
        '"Hello, world"',
      );
      expect(
        FlashcardExportWriter.escapeCsvCell('She said "hi"'),
        '"She said ""hi"""',
      );
      expect(
        FlashcardExportWriter.escapeCsvCell('Line 1\nLine 2'),
        '"Line 1\nLine 2"',
      );
      expect(
        FlashcardExportWriter.escapeCsvCell('Line 1\rLine 2'),
        '"Line 1\rLine 2"',
      );
      expect(FlashcardExportWriter.escapeCsvCell(' hello '), '" hello "');
    });

    test(
      'EX7 buildDeckFileName sanitizes deck names and keeps the csv extension',
      () {
        expect(
          FlashcardExportWriter.buildDeckFileName(
            deckName: '  Korean / N5: vocab?  ',
            deckId: 'deck-1',
          ),
          'Korean_N5_vocab.csv',
        );
      },
    );

    test(
      'EX7 buildDeckFileName falls back to the deck id for blank or unsafe titles',
      () {
        expect(
          FlashcardExportWriter.buildDeckFileName(
            deckName: ' /\\?* ',
            deckId: 'deck-1',
          ),
          'deck_export_deck-1.csv',
        );
      },
    );
  });
}
