import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/entities/flashcard.dart';

/// Maps between the Drift `FlashcardRow` and the domain [Flashcard] entity.
///
/// Storage conventions (`docs/database/schema-contract.md`): optional text
/// fields are `null` when blank (never an empty string); timestamps are UTC
/// epoch milliseconds. Repositories MUST map rows through here and never leak
/// `FlashcardRow` past the data layer.
abstract final class FlashcardMapper {
  const FlashcardMapper._();

  static Flashcard fromRow(FlashcardRow row) => Flashcard(
    id: row.id,
    deckId: row.deckId,
    front: row.front,
    back: row.back,
    exampleSentence: row.exampleSentence,
    pronunciation: row.pronunciation,
    hint: row.hint,
    partOfSpeech: row.partOfSpeech,
    isFlagged: row.isFlagged,
    sortOrder: row.sortOrder,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt, isUtc: true),
  );
}
