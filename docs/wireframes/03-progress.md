---
last_updated: 2026-06-12
route: /progress
source_specs:
  - docs/business/engagement/dashboard-engagement.md
  - docs/business/srs/srs-review.md
  - docs/business/system/overview.md
---

# 03 — Progress

## Purpose

Long-form analytics surface. Dashboard shows "today"; Progress shows trends and totals. Read-only.

> **Status (2026-06-12):** Progress V1 is implemented. `/progress` renders `ProgressScreen`
> (`lib/presentation/features/progress/screens/progress_screen.dart`) with range tabs,
> cards-studied chart, accuracy + delta + sparkline, box distribution, streak, and card-state
> counts, backed by `LoadProgressOverviewUseCase` →
> `ProgressRepository.loadProgressOverview`. The kit mock
> (`docs/system-design/MemoX Design System/ui_kits/mobile/shots/19-progress--*.png`) is the
> canonical visual reference; goldens live at
> `test/presentation/features/progress/goldens/`.

## V1 verification status

| Section / behavior                       | Status  | Current owner                                                                                                | Notes |
|------------------------------------------|---------|--------------------------------------------------------------------------------------------------------------|-------|
| `/progress` route                        | Current | `RouteNames.progress` / `RoutePaths.progress`; `progressRoutes()` in `lib/presentation/features/progress/routes/progress_routes.dart` | Shell branch renders `ProgressScreen`; placeholder removed. |
| Bottom/app navigation to Progress        | Current | Shell branch + bottom nav                                                                                    | Shell navigation stays visible on `/progress`. |
| Read-only screen                         | Current | `ProgressScreen`                                                                                             | No edit actions, no Flashcard History, no Global Search entry, no Settings mutation. |
| Range tabs (Week / Month / All time)     | Current | `ProgressRangeTabs` + `ProgressRangeController`                                                              | Default Week. Week = last 7 local days; Month = last 28 local days (4 full weeks, matches the 28-bar mock chart); All time = whole history, no day buckets. |
| Cards-studied section                    | Current | `ProgressCardsStudiedCard` + `ProgressBarChart`                                                              | Total + per-day bar chart. Today's bar full primary, past bars softened, zero days show a thin stub. Chart hidden for All time. |
| Accuracy section                         | Current | `ProgressAccuracyCard` + `ProgressSparkline`                                                                 | Range accuracy %, delta vs previous range (needs previous-range attempts; hidden for All time), per-day sparkline (needs ≥ 2 distinct study days). |
| Box distribution                         | Current | `ProgressBoxDistributionCard`                                                                                | Total + B1..B8 horizontal bars; B1–B5 primary, B6–B8 mastery green, opacity ramps toward B8. Snapshot, not range-filtered. |
| Streak section                           | Current | `ProgressStreakCard`; computed in `ProgressRepositoryImpl._computeStreak` from `study_attempts`              | Study-day streak (any attempt counts), NOT the engagement daily-goal streak. An unfinished today does not break the current streak. |
| Suspended / buried counts                | Current | `ProgressCardStatesCard`                                                                                     | Read-only counts. Navigation chevrons to filtered lists are Future (WBS 2.17.x). |
| Per-section empty/insufficient states    | Current | `ProgressHintBox`, `ProgressInfoBanner`                                                                      | Data-driven: each section shows its own dashed hint box when its slice is empty; chart needs ≥ 3 distinct study days (`kProgressTrendMinDays`). |
| Loading state                            | Current | `MxRetainedAsyncState` skeleton builder                                                                      | Tabs stay visible above three skeleton section cards. |
| Error / retry                            | Current | `MxErrorState` via `MxRetainedAsyncState`                                                                    | Failure maps to the shared retryable error state; raw exception text is never shown. |
| Help (?) app-bar action                  | Future  | Not implemented                                                                                              | Visible in the kit mock; no help content exists yet. |
| Suspended/buried navigation links        | Future  | Not implemented                                                                                              | Mock shows chevrons; filtered flashcard-list navigation is WBS 2.17.x. |
| Daily goal / engagement widgets          | Future  | Not implemented                                                                                              | Engagement goal streak stays on Dashboard scope. |
| Flashcard History / study history list   | Future  | Not implemented                                                                                              | Flashcard History remains a Future Proposal and must not be exposed from Progress. |
| Tap chart bar/point interactions         | Future  | Not implemented                                                                                              | Read-only charts in V1. |

## V1 metric semantics

| Metric                | Empty value | Calculation / source                                                                                            | Test coverage |
|-----------------------|-------------|------------------------------------------------------------------------------------------------------------------|----------------|
| Cards studied (range) | `0` + hint  | Attempt count bucketed per local day from `study_attempts` (`progressAttemptsBetween`); All time uses whole-history totals | `test/data/repositories/progress_repository_overview_test.dart` |
| Accuracy (range)      | hint box    | correct / total within range; correct = result IN (`perfect`, `initial_passed`, `recovered`)                     | Same + `test/presentation/features/progress/progress_screen_test.dart` |
| Accuracy delta        | hidden      | Range accuracy minus previous-range accuracy (same length window immediately before); hidden when previous range has no attempts or range is All time | Same |
| Box distribution      | `0` + hint  | `flashcard_progress` GROUP BY `box_number`, zero-filled 1..8; integrity failure on out-of-range boxes             | `test/data/repositories/progress_repository_impl_test.dart` |
| Current streak        | `0` + hint  | Consecutive local study days ending today (or yesterday when today has no attempt yet), from raw `study_attempts` timestamps grouped in Dart | `test/data/repositories/progress_repository_overview_test.dart` |
| Longest streak        | `0` + hint  | Longest consecutive local-day run across whole history                                                            | Same |
| Suspended count       | `0`         | `flashcard_progress WHERE is_suspended = TRUE`                                                                     | Same |
| Buried today count    | `0`         | `flashcard_progress WHERE buried_until > now`                                                                      | Same |

Local-day grouping happens in Dart (`toLocal()`), not SQL: the sqlite3 build used by Flutter
tests on Windows returns NULL for the `'localtime'` modifier
(see `lib/data/datasources/local/drift/progress_queries.drift`).

## Layout

Canonical visual reference: `docs/system-design/MemoX Design System/ui_kits/mobile/shots/19-progress--*.png`
(week, month, empty, insufficient, partial, loading, error × light/dark) and
`docs/system-design/MemoX Design System/ui_kits/mobile/specs/19-progress.md` (DOM spec).

```
┌───────────────────────────────────────┐
│ Progress                              │  ← App bar (help icon: Future)
├───────────────────────────────────────┤
│ [ Week ][ Month ][ All time ]         │  ← Segmented range tabs
│ ┌───────────────────────────────────┐ │
│ │ CARDS STUDIED                     │ │
│ │ 92                                │ │
│ │ over the past 7 days              │ │
│ │  ▂▄_▇▅▃█   (bar chart)            │ │
│ │  M T W T F S S                    │ │
│ └───────────────────────────────────┘ │
│ ┌───────────────────────────────────┐ │
│ │ ACCURACY                          │ │
│ │ 73%                               │ │
│ │ ↗ +4% vs previous week            │ │
│ │  ── sparkline ──●                 │ │
│ └───────────────────────────────────┘ │
│ ┌───────────────────────────────────┐ │
│ │ BOX DISTRIBUTION                  │ │
│ │ 414  total cards across boxes     │ │
│ │ B1 ████░░░░░░░░░░░░░░         24  │ │
│ │ …   (B1–B5 primary, B6–B8 green)  │ │
│ │ least known          best known   │ │
│ └───────────────────────────────────┘ │
│ ┌───────────────────────────────────┐ │
│ │ STREAK                            │ │
│ │ [🔥 Current 6 days][🏆 Longest 14]│ │
│ └───────────────────────────────────┘ │
│ CARD STATES                           │
│ ┌───────────────────────────────────┐ │
│ │ ⏸ Suspended …            12       │ │  ← counts only; chevron link Future
│ │ 🌙 Buried (today) …       3       │ │
│ └───────────────────────────────────┘ │
│ Read-only summary · last 7 days       │  ← footer, range-specific
├───────────────────────────────────────┤
│ 🏠 Home  📚 Library  📈 Stats  ⚙️     │
└───────────────────────────────────────┘
```

## Inputs

| Param  | Source    | Notes                                                       |
|--------|-----------|--------------------------------------------------------------|
| range  | in-memory | `ProgressRangeController` (Riverpod); default `week`. No URL query param in V1. |

## Data loading

One `LoadProgressOverviewUseCase.call(now, range)` per range selection composes everything the
screen renders (`ProgressOverview`): activity (day buckets + previous-range totals), box
distribution, streak, and card-state counts. The repository runs the DAO queries in parallel.
Data reloads on screen entry, range switch, and Retry; V1 does not live-refresh on new attempts.

| Data                                | Source                                                                  |
|-------------------------------------|--------------------------------------------------------------------------|
| Daily attempt counts + accuracy     | `progressAttemptsBetween` over `study_attempts`, bucketed per local day in Dart |
| Previous-range totals (for delta)   | Same single query window (previous range start → range end), split in Dart |
| Box distribution (1-8 counts)       | `progressBoxDistribution` over `flashcard_progress`                      |
| Streak (current + longest)          | `progressAttemptTimestamps` (raw), local-day grouping + runs in Dart     |
| Suspended count                     | `progressSuspendedCount`                                                 |
| Buried today count                  | `progressBuriedTodayCount` (`buried_until > now`)                        |

## Forbidden

- ❌ Add edit actions. Progress is strictly read-only.
- ❌ Use one shared empty state for all sections; each section handles empty independently.
- ❌ Bury count copy says "this week" — buried is daily by definition.
- ❌ Sort box distribution by count; sort by box number (1→8) for predictable scan.
- ❌ Render the streak as the engagement daily-goal streak; Progress shows the study-day streak.

## Components

| Component              | Spec                                                                                                   |
|------------------------|----------------------------------------------------------------------------------------------------------|
| Range tabs             | Segmented control: Week (last 7 local days), Month (last 28), All time. Default Week.                  |
| Cards studied chart    | Bar chart, one bar per day in range; hidden for All time. Needs ≥ 3 distinct study days, else hint + trend banner. |
| Accuracy section       | Accuracy %, delta vs previous range (green up / error down), sparkline (≥ 2 distinct study days).      |
| Box distribution       | Horizontal bars per box (1-8); snapshot, not range-filtered; legend least/best known.                  |
| Streak card            | Two tiles: current and longest study-day streaks.                                                       |
| Card states card       | Suspended + buried-today counts, read-only. Chevron navigation Future.                                  |
| Hint box               | Dashed-border rounded box, centered muted copy; one per empty section slice.                            |

## States

| State             | Trigger                                  | Behavior                                                                              |
|-------------------|------------------------------------------|----------------------------------------------------------------------------------------|
| Loading           | Initial fetch / range switch first load  | Range tabs stay visible above three skeleton section cards.                            |
| Empty             | A section's data slice is empty          | That section shows its own hint box (`progress*EmptyHint` keys); other sections render. |
| Populated         | Normal                                   | All sections visible; footer states the range.                                         |
| Insufficient data | < 3 distinct study days in range         | Chart swaps for `progressChartInsufficientHint` + `progressTrendBanner`; accuracy still renders from existing attempts. |
| Error             | Overview load fails                      | `MxErrorState` with `progressErrorTitle` / `progressErrorMessage` + Retry; retry reloads. |

The kit's Empty / Insufficient / Partial screen variants are data-driven combinations of the
per-section states above, not separate screen modes.

> **Mock conflict (documented, not implemented):** the kit "partial" mock shows a populated
> cards-studied chart next to an accuracy hint reading "Not enough answered cards yet to show
> accuracy." With real data that combination is unreachable — any charted attempt makes accuracy
> computable — so V1 keeps one accuracy empty hint (`progressAccuracyEmptyHint`) shown only when
> the range has zero attempts. Likewise the "insufficient" mock renders a sparkline with one day
> of data; V1 requires ≥ 2 distinct study days for the sparkline.

## Actions

| Action                  | Trigger | Result                                                              |
|-------------------------|---------|----------------------------------------------------------------------|
| Tap range tab           | Tap     | Current: reload overview for the selected range.                    |
| Tap Retry on error      | Tap     | Current: invalidate the overview query and reload.                  |
| Tap suspended/buried row| Tap     | Future: navigate to filtered flashcard list (WBS 2.17.x). V1 rows are not tappable. |
| Tap chart bar/point     | Tap     | Future/optional. Not rendered in V1.                                |

## Dialogs and bottom-sheets used

None in V1.

## Navigation in

- Bottom nav tap "Stats" (Progress branch).

## Navigation out

- Tabs → other top-level destinations. No other exits in V1.

## Responsive

- ≥600dp: charts arranged in 2 columns. Box distribution stays full-width below. (Target; V1 is single-column.)

## Accessibility

- Each section leads with a textual total above the chart (e.g., "92 / over the past 7 days").
- Range tabs are tappable Material surfaces via `MxTappable`.
- Box distribution rows render box label + count as text.

## Rules

- Range tabs default Week.
- Box distribution does NOT filter by range (it's a snapshot).
- Charts MUST handle empty data gracefully (no NaN, no crash) — zero-attempt days render stubs.
- Suspended/buried counts include all decks (account-scoped global).
- Streak = study-day streak from `study_attempts`; the engagement daily-goal streak is a different metric.

## Agent rule

- Do NOT add edit actions here. Progress is read-only.
- Empty state per section, not one shared empty state across all sections.
- Buried count uses `buried_until > now` filter; "today" copy is correct only because bury duration
  is fixed to next-midnight.
- Do NOT group attempts by local day in SQL; the test-environment sqlite returns NULL for
  `'localtime'`. Group in Dart via `toLocal()`.

## Implementation refs

**Business specs:**

- `docs/business/engagement/dashboard-engagement.md` (engagement streak — distinct metric)
- `docs/business/srs/srs-review.md` (box distribution semantics)

**Decision rows:** P1–P18 in `docs/decision-tables/memox-core-decision-table.md`.

**Schema / storage:**

- `study_attempts` (range aggregates, streak), `flashcard_progress` (box distribution snapshot,
  `is_suspended`, `buried_until`). Queries: `lib/data/datasources/local/drift/progress_queries.drift`.

**Code paths:**

- `lib/presentation/features/progress/routes/progress_routes.dart` → `/progress`
- `lib/presentation/features/progress/screens/progress_screen.dart`
- `lib/presentation/features/progress/viewmodels/progress_viewmodel.dart`
- `lib/presentation/features/progress/widgets/progress_range_tabs.dart`
- `lib/presentation/features/progress/widgets/progress_activity_sections.dart`
- `lib/presentation/features/progress/widgets/progress_summary_sections.dart`
- `lib/domain/usecases/progress/load_progress_overview_usecase.dart`
- `lib/data/repositories/progress_repository_impl.dart`
- `lib/data/datasources/local/daos/progress_dao.dart`

**Tests:**

- `test/data/repositories/progress_repository_overview_test.dart` (BE: buckets, streak, card states)
- `test/presentation/features/progress/progress_screen_test.dart` (all screen states + routing)
- `test/presentation/features/progress/progress_screen_golden_test.dart` (visual parity goldens, light/dark × 7 states)

**Related wireframes:**

- `docs/wireframes/01-dashboard.md` — Dashboard engagement streak is a separate metric
- `docs/wireframes/06-flashcard-list.md` — Future suspended/buried links navigate there (filtered)
