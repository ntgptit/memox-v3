import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'flashcard_dao.g.dart';

/// Thin Drift accessor for the `flashcards`, `flashcard_progress`, and
/// `flashcard_tags` tables.
///
/// Single-table lookups and mutations only — validation, tag normalization, the
/// initial-progress invariant, and cross-table writes are orchestrated in
/// `FlashcardRepositoryImpl`, which calls these inside its transactions. No
/// business logic lives here (`docs/database/drift-guide.md`).
@DriftAccessor(include: <String>{'../drift/flashcards.drift'})
class FlashcardDao extends DatabaseAccessor<AppDatabase>
    with _$FlashcardDaoMixin {
  FlashcardDao(super.db);

  // ---- flashcards ----

  /// Single flashcard row, or `null` if it does not exist.
  Future<FlashcardRow?> findFlashcardById(String id) => (select(
    flashcards,
  )..where((Flashcards t) => t.id.equals(id))).getSingleOrNull();

  /// Cards in [deckId] ordered by `sort_order` then `id` (deterministic), used
  /// for the list read, the next `sort_order`, and reorder validation.
  Future<List<FlashcardRow>> flashcardsInDeck(String deckId) =>
      _orderedCardsInDeck(deckId).get();

  /// Live stream of the cards in [deckId] ordered by `sort_order` then `id`.
  Stream<List<FlashcardRow>> watchFlashcardsInDeck(String deckId) =>
      _orderedCardsInDeck(deckId).watch();

  SimpleSelectStatement<Flashcards, FlashcardRow> _orderedCardsInDeck(
    String deckId,
  ) => select(flashcards)
    ..where((Flashcards t) => t.deckId.equals(deckId))
    ..orderBy(<OrderClauseGenerator<Flashcards>>[
      (Flashcards t) => OrderingTerm(expression: t.sortOrder),
      (Flashcards t) => OrderingTerm(expression: t.id),
    ]);

  Future<void> insertFlashcard(FlashcardsCompanion card) =>
      into(flashcards).insert(card);

  Future<void> updateFlashcardColumns(String id, FlashcardsCompanion changes) =>
      (update(
        flashcards,
      )..where((Flashcards t) => t.id.equals(id))).write(changes);

  Future<void> deleteFlashcardById(String id) =>
      (delete(flashcards)..where((Flashcards t) => t.id.equals(id))).go();

  // ---- flashcard_progress ----

  /// Progress row for [flashcardId], or `null` if absent.
  Future<FlashcardProgressRow?> findProgress(String flashcardId) =>
      (select(flashcardProgress)
            ..where((FlashcardProgress t) => t.flashcardId.equals(flashcardId)))
          .getSingleOrNull();

  Future<void> insertProgress(FlashcardProgressCompanion progress) =>
      into(flashcardProgress).insert(progress);

  Future<void> updateProgressColumns(
    String flashcardId,
    FlashcardProgressCompanion changes,
  ) =>
      (update(flashcardProgress)
            ..where((FlashcardProgress t) => t.flashcardId.equals(flashcardId)))
          .write(changes);

  /// Progress rows for the given [flashcardIds] in one query (deck-scoped read
  /// for the status filter, WBS 2.17.1). A card without a row is a new card
  /// (box 1, due_at NULL, not suspended, not buried).
  Future<List<FlashcardProgressRow>> progressForFlashcards(
    List<String> flashcardIds,
  ) {
    if (flashcardIds.isEmpty) {
      return Future<List<FlashcardProgressRow>>.value(
        const <FlashcardProgressRow>[],
      );
    }
    return (select(
      flashcardProgress,
    )..where((FlashcardProgress t) => t.flashcardId.isIn(flashcardIds))).get();
  }

  // ---- flashcard_tags ----

  /// All tag rows for the given [flashcardIds] in one query (deck-scoped read).
  Future<List<FlashcardTagRow>> tagsForFlashcards(List<String> flashcardIds) {
    if (flashcardIds.isEmpty) {
      return Future<List<FlashcardTagRow>>.value(const <FlashcardTagRow>[]);
    }
    return (select(flashcardTags)
          ..where((FlashcardTags t) => t.flashcardId.isIn(flashcardIds))
          ..orderBy(<OrderClauseGenerator<FlashcardTags>>[
            (FlashcardTags t) => OrderingTerm(expression: t.tag),
          ]))
        .get();
  }

  Future<void> insertTag(FlashcardTagsCompanion tag) =>
      into(flashcardTags).insert(tag);

  Future<void> deleteTagsForFlashcard(String flashcardId) => (delete(
    flashcardTags,
  )..where((FlashcardTags t) => t.flashcardId.equals(flashcardId))).go();

  // ---- transaction ----

  /// Run [action] in a single database transaction.
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      transaction(action);
}
