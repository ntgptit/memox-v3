---
last_updated: 2026-06-10
applies_to: SRS algorithm, flashcard_progress, review session finalization
---

# SRS Review

> **Status: Current (one-terminal-attempt flows + finalization) / Target (history surfaces).** Box transition and
> interval computation are implemented in `StudyRepositoryImpl.finalizeStudySession` and verified by
> `test/data/repositories/study_srs_transition_test.dart` (decision rows S11–S15). The columns
> `study_attempts.box_before` / `box_after` **exist in the current schema**
> (`lib/data/datasources/local/drift/study_attempts.drift`) and are populated on every attempt
> insert by `recordStudySessionAnswer`. What remains Target: `flashcard_progress.last_reset_at`
> (needed only by the Future card-history/reset features), the card history timeline screen, study
> result box-change aggregates, and the progress-screen box distribution chart.

## Source files to inspect

- `lib/domain/**progress**`
- `lib/domain/**study**`
- `lib/data/**progress**`
- `lib/data/**study**`
- `lib/data/datasources/local/drift/flashcard_progress.drift`
- `lib/data/datasources/local/drift/study_attempts.drift`
- `lib/data/repositories/study_repo_impl.dart` (canonical owner of finalization in V1).
- `lib/data/repositories/study_repo_impl_study_session.dart` (`_finalizeResultForAttempts`,
  `_boxAfterFinalization`, `_intervalForBox` — transitions and due-date calculation).
- `lib/data/repositories/study_repo_record_answer.dart` (in-session answer recording helper; keeps
  `flashcard_progress` unchanged until finalization).
- `lib/domain/study/usecases/study_usecases.dart` (session creation, empty-scope checks, and
  in-session answer orchestration; the legacy `lib/domain/srs/box_intervals.dart` and
  `lib/domain/srs/box_transition.dart` files do NOT exist).

## Data

SRS state is stored in `flashcard_progress`.

Important fields:

- `flashcard_id`
- `current_box` (1-8)
- `review_count`
- `lapse_count`
- `last_studied_at` (UTC epoch ms)
- `due_at` (UTC epoch ms)

`last_result` is not part of the current schema and remains a future/reporting concern.

## Rules

- Box range is 1 to 8 inclusive.
- New flashcard starts at `current_box = 1` with `due_at = now`.
- Due card: `due_at <= now`.
- **Daily new-card limit (BE V1, WBS 4.5.10):** at most `dailyNewLimit` new cards (default 20)
  enter study per local day. Daily usage is derived from persisted `study_session_items` belonging
  to new-card sessions whose `started_at` falls within the current local-day window
  (`start <= started_at < end`). Cancelled new-card sessions still consume quota in BE V1 because
  the persisted items are the source of truth. New-card eligibility queries must respect the
  remaining quota for the day; cards beyond the quota stay queued for following days. This cap only
  trims new-card eligibility and does not hide due review cards.
  Rationale: a new card defaults to `due_at = now`, so without a limit a 500-row import floods
  "Today" with 500 cards at once — the primary burnout driver in SRS apps.
- Deleted flashcards must not appear in due list (foreign key enforced).
- Review result must update progress through domain/use case/repository flow.
- UI must not update SRS box directly.
- SRS review must use study session tables.
- Do not add separate review tables unless schema change is explicitly approved.
- In-session bury/suspend is not a review result: it removes the current
  session item from the queue, updates only `buried_until` or
  `is_suspended`, preserves `current_box` / `due_at` / `review_count` /
  `lapse_count`, and touches `study_sessions.updated_at`.

## Review results

See `docs/business/glossary.md` for result definitions.

| Result           | When it applies (adopted contract 2026-06-10)                                                      |
|------------------|------------------------------------------------------------------------------------------------------|
| `perfect`        | Correct, clean attempt (V1 "Got it")                                                                  |
| `recovered`      | Single passing-but-imperfect attempt: fill hint-taint or Mark-correct override (Target; redefined — no longer "forgot then passed", which now finalizes as `forgot`) |
| `forgot`         | First attempt failed (V1 "Forgot"); under retry modes, a first-attempt fail stays `forgot` even after a same-session re-queue pass |
| `initial_passed` | **Never emitted** (kept in the enum/storage codec for compatibility; identical transition to `perfect`). Reviving it requires a new product decision. |

Guess mode follows the clean-attempt contract above: a correct tap emits `perfect`, not `initial_passed`.

## Box transition table

This is the authoritative transition contract. The box transition is computed at session
finalization by `StudyRepositoryImpl.finalizeStudySession` in
`lib/data/repositories/study_repo_impl.dart`; the in-session
`Answer*UseCase` family in `lib/domain/study/usecases/study_usecases.dart` only records attempts
and re-queues failed cards. Implementation must match this table. There is no standalone
`box_transition.dart` file at present.

Per-card result classification at finalization (implemented in
`_finalizeResultForAttempts`, `lib/data/repositories/study_repo_impl_study_session.dart`): the
current V1 runtime only has one terminal persisted attempt per item, so the **last** attempt is
also the only attempt. That makes the current classifier observationally equivalent to
`perfect` / `recovered` / `forgot` on single-attempt flows.

> **✅ Adopted decision (2026-06-10, C1 — SRS demotion reachability): first attempt decides SRS.**
> When a future retry/re-queue mode actually appends multiple attempts before finalization, the
> FIRST persisted attempt for that item will determine the SRS outcome: first attempt `forgot` →
> final result `forgot` (box → 1, lapse +1) even if the card is re-queued and passed later in the
> same session. Re-queued passes are in-session relearning: they are recorded as attempts and
> satisfy session completion, but do not change the SRS outcome.
>
> For the current repo slice, that rule is deferred because Fill V1 still persists one terminal
> attempt per item. No classifier change is required for Fill BE V1.
>
> Consequences for the implementation when the first append-attempt retry mode is built (do these
> together):
>
> - `_finalizeResultForAttempts` must switch from the current single-terminal-attempt behavior to
>   **first-attempt** classification for the forgot path; update
>   `test/data/repositories/study_srs_transition_test.dart` (S13 changes meaning) and decision rows
>   S13/S20 in the same change.
> - `recovered` is **redefined** only for that future append-attempt flow: it no longer means
>   "forgot then passed" (that is now `forgot`); it means a single passing-but-imperfect attempt
>   (fill hint-taint, Mark-correct override). Transition stays: box unchanged, no lapse. Update
>   `docs/business/glossary.md` together.
> - Fill V1 and the current self-grade flows stay on the existing one-terminal-attempt contract.

| Current box | Result           | Next box | Next due              |
|-------------|------------------|----------|-----------------------|
| n (1-7)     | `perfect`        | n + 1    | now + interval[n + 1] |
| n (1-7)     | `initial_passed` | n + 1    | now + interval[n + 1] |
| 8           | `perfect`        | 8 (stay) | now + interval[8]     |
| 8           | `initial_passed` | 8 (stay) | now + interval[8]     |
| n (1-8)     | `recovered`      | n (stay) | now + interval[n]     |
| n (1-8)     | `forgot`         | 1        | now + interval[1]     |

## Interval table

Intervals are defined in `_intervalForBox`
(`lib/data/repositories/study_repo_impl_study_session.dart`). Verified 2026-06-10: the runtime
ladder **matches this table exactly** and is pinned by table-driven tests
(`test/data/repositories/study_srs_transition_test.dart`). Any change to either side must update
both in the same commit.

**Due-time normalization (BE V1, WBS 4.6.4):**
`due_at` is normalized to the **local midnight of the target day**
(`localMidnight(studyDay + interval)`), not `finalize_instant + interval`. Rationale: with exact
timestamps a card finalized at 15:47 becomes due at 15:47 the next day, so "due today" counts
drift upward during the day ("0 cards" in the morning, "12 cards" by evening) and users stop
trusting the number. This also aligns with bury's existing local-midnight semantics.

| Box | Interval | Approx   | Rationale                                                                |
|-----|----------|----------|--------------------------------------------------------------------------|
| 1   | 1 day    | 1 day    | Same-day-next retry; force overnight memory consolidation before re-test |
| 2   | 2 days   | 2 days   | Gentle stretch                                                           |
| 3   | 3 days   | 3 days   | Gentle stretch                                                           |
| 4   | 4 days   | 4 days   | Gentle stretch                                                           |
| 5   | 5 days   | 5 days   | Gentle stretch                                                           |
| 6   | 12 days  | ~2 weeks | First larger jump after solid short-term retention                       |
| 7   | 30 days  | 1 month  | Long-term retention check                                                |
| 8   | 60 days  | 2 months | Maintenance                                                              |

Design intent: avoid overwhelming the user. Box 1 → 5 increases linearly by one day, so each
successive review feels like a small step. Larger jumps reserved for boxes 6+ where the card is
already stable.

When implementation differs from this table, record the mismatch as a product/docs decision and
update whichever side is chosen in the same commit. (No mismatch exists as of 2026-06-10.)

## Counter rules

| Counter        | When incremented                    |
|----------------|-------------------------------------|
| `review_count` | Every finalized review (any result) |
| `lapse_count`  | Only on `forgot` result             |

## In-session self-grade V1

The current Study Session recall shell records answer attempts during the session:

- Reveal the current card.
- Tap `Forgot` or `Got it`.
- Persist a `study_attempts` row and set `study_session_items.answered_at`.
- Do not update `flashcard_progress` yet.

This keeps progress commits and box transitions in the finalization path, while the active session can move to the next unanswered item immediately.

## Finalization

At session finalization:

1. Persist all attempts (already done during session).
2. Compute final result per item based on attempt history and flow.
3. Update progress: `current_box`, `review_count`, `lapse_count`, `last_studied_at`, `due_at`.
4. Update session status to `completed`.

All steps must be in a single transaction. See `docs/database/storage-boundaries.md`.

On failure:

- Keep the user on the study session screen.
- Do not partially update progress.
- Show a controlled error and let the user retry the Finish action after the issue is resolved.
- The V1 finish flow does not auto-transition to a retry state.

## Due query contract

The due query must:

- Filter by `due_at <= now`.
- Exclude deleted flashcards (foreign key, but enforce in query).
- Order by `due_at ASC` then `current_box ASC`.
- Scope correctly (deck / folder recursive / all).

## Agent rule

Any SRS behavior change must update:

- `lib/data/repositories/study_repo_impl.dart` and
  `lib/data/repositories/study_repo_impl_study_session.dart` (finalization and interval helpers)
- This doc (transition table and/or interval table)
- `docs/business/study/study-flow.md` if flow changes
- Decision table rows S6-S15
- Targeted tests in `test/data/repositories/study_srs_transition_test.dart` and
  `test/data/repositories/study_repository_test.dart`

## Related

**Wireframes:**

- `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md` —
  every mode persists SRS update via this contract
- `docs/wireframes/18-study-result.md` — Box changes block aggregates from `box_before` /
  `box_after`
- `docs/wireframes/03-progress.md` — Box distribution chart

**Schema:**

- `docs/database/schema-contract.md` → `flashcard_progress` (current_box 1-8, due_at, review_count,
  lapse_count, last_studied_at, last_result, last_reset_at), `study_attempts` (box_before,
  box_after, result)

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "SRS" + history rows H1-H8

**Glossary terms:**

- `docs/business/glossary.md` → `current_box`, `due_at`, `result`, `perfect`, `initial_passed`,
  `recovered`, `forgot`, `lapse_count`

**Related business specs:**

- `docs/business/study/study-flow.md` — caller of SRS update
- `docs/business/history/card-history.md` — read-only view of attempts
- `docs/business/study-actions/bury-suspend.md` — bury/suspend preserves SRS state (does NOT reset
  box)
- `docs/business/flashcard/flashcard-management.md` — reset progress sets box=1, last_reset_at=now

**Source files to inspect (verified 2026-06-10):**

- `lib/domain/study/usecases/study_usecases.dart` — session lifecycle use cases
  (`StartStudySessionUseCase`, `RestartStudySessionUseCase`, `RecordStudySessionAnswerUseCase`,
  `FinalizeStudySessionUseCase`, `CancelStudySessionUseCase`, review/result loaders). In-session
  answers record attempts only; the final SRS transition is committed by the data repository at
  finalization. The `Answer*BatchUseCase` family from earlier revisions does NOT exist.
- `lib/domain/study/modes/study_mode_strategy.dart` +
  `recall_study_mode_strategy.dart` + `study_mode_strategy_factory.dart` — per-mode behavior
  contract; V1 supports recall with a controlled-unsupported fallback for other modes.
- `lib/data/datasources/local/drift/study_attempts.drift` — persistence of each attempt with
  `box_before`, `box_after`, `result`, `study_mode`, `user_input`, `attempted_at`.
- `lib/data/datasources/local/drift/flashcard_progress.drift` — per-card SRS state
  (`box_number`, `lapse_count`, `due_at`, `last_studied_at`, `buried_until`, `is_suspended`).
- `lib/data/repositories/study_repo_impl.dart` +
  `lib/data/repositories/study_repo_impl_study_session.dart` — finalization write path; computes
  the final per-card result from persisted attempts, applies the box transition, and computes
  runtime due intervals through `_intervalForBox`.

> **Drift note**: earlier revisions of this doc referenced `lib/domain/srs/box_intervals.dart`,
`lib/domain/srs/box_transition.dart`, `lib/domain/srs/srs_service.dart`,
`lib/data/repositories/srs_repository.dart`, and
`lib/domain/usecases/study/grade_attempt_usecase.dart`. **None of those paths exist** in the current
> codebase (verified by `find lib/domain -name "box_*"` returning empty). The current finalization
> path lives in `lib/data/repositories/study_repo_impl.dart`. If a future refactor extracts
> transitions into dedicated domain files, update this list and `CLAUDE.md` in the same commit.
