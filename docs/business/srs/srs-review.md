---
last_updated: 2026-06-10
applies_to: SRS algorithm, flashcard_progress, review session finalization
---

# SRS Review

> **Status: Current (data + finalization) / Target (history surfaces).** Box transition and
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
- `lib/data/repositories/study_repository_impl.dart` (canonical owner of finalization in V1:
  `finalizeStudySession` + `_terminalResult` classifier + `dueAtFor`; also `recordStudySessionAnswer`,
  WBS 4.4.1 — the in-session answer path, which records `study_attempts.box_before`/`box_after`
  and keeps `flashcard_progress` unchanged until finalization).
- `lib/domain/srs/srs_box.dart` (`SrsBox.nextBox` box transition) +
  `lib/domain/srs/box_intervals.dart` (`BoxIntervals.daysFor` interval ladder) — the SRS math owners.
- `lib/domain/usecases/study/finalize_study_session_usecase.dart` (and the sibling
  `lib/domain/usecases/study/*` files) — the study use cases.

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
- New flashcard starts at `current_box = 1` with **`due_at = NULL`** ("brand-new,
  never scheduled"). A new card is therefore **not** a due card — it is counted
  as NEW and is only eligible for New Study, never for SRS review. `due_at` is
  first set at the initial finalization (`now + interval[nextBox]`,
  local-midnight normalized). This keeps "new" and "due" cleanly separable in
  the read model (`new_count` = no progress row OR `due_at IS NULL`; `due_at`
  must be `NOT NULL AND <= now` to be due).
- Due card: `due_at IS NOT NULL AND due_at <= now`.
- **Daily new-card limit (BE V1, WBS 4.5.10):** at most `dailyNewLimit` new cards (default 20)
  enter study per local day. Daily usage is derived from persisted `study_session_items` belonging
  to new-card sessions whose `started_at` falls within the current local-day window
  (`start <= started_at < end`). Cancelled new-card sessions still consume quota in BE V1 because
  the persisted items are the source of truth. New-card eligibility queries must respect the
  remaining quota for the day; cards beyond the quota stay queued for following days. This cap only
  trims new-card eligibility and does not hide due review cards.
  Rationale: every new card is immediately eligible for New Study, so without a limit a 500-row
  import floods New Study with 500 cards at once — the primary burnout driver in SRS apps.
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
| `recovered`      | Single passing-but-imperfect attempt: fill hint-taint (WP-FI2b) or Mark-correct override (WP-FI2a) — **now emitted by the Fill FE**; redefined — no longer "forgot then passed", which now finalizes as `forgot` (decision row S20 reconciled 2026-06-22 to this redefined meaning) |
| `forgot`         | First attempt failed (V1 "Forgot"); under retry modes, a first-attempt fail stays `forgot` even after a same-session re-queue pass |
| `initial_passed` | Compatibility-only legacy storage codec value; never emitted by current modes. Reviving it requires a new product decision. |

## Box transition table

This is the authoritative transition contract for one-terminal-attempt flows. The box transition
is computed at session finalization by `StudyRepositoryImpl.finalizeStudySession` in
`lib/data/repositories/study_repository_impl.dart` (via `SrsBox.nextBox` in
`lib/domain/srs/srs_box.dart` + `BoxIntervals` in `lib/domain/srs/box_intervals.dart`, WBS
4.6.1/4.6.2/4.6.4); the in-session `RecordStudySessionAnswerUseCase` only records attempts.
Implementation must match this table (pinned by `test/data/repositories/study_srs_transition_test.dart`).

Per-card result classification at finalization (implemented in
`StudyRepositoryImpl._terminalResult`, `lib/data/repositories/study_repository_impl.dart`) for the
current one-terminal-attempt flows: the **last** attempt decides — last attempt `forgot` →
`forgot` (box → 1, lapse +1); any earlier `forgot` but last attempt passing → `recovered` (box
stays, no lapse); all attempts passing → the last attempt's result (`perfect` / compatibility-only
`initial_passed`, box +1).

Match finalization is separate: it derives a single terminal result per session item from
`study_match_evaluations`, mapping a clean correct pair to `perfect` and any wrong-before-correct
or never-correct path to `forgot`.

> **✅ Adopted decision (2026-06-10, C1 — SRS demotion reachability): first attempt decides SRS.**
> When retry/re-queue modes land, the FIRST attempt recorded for an item in the session determines
> the SRS outcome: first attempt `forgot` → final result `forgot` (box → 1, lapse +1) **even if
> the card is re-queued and passed later in the same session**. Re-queued passes are in-session
> relearning: they are recorded as attempts and satisfy session completion, but do not change the
> SRS outcome. This keeps demotion reachable, gives the learner a same-session repetition of every
> forgotten card (the relearning step), and keeps the interval table unchanged.
>
> Consequences for the implementation when the first retry mode is built (do these together):
>
> - `StudyRepositoryImpl._terminalResult` must switch from last-attempt to **first-attempt** classification
>   for the forgot path; update `test/data/repositories/study_srs_transition_test.dart` (S13
>   changes meaning) and decision rows S13/S20 in the same change.
> - `recovered` is **redefined**: it no longer means "forgot then passed" (that is now `forgot`);
>   it means a single passing-but-imperfect attempt (fill hint-taint, Mark-correct override).
>   Transition stays: box unchanged, no lapse. Update `docs/business/glossary.md` together.
> - Current V1 (one attempt per item, last-attempt classifier) produces identical user-visible
>   behavior, so no code change is required before retry modes land.

| Current box | Result           | Next box | Next due              |
|-------------|------------------|----------|-----------------------|
| n (1-7)     | `perfect`        | n + 1    | now + interval[n + 1] |
| n (1-7)     | `initial_passed` | n + 1    | Compatibility-only legacy codec path; not emitted by current modes |
| 8           | `perfect`        | 8 (stay) | now + interval[8]     |
| 8           | `initial_passed` | 8 (stay) | Compatibility-only legacy codec path; not emitted by current modes |
| n (1-8)     | `recovered`      | n (stay) | now + interval[n]     |
| n (1-8)     | `forgot`         | 1        | now + interval[1]     |

## Interval table

Intervals are defined in `BoxIntervals.daysFor`
(`lib/domain/srs/box_intervals.dart`, WBS 4.6.2). Verified: the runtime
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

1. Persist all attempts (already done during session for one-terminal flows; Match appends
   evaluations during the session and derives terminal attempts here).
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

- `lib/data/repositories/study_repository_impl.dart` (finalization: `finalizeStudySession` /
  `_terminalResult` / `dueAtFor`) and `lib/domain/srs/{srs_box,box_intervals}.dart` (transition +
  interval owners)
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
- `lib/data/repositories/study_repository_impl.dart` — finalization write path
  (`finalizeStudySession`): computes the final per-card result from persisted attempts
  (`_terminalResult`), applies the box transition (`SrsBox.nextBox`), and computes the
  local-midnight due date (`dueAtFor` via `BoxIntervals.daysFor`), all in one transaction
  (`StudySessionDao.finalizeSession`), WBS 4.6.1/4.6.2/4.6.4.
