---
last_updated: 2026-06-10
applies_to: bury (skip card today), suspend (hide card indefinitely)
---

# Bury and Suspend

> **Status: Partial — schema + queue exclusion Current; in-session BE Implemented; flashcard-list
> / bulk / undo surfaces Specified (verified 2026-06-10).**
>
> **Current:** the schema fields `flashcard_progress.buried_until INTEGER NULL` and
> `flashcard_progress.is_suspended BOOL NOT NULL DEFAULT 0` exist
> (`lib/data/datasources/local/drift/flashcard_progress.drift`); study scope queries and due
> counting exclude suspended and currently-buried cards and an expired bury re-enters
> (`lib/data/datasources/local/drift/study_scope_queries.drift`); the empty-scope variants
> `studyEmpty_allBuried` / `studyEmpty_allSuspended` render on the Study Entry gate.
>
> **Implemented (BE V1):** in-session bury/suspend use cases remove the current
> `study_session_items` row from the active session queue, do not create a
> `study_attempts` row, preserve SRS fields (`current_box`, `due_at`, `review_count`,
> `lapse_count`), and touch `study_sessions.updated_at`.
>
> **Specified (NOT implemented):** flashcard-list state badges + status filter chips; bulk
> suspend/unsuspend; unsuspend from the flashcard list; undo toast/reinsert behavior. WBS rows
> 4.11.3 and 2.17.x track the remaining surfaces (`docs/project-management/wbs.md`).

## Purpose

When a user encounters a card mid-session that they don't want to study right now, the only options
today are `forgot` (which resets to box 1, lying to the SRS algorithm) or quit the session. Both
punish the user for normal human behavior. This document specs two escape hatches:

- **Bury**: hide this card for the rest of today. It returns tomorrow as part of normal due/new
  flow.
- **Suspend**: hide this card indefinitely until the user explicitly unsuspends it.

## Data model

Two fields on `flashcard_progress` (already present in the current schema):

| Field          | Type         | Default | Meaning                                                                         |
|----------------|--------------|---------|---------------------------------------------------------------------------------|
| `buried_until` | INTEGER NULL | NULL    | UTC epoch ms; card is hidden from study queues while `buried_until > now`.      |
| `is_suspended` | BOOL         | `false` | When true, card is hidden from all study queues regardless of due/buried state. |

No migration is pending: both columns and the eligibility index
(`idx_flashcard_progress_eligibility` covering `is_suspended`, `buried_until`, `due_at`) are in
the current schema (`lib/data/datasources/local/drift/flashcard_progress.drift`).

## Bury

### Behavior

When user buries a card during a study session:

1. Set `flashcard_progress.buried_until = midnight + 1 second` in user's local timezone. (Card
   becomes available the next calendar day.)
2. Skip this card in the current session: remove from remaining items queue OR mark item with skip
   flag.
3. Continue session with next item.
4. NO attempt recorded for this bury. SRS state (box, counters) unchanged.

### Where bury appears in UI

| Surface                               | Trigger                                                           |
|---------------------------------------|-------------------------------------------------------------------|
| Study session screen                  | Action menu (e.g., overflow icon on card) → "Bury until tomorrow" |
| Long-press on card during review mode | Optional shortcut                                                 |

Confirmation NOT required (bury is reversible and low-impact). Show inline toast "Buried until
tomorrow" with "Undo" action for 5 seconds.

### Auto-unbury

A card becomes available again when `now >= buried_until`. No background task needed; queries simply
filter.

Due query update:

```sql
WHERE due_at <= now
  AND is_suspended = 0
  AND (buried_until IS NULL OR buried_until <= now)
```

## Suspend

### Behavior

When user suspends a card:

1. Set `flashcard_progress.is_suspended = true`.
2. Card disappears from all study queues immediately (today's due, deck/folder study, today's
   review).
3. SRS state preserved (box, due_at, counters unchanged) so unsuspending resumes from where it was.
4. Card still appears in flashcard list (with suspended badge) and in card history.

### Where suspend appears in UI

| Surface                                                     | Trigger                      |
|-------------------------------------------------------------|------------------------------|
| Study session screen                                        | Action menu → "Suspend card" |
| Flashcard list (long-press / item menu)                     | "Suspend" action             |
| Card history view (`docs/business/history/card-history.md`) | "Suspend" action             |

Confirmation NOT required, but the toast must show "Suspended" with "Undo" for 5 seconds since the
action is impactful.

### Unsuspend

| Surface                                                                      | Trigger                            |
|------------------------------------------------------------------------------|------------------------------------|
| Flashcard list, filtered to "Suspended"                                      | Tap item → "Unsuspend"             |
| Suspended cards screen (`/library/deck/:deckId/flashcards?filter=suspended`) | Bulk select → "Unsuspend selected" |
| Single card detail                                                           | "Unsuspend"                        |

On unsuspend:

- `is_suspended = false`.
- Card re-enters due flow normally based on existing `due_at`.
- If `due_at` is in the past (because card was suspended past its due time), it shows as due
  immediately.

## Visibility rules

### Where buried/suspended cards are hidden

- All study queues (deck study, folder study, today's review).
- Due count badges on Dashboard, folder/deck cards.
- "Next due" calculations on empty states.

### Where they remain visible

- Flashcard list (with badge: "Buried until tomorrow" / "Suspended").
- Card history view.
- Tag-filtered views.
- Search results.
- Export (already independent of due state).

## Filters in flashcard list

Add filter chips to flashcard list:

| Filter    | Behavior                                           |
|-----------|----------------------------------------------------|
| All       | Default; shows all cards regardless of state       |
| Active    | Hides suspended and currently-buried               |
| Suspended | Only suspended                                     |
| Buried    | Only currently-buried (where `buried_until > now`) |
| Due       | Only currently due (and active)                    |

Filters multiplex with tag filter (see `docs/business/tags/tag-system.md`). Default: All.

## Bulk operations

Both bury and suspend support bulk operations from flashcard list multi-select (see
`docs/business/bulk/bulk-operations.md`):

- Bulk suspend.
- Bulk unsuspend.
- Bulk bury (rarely useful; available for completeness).
- Bulk unbury (same).

## Rules

- Bury and suspend MUST NOT record a `study_attempts` row. They are scheduling actions, not answers.
- Bury and suspend MUST NOT alter `current_box`, `review_count`, `lapse_count`, or `due_at`.
- The due query MUST exclude buried and suspended cards (added filter clause).
- Bury duration is always "until tomorrow's local midnight". No user-configurable bury duration. (
  Anki has flexible bury; we keep it simple.)
- Unsuspending a card whose `due_at` is in the past makes it immediately due. Do not auto-bump
  `due_at` forward.
- Buried/suspended cards still count toward total card counts in deck/folder labels (e.g., "Deck has
  50 cards" includes them). Only DUE counts exclude them.

## Edge cases

| Case                                                                       | Behavior                                                                                                                                          |
|----------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Card buried during session, session continues, midnight passes mid-session | Card remains hidden from current session (already removed from queue). New session next day sees it as available.                                 |
| All due cards in a deck are buried                                         | Show empty state "You buried all due cards. They'll return tomorrow." (already covered in `docs/business/study/study-flow.md` empty scope matrix) |
| All cards in a deck suspended                                              | Deck shows "0 cards available" badge but total count still shown. Study refuses with appropriate empty state.                                     |
| Bury then immediately unbury (via toast undo)                              | Clear `buried_until` back to NULL. Re-insert card into current session queue at next position.                                                    |
| Suspend then unsuspend (via toast undo)                                    | Clear `is_suspended = false`. Card remains in current session queue if it was active there; no special action.                                    |
| Card buried, then user deletes the card                                    | Deletion cascades normally; `buried_until` is irrelevant.                                                                                         |
| Card suspended, then deck is deleted                                       | Cascade delete via existing rules.                                                                                                                |
| Bury card during folder study (recursive scope)                            | Bury affects only that card globally. Other decks in folder unaffected.                                                                           |
| Time zone changes while a card is buried                                   | `buried_until` is a fixed UTC instant computed from the local midnight **at bury time**. After a timezone change the card returns at that same instant, which may no longer align with the new local midnight. Accepted: do not recompute on timezone change. |

## Required UI states

| Surface                        | States                                           |
|--------------------------------|--------------------------------------------------|
| Bury action button             | Always available during session for current card |
| Suspend action button          | Always available during session for current card |
| Bury/suspend toast             | Visible 5s with undo; undo reverts               |
| Flashcard list filter chip     | Visible always; reflects current filter          |
| Suspended/buried badge on card | Visible when card has state                      |
| Bulk select bar                | Includes bury/suspend/unbury/unsuspend actions   |

## Performance

- Due query: existing index on `due_at` plus added filter on `is_suspended` and `buried_until`.
  Expect minor cost. Profile after migration.
- Flashcard list with filter: stream-based via Drift `watch*` query with filter clause.
- Bulk operations: single transaction for all rows.

## Agent rule

- Do NOT implement bury/suspend by deleting `flashcard_progress` rows. State must be preserved for
  unsuspend.
- Do NOT add user-configurable bury durations. Keep it "until tomorrow" only.
- Do NOT introduce a "bury for N days" variant without updating this doc.
- Undo UI remains deferred to WBS 4.11.3; when it lands, it must revert the state.
- Due query MUST be updated in ALL places (deck study, folder study, today, due count badges) —
  search the codebase for `due_at <= now` and update each.

## Related

**Wireframes:**

- `docs/wireframes/06-flashcard-list.md` — state badges (Suspended > Buried > Due > Active)
- `docs/wireframes/08-flashcard-edit.md` — Suspend/Unsuspend toggle action
- `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md` —
  overflow ⋮ Bury / Suspend actions
- `docs/wireframes/25-shared-bottom-sheets.md` §undo-toast (5s undo)

**Schema:**

- `docs/database/schema-contract.md` → `flashcard_progress.buried_until INTEGER NULL`,
  `flashcard_progress.is_suspended BOOL` (both shipped in the current schema)
- Index: `idx_flashcard_progress_eligibility` on
  `flashcard_progress(is_suspended, buried_until, due_at)` (shipped)

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Bury" and "Suspend"

**Glossary terms:**

- `docs/business/glossary.md` → `buried_until`, `is_suspended`, "bury until tomorrow", "suspend
  indefinitely"

**Related business specs:**

- `docs/business/srs/srs-review.md` — bury/suspend do NOT change current_box or due_at
- `docs/business/study/study-flow.md` — empty-scope matrix includes `studyEmpty_allBuried` and
  `studyEmpty_allSuspended`
- `docs/business/bulk/bulk-operations.md` — bulk suspend/unsuspend in selection mode
- `docs/business/flashcard/flashcard-management.md` — state badge priority on card row

**Source files to inspect (verified 2026-06-10):**

- `lib/data/datasources/local/drift/flashcard_progress.drift` — `buried_until` / `is_suspended`
  columns + eligibility index
- `lib/data/datasources/local/drift/study_scope_queries.drift` — queue queries filter
  buried+suspended
- `lib/data/repositories/study_repo_impl_study_session.dart` — `isVisible` eligibility +
  all-buried/all-suspended empty-state resolution
- In-session bury/suspend use cases live under `lib/domain/study/usecases/study_usecases.dart`
  and are implemented by `lib/data/repositories/study_repo_impl.dart`.
