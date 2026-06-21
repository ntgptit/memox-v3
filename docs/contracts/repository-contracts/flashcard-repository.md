---
last_updated: 2026-06-21
status: contract
---

# Flashcard Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Handles flashcards + their `flashcard_progress` rows (1:1) + `flashcard_tags` (1:N).

## Methods

```dart
// Queries
Stream<List<FlashcardWithState>> watchByDeck(DeckId deckId, {
  CardStatusFilter status = CardStatusFilter.all,
  List<TagName> tags = const [],
});
Stream<FlashcardDetail?> watchDetail(FlashcardId id);
Future<Either<Failure, Flashcard>> findById(FlashcardId id);
Future<Either<Failure, int>> countByDeck(DeckId deckId);
Future<Either<Failure, int>> countDueByDeck(DeckId deckId);
Future<Either<Failure, int>> countDueGlobal();
Future<Either<Failure, List<Flashcard>>> findByIds(List<FlashcardId> ids);
Future<Either<Failure, List<Flashcard>>> findInScope(StudyScope scope);
Future<Either<Failure, List<Flashcard>>> existingByFrontBackPairs(
  DeckId deckId,
  List<({String front, String back})> pairs,
);
Future<Either<Failure, DeckCsvExport>> exportDeckCsv(DeckId deckId);

// Mutations
Future<Either<Failure, Flashcard>> create(FlashcardCreationData data);
Future<Either<Failure, Flashcard>> update(FlashcardId id, FlashcardUpdateData data);
Future<Either<Failure, Flashcard>> move(FlashcardId id, DeckId newDeckId);
Future<Either<Failure, Unit>> delete(FlashcardId id);
Future<Either<Failure, int>> deleteMany(List<FlashcardId> ids);
Future<Either<Failure, int>> moveMany(List<FlashcardId> ids, DeckId targetDeckId);
Future<Either<Failure, int>> bulkAddTags(List<FlashcardId> ids, List<String> tags);
Future<Either<Failure, int>> bulkRemoveTags(List<FlashcardId> ids, List<String> tags);
Future<Either<Failure, int>> bulkSuspend(List<FlashcardId> ids);
Future<Either<Failure, int>> bulkUnsuspend(List<FlashcardId> ids);
Future<Either<Failure, int>> bulkResetProgress(List<FlashcardId> ids);
Future<Either<Failure, ImportCommitResult>> importChunked(
  DeckId deckId, 
  List<FlashcardCreationData> items,
);
```

> **Current implementation (verified 2026-06-10).** The interface above is the
> **Target** (`Either`-based, full surface). The shipped V1
> `FlashcardRepository` (`lib/domain/repositories/flashcard_repository.dart`,
> impl `lib/data/repositories/flashcard_repository_impl.dart`) is a `Result`-based
> subset for the Flashcard List/editor slice:
> - `Future<Result<FlashcardDetail>> getFlashcardDetail({flashcardId})` — loads the editor detail
>   model with deck context, breadcrumb, normalized tags, and the progress snapshot used by the
>   progress-policy dialog.
> - `Future<Result<Flashcard>> createFlashcard({deckId, front, back, exampleSentence, pronunciation, hint, tags})`
>   — trims required fields, stores the optional example sentence / pronunciation / hint when
>   provided, lowercases/dedupes tags, and inserts the initial `flashcard_progress` row plus
>   `flashcard_tags` rows in the same transaction.
> - `Future<Result<Flashcard>> updateFlashcard({flashcardId, front, back, exampleSentence, pronunciation, hint, tags, progressPolicy})`
>   — updates the content and tags, and optionally resets the current `flashcard_progress` row
>   when the editor explicitly selects `resetProgress`.
> - `Future<Result<int>> commitDeckImport({deckId, rows})` — inserts valid CSV preview rows for a
>   deck in one transaction, creating the default `flashcard_progress` row for each insert and
>   returning the committed count.
> - `Future<Result<DeckCsvExport>> exportDeckCsv({deckId})` — exports one deck as a deterministic
>   CSV payload using `front,back` columns only. Empty decks return a valid header-only CSV. The
>   repository also returns a safe file name derived from the deck name with a deterministic
>   deck-id fallback.
> - `Stream<Result<FlashcardListDetail>> watchFlashcardList(deckId, {searchTerm, tags, status, sort})`
>   — deck + folder breadcrumb + search/tag/status-filtered cards (search matches front/back,
>   case-insensitive contains; `tags` is a multi-select **AND** filter, each tag normalized with the
>   storage rule `_normalizeTags` so it matches stored tags; empty `tags` = no filter) +
>   filter-independent `totalCount` (composes `FlashcardDao` with `FolderDao` for the breadcrumb +
>   content-revision stream). Tag filter is Current (WBS 2.18.1). The **status** filter
>   (`FlashcardStatusFilter`: `all` / `active` / `due` / `suspended` / `buried`) is Current
>   (WBS 2.17.1) — each card's state is derived from its `flashcard_progress` row at read time (no
>   row = new, active card), with `now` read once per emission from the repository's injected clock;
>   `active` excludes suspended + currently-buried (expired bury counts active), `due` keeps active
>   cards with `due_at <= now`. The list stream watches the `flashcards` table only, so a FE consumer
>   must invalidate the list after a bury/suspend (which writes to `flashcard_progress`) — see
>   WBS 2.17.2 / `docs/business/study-actions/bury-suspend.md` §Filters.
> - `Future<Result<void>> deleteFlashcard({flashcardId})` — single-card delete (progress
>   cascades via FK).
> - `Future<Result<void>> reorderFlashcards({deckId, orderedIds})` — writes `sort_order` by
>   list position in one transaction after validating the full sibling set. Empty, duplicate,
>   missing, wrong-deck, and partial reorder lists are rejected.
>
> Deck deletion lives on `FolderRepository.deleteDeck` (cascades cards, reverts an emptied
> parent folder to `unlocked`). `watchByDeck` (filtered + `CardState`), `move`, all `bulk*`,
> `findInScope`, and tag operations are **Future** (block on the bury/suspend + bulk epics).
> Migration to the `Either`/full surface is deferred to the approved `fpdart` migration.

## Transaction requirements

| Operation | Single transaction across |
| --- | --- |
| `create` | `flashcards` INSERT + `flashcard_progress` initial row + `flashcard_tags` rows |
| `update` (with tags) | `flashcards` UPDATE + replace `flashcard_tags` rows |
| `move` | `flashcards.deck_id` UPDATE + `sort_order` recompute |
| `delete` | `study_attempts`, `flashcard_tags`, `flashcard_progress`, `flashcards` |
| `bulk*` | Single transaction for ALL ids in batch |
| `commitDeckImport` | Valid preview rows + `flashcard_progress` rows (single transaction) |
| `importChunked` | Each chunk = own transaction (SQLite param limit ~500). Caller treats overall result as committed/aborted as whole. |

## CardState computation

When returning `FlashcardWithState`, compute priority: Suspended > Buried > Due > Active. Logic in `CardStateComputer` (shared, NOT duplicated per repo method).

## Constraints

- `front` and `back` non-empty after trim.
- Optional example sentence / pronunciation / hint text is trimmed and stored as `null` when blank.
- Tags via `flashcard_tags` rows, lowercased, max 50 chars, deduped case-insensitively.
- Initial progress row MUST be created with `current_box=1`, `due_at=NULL` (brand-new, never
  scheduled — the card counts as NEW until first studied; `due_at` is set on first finalization).

## Forbidden

- ❌ Skip initial `flashcard_progress` row on create.
- ❌ Update `current_box` from this repo (only `docs/contracts/repository-contracts/progress-repository.md` does that).
- ❌ Return Drift row.
- ❌ Apply tag normalization without going through `TagValidator`.
- ❌ Bulk operation outside transaction.
- ❌ Per-row loop in `deleteMany` / `moveMany` (use batch operation).

## Test contract

- Create flashcard with tags → verify progress + tags rows created.
- Get flashcard detail → verify deck context, breadcrumb, tags, and progress snapshot.
- Update flashcard tags → verify replace semantics.
- Update flashcard with reset policy → verify progress row resets to the fresh-card state.
- Move flashcard → verify progress + tags preserved.
- Reorder flashcards → verify full-list validation, transactional update, and rollback on failure.
- Bulk operations → verify atomicity (rollback on one failure).
- Deck import commit → verify transactional success and rollback on row validation failure.
- Import chunked → verify chunked transactions, verify duplicate detection.
- Deck export CSV → verify missing-deck failure, header-only empty export, deterministic row order, CSV escaping, safe file name, and read-only behavior.
- Filter by status + tags → verify SQL correctness.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/flashcard/flashcard-management.md`
**Use cases:** `docs/contracts/usecase-contracts/flashcard.md`, `docs/contracts/usecase-contracts/bulk.md`
**Schema:** `docs/database/schema-contract.md` `flashcards`, `flashcard_progress`, `flashcard_tags`
**Code paths:**

- `lib/domain/repositories/flashcard_repository.dart`
- `lib/data/repositories/flashcard_repository_impl.dart`
- `lib/data/datasources/local/daos/flashcard_dao.dart`
- `lib/data/datasources/local/daos/flashcard_progress_dao.dart`
- `lib/domain/flashcard/card_state_computer.dart`
