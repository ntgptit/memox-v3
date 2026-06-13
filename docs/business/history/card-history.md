---
last_updated: 2026-06-13
applies_to: per-card study history view, attempt timeline
status: Implemented (promoted 2026-06-13; `last_reset_at` shipped v6)
related_decision: docs/project-management/wbs.md (§6 Deferred / Future / Rejected register)
---

# Card History

> **Status: Implemented (V1, promoted 2026-06-13).** Per-card history is live: route
> `/library/deck/:deckId/flashcards/:flashcardId/history`, entered from the flashcard row-action
> sheet ("View history"). `flashcard_progress.last_reset_at` shipped with schema v6; the timeline,
> lifetime stats, and the activity feed (attempts + created/edited/reset events) are all implemented.
>
> **Data dependencies:** `study_attempts.box_before` / `box_after` (v4) and
> `flashcard_progress.last_reset_at` (v6) all exist and are populated. Suspend/unsuspend from the
> overflow remains deferred with the Bury/Suspend feature (WBS 4.11.x); the V1 overflow exposes
> Edit / Reset progress / Delete only.

## V1 decision

Card History is **Implemented** for V1. The screen renders (top → bottom): a breadcrumb, a header
card (front/back + `Box n/8` chip + reset sub-label), a **CURRENT PROGRESS** card (Leitner box
stepper + a 6-stat grid: Due, Reviews, Recall rate, Lapses, Correct streak, Since added), and a
unified **activity feed** on a left rail terminating in a "Beginning of history" marker. The feed
merges study attempts with card lifecycle events (created / edited / reset), newest first, with an
"All events" filter (All / Reviews only / Card changes). The app bar exposes an **Edit** pill; the
overflow exposes Reset progress / Delete.

- Per-attempt **duration** (`study_attempts.duration_ms`, v7) is measured by the study review
  viewmodel and shown per row; rows without a measured duration show "duration not logged".
- **Reset** appears as a lifecycle event in the feed (not a divider); the header keeps the
  "Includes attempts before last reset" sub-label.
- **Suspend/unsuspend** is deferred to the Bury/Suspend feature; timeline row tap → session result
  is deferred (rows are read-only).
- **Audio added** is a defined lifecycle kind but not emitted yet — there is no audio-capture
  feature; it will appear once audio recording ships.

## Purpose

When a user repeatedly forgets a card, they need to see the pattern: "Have I always struggled with
this?" or "When did I last get it right?". Today, `study_attempts` stores every answer but there is
no UI surface to inspect it. This doc specs the per-card history view.

## Data source

The activity feed merges two sources (see `docs/database/schema-contract.md`):

- `study_attempts` — graded attempts (incl. `box_before`/`box_after`, `duration_ms`).
- `card_events` (v7) — lifecycle events (`created` / `edited` / `reset` / `audio_added`).

Both are loaded fully per card (per-card scale is small — no offset pagination), mapped to a
`CardHistoryEvent` union, and merged by `occurred_at` DESC (tiebreak id DESC) in Dart:

```sql
-- attempts
SELECT a.id, a.result, a.study_mode, a.box_before, a.box_after, a.duration_ms,
       a.attempted_at, i.session_id, s.status
FROM study_attempts a
INNER JOIN study_session_items i ON a.session_item_id = i.id
INNER JOIN study_sessions s ON s.id = i.session_id
WHERE i.flashcard_id = :flashcardId
ORDER BY a.attempted_at DESC, a.id DESC;

-- lifecycle events
SELECT e.id, e.type, e.occurred_at, e.detail
FROM card_events e
WHERE e.flashcard_id = :flashcardId
ORDER BY e.occurred_at DESC, e.id DESC;
```

## Future surfaces

These are proposal entry points only. V1 must keep these triggers hidden or
disabled until Card History is promoted and the required migration is approved.

| Surface                         | Trigger                                                                                 |
|---------------------------------|-----------------------------------------------------------------------------------------|
| Card detail or flashcard editor | Future "View history" action                                                            |
| Suspended/buried card list      | Future "View history" action                                                            |
| Search result (flashcard)       | Future long-press → "View history"                                                      |
| Study session (current card)    | Future action menu → "View history of this card" (opens overlay, does not exit session) |

## Card history screen

Route: suggested `/library/deck/:deckId/flashcards/:flashcardId/history` (verify in router; update
`docs/business/navigation/navigation-flow.md` when wiring).

### Header section

| Element           | Source                                                                        |
|-------------------|-------------------------------------------------------------------------------|
| Front preview     | `flashcards.front` (truncated)                                                |
| Current SRS state | "Box {n} of 8 • Due {relativeTime}" or "Suspended" or "Buried until tomorrow" |
| Lifetime stats    | "Reviewed {reviewCount} times • Forgotten {lapseCount} times • Accuracy {x}%" |

Accuracy = `(reviewCount - lapseCount) / reviewCount` when `reviewCount > 0`, else "—".

### Timeline section (activity feed)

Chronological list (newest first), terminating in a "Beginning of history" marker. Two row types:

**Attempt row:**

| Column         | Source                                                                                    |
|----------------|-------------------------------------------------------------------------------------------|
| Date/time      | `attempted_at` — relative ("2h ago") + absolute ("May 26, 14:32")                         |
| Status chip    | category from `result`: CORRECT (perfect/initial_passed), RECOVERED, FORGOT               |
| Description    | "Answered correctly" / "Got it back after a slip" / "Couldn’t recall — reset to box 1"; "Logged with missing details" for pre-migration rows |
| Box transition | `B{box_before} → B{box_after}` (arrow flips left when the box decreased); omitted when either is 0 |
| Mode           | `study_mode` (review/match/guess/recall/fill)                                              |
| Duration       | `duration_ms` as "1.4s"; "duration not logged" when null                                  |

**Lifecycle row** (`card_events`): chip + description — Created ("Card added to {deck}", mastery
accent), Edited ("Card edited"), Reset ("Progress reset to box 1"), Audio added (reserved).

No pagination: the feed loads fully (per-card scale) and ends with "Beginning of history".
The "All events" filter narrows the feed to All / Reviews only / Card changes.

### Visualizations (optional, lightweight)

Below the timeline, a small section:

- Heatmap: last 90 days, dots colored by accuracy that day. Skipped days greyed out.
- Box progression graph: line chart of `box_after` over time.

If implementing graphs increases scope significantly, defer to a later iteration. Timeline alone is
the minimum value.

## Actions from history view

| Action              | Behavior                                                                        |
|---------------------|---------------------------------------------------------------------------------|
| Edit card           | Opens flashcard edit screen                                                     |
| Suspend / unsuspend | Deferred to Bury/Suspend (`docs/business/study-actions/bury-suspend.md`); not in the V1 overflow |
| Reset progress      | Confirmation → reset SRS scheduling (box=1, due=now, unburied) + `last_reset_at=now`. Lifetime counters and attempts are retained (cumulative). |
| Delete card         | Confirmation → delete cascade                                                   |

"Reset progress" is potentially useful when a card was placed in a wrong box (e.g., user
accidentally answered correctly while distracted, then card moved to high box). Confirmation must
clarify "Attempts history is kept; only SRS state is reset."

## Rules

- History MUST be read-only with respect to `study_attempts`. No edit/delete of attempt rows.
- Box transitions in the timeline come from `study_attempts.box_before` and
  `study_attempts.box_after` — both columns required. See `docs/database/schema-contract.md` for the
  migration.
- Lifetime stats come from `flashcard_progress` (current view) plus `study_attempts` (historical),
  not recomputed across all attempts every load.
- Reset progress MUST NOT delete attempts.
- Reset progress inserts a `card_events` row of type `reset` (it appears as a lifecycle event in the
  feed) and stamps `flashcard_progress.last_reset_at = now`.
- History view is account-scoped (current active account database only).
- A card with zero events shows the "No reviews yet" empty state and links to "Study this card now".

## Progress reset event

When the user resets a card's SRS progress, a `card_events` row of type `reset` is appended to the
timeline (rendered as a lifecycle event, "Progress reset to box 1") and `last_reset_at` is stamped.
Earlier designs used a synthetic divider row; the activity feed supersedes that — reset is a
first-class event. `last_reset_at` still drives the header sub-label ("Includes attempts before last
reset on {date}").

### Lifetime stats clarification

Lifetime stats remain cumulative across resets (preserve "total times reviewed" sense). Header copy
must clarify this so the user understands why box=1 can coexist with reviewCount=50:

- "Reviewed 50 times • Forgotten 5 times • Accuracy 90%"
- Sub-label (small text): "Includes attempts before last reset on {date}." (shown only when
  `last_reset_at` is not null)

## Edge cases

| Case                                                            | Behavior                                                                                                              |
|-----------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| Card has many events                                            | Per-card scale is small; the feed loads fully (no pagination) and ends with "Beginning of history" |
| Card was deleted then recreated                                 | Different `flashcard.id`; history is per-id, so this is a fresh card                                                  |
| Card moved via deck change                                      | Attempts retained; history persists across deck changes (per-card not per-deck)                                       |
| Session was `cancelled` mid-card                                | Attempts within that session still appear                                                                             |
| Card reset multiple times                                       | Each reset is its own `card_events` row in the feed; `last_reset_at` keeps the most recent for the header sub-label   |
| Reset progress then immediately study                           | Header shows `box=1, due=now`; lifetime stats stay cumulative; the reset event sits below the new attempts            |
| Reset on a card with zero attempts                              | A `reset` event still appears in the feed; the header sub-label shows once `last_reset_at` is set                     |
| Stats lookup when `last_reset_at != null`                       | Header sub-label visible: "Includes attempts before last reset on {date}."                                            |

## Performance

- Timeline query: indexed on `study_session_items(flashcard_id)` and
  `study_attempts(session_item_id)`. Add compound index if necessary.
- Lifetime stats: single aggregate query.
- Heatmap data: 90-day aggregate, single query grouped by date.

## Required UI states

- Loading.
- Empty (no attempts).
- Error.
- Normal (with timeline).
- Card deleted while viewing → error state + back navigation.

## Agent rule

- Card History is Implemented (V1). Keep this doc in sync with
  `lib/presentation/features/history/**`, `lib/domain/usecases/history/**`,
  `lib/data/repositories/card_history_repository_impl.dart`, and the wireframe on any change.
- Do NOT delete from `study_attempts` for any reason except cascade from session/item deletion.
- "Reset progress" updates `flashcard_progress` (box=1/due=now/`last_reset_at`) and appends a
  `card_events` `reset` row. It does not touch `study_attempts`.
- `study_attempts.box_before` and `box_after` are populated on every new attempt insert; pre-migration
  rows (0) render "Logged with missing details".
- `study_attempts.duration_ms` is populated when measured; null rows render "duration not logged".
- `card_events` is append-only. `created`/`edited` are logged in the flashcard create/update
  transactions; `reset` on progress reset; `audio_added` is reserved (no emitter yet).
- History is per-card. The feed merges attempts + lifecycle events; do not add a separate
  "session history" surface.

## Related

**Wireframes:**

- `docs/wireframes/09-flashcard-history.md` — full activity-feed screen + lifetime stats
- `docs/wireframes/08-flashcard-edit.md` — V1 editor explicitly does not expose a live "View
  history" action
- `docs/wireframes/24-shared-dialogs.md` §reset-progress (single + bulk variants)

**Schema:**

- `docs/database/schema-contract.md` → `study_attempts` with NEW columns `box_before` and
  `box_after` (both in 6 pending migrations)
- `flashcard_progress.last_reset_at INTEGER NULL` (in 6 pending migrations)
- Recommended index: `study_attempts(box_after)` (after profiling)

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows H1-H8 (feed rendering, reset event,
  pre-migration row handling)

**Glossary terms:**

- `docs/business/glossary.md` → "card history", "progress reset", "reset divider", `last_reset_at`,
  `box_before`, `box_after`

**Related business specs:**

- `docs/business/srs/srs-review.md` — attempt insert MUST populate box_before/box_after
- `docs/business/study/study-flow.md` — attempts written during study session
- `docs/business/flashcard/flashcard-management.md` — reset progress action
- `docs/business/bulk/bulk-operations.md` — bulk reset progress sets last_reset_at per card

**Source files to inspect:**

- `lib/domain/models/card_history.dart`
- `lib/domain/repositories/card_history_repository.dart`
- `lib/domain/usecases/history/get_card_history_header_usecase.dart`
- `lib/domain/usecases/history/get_card_history_page_usecase.dart`
- `lib/domain/usecases/history/reset_flashcard_progress_usecase.dart`
- `lib/data/datasources/local/drift/history_queries.drift`
- `lib/data/datasources/local/daos/card_history_dao.dart`
- `lib/data/repositories/card_history_repository_impl.dart`
- `lib/app/di/card_history_providers.dart`
- `lib/presentation/features/history/**`
