---
last_updated: 2026-06-19
source: split from memox-core-decision-table.md
applies_to: Progress Overview, Card history, and Daily engagement behavior branches
---

# MemoX Decision Table — Progress + History + Engagement

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: P1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

## Progress Overview

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| P1 | Open progress route | Direct `/progress` route | Render `ProgressScreen` inside the shell; do not open Study Session, History, Search, Settings, or sync surfaces | C0+C1 | TBD |
| P2 | Load overview | Provider pending on initial open | Show skeleton section cards with the range tabs still visible; do not show stale or fake summary content | C0 | TBD |
| P3 | Load overview | Provider fails before data exists | Show shared retryable error state without raw exception text; Retry reloads and recovers | C1 | TBD |
| P4 | Display overview | Every section's data slice is empty | Each section shows its own hint box; no shared empty state, no invented analytics history | C0+C1 | TBD |
| P5 | Display overview | Week range with study data | Render cards-studied total + bar chart, accuracy + delta + sparkline, box distribution, streak, card states, footer | C0+C1 | TBD |
| P6 | Switch range tab | Tap Month (or All time) | Reload the overview for the selected range and update range-dependent captions/footer | C1 | TBD |
| P7 | Display overview | All-time range selected | Show whole-history totals; hide the bar chart, previous-range delta, and sparkline (no day buckets) | C1 | TBD |
| P8 | Load due summary | Progress data present or empty | Return zero-safe global due counts plus deterministic per-deck rows; exclude suspended, buried, and future-due cards | C1 | `test/data/repositories/progress_repository_impl_test.dart` |
| P9 | Load box distribution | Invalid or valid box rows | Fail fast on invalid `box_number`; otherwise return boxes 1..8 with deterministic zero-fill | C1 | `test/data/repositories/progress_repository_impl_test.dart` |
| P10 | Load study statistics | Sessions and attempts present or empty | Count completed sessions, all attempts, correct/forgot outcomes, and last studied timestamp without mutation | C1 | TBD |
| P11 | Load combined progress read model | Progress screen backend requested | Compose due summary, box distribution, and study statistics in one call; empty DB returns safe zero values | C1 | TBD |
| P12 | Display overview | Fewer than 3 distinct study days in a week/month range | Replace the bar chart with an insufficient-data hint plus a "trend appears after 3 days" banner; accuracy still renders from existing attempts | C1 | TBD |
| P13 | Display overview | Some sections have data, others are empty | Populated sections render fully; each empty section shows its own hint box independently | C1 | TBD |
| P14 | Load activity | Attempts across current range, previous range, and older history | Bucket attempts per local day inside the range; sum the previous range separately; ignore older attempts | C1 | TBD |
| P15 | Load activity | All-time range requested | Return whole-history totals with no day buckets and no previous-range comparison | C1 | TBD |
| P16 | Compute streak | Consecutive study days exist; today has no attempt yet | Current streak counts back from yesterday (an unfinished today does not break it); longest streak scans whole history | C1 | TBD |
| P17 | Load card states | Suspended, currently-buried, and bury-expired cards exist | Count suspended cards and `buried_until > now` cards only; expired burials are excluded | C1 | TBD |
| P18 | Load overview | Empty database, any range | Return zero-safe overview (zero totals, zero streak, zero card states, full zero-filled day buckets for week/month) | C1 | TBD |
| P19 | Dashboard progress summary | Same persisted dataset as Progress read model | Due count matches Progress due summary; attempt counts come from `study_attempts`; empty DB returns zero-safe dashboard summary | C1 | TBD |

## Card History

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| H1 | Open history | Card with events | Show activity feed (attempts + lifecycle) newest-first | C0+C1 | TBD |
| H2 | Open history | Card with zero events | Show empty state with "Study this card now" CTA | C1 | TBD |
| H3 | Reset progress | From history screen overflow | Reset SRS (box=1, due=now), set `last_reset_at=now`, append a `card_events` reset row, retain attempts + cumulative counters | C0+C1 | TBD |
| H4 | Lifetime stats | Recall-rate calculation | (reviewCount - lapseCount) / reviewCount from stored counters | C0 | TBD |
| H5 | Timeline | Card progress reset | Reset appears as a lifecycle event in the feed | C0+C1 | TBD |
| H6 | Timeline | `box_before=0` (pre-migration row) | Omit the box transition; show "Logged with missing details" + "duration not logged" | C1 | TBD |
| H7 | Header sub-label | `last_reset_at != null` | Show "Includes attempts before last reset on {date}." | C1 | TBD |
| H8 | New attempt insert | Any | `box_before`, `box_after`, `duration_ms` recorded | C0+C1 | TBD |
| H9 | Timeline | Lifecycle event (created/edited/reset) | Render a lifecycle row with its chip + description | C1 | TBD |

## Daily Engagement

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| EN1 | Daily progress | Attempt recorded today | Increment progress, computed from `study_attempts` aggregate | C0+C1 | TBD |
| EN2 | Daily progress | Goal disabled | Hide progress on Dashboard | C1 | TBD |
| EN3 | Streak | Goal met today, yesterday was goal-met | `currentStreak++` | C0+C1 | TBD |
| EN4 | Streak | Yesterday was NOT goal-met | Streak broken, reset to 0 + show notice once | C0+C1 | TBD |
| EN5 | Streak | Goal changed mid-day from 20 to 10, progress=12 | Already met; streak advances if not yet | C1 | TBD |
| EN6 | Reminder fires | Goal met today | Suppress notification | C1 | TBD |
| EN7 | Reminder fires | Has resumable session | Body promotes resume + deep link to session | C0+C1 | TBD |
| EN8 | Reminder | Permission denied | Toggle shows inline help; no fire | C1 | TBD |
| EN9 | Landing screen | App launch | Dashboard, not Library | C0 | TBD |
| EN10 | Onboarding | Zero content | Show onboarding state on Dashboard | C0+C1 | TBD |
| EN11 | Day boundary | Local timezone midnight | Day rollover at local midnight | C1 | TBD |
| EN12 | Dashboard loaded state | Dashboard content loads with current V1 engagement surfaces | Show resume card, computed streak chip, daily-goal ring, today's review card, start-new-learning CTA, recent decks, search shortcut, and zero-content onboarding when the library is empty | C0+C1 | TBD |
| EN13 | Dashboard progress summary | Goal enabled and attempts exist | Return due-today count, today progress, and computed streak from persisted attempt history | C1 | TBD |
| EN14 | Dashboard progress summary | Goal disabled | Return a controlled disabled goal state and unknown streak; do not fabricate progress numbers | C1 | TBD |
| EN15 | Dashboard onboarding | Zero decks and zero flashcards | Show the richer onboarding hero, primary/secondary deck actions, and reassurance cards | C1 | TBD |
| EN16 | Dashboard visual chrome | Offline chrome enabled | Show a non-blocking offline banner above the dashboard content | C1 | TBD |
| EN17 | Dashboard visual chrome | Streak-broken chrome enabled | Show the streak-broken banner above the resume card | C1 | TBD |
| EN18 | Dashboard visual chrome | Multiple paused sessions chrome enabled | Show the paused-session count chip on the resume card | C1 | TBD |
