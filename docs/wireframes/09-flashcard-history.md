---
last_updated: 2026-06-24
status: Implemented (V1 redesign-simplified, 2026-06-24, WBS 7.6.1–7.6.3)
route: /library/deck/:deckId/flashcards/:flashcardId/history
source_specs:
  - docs/business/history/card-history.md
  - docs/business/study-actions/bury-suspend.md
related_decision: docs/project-management/wbs.md (§6 Deferred / Future / Rejected register)
---

# 09 — Flashcard History

## V1 decision

> **Status (2026-06-24):** Implemented to the **kit-09 mock** (redesign-simplified). `CardHistoryScreen`
> (`lib/presentation/features/history/screens/card_history_screen.dart`) renders at
> `/library/deck/:deckId/flashcards/:flashcardId/history` as a **top-level immersive route** (outside
> the bottom-nav shell, like Study). Backed by `GetCardHistoryUseCase` →
> `CardHistoryRepository.loadCardHistory` over the v7 `card_events` + `study_attempts.duration_ms` +
> `flashcard_progress` reads. Goldens: `test/presentation/features/history/goldens/`.

The redesigned mock is authoritative. The screen renders (top → bottom): a **breadcrumb** (Root ›
…folders › Deck › History), a **header card** (tinted tile + card front + deck + `Box n` chip, over
Reviews / Retention / Avg-time), and a unified **activity feed** (`ACTIVITY` overline + a card of
rows). Each row is a graded attempt (result tile + "Reviewed · Correct/Recovered/Forgot" + relative
meta + duration) or a lifecycle event (Card created / edited / reset / audio). Lifetime stats come
from the stored counters (`(reviewCount − lapseCount)/reviewCount` = retention); avg time =
`AVG(study_attempts.duration_ms)`. The "Card created" row is **synthesized** from
`flashcards.created_at` (the feed's floor).

**Dropped vs the pre-redesign design (Rejected / out of scope, mock-authoritative):** the CURRENT
PROGRESS card (box stepper + 6-stat grid), the "All events" filter, the Edit pill, the overflow
(Reset progress / Delete), and the heatmap / box-progression graphs are **not** in the kit-09 mock
and are not built. Reset/Delete/Edit + Suspend/unsuspend (Bury/Suspend, WBS 4.11.x) and the
timeline-row→session-result tap remain deferred. The body below documents the pre-redesign TARGET,
not current code.

**Entry point (Future):** all "View history" surfaces are Future per
`docs/business/history/card-history.md` §Future surfaces (no flashcard row-action sheet exists yet);
the route is reachable by path/deep-link. Parked as Q6 in `state.md`.

## Purpose

Per-card timeline showing every study attempt. Helps user spot patterns ("always struggling with
this card") and decide on actions (suspend, reset).

## Layout

```
┌───────────────────────────────────────┐
│ ←   Card history                ⋮     │
├───────────────────────────────────────┤
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 안녕하세요                         │ │  ← Front preview (truncated)
│ │ Hello                             │ │     back as subtitle
│ │                                   │ │
│ │ Box 3 of 8 · Due in 2 days        │ │  ← Current state
│ │                                   │ │
│ │ Reviewed 50 times · Forgot 5      │ │  ← Lifetime stats
│ │ Accuracy 90%                      │ │
│ │ ⓘ Includes attempts before last   │ │  ← Shown when last_reset_at != null
│ │   reset on 2026-04-12.            │ │
│ └───────────────────────────────────┘ │
│                                       │
│ Timeline                              │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ Today 14:30                       │ │
│ │ ✓ Perfect           Box 4 → 5     │ │
│ ├───────────────────────────────────┤ │
│ │ Today 14:20                       │ │
│ │ ✗ Forgot            Box 5 → 1     │ │
│ ├───────────────────────────────────┤ │
│ │ Today 14:18                       │ │
│ │ ✗ Forgot            Box 5 → 1     │ │
│ ├═══════════════════════════════════┤ │
│ │ ─── Progress reset on 2026-04-12  │ │  ← DIVIDER ROW
│ ├═══════════════════════════════════┤ │
│ │ 2026-03-21 09:10                  │ │
│ │ ✓ Perfect           Box 5 → 5     │ │
│ ├───────────────────────────────────┤ │
│ │ 2026-03-15 09:05                  │ │
│ │ ✓ Perfect           Box 4 → 5     │ │
│ ├───────────────────────────────────┤ │
│ │ 2026-03-10 14:00                  │ │
│ │ ⚠ Recovered         Box 4 → 4     │ │
│ │     mode: recall                  │ │  ← Mode label optional
│ └───────────────────────────────────┘ │
│                                       │
│      [ Load more (12) ]               │  ← Pagination
│                                       │
└───────────────────────────────────────┘
```

## Layout — empty state

```
┌───────────────────────────────────────┐
│ ←   Card history                      │
├───────────────────────────────────────┤
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 안녕하세요                         │ │
│ │ Hello                             │ │
│ │                                   │ │
│ │ Box 1 of 8 · Due now              │ │
│ │ No reviews yet                    │ │
│ └───────────────────────────────────┘ │
│                                       │
│           📊                           │
│                                       │
│      No study history yet.            │
│                                       │
│   Start a study session on this deck  │
│   to see this card's progress here.   │
│                                       │
│   [ Start study ]                     │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param                               | Source | Notes                      |
|-------------------------------------|--------|----------------------------|
| `deckId` (required path param)      | URL    | parent deck                |
| `flashcardId` (required path param) | URL    | card whose history to show |

## Data to load

| Data                                                                | Source                                          | Refresh trigger    |
|---------------------------------------------------------------------|-------------------------------------------------|--------------------|
| Card preview (front, back) + breadcrumb (deck + folders)            | `flashcards` + `decks`/`folders`                | once               |
| Current SRS state (box, due_at, is_suspended)                       | `flashcard_progress` lookup                     | once               |
| Lifetime stats (review_count, lapse_count, recall rate, last_reset_at, correct streak, created_at) | `flashcard_progress` counters + `study_attempts` (streak) + `flashcards.created_at` | once |
| Activity feed (attempts + lifecycle events, full load DESC)         | `study_attempts` + `card_events` WHERE flashcard_id = :id | once (invalidated on reset) |

## Forbidden

- ❌ Compute lifetime accuracy/recall by scanning all attempts. Use stored counters.
- ❌ Allow inline edit of attempts/events. Read-only.
- ❌ Render the box transition or "Box 0" for pre-migration rows (box=0); show "Logged with missing
  details" instead.
- ❌ Reset progress without appending a `card_events` `reset` row and updating `last_reset_at = now`.

## Components

| Component        | Spec                                                                                                                            |
|------------------|-------------------------------------------------------------------------------------------------------------------------------|
| App bar          | Back, title "Card history", **Edit** pill (→ flashcard editor), overflow ⋮ (Reset progress / Delete; Suspend deferred).        |
| Breadcrumb       | `Library › {folders…} › {deck} › History`. Library/folder/deck segments tappable; History is the current (non-tap) segment.   |
| Header card      | Front preview, back subtitle, current-box chip (`Box {n} / 8`). Reset sub-label visible only when `last_reset_at != null`.     |
| Progress card    | "CURRENT PROGRESS": Leitner box stepper (8 segments, current highlighted) + 2×3 stat grid — Due, Reviews, Recall rate, Lapses, Correct streak, Since added. |
| Timeline header  | "TIMELINE · {N} EVENTS" (N = visible events) + an "All events" filter pill (All / Reviews only / Card changes).               |
| Timeline         | Unified activity feed on a left rail with a node per event, newest first; loads fully and ends with a "Beginning of history" marker. Rows are read-only (row→result nav deferred). |
| Attempt row      | Status chip (CORRECT/RECOVERED/FORGOT) + relative/absolute time + description + `B{before} → B{after}` (arrow flips when box drops) · mode · duration ("1.4s" or "duration not logged"). |
| Lifecycle row    | `card_events` row: Created (mastery) / Edited / Reset / Audio added (reserved). Chip + description, no meta.                   |
| Beginning marker | Terminal "Beginning of history" row closing the feed.                                                                          |
| Empty state      | When the card has zero events, a framed card with "No reviews yet" + "Study this card now" CTA.                               |

**Stat sourcing (Progress card):** Due ← `flashcard_progress.due_at`/`is_suspended`; Reviews ← `review_count`;
Recall rate ← `(review_count − lapse_count) / review_count`; Lapses ← `lapse_count`; Correct streak ←
leading non-`forgot` run over `study_attempts` (newest first); Since added ← `flashcards.created_at`.

## Timeline row shape

```
{relative or absolute date/time}
{result icon} {result label}      Box {before} → {after}
[mode: {mode}]   optional, smaller text
```

Result label mapping:

| `result`         | Icon     | Label     |
|------------------|----------|-----------|
| `perfect`        | ✓ green  | Perfect   |
| `initial_passed` | ✓ green  | Passed    |
| `recovered`      | ⚠ yellow | Recovered |
| `forgot`         | ✗ red    | Forgot    |

When `box_before = 0` or `box_after = 0` (pre-migration data), the transition is omitted and the
description reads "Logged with missing details" (the kit's **Partial** state).

## States

Maps the five kit states (`shots/INDEX.md`: Loaded, Empty, Loading, Error, Partial), light + dark:

| Kit state | Trigger              | Behavior                                                                       |
|-----------|----------------------|-------------------------------------------------------------------------------|
| Loaded    | Card has events      | Breadcrumb + header + progress card + activity feed + "Beginning of history". |
| Empty     | Card has zero events | Framed "No reviews yet" card + "Study this card now" CTA.                      |
| Loading   | Initial fetch        | Header skeleton + timeline skeleton rows (`MxLoadingState`).                   |
| Error     | Query failure        | Cloud-off error card + Retry (header stays when its query succeeded).          |
| Partial   | Attempt missing data | Row with no box transition + "Logged with missing details" + "duration not logged". |
| Card not found | Card deleted    | "Card no longer exists" error state, no retry.                                 |

## Actions

| Action                    | Trigger | Result                                                                 |
|---------------------------|---------|------------------------------------------------------------------------|
| Tap back                  | Back    | Pop.                                                                   |
| Tap overflow ⋮            | Tap     | Menu: Edit card / Reset progress / Delete (Suspend deferred).          |
| Tap "Start study" (empty) | Tap     | Navigate to deck study entry gate.                                     |
| Tap timeline row          | Tap     | Open session result screen if session is `completed`. No-op otherwise. |
| Tap Load more             | Tap     | Fetch next page.                                                       |

## Dialogs and bottom-sheets used

- Reset progress dialog — `docs/wireframes/24-shared-dialogs.md` §reset-progress.
- Delete card dialog — `docs/wireframes/24-shared-dialogs.md` §delete-confirm.

## Navigation in

- "View history" action in flashcard edit screen.
- "View history of this card" overlay action in study session.
- Long-press card → context sheet → "View history" (if available).

## Navigation out

- Back → flashcard edit or list (depending on source).
- "Start study" empty CTA → study entry gate.
- Timeline row tap → session result.
- Overflow actions → confirm dialogs then back.

## Responsive

- ≥600dp: header card and timeline side-by-side; timeline scrollable in right column.

## Performance

- Initial query: paginated 50 rows.
- Lifetime stats: pre-aggregated from `flashcard_progress.review_count` / `lapse_count`.
- Divider position determined client-side via single `last_reset_at` field comparison.

## Accessibility

- Each timeline row labeled "{date}, {result}, box {before} to {after}".
- Divider row labeled "Section divider: progress reset on {date}" with role=separator.
- Empty state CTA focusable.

## Rules

- Timeline is read-only.
- Divider only renders when `last_reset_at` is non-null AND there are attempts both above (newer)
  and below (older) the reset point.
- If reset happened but no attempts existed before reset, no divider needed (timeline starts
  post-reset).
- `box_before` / `box_after` from `study_attempts`. If 0, render `—`.

## Agent rule

- V1: Implemented. Keep this wireframe in sync with `lib/presentation/features/history/**`.
- V1 overflow = Edit / Reset progress / Delete. Suspend/unsuspend stays deferred to Bury/Suspend.
- Timeline row tap is a no-op in V1 (session-result navigation deferred).
- Do NOT recalculate accuracy on every render; use stored counters.
- Do NOT add inline edit of attempts. Read-only.
- Reset progress from this screen MUST update `last_reset_at = now` AND refresh the timeline so
  divider appears.
- "Load more" pagination uses cursor based on `attempted_at DESC`; do NOT use offset (perf reason).

## Implementation refs

**Business specs:**

- `docs/business/history/card-history.md`
- `docs/business/srs/srs-review.md` (box transitions)

**Decision rows:**

- H1-H8 (history rendering, divider, pre-migration row handling, header sub-label)

**Schema / storage:**

- READ `study_attempts` (box_before, box_after, result, attempted_at) paginated DESC
- READ `flashcard_progress.last_reset_at`, lifetime counters
- Cursor-based pagination on `attempted_at DESC`

**Contracts:** `docs/contracts/usecase-contracts/history.md`,
`docs/contracts/repository-contracts/progress-repository.md`

**Code paths:**

- `lib/presentation/features/history/screens/card_history_screen.dart`
- `lib/presentation/features/history/viewmodels/card_history_viewmodel.dart`
- `lib/presentation/features/history/widgets/card_history_body.dart`
- `lib/presentation/features/history/widgets/card_history_header_card.dart`
- `lib/presentation/features/history/widgets/card_history_progress_card.dart`
- `lib/presentation/features/history/widgets/card_history_event_card.dart`
- `lib/presentation/features/history/widgets/card_history_timeline_row.dart`
- `lib/presentation/features/history/widgets/card_history_lifecycle_row.dart`
- `lib/presentation/features/history/widgets/card_history_beginning_row.dart`
- `lib/presentation/features/history/widgets/card_history_filter_pill.dart`
- `lib/presentation/features/history/widgets/card_history_overflow_sheet.dart`
- `lib/data/datasources/local/drift/card_events.drift`
- `lib/domain/usecases/history/get_card_history_header_usecase.dart`
- `lib/domain/usecases/history/get_card_timeline_usecase.dart`
- `lib/domain/usecases/history/reset_flashcard_progress_usecase.dart`
- `lib/app/router/route_names.dart` → `RouteNames.flashcardHistory`

**Related wireframes:**

- `docs/wireframes/08-flashcard-edit.md` (entry point), `docs/wireframes/18-study-result.md` (
  timeline row tap target if completed)
