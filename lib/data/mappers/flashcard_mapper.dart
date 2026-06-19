// Hide the generated Drift `FlashcardProgress` *table* class so it does not
// clash with the domain [FlashcardProgress] entity (the mapper only needs the
// row type, `FlashcardProgressRow`).
import 'package:memox/data/datasources/local/app_database.dart'
    hide FlashcardProgress;
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/flashcard_progress.dart';
import 'package:memox/domain/types/ids.dart';

/// Maps between Drift rows and the domain [Flashcard] / [FlashcardProgress].
///
/// Storage conventions (`docs/database/schema-contract.md`): optional notes are
/// `NULL` when blank; tags live in `flashcard_tags` (passed in separately);
/// timestamps are UTC epoch milliseconds. Repositories MUST map rows through
/// here and never leak Drift rows past the data layer
/// (`docs/contracts/repository-contracts/flashcard-repository.md` §Forbidden).
abstract final class FlashcardMapper {
  const FlashcardMapper._();

  static Flashcard fromRow(
    FlashcardRow row, {
    List<TagName> tags = const <TagName>[],
  }) => Flashcard(
    id: row.id,
    deckId: row.deckId,
    front: row.front,
    back: row.back,
    exampleSentence: row.exampleSentence,
    pronunciation: row.pronunciation,
    hint: row.hint,
    tags: tags,
    sortOrder: row.sortOrder,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt, isUtc: true),
  );

  static FlashcardProgress progressFromRow(FlashcardProgressRow row) =>
      FlashcardProgress(
        flashcardId: row.flashcardId,
        currentBox: row.boxNumber,
        dueAt: row.dueAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row.dueAt!, isUtc: true),
        reviewCount: row.reviewCount,
        lapseCount: row.lapseCount,
      );
}
