---
last_updated: 2026-06-24
status: Implemented (V1 redesign-simplified, 2026-06-24, WBS 7.6.1–7.6.3)
---

# History Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended
> error/result contract style. The project has not yet adopted `fpdart`, so these use cases use the
> existing `Result<T>` (`Ok`/`Err`) contract (`docs/contracts/error-contract.md`).

Read-only per-card attempt timeline + lifetime stats. **Implemented** to the kit-09 mock
(redesign-simplified) on 2026-06-24.

## GetCardHistoryUseCase (the V1 read)

```dart
Future<Result<CardHistory>> call({required FlashcardId flashcardId});
```

The single full-load read (`lib/domain/usecases/history/get_card_history_usecase.dart`) →
`CardHistoryRepository.loadCardHistory`. Per-card scale is small, so the feed loads **fully** (no
pagination — supersedes the earlier paginated `GetCardHistoryPageUseCase` design below;
`docs/business/history/card-history.md`).

**Rules:**

- **Header** (`CardHistoryHeader`): card front + deck name + current `box_number` + lifetime counters
  + `last_reset_at` from `flashcards` JOIN `decks` LEFT JOIN `flashcard_progress` in one query.
  `accuracy` (retention) is derived from the stored counters
  (`(reviewCount - lapseCount) / reviewCount`); `avgDurationMs` = `AVG(study_attempts.duration_ms)`
  over measured attempts. Do NOT scan attempts for accuracy.
- **Feed** (`List<CardHistoryEvent>`): all `study_attempts` (joined via `study_session_items`) mapped
  to `CardHistoryEvent.attempt` + all `card_events` mapped to `CardHistoryEvent.lifecycle` + a
  **synthesized** `created` event from `flashcards.created_at` (skipped if a real `created` row
  exists), sorted by `occurred_at` DESC (the synthesized created sinks to the floor).

**Returns:** `CardHistory { header, events }`.

**Errors:** `NotFoundFailure` (card), `StorageFailure`.

**Test refs:** H1, H4, H7; `test/data/repositories/card_history_repository_impl_test.dart`.

## Deferred / superseded

- **`ResetFlashcardProgressUseCase`** (reset SRS + append a `reset` `card_events` row): NOT built —
  the kit-09 mock exposes no reset/overflow affordance (mock-authoritative). Deferred with the
  Reset/Delete/Edit actions (decision rows H3/H5). When built it must retain counters + attempts.
- **`GetCardHistoryHeaderUseCase` / `GetCardHistoryPageUseCase` (paginated split):** superseded by the
  full-load `GetCardHistoryUseCase` above.

## Forbidden patterns

- ❌ Compute lifetime accuracy by scanning attempts. Use stored counters.
- ❌ Allow inline edit of attempts (read-only).
- ❌ Render `Box 0` for pre-migration rows (box_before=0 or box_after=0). Render `—` instead.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`,
`docs/contracts/code-style.md`

**Business spec:** `docs/business/history/card-history.md`
**Repository:** `docs/contracts/repository-contracts/card-history-repository.md`
**Wireframes:** `docs/wireframes/09-flashcard-history.md`
**Decision table:** H1-H9 in `docs/decision-tables/progress-history.md`
**Code paths:** `lib/domain/usecases/history/get_card_history_usecase.dart`,
`lib/data/repositories/card_history_repository_impl.dart`,
`lib/presentation/features/history/**`
