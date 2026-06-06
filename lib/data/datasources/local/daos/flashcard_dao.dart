import 'package:drift/drift.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/types/content_sort_mode.dart';

part 'flashcard_dao.g.dart';

/// Drift accessor for flashcard reads + V1 mutations
/// (`docs/contracts/repository-contracts/flashcard-repository.md`).
///
/// SQL reads live in `drift/flashcard_queries.drift` (pulled in via `include`);
/// the methods here bind parameters and build the runtime `ORDER BY`. The small
/// single-row mutations (delete, sort-order write) use the Drift query builder.
@DriftAccessor(include: <String>{'../drift/flashcard_queries.drift'})
class FlashcardDao extends DatabaseAccessor<AppDatabase>
    with _$FlashcardDaoMixin {
  FlashcardDao(super.db);

  // ── Read queries (defined in flashcard_queries.drift) ─────────────

  /// Cards in [deckId], optionally name-filtered, ordered per [sort].
  /// [normalizedSearch] is already-normalized (or null/blank for the full list);
  /// it is turned into a LIKE pattern here.
  Future<List<FlashcardRow>> getFlashcards({
    required String deckId,
    required ContentSortMode sort,
    String? normalizedSearch,
  }) => flashcardListItems(
    deckId,
    _searchPattern(normalizedSearch),
    _flashcardOrder(sort),
  ).get();

  /// Total cards in [deckId] regardless of search.
  Future<int> countFlashcards(String deckId) =>
      flashcardCountInDeck(deckId).getSingle();

  /// Highest `sort_order` in [deckId], or -1 when the deck has no cards yet.
  Future<int> maxFlashcardSortOrder(String deckId) =>
      flashcardMaxSortOrderInDeck(deckId).getSingle();

  // ── Single-row mutations (Drift query builder) ────────────────────

  Future<void> deleteFlashcardById(String id) =>
      (delete(flashcards)..where((Flashcards t) => t.id.equals(id))).go();

  Future<FlashcardRow?> findFlashcard(String id) => (select(
    flashcards,
  )..where((Flashcards t) => t.id.equals(id))).getSingleOrNull();

  Future<void> updateSortOrder(String id, int sortOrder, int updatedAt) =>
      (update(flashcards)..where((Flashcards t) => t.id.equals(id))).write(
        FlashcardsCompanion(
          sortOrder: Value<int>(sortOrder),
          updatedAt: Value<int>(updatedAt),
        ),
      );

  // ── ORDER BY builder for the `$order` query placeholder ───────────
  //
  // Mirrors `FolderDao._deckOrder`. `lastStudied` falls back to manual order
  // here — the read model carries no SRS data yet (study layer is Future).
  FlashcardListItems$order _flashcardOrder(ContentSortMode sort) =>
      (Flashcards f) => switch (sort) {
        ContentSortMode.name => OrderBy(<OrderingTerm>[
          OrderingTerm(expression: f.front),
          OrderingTerm(expression: f.sortOrder),
        ]),
        ContentSortMode.newest => OrderBy(<OrderingTerm>[
          OrderingTerm(expression: f.createdAt, mode: OrderingMode.desc),
          OrderingTerm(expression: f.sortOrder),
        ]),
        ContentSortMode.lastStudied || ContentSortMode.manual => OrderBy(
          <OrderingTerm>[
            OrderingTerm(expression: f.sortOrder),
            OrderingTerm(expression: f.createdAt),
          ],
        ),
      };

  static String _searchPattern(String? normalized) =>
      (normalized == null || normalized.isEmpty) ? '' : '%$normalized%';
}
