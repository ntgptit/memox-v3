---
last_updated: 2026-06-02
status: contract
---

# Deck Use Cases Contract

> **Current implementation note (Prompt 43A, 2026-06-03):** nullable
> `parentFolderId` / root-deck signatures are Rejected / Out of Scope. Current
> production use cases require concrete folder ids and the Drift
> `decks.folder_id` column is non-null. Keep every deck folder-owned.
>
> **Prompt 42B design note (2026-06-02):**
> The nullable-deck-parent design (formerly `docs/database/migrations/nullable-deck-parent-migration.md`, file removed) is retained only
> as a rejected historical design note. Do not implement it.

> **Current implementation note (2026-06-20, WBS 2.7.1 / 2.8.1 / 2.10.1 / 2.19.1):**
> `CreateDeckUseCase`, `RenameDeckUseCase`, `ReorderDecksUseCase`, and `MoveDeckUseCase` are
> implemented over the project `Result` contract (NOT `Either` — see the target-architecture note
> below) and wired in `lib/app/di/folder_providers.dart`. Decks are folder-owned, so the use cases
> are backed by `FolderRepository.{createDeck,renameDeck,reorderDecks,moveDeck}` (there is no
> separate `DeckRepository`). Code: `lib/domain/usecases/deck/{create_deck,rename_deck,
> reorder_decks,move_deck}_usecase.dart`. Tests:
> `test/domain/usecases/deck/{create,rename,reorder,move}_deck*_usecase_test.dart`,
> `test/data/repositories/folder_repository_impl_deck_test.dart` and
> `folder_repository_impl_move_deck_test.dart`.
>
> **Current implementation note (2026-06-20, WBS 2.9.1):** `DeleteDeckUseCase` is now implemented
> over `FolderRepository.deleteDeck` (returning the project `Result<void>`). The deck-row delete
> cascades to its flashcards and, through the schema chain, their `flashcard_progress` +
> `flashcard_tags` rows (`flashcards.deck_id` ON DELETE CASCADE, schema v3); the source folder
> reverts to `unlocked` when it loses its last deck; a missing deck returns `NotFoundFailure`.
> Code: `lib/domain/usecases/deck/delete_deck_usecase.dart`. Tests:
> `test/domain/usecases/deck/delete_deck_usecase_test.dart`,
> `test/data/repositories/folder_repository_impl_delete_deck_test.dart`. Study attempt/session
> cascade is added when those tables ship (WBS 4.x).
>
> **Deferred (Specified):** `UpdateDeckUseCase`, `GetDeckDetailUseCase`, and
> `WatchDeckCountsUseCase` (WBS 3.7.x) are NOT yet implemented — their due-count logic depends on
> the recursive folder/deck count read model (WBS 3.7.x). Signatures below remain the target
> contract.

## RenameDeckUseCase

```dart
Future<Either<Failure, Deck>> call({required DeckId deckId, required String name});
```

**Rules:**

- Trim name. Reject empty.
- Repository enforces case-insensitive sibling uniqueness and keeps the deck's folder ownership
  and `sort_order` unchanged.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.

**Test refs:** `test/domain/usecases/deck/rename_deck_usecase_test.dart`.

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. If the project has not yet adopted `fpdart`, do not add it during
> ordinary feature implementation. First run an approved dependency/API migration task, or use the
> existing repository error/result pattern until that migration is approved.

## CreateDeckUseCase

```dart
Future<Either<Failure, Deck>> call({
  required String name,
  required TargetLanguage targetLanguage,
  required FolderId parentFolderId,
});
```

**Preconditions:**

- Parent folder exists.
- Parent `content_mode` ∈ (`unlocked`, `decks`).

**Rules:**

- Trim name. Reject empty.
- Reject duplicate within same parent (case-insensitive).
- Atomic insert + parent mode update. See `docs/contracts/repository-contracts/deck-repository.md`.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure` (parent locked to subfolders),
`ValidationFailure`, `StorageFailure`.

**Test refs:** D1-D3.

## UpdateDeckUseCase

```dart
Future<Either<Failure, Deck>> call({
  required DeckId id,
  String? newName,
  TargetLanguage? newTargetLanguage,
});
```

**Rules:**

- At least one of `newName`/`newTargetLanguage` provided; else `ValidationFailure`.
- Trim name. Reject empty.
- Reject duplicate name in same parent.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.

**Test refs:** D4-D5.

## MoveDeckUseCase

```dart
Future<Either<Failure, Deck>> call({
  required DeckId id,
  required FolderId newParentId,
});
```

**Preconditions:**

- New parent's `content_mode` ∈ (`unlocked`, `decks`).

**Rules:**

- Atomic deck-parent + both folder modes; recompute `sort_order`. See
  `docs/contracts/repository-contracts/deck-repository.md`.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure`, `StorageFailure`.

**Test refs:** D6.

## GetDeckMoveTargetsUseCase

```dart
Future<Either<Failure, List<DeckMoveTarget>>> call({required DeckId deckId});
```

Read path backing the deck §folder-picker sheet (kit `04-folder-detail--move-sheet`).

**Rules:**

- Returns **every folder** (no Library-root option — a deck always belongs to a folder,
  `decks.folder_id` non-null), each annotated: `isCurrentParent` (the deck's current folder,
  always selectable — re-selecting it is a same-folder **no-op** in `MoveDeckUseCase` that bypasses
  the content-mode guard, so it is safe even though `_deckParentGuard` would otherwise reject a
  `subfolders`-mode folder), and a non-null `block` = `DeckMoveBlock.lockedToSubfolders` when the
  folder is `content_mode = subfolders` (cannot hold a deck — mirrors the `MoveDeckUseCase`
  precondition / `_deckParentGuard`). Unlocked + decks-mode folders are selectable. Blocked rows are
  **disabled, never hidden** (`docs/wireframes/25-shared-bottom-sheets.md` §folder-picker). Sorted by
  breadcrumb path. Pure read — see `docs/contracts/repository-contracts/deck-repository.md`.

**Errors:** `NotFoundFailure` (missing deck), `StorageFailure`.

**Test refs:** D11, D12 — `test/data/repositories/get_deck_move_targets_test.dart`,
`test/domain/usecases/deck/get_deck_move_targets_usecase_test.dart`.

## DeleteDeckUseCase

```dart
Future<Either<Failure, Unit>> call({required DeckId id});
```

> Implemented (WBS 2.9.1) over the project `Result<void>` contract — `DeleteDeckUseCase.call`
> delegates to `FolderRepository.deleteDeck`.

**Rules:**

- Atomic deck-row delete inside a transaction; flashcards + their `flashcard_progress` /
  `flashcard_tags` rows go with it via the `flashcards.deck_id` ON DELETE CASCADE chain (schema v3).
  The source folder reverts to `unlocked` when it loses its last deck. Study attempt/session
  cascade is added when those tables ship (WBS 4.x). Full target cascade list in
  `docs/contracts/repository-contracts/deck-repository.md`.

**Errors:** `NotFoundFailure` (missing deck), `StorageFailure`.

**Caution:** Highly destructive. Caller MUST confirm via §delete-confirm dialog.

**Test refs:** D3 — `test/domain/usecases/deck/delete_deck_usecase_test.dart`,
`test/data/repositories/folder_repository_impl_delete_deck_test.dart`.

## ReorderDecksUseCase

```dart
Future<Either<Failure, Unit>> call({required FolderId parentId, required List<DeckId> orderedIds});
```

Same shape as ReorderFoldersUseCase.

**Test refs:** D8.

## GetDeckDetailUseCase

```dart
Future<Either<Failure, DeckDetail>> call({required DeckId id});
```

`DeckDetail` = deck + folder path + card count + due count.

## WatchDeckCountsUseCase

```dart
Stream<Either<Failure, DeckCounts>> call({required DeckId id});
```

`DeckCounts` = `{ totalCards, dueNow, suspendedCount, buriedTodayCount }`.

Used by deck-level study CTA enable/disable and Today CTA subtitle.

## Forbidden patterns

- ❌ Change `target_language` without consideration of TTS impact (UI must reflect on next study
  session).
- ❌ Delete deck without cascading session deletion.
- ❌ Allow create in `subfolders`-mode parent.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types),
`docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/deck/deck-management.md`
**Repository:** `docs/contracts/repository-contracts/deck-repository.md`
**Rejected migration design:** nullable deck parent (design note removed; decision recorded in `docs/business/deck/deck-management.md`)
**Wireframes:** `docs/wireframes/02-library.md`, `docs/wireframes/05-folder-detail.md`,
`docs/wireframes/06-flashcard-list.md`
**TTS gate:** `docs/business/tts/tts-settings.md`
**Decision table:** rows D1-D8
**Code paths:** `lib/domain/usecases/deck/**`
