---
last_updated: 2026-05-28
status: contract
---

# SRS Use Cases Contract

Pure SRS transition and due-date contracts. The target architecture is deterministic domain functions/services, but the current runtime owners are repository finalization helpers. Documented here for AI agent reference so future extraction does not change behavior accidentally.

> No `fpdart` / `Either<Failure, T>` disclaimer in this file. All functions here are pure synchronous logic that returns plain values or throws `AssertionError` on programmer error. They do not perform IO and therefore never return `Either`. Error/result wrapping concerns apply at the calling layer (`GradeAttemptUseCase`), not here. If a future change introduces IO into this layer, add the disclaimer per `docs/contracts/error-contract.md` and update this note.

## BoxIntervals

```dart
abstract final class BoxIntervals {
  /// Interval in days for [box] (1..8): 1,2,3,4,5,12,30,60.
  static int daysFor(int box);
}
```

**Rules:**

- Returns the interval in **days** for a given box (1-8 inclusive).
- Asserts box in 1..8 (programmer error); also clamps so release builds never
  crash.

**Source (current — WBS 4.6.2):** `BoxIntervals.daysFor(box)` in `lib/domain/srs/box_intervals.dart` (the single owner of the ladder; values match this table 1:1, pinned by `test/data/repositories/study_srs_transition_test.dart`).

## BoxTransition

```dart
class BoxTransition {
  static BoxNumber computeNext({required BoxNumber current, required AttemptResult result});
}
```

**Rules:**

| Current | Result | Next |
| --- | --- | --- |
| 1..7 | perfect, initialPassed | current+1 |
| 8 | perfect, initialPassed | 8 (capped) |
| 1..8 | recovered | current (no change) |
| 1..8 | forgot | 1 |

**Source (current — WBS 4.4.1/4.6.2):** `SrsBox.nextBox(current, result)` in `lib/domain/srs/srs_box.dart`, applied at finalization by `StudyRepositoryImpl.finalizeStudySession` (`lib/data/repositories/study_repository_impl.dart`). The `RecordStudySessionAnswerUseCase` family records attempts only; final box transitions on `flashcard_progress` are finalization-owned.

## DueDateComputer

```dart
class DueDateComputer {
  DueDateComputer(this._clock);
  final Clock _clock;

  DateTime computeFromBox(BoxNumber box);
}
```

**Rules:**

- V1 (WBS 4.6.4): `due_at = localMidnight(studyDay + BoxIntervals.daysFor(box))` —
  normalized to the local midnight of the target day (not `finalize_instant +
  interval`) so "due today" counts stay stable across the day. Computed in Dart
  local time; never via a SQLite `localtime` modifier.

**Source (current — WBS 4.6.4):** `StudyRepositoryImpl._dueAtFor(now, box)` in `lib/data/repositories/study_repository_impl.dart`, using `BoxIntervals.daysFor` and the injected `now` (epoch ms); pinned by `test/data/repositories/study_srs_transition_test.dart`.

## NextCardSelector

```dart
class NextCardSelector {
  List<Flashcard> orderQueue(List<Flashcard> candidates, StudyType studyType);
}
```

**Rules:**

- Target `srsReview`: order due candidates deterministically, with oldest-due cards first.
- Target `newCards`: order new candidates deterministically before applying any configured shuffle.
- Stable sort unless study settings explicitly shuffle.

**Source (target/future extraction):** a future extracted domain helper if approved.
**Source (current):** no dedicated `NextCardSelector` implementation exists. Runtime selection is implemented by `StudyRepoImpl.loadNewCards` and `StudyRepoImpl.loadDueCards` in `lib/data/repositories/study_repo_impl.dart`, backed by `_eligibleFlashcards` in `lib/data/repositories/study_repo_impl_helpers.dart`. Current due-card SQL orders by `p.due_at ASC, f.sort_order ASC`; new-card SQL orders by `f.sort_order ASC`; repository settings may then shuffle the loaded batch.

## LifetimeStatsComputer

```dart
class LifetimeStatsComputer {
  LifetimeStats compute(FlashcardProgress progress);
}
```

**Rules:**

- `accuracy = (review_count - lapse_count) / review_count` if review_count > 0, else 0.0.
- Uses counters on `flashcard_progress` directly. Does NOT scan `study_attempts`.

**Source (target/future extraction):** a future extracted domain helper if approved.
**Source (current):** no dedicated `LifetimeStatsComputer` implementation exists. Current runtime does not expose this standalone lifetime-stats abstraction; existing SRS counters are persisted on `flashcard_progress`, while result-screen accuracy is session-scoped rather than lifetime-scoped.

## Forbidden patterns

- ❌ Hardcode interval days outside the single owner `BoxIntervals.daysFor` (`lib/domain/srs/box_intervals.dart`).
- ❌ Box transition computed inline in a notifier or widget.
- ❌ Different transition rules per study mode (mode does NOT affect transition).
- ❌ Use `DateTime.now()` directly. Always via injected `Clock`.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Repositories used:** Target/future extracted helpers would be pure domain logic. Current runtime behavior is inside `StudyRepoImpl` finalization and query/load helpers.

**Business spec:** `docs/business/srs/srs-review.md`
**Caller:** `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase
**Wireframes:** `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md`
**Decision table:** rows under "SRS"
**Code paths (current — WBS 4.6.x):** SRS finalization lives in `StudyRepositoryImpl.finalizeStudySession` (`lib/data/repositories/study_repository_impl.dart`); box transition in `SrsBox.nextBox` (`lib/domain/srs/srs_box.dart`); interval ladder in `BoxIntervals.daysFor` (`lib/domain/srs/box_intervals.dart`); due-date normalization in `StudyRepositoryImpl._dueAtFor`. Due/new-card SELECTION (`NextCardSelector` above) is not yet implemented (eligibility counts land via WBS 4.1.1; ordered-card selection is a later slice).
