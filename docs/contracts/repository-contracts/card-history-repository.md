---
last_updated: 2026-06-24
status: Implemented (V1, 2026-06-24, WBS 7.6.1)
---

# Card History Repository Contract

> Target architecture note: the `Either<Failure, T>` shape is the intended style; this port uses the
> existing repository `Result<T>` pattern (`docs/contracts/error-contract.md`).

Read-only per-card history (kit screen 09). One full-load read; per-card scale is small, so there is
no pagination (`docs/business/history/card-history.md`).

## Port

```dart
abstract interface class CardHistoryRepository {
  Future<Result<CardHistory>> loadCardHistory({required FlashcardId flashcardId});
}
```

`lib/domain/repositories/card_history_repository.dart`; impl
`lib/data/repositories/card_history_repository_impl.dart` over `CardHistoryDao`
(`lib/data/datasources/local/daos/card_history_dao.dart` →
`lib/data/datasources/local/drift/history_queries.drift`).

## loadCardHistory

Composes `CardHistory { header, events }`:

- **Header** (`cardHistoryHeader`): `flashcards` JOIN `decks` LEFT JOIN `flashcard_progress` →
  front, deck name, `box_number`, `review_count`, `lapse_count`, `last_reset_at`, `created_at`.
  `avgDurationMs` = `cardHistoryAvgDuration` (`AVG(study_attempts.duration_ms)` over measured
  attempts; null when none). Accuracy/retention is derived from the counters, never by scanning
  attempts.
- **Feed**: `cardHistoryAttempts` (attempts joined via `study_session_items`) → `attempt` events +
  `cardHistoryEvents` (`card_events`) → `lifecycle` events + a synthesized `created` event from
  `created_at` (skipped if a real `created` row exists). Sorted by `occurred_at` DESC in Dart.

**Errors:** `NotFoundFailure` (missing card), `StorageFailure` (read).

No schema change — reads the v7 `card_events` / `study_attempts.duration_ms` /
`flashcard_progress.last_reset_at` columns.

## Forbidden

- ❌ Delete/edit `study_attempts` rows (read-only).
- ❌ Compute accuracy by scanning attempts (use stored counters).
- ❌ Offset/cursor pagination (per-card full load).

## Related

**Use cases:** `docs/contracts/usecase-contracts/history.md` (`GetCardHistoryUseCase`).
**Business spec:** `docs/business/history/card-history.md`.
**Decision table:** H1–H9 in `docs/decision-tables/progress-history.md`.
**Tests:** `test/data/repositories/card_history_repository_impl_test.dart`.
