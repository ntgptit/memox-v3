---
last_updated: 2026-06-13
status: Implemented (V1, promoted 2026-06-13)
---

# History Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. The project has not yet adopted `fpdart`, so these use cases use the
> existing `Result<T>` (`Ok`/`Err`) contract (`docs/contracts/error-contract.md`).

Read-only per-card attempt timeline + lifetime stats + progress reset. **Implemented** in V1;
`flashcard_progress.last_reset_at` shipped with schema v6.

## GetCardHistoryHeaderUseCase

```dart
Future<Result<CardHistoryHeader>> call({required FlashcardId flashcardId});
```

**Rules:**

- READ card preview (`flashcards.front` / `back`) + current SRS state + lifetime counters +
  `last_reset_at` from `flashcards` LEFT JOIN `flashcard_progress` in one query.
- `CardHistoryHeader.accuracy` is derived from the stored counters
  (`(reviewCount - lapseCount) / reviewCount`). Do NOT scan attempts.

**Returns:** `CardHistoryHeader`.

**Errors:** `NotFoundFailure` (card), `StorageFailure`.

**Test refs:** H4, H7.

## GetCardHistoryPageUseCase

```dart
Future<Result<CardHistoryPage>> call({
  required FlashcardId flashcardId,
  CardHistoryCursor? before,  // cursor
  int limit = 50,
});
```

**Rules:**

- READ `study_attempts` joined to `study_session_items` / `study_sessions` WHERE
  `flashcard_id = :id` ORDER BY `(attempted_at, id) DESC` LIMIT :limit (cursor compares on the
  composite `(attempted_at, id)` when [before] is provided).
- Cursor pagination (NOT offset).

**Returns:** `CardHistoryPage { attempts: List<CardHistoryAttempt>, nextCursor: CardHistoryCursor? }`.

**Errors:** `StorageFailure`.

**Test refs:** H1.

## ResetFlashcardProgressUseCase

```dart
Future<Result<void>> call({required FlashcardId flashcardId});
```

Resets SRS scheduling (box=1, due=now, unburied) and sets `flashcard_progress.last_reset_at = now`.
Lifetime counters and `study_attempts` rows are retained (cumulative), so the timeline keeps prior
attempts and renders the reset divider.

**Errors:** `StorageFailure`.

**Test refs:** H3, H5.

## Forbidden patterns

- ❌ Compute lifetime accuracy by scanning attempts. Use stored counters.
- ❌ Use OFFSET pagination. Cursor only.
- ❌ Allow inline edit of attempts (read-only).
- ❌ Render `Box 0` for pre-migration rows (box_before=0 or box_after=0). Render `—` instead.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`,
`docs/contracts/code-style.md`

**Business spec:** `docs/business/history/card-history.md`
**Repository:** `docs/contracts/repository-contracts/progress-repository.md` (attempts methods)
**Wireframes:** `docs/wireframes/09-flashcard-history.md`
**Decision table:** H1-H8
**Code paths:** `lib/domain/usecases/history/**`
