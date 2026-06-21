---
last_updated: 2026-06-20
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
  List<String> tags = const [],
});
```

**Rules:**

- Trim front and back. Reject empty for either → `ValidationFailure(field, code: empty)`.
- Trim `exampleSentence`, `pronunciation`, and `hint`; store `null` when any value is blank after
  trim.
- Validate tags: reject commas, trim, dedupe case-insensitively, and store lowercased values.
- Atomic insert flashcard + initial `flashcard_progress` row (current_box=1, due_at=NULL,
  review_count=0, lapse_count=0) plus `flashcard_tags` rows when provided. See
  `docs/contracts/repository-contracts/flashcard-repository.md`.
- Current shipped create flow supports front, back, example sentence, pronunciation, hint, and
  tags.

**Errors:** `NotFoundFailure` (deck), `ValidationFailure`, `StorageFailure`.

**Test refs:** FC1-FC3, TG9, TG10.

> **Current implementation (rebuild, WBS 2.11.1 — Partial).** Shipped as the
> `Result`-based `CreateFlashcardUseCase`
> (`lib/domain/usecases/flashcard/create_flashcard_usecase.dart`) over
> `FlashcardRepository.createFlashcard`. The signature adds `partOfSpeech` and
> omits `tags` (no `flashcard_tags` table yet) and the initial
> `flashcard_progress` row (no `flashcard_progress` table yet) — both deferred
> until those tables ship (WBS 2.15.x / SRS). Front/back required-after-trim,
> blank optional → null, appended `sort_order`, and the missing-deck
> `NotFoundFailure` parent check (WBS 2.16.1) are implemented. Decision rows
> C1-C3, C8, C41. Test: `test/data/repositories/flashcard_repository_impl_test.dart`.

## UpdateFlashcardUseCase

```dart
Future<Either<Failure, Flashcard>> call({
  required FlashcardId flashcardId,
  required String front,
  required String back,
  String? exampleSentence,
  String? pronunciation,
  String? hint,
  List<String> tags = const [],
  FlashcardProgressEditPolicy progressPolicy = FlashcardProgressEditPolicy.keepProgress,
});
```

> **Current implementation (verified 2026-06-07).** Shipped as the `Result`-based
> `UpdateFlashcardUseCase` (`lib/domain/usecases/flashcard/update_flashcard_usecase.dart`).

**Rules:**

- Same validation as create for provided fields. Front/back are required after trim; optional
  example sentence / pronunciation / hint are trimmed and collapsed to `null` when blank.
- Tag list replaces the current tags, deduped case-insensitively and normalized for storage. See
  `docs/contracts/repository-contracts/flashcard-repository.md`.
- V1 editor passes `FlashcardProgressEditPolicy.keepProgress` by default and only switches to
  `resetProgress` after the explicit progress-policy dialog.
- If learned front/back content changes on a card with learning progress, the editor must ask for an
  explicit policy before saving:
    - `keepProgress` preserves existing `flashcard_progress`.
    - `resetProgress` resets `flashcard_progress` to the current V1 fresh-card state through the
      repository update path.
- This policy dialog is not the Future standalone Card History reset flow and does not require a
  live History route.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.

**Test refs:** FC4-FC5, `test/domain/usecases/flashcard/update_flashcard_usecase_test.dart::normalizes tags and forwards the reset progress policy`.

> **Current implementation (rebuild, WBS 2.12.1).** Shipped as the
> `Result`-based `UpdateFlashcardUseCase`
> (`lib/domain/usecases/flashcard/update_flashcard_usecase.dart`) over
> `FlashcardRepository.updateFlashcard({id, front, back, exampleSentence,
> pronunciation, hint, partOfSpeech})`. Tags and the `FlashcardProgressEditPolicy`
> are not wired yet (no `flashcard_tags` / `flashcard_progress` tables). Front/back
> required-after-trim, blank optional → null, deck + `sort_order` preserved, and a
> missing-card `NotFoundFailure(flashcard)`. Test:
> `test/data/repositories/flashcard_repository_impl_test.dart`.

## CheckManualDuplicateFlashcardUseCase

```dart
Future<Result<FlashcardDuplicateCheckResult>> call({
  required DeckId deckId,
  required String front,
  required String back,
  FlashcardId? excludeId,
});
```

> **Current implementation (rebuild, WBS 2.20.1).** Shipped as the
> `Result`-based `CheckManualDuplicateFlashcardUseCase`
> (`lib/domain/usecases/flashcard/check_manual_duplicate_flashcard_usecase.dart`)
> over `FlashcardRepository.checkManualDuplicate`.

**Rules:**

- **Non-blocking soft-warning.** Never rejects a save; the editor uses the result
  to show a "save anyway?" confirm. Create/update save the card regardless.
- A card is a duplicate when its trimmed, case-insensitive `front` + `back` match
  an existing card in the **same deck**.
- `excludeId` skips the card itself on edit.
- Returns `FlashcardDuplicateCheckResult { isDuplicate, matchingFlashcardIds }`
  (`lib/domain/models/flashcard_duplicate_check_result.dart`).

**Errors:** `StorageFailure(read)`.

**Test refs:** C40, `test/data/repositories/flashcard_repository_impl_duplicate_behavior_test.dart`,
`test/domain/usecases/flashcard/check_manual_duplicate_flashcard_usecase_test.dart`.

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

## ExportDeckCsvUseCase

```dart
Future<Either<Failure, DeckCsvExport>> call({required DeckId deckId});
```

> **Current implementation (verified 2026-06-10).** Shipped as the `Result`-based
`ExportDeckCsvUseCase` (`lib/domain/usecases/flashcard/export_deck_csv_usecase.dart`) over
`FlashcardRepository.exportDeckCsv`. V1 exports one deck to CSV using `front,back` columns only.
Empty decks return a valid header-only CSV. The repository returns the safe file name, deck id,
deck name, CSV text, and exported row count.

**Rules:**

- Trim `deckId` and reject blanks with `ValidationFailure(field: deckId, code: empty)`.
- Delegate deck existence and CSV building to the repository.
- Export is read-only. It does not mutate database rows.

**Errors:** `ValidationFailure`, `NotFoundFailure`, `StorageFailure`.

**Test refs:** `test/domain/usecases/flashcard/export_deck_csv_usecase_test.dart`.

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
  required ImportSource source,  // Target shorthand; concrete type = ImportSourceFormat
  required ImportOptions options,  // separator (ImportTextSeparator), has-header, etc.
});
```

> **Pinned contract (WBS 6.0.1 enabler).** The single `ImportFlashcardsUseCase` /
> `Either<Failure, …>` signature above is the **Target** style. The rebuild splits it into three
> `Result`-based use cases in `lib/domain/usecases/flashcard/` (code lands WBS 6.2.x–6.9.1; the
> shared types + preview/preparation models are pinned now in `lib/domain/types/**` +
> `lib/domain/models/flashcard_import_preview.dart`):
> - `ParseDeckImportCsvUseCase.call({rawCsv}) → FlashcardImportPreview` — parse pasted CSV (and, via
>   `ImportTextSeparator`, structured text), detect an optional `front,back` header, preserve quoted
>   values / escaped quotes, skip blank rows, and collect row-level issues as `ImportValidationIssue`
>   (categorized by `ImportRowIssueType`). (WBS 6.2.1 / 6.2.2 / 6.9.1.)
>   **Implemented (WBS 6.2.1 + 6.2.2):** pure synchronous transform; RFC-4180 quoting (quoted comma/
>   newline/`""`-escape), header drop, blank-line skip, trims front/back; a record with ≥2 columns
>   maps to the first two (extra columns ignored — decision row C7), a record with <2 columns becomes
>   a `malformedRow` issue. CONTENT validation (WBS 6.2.2): front/back required-after-trim →
>   `missingFront`/`missingBack` line-numbered issue, that row excluded from committable `rows`
>   (decision C30); no max-length is enforced anywhere so `*TooLong` stays reserved. The
>   `ImportTextSeparator` option is WBS 6.9.1 (V1 default comma).
> - `PrepareDeckImportUseCase.call({deckId, preview}) → Future<Result<FlashcardImportPreparation>>` —
>   over a clean preview, apply `FlashcardImportDuplicatePolicy.skipExactDuplicates` against earlier
>   file rows and existing deck cards, returning the committable `previewItems` + `skippedDuplicates`
>   (each tagged with its `FlashcardImportDuplicateSource`). (WBS 6.6.1.)
> - `CommitDeckImportUseCase.call({deckId, preparation}) → Future<Result<int>>` — reject empty deck
>   id, reject empty `previewItems`, then commit the rows + default SRS progress in a single
>   repository transaction (no silent partial import). Returns the committed count. (WBS 6.4.1.)
>
> Preview is in-line and clean preview rows are committed from the same screen. Migration to the
> `Either`/single-call form is deferred to the approved `fpdart` migration.

### Import preview model family (WBS 6.0.1)

Pinned, behavior-free DTOs shared by the three use cases above and the preview screen — defined in
`lib/domain/models/flashcard_import_preview.dart`, composing the enums in
`docs/contracts/types-catalog.md` (§ImportSourceFormat, §ImportRowIssueType,
§FlashcardImportDuplicateSource):

| Type | Shape | Role |
| --- | --- | --- |
| `FlashcardImportRow` | `{ int lineNumber, String front, String back }` | One candidate card (V1 CSV = front/back only). |
| `ImportValidationIssue` | `{ ImportRowIssueType kind, int lineNumber, String message }` | A per-row validation problem. |
| `FlashcardImportPreview` | `{ List<FlashcardImportRow> rows, List<ImportValidationIssue> issues }` + `canCommit` (rows non-empty & no issues), `hasIssues` | Parse + validation output; drives the preview screen + commit gate. |
| `FlashcardImportSkippedDuplicate` | `{ int lineNumber, String front, String back, FlashcardImportDuplicateSource source }` | A row dropped by duplicate detection. |
| `FlashcardImportPreparation` | `{ List<FlashcardImportRow> previewItems, List<FlashcardImportSkippedDuplicate> skippedDuplicates }` + `importCount`, `skippedCount` | Dedup output; `previewItems` are committed. |

**Phases:**

1. Parse pasted CSV → list of (front, back) candidates.
2. Validate each candidate. Issues collected.
3. Skip blank rows.
4. If preview call, return the preview model.
5. If commit call and preview is clean, write the valid rows in a single transaction.

**Errors:** `NotFoundFailure` (deck), `ValidationFailure`, `StorageFailure`, parse errors mapped to
row-level validation issues in the preview model.

**Test refs:** IM1-IM6, plus import commit rows/rollback tests in `docs/decision-tables/memox-core-decision-table.md`.

## WatchFlashcardListUseCase

```dart
Stream<Either<Failure, FlashcardListDetail>> call(
  DeckId deckId, {
  String? searchTerm,
  List<TagName> tags = const [],
  ContentSortMode sort = ContentSortMode.manual,
});
```

> **Current implementation (search verified 2026-06-10; tag filter WBS 2.18.1, 2026-06-20).** Shipped
> as the `Result`-based `WatchFlashcardListUseCase`
> (`lib/domain/usecases/flashcard/watch_flashcard_list_usecase.dart`) over
> `FlashcardRepository.watchFlashcardList`. The V1 list-watch supports a deck-scoped front/back
> **search** term and a **multi-select AND `tags` filter** (each selected tag normalized with the
> storage rule — trim + lowercase + dedup — so it matches stored tags; empty selection = no filter).
> Search and tag filters compose, and `totalCount` reflects the full deck total regardless of either,
> so the UI can distinguish empty-deck from no-results. **Status filters** (`active` / `due` /
> `suspended` / `buried`) and the computed `CardState` / `WatchFlashcardsByFilterUseCase` remain
> **Specified / Future** (WBS 2.17.1) — blocked on the suspend/bury columns, which have not shipped.

**Rules:**

- `FlashcardListDetail` = deck + folder breadcrumb + (search/tag-filtered) cards + `totalCount`.
- A non-blank `searchTerm` keeps cards whose front or back contains the trimmed, case-insensitive
  term. A non-empty `tags` keeps cards carrying **every** selected tag (AND); the two compose.
  Decision rows C38, C39.
- `totalCount` is the deck's full card count, independent of `searchTerm` and `tags` — it lets the
  UI tell empty-deck (`totalCount == 0`) apart from no-results (`cards.isEmpty && totalCount > 0`).
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
Future<Either<Failure, FlashcardDetail>> call({required FlashcardId flashcardId});
```

> **Current implementation (verified 2026-06-07).** Shipped as the `Result`-based
> `GetFlashcardDetailUseCase` (`lib/domain/usecases/flashcard/get_flashcard_detail_usecase.dart`).

`FlashcardDetail` = flashcard + tags + progress snapshot + deck context.

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
