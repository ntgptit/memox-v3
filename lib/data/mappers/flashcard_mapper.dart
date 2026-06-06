import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/entities/flashcard.dart';

/// Maps Drift rows to flashcard domain types
/// (`docs/contracts/repository-contracts/flashcard-repository.md`).
abstract final class FlashcardMapper {
  FlashcardMapper._();

  static DateTime _dateFromMs(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  static Flashcard fromRow(FlashcardRow row) => fromStorageFields(
    id: row.id,
    deckId: row.deckId,
    front: row.front,
    back: row.back,
    exampleSentence: row.exampleSentence,
    pronunciation: row.pronunciation,
    hint: row.hint,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  /// Converts database storage fields to the domain entity.
  ///
  /// Generated query result classes are consumed at the repository boundary
  /// instead of being mirrored here.
  static Flashcard fromStorageFields({
    required String id,
    required String deckId,
    required String front,
    required String back,
    required String? exampleSentence,
    String? pronunciation,
    String? hint,
    required int sortOrder,
    required int createdAt,
    required int updatedAt,
  }) => Flashcard(
    id: id,
    deckId: deckId,
    front: front,
    back: back,
    exampleSentence: exampleSentence,
    pronunciation: pronunciation,
    hint: hint,
    sortOrder: sortOrder,
    createdAt: _dateFromMs(createdAt),
    updatedAt: _dateFromMs(updatedAt),
  );
}
