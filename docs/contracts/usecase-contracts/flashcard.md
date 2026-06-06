---
last_updated: 2026-06-06
status: contract
---

# Flashcard Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.

## CreateFlashcardUseCase

```dart
Future<Either<Failure, Flashcard>> call({
  required DeckId deckId,
  required String front,
  required String back,
  String? exampleSentence,
  String? pronunciation,
  String? hint,
});
```

**Rules:**

- Trim front and back. Reject empty for either → `ValidationFailure(field, code: empty)`.
- Trim `exampleSentence`, `pronunciation`, and `hint`; store `null` when any value is blank after
  trim.
- Atomic insert flashcard + initial `flashcard_progress` row (current_box=1, due_at=now,
  review_count=0, lapse_count=0). See `docs/contracts/repository-contracts/flashcard-repository.md`.
- Current shipped create flow supports front, back, example sentence, pronunciation, and hint.
  Tags remain future editor work until the schema and screen expand together.

**Errors:** `NotFoundFailure` (deck), `ValidationFailure`, `StorageFailure`.

**Test refs:** FC1-FC3, TG9, TG10.

## UpdateFlashcardUseCase

```dart
Future<Either<Failure, Flashcard>> call({
  required FlashcardId id,
  String? front, String? back, String? note, String? example, String? pronunciation, String? hint,
  List<String>? tags,  // if non-null, replace ALL tags
});
```

**Rules:**

- Same validation as create for provided fields.
- Tag list (if provided) replaces; old tags removed, new tags inserted, dedup applied. Atomic. See
  `docs/contracts/repository-contracts/flashcard-repository.md`.
- V1 editor passes `FlashcardProgressEditPolicy.keepProgress` by default.
- If learned front/back content changes on a card with learning progress, the editor must ask for an
  explicit policy before saving:
    - `keepProgress` preserves existing `flashcard_progress`.
    - `resetProgress` resets `flashcard_progress` to the current V1 fresh-card state through the
      repository update path.
- This policy dialog is not the Future standalone Card History reset flow and does not require a
  live History route.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.

**Test refs:** FC4-FC5.

## MoveFlashcardUseCase

```dart
Future<Either<Failure, Flashcard>> call({required FlashcardId id, required DeckId newDeckId});
```

**Preconditions:**

- New deck exists.
- New deck's parent folder allows decks (parent is `decks` or `unlocked`).

**Rules:**

- UPDATE `flashcards.deck_id`.
- Recompute `sort_order` at new deck.
- Preserve `flashcard_progress` and `flashcard_tags`.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Test refs:** FC6.

## DeleteFlashcardUseCase

```dart
Future<Either<Failure, Unit>> call({required FlashcardId id});
```

**Rules:**

- Atomic cascade: attempts, tags, progress, flashcard row. See
  `docs/contracts/repository-contracts/flashcard-repository.md`.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Caution:** Destructive. Confirm via §delete-confirm.

**Test refs:** FC7.

## ResetFlashcardProgressUseCase (Future / migration-required standalone action)

```dart
Future<Either<Failure, FlashcardProgress>> call({required FlashcardId id});
```

**Rules:**

- UPDATE `flashcard_progress`: `current_box = 1`, `due_at = now`, `last_reset_at = now`.
  `review_count` and `lapse_count` UNCHANGED.
- Do NOT delete `study_attempts`. History preserved.
- Not V1 editor scope. Do not expose this standalone action until
  `docs/business/history/card-history.md` is promoted and its migration dependencies are approved.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Test refs:** H3, H5, H7.

## ImportFlashcardsUseCase

```dart
Future<Either<Failure, ImportResult>> call({
  required DeckId deckId,
  required ImportSource source,  // structured-text / csv-file / xlsx-file
  required ImportOptions options,  // separator, has-header, etc.
});
```

> **Current implementation (verified 2026-05-31, Prompt 17).** The single
`ImportFlashcardsUseCase` / `Either<Failure, …>` signature above is the **Target** style. The
> shipped code splits this into two `Result`-based use cases in
`lib/domain/usecases/flashcard_usecases.dart`:
> - `PrepareFlashcardImportUseCase.execute(...) → Future<Result<FlashcardImportPreparation>>` —
    parse + validate + dedupe-against-deck (phases 1–5).
> - `CommitFlashcardImportUseCase.execute({deckId, preparation}) → Future<Result<int>>` — re-applies
    the duplicate policy, rejects when `!canCommit`, then chunk-inserts in a single transaction (
    phase 6). Returns the committed count.
>
> Preview is in-line (no preview-only flag); `FlashcardImportPreparation.canCommit` gates the
> commit. Migration to the `Either`/single-call form is deferred to the approved `fpdart` migration.

**Phases:**

1. Parse source → list of (front, back) candidates.
2. Validate each candidate. Issues collected.
3. Deduplicate within file (in-file duplicates marked).
4. Compare against existing deck cards (in-deck duplicates marked).
5. If preview-only call, return `ImportPreview`.
6. If commit call AND `issues.isEmpty` AND `commit==true`, chunked INSERT in single logical
   transaction.

**Errors:** `NotFoundFailure` (deck), `ValidationFailure`, `StorageFailure`, parse errors mapped to
`ValidationFailure` with line numbers.

**Test refs:** IM1-IM6.

## WatchFlashcardListUseCase

```dart
Stream<Either<Failure, FlashcardListDetail>> call(
  DeckId deckId, {
  String? searchTerm,
  ContentSortMode sort = ContentSortMode.manual,
});
```

> **Current implementation (verified 2026-06-06).** Shipped as the `Result`-based
> `WatchFlashcardListUseCase` (`lib/domain/usecases/flashcard/watch_flashcard_list_usecase.dart`)
> over `FlashcardRepository.watchFlashcardList`. This is the V1 list-watch — the
> unfiltered (search-only) precursor to `WatchFlashcardsByFilterUseCase`; status/tag
> filters and computed `CardState` are Future.

**Rules:**

- `FlashcardListDetail` = deck + folder breadcrumb + (search-filtered) cards + `totalCount`.
- `totalCount` is the deck's full card count, independent of `searchTerm` — it lets the UI
  tell empty-deck (`totalCount == 0`) apart from no-results-on-search (`cards.isEmpty &&
  totalCount > 0`).
- A missing/deleted deck yields `NotFoundFailure`.

**Errors:** `NotFoundFailure`, `StorageFailure`.

## ReorderFlashcardsUseCase

```dart
Future<Either<Failure, Unit>> call({
  required DeckId deckId,
  required List<FlashcardId> orderedIds,
});
```

> **Current implementation (verified 2026-06-06).** Shipped as the `Result`-based
> `ReorderFlashcardsUseCase` (`lib/domain/usecases/flashcard/reorder_flashcards_usecase.dart`).

**Rules:**

- `orderedIds` is the full post-drag order of the deck's cards; the repository writes
  `sort_order` by list position in one transaction (`docs/decision-tables/memox-core-decision-table.md`
  §D4).

**Errors:** `StorageFailure`.

**Test refs:** D4.

## WatchFlashcardsByFilterUseCase

```dart
Stream<Either<Failure, List<FlashcardWithState>>> call({
  required DeckId deckId,
  CardStatusFilter statusFilter = CardStatusFilter.all,
  List<TagName> tagFilter = const [],
});
```

Returns flashcards with computed `CardState` (priority: Suspended > Buried > Due > Active).
**Future** — status/tag filtering and `CardState` are not yet implemented; V1 uses
`WatchFlashcardListUseCase` above.

## GetFlashcardDetailUseCase

```dart
Future<Either<Failure, FlashcardDetail>> call({required FlashcardId id});
```

`FlashcardDetail` = flashcard + tags + progress + deck context.

## Forbidden patterns

- ❌ Update `current_box` from UI / outside `GradeAttemptUseCase` or `ResetFlashcardProgressUseCase`.
- ❌ Delete attempts when resetting progress.
- ❌ Skip initial `flashcard_progress` row on create.
- ❌ Commit import when `issues.isNotEmpty`.
- ❌ Apply tag normalization (lowercase, trim) before validation. Validate as-typed, then normalize
  for storage.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types),
`docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/flashcard/flashcard-management.md`
**Repository:** `docs/contracts/repository-contracts/flashcard-repository.md`
**Wireframes:** `docs/wireframes/06-flashcard-list.md` through `docs/wireframes/10-deck-import.md`
**Tags spec:** `docs/business/tags/tag-system.md`
**Decision table:** rows FC*, IM*, H3
**Code paths:** `lib/domain/usecases/flashcard/**`
