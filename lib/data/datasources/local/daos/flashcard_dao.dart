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

  /// Tags attached to a flashcard, returned in storage order.
  Future<List<FlashcardTagRow>> findFlashcardTags(String flashcardId) =>
      (select(attachedDatabase.flashcardTags)
            ..where((FlashcardTags t) => t.flashcardId.equals(flashcardId)))
          .get();

  /// SRS progress row for a flashcard, if present.
  Future<FlashcardProgressRow?> findFlashcardProgress(String flashcardId) =>
      (select(attachedDatabase.flashcardProgress)
            ..where((FlashcardProgress t) => t.flashcardId.equals(flashcardId)))
          .getSingleOrNull();

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

  Future<void> updateFlashcardContent({
    required String id,
    required String front,
    required String back,
    required String? exampleSentence,
    required String? pronunciation,
    required String? hint,
    required int updatedAt,
  }) => (update(flashcards)..where((Flashcards t) => t.id.equals(id))).write(
    FlashcardsCompanion(
      front: Value<String>(front),
      back: Value<String>(back),
      exampleSentence: Value<String?>(exampleSentence),
      pronunciation: Value<String?>(pronunciation),
      hint: Value<String?>(hint),
      updatedAt: Value<int>(updatedAt),
    ),
  );

  Future<void> replaceFlashcardTags({
    required String flashcardId,
    required List<String> tags,
  }) async {
    await (delete(attachedDatabase.flashcardTags)
          ..where((FlashcardTags t) => t.flashcardId.equals(flashcardId)))
        .go();
    for (final String tag in tags) {
      await into(attachedDatabase.flashcardTags).insert(
        FlashcardTagsCompanion.insert(flashcardId: flashcardId, tag: tag),
      );
    }
  }

  Future<void> resetFlashcardProgress({
    required String flashcardId,
    required int nowMs,
  }) => (update(attachedDatabase.flashcardProgress)
        ..where((FlashcardProgress t) => t.flashcardId.equals(flashcardId)))
      .write(
        FlashcardProgressCompanion(
          boxNumber: const Value<int>(1),
          dueAt: Value<int?>(nowMs),
          buriedUntil: const Value<int?>(null),
          isSuspended: const Value<bool>(false),
          reviewCount: const Value<int>(0),
          lapseCount: const Value<int>(0),
          lastStudiedAt: const Value<int?>(null),
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
