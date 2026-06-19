import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';

part 'flashcard_dao.g.dart';

/// Thin Drift accessor for the `flashcards` table plus the LIKE-based global
/// search queries.
///
/// Single-table lookups and mutations only — validation (front/back required,
/// duplicate detection) and cross-table parent checks are orchestrated in
/// `FlashcardRepositoryImpl`, which calls these inside its transactions. No
/// business logic lives here (`docs/database/drift-guide.md`).
@DriftAccessor(include: <String>{'../drift/flashcards.drift'})
class FlashcardDao extends DatabaseAccessor<AppDatabase>
    with _$FlashcardDaoMixin {
  FlashcardDao(super.db);

  /// Single flashcard row, or `null` if it does not exist.
  Future<FlashcardRow?> findFlashcardById(String id) => (select(
    flashcards,
  )..where((Flashcards t) => t.id.equals(id))).getSingleOrNull();

  /// Flashcards in [deckId], used for case-insensitive duplicate checks and the
  /// next `sort_order`.
  Future<List<FlashcardRow>> flashcardsInDeck(String deckId) => (select(
    flashcards,
  )..where((Flashcards t) => t.deckId.equals(deckId))).get();

  Future<void> insertFlashcard(FlashcardsCompanion card) =>
      into(flashcards).insert(card);

  Future<void> updateFlashcardColumns(String id, FlashcardsCompanion changes) =>
      (update(
        flashcards,
      )..where((Flashcards t) => t.id.equals(id))).write(changes);

  Future<void> deleteFlashcardById(String id) =>
      (delete(flashcards)..where((Flashcards t) => t.id.equals(id))).go();

  /// Run [action] in a single database transaction.
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      transaction(action);
}
