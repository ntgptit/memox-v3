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

> **Status (2026-06-24 — CORRECTED):** This screen (the deeper Progress **detail**, kit screen 19:
> range tabs, cards-studied chart, accuracy + delta + sparkline, box distribution, streak, card
> states) is **NOT implemented**. A prior revision of this file claimed it was built
> (`ProgressScreen`, `LoadProgressOverviewUseCase`, `lib/presentation/features/progress/**`,
> progress goldens) — **none of those exist in code**; that was doc drift. The `/progress` shell
> branch currently renders the **Stats tab** (`StatsScreen`, kit screen 18 — weekly activity +
> per-deck mastery; see `docs/wireframes/18-stats.md`), NOT this detail. WBS 7.5.1/7.5.2 (this
> detail) remain **Specified**; WBS 7.4.2 (`ProgressOverview` read model) is unbuilt. The sections
> below describe the TARGET detail screen, not current code. Canonical visual reference for the
> target: `docs/system-design/MemoX Design System/ui_kits/mobile/shots/19-progress--*.png`. When
> this detail is built it will need its own route (pushed detail or a `/progress` rename), since
> `/progress` is taken by the Stats tab (see `state.md` Parked Q3).

## Section status (target detail — NOT built)

> Every row below is **Future / unbuilt**. The Progress **detail** screen (kit 19) does not exist in
> code: there is no `lib/presentation/features/progress/**`, no `ProgressScreen` /
> `ProgressRangeController` / progress widgets, no `LoadProgressOverviewUseCase` / `ProgressOverview`
> read model, and no progress screen/golden tests. `/progress` is served by `StatsScreen` (kit 18,
> `lib/presentation/features/stats/**`). The "Target owner" column names the **planned** symbol, not
> existing code. WBS 7.4.2 (`ProgressOverview` read model) + 7.5.1/7.5.2 (this detail) are Specified.

| Section / behavior                       | Status  | Target owner (planned — not built)                                                                           | Notes |
|------------------------------------------|---------|--------------------------------------------------------------------------------------------------------------|-------|
| Detail route (own path or `/progress` rename) | Future  | new `progressRoutes()` (Parked Q3 — `/progress` is taken by the Stats tab → needs a pushed-detail route or rename) | Today `/progress` → `StatsScreen` (kit 18); the detail has no route yet. |
| Read-only screen                         | Future  | `ProgressScreen` (planned)                                                                                    | No edit actions, no Flashcard History, no Global Search entry, no Settings mutation. |
| Range tabs (Week / Month / All time)     | Future  | `ProgressRangeTabs` + `ProgressRangeController` (planned)                                                     | Default Week. Week = last 7 local days; Month = last 28 local days (4 full weeks, matches the 28-bar mock chart); All time = whole history, no day buckets. |
| Cards-studied section                    | Future  | `ProgressCardsStudiedCard` + `ProgressBarChart` (planned)                                                    | Total + per-day bar chart. Today's bar full primary, past bars softened, zero days show a thin stub. Chart hidden for All time. |
| Accuracy section                         | Future  | `ProgressAccuracyCard` + `ProgressSparkline` (planned)                                                        | Range accuracy %, delta vs previous range (needs previous-range attempts; hidden for All time), per-day sparkline (needs ≥ 2 distinct study days). |
| Box distribution                         | Future  | `ProgressBoxDistributionCard` (planned)                                                                       | Total + B1..B8 horizontal bars; B1–B5 primary, B6–B8 mastery green, opacity ramps toward B8. Snapshot, not range-filtered. |
| Streak section                           | Future  | `ProgressStreakCard` (planned); computed from `study_attempts`                                               | Study-day streak (any attempt counts), NOT the engagement daily-goal streak. An unfinished today does not break the current streak. |
| Suspended / buried counts                | Future  | `ProgressCardStatesCard` (planned)                                                                            | Read-only counts. Navigation chevrons to filtered lists are also Future (WBS 2.17.x). |
| Per-section empty/insufficient states    | Future  | `ProgressHintBox`, `ProgressInfoBanner` (planned)                                                             | Data-driven: each section shows its own dashed hint box when its slice is empty; chart needs ≥ 3 distinct study days (`kProgressTrendMinDays`). |
| Loading state                            | Future  | `MxRetainedAsyncState` skeleton builder (planned)                                                             | Tabs stay visible above three skeleton section cards. |
| Error / retry                            | Future  | `MxErrorState` via `MxRetainedAsyncState` (planned)                                                           | Failure maps to the shared retryable error state; raw exception text is never shown. |
| Help (?) app-bar action                  | Future  | Not implemented                                                                                              | Visible in the kit mock; no help content exists yet. |
| Suspended/buried navigation links        | Future  | Not implemented                                                                                              | Mock shows chevrons; filtered flashcard-list navigation is WBS 2.17.x. |
| Daily goal / engagement widgets          | Future  | Not implemented                                                                                              | Engagement goal streak stays on Dashboard scope. |
| Flashcard History / study history list   | Future  | Not implemented                                                                                              | Flashcard History remains a Future Proposal and must not be exposed from Progress. |
| Tap chart bar/point interactions         | Future  | Not implemented                                                                                              | Read-only charts. |

## Target metric semantics

> **Target — none of this is implemented for the detail screen.** The `ProgressOverview` read model
> + `LoadProgressOverviewUseCase` and the test files named below do **not** exist yet. (The shipped
> Stats screen, kit 18, has its own separate read models — `LoadStatsOverviewUseCase` /
> `LoadStudyStatisticsUseCase` / `LoadBoxDistributionUseCase` — in `lib/domain/usecases/progress/`.)
> The table is the planned contract for the detail when WBS 7.4.2/7.5.x are built.

| Metric                | Empty value | Calculation / source (target)                                                                                   | Planned test |
|-----------------------|-------------|------------------------------------------------------------------------------------------------------------------|----------------|
| Cards studied (range) | `0` + hint  | Attempt count bucketed per local day from `study_attempts`; All time uses whole-history totals | TBD (unbuilt) |
| Accuracy (range)      | hint box    | correct / total within range; correct = result IN (`perfect`, `initial_passed`, `recovered`)                     | TBD (unbuilt) |
| Accuracy delta        | hidden      | Range accuracy minus previous-range accuracy (same length window immediately before); hidden when previous range has no attempts or range is All time | TBD (unbuilt) |
| Box distribution      | `0` + hint  | `flashcard_progress` GROUP BY `box_number`, zero-filled 1..8; integrity failure on out-of-range boxes             | TBD (unbuilt) |
| Current streak        | `0` + hint  | Consecutive local study days ending today (or yesterday when today has no attempt yet), from raw `study_attempts` timestamps grouped in Dart | TBD (unbuilt) |
| Longest streak        | `0` + hint  | Longest consecutive local-day run across whole history                                                            | TBD (unbuilt) |
| Suspended count       | `0`         | `flashcard_progress WHERE is_suspended = TRUE`                                                                     | TBD (unbuilt) |
| Buried today count    | `0`         | `flashcard_progress WHERE buried_until > now`                                                                      | TBD (unbuilt) |

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

**Target (unbuilt).** One planned `LoadProgressOverviewUseCase.call(now, range)` per range selection
would compose everything the screen renders (a planned `ProgressOverview` read model, WBS 7.4.2):
activity (day buckets + previous-range totals), box distribution, streak, and card-state counts,
with the repository running the DAO queries in parallel. Data would reload on screen entry, range
switch, and Retry; no live-refresh on new attempts. None of this exists yet.

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
| Tap range tab           | Tap     | Target: reload overview for the selected range.                     |
| Tap Retry on error      | Tap     | Target: invalidate the overview query and reload.                   |
| Tap suspended/buried row| Tap     | Future: navigate to filtered flashcard list (WBS 2.17.x). Target rows are not tappable. |
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

**Target code paths (planned — none of the presentation/overview paths exist yet):**

- `lib/presentation/features/progress/routes/progress_routes.dart` (own detail route — Parked Q3)
- `lib/presentation/features/progress/screens/progress_screen.dart`
- `lib/presentation/features/progress/viewmodels/progress_viewmodel.dart`
- `lib/presentation/features/progress/widgets/progress_range_tabs.dart`
- `lib/presentation/features/progress/widgets/progress_activity_sections.dart`
- `lib/presentation/features/progress/widgets/progress_summary_sections.dart`
- `lib/domain/usecases/progress/load_progress_overview_usecase.dart` (+ a `ProgressOverview` read model, WBS 7.4.2)

Existing-but-unrelated (these back the Stats screen, kit 18 — not this detail):
`lib/data/repositories/progress_repository_impl.dart`, `lib/data/datasources/local/daos/progress_dao.dart`,
`lib/data/datasources/local/drift/progress_queries.drift`.

**Target tests (planned — none exist yet):**

- `test/data/repositories/progress_repository_overview_test.dart` (BE: buckets, streak, card states)
- `test/presentation/features/progress/progress_screen_test.dart` (all screen states + routing)
- `test/presentation/features/progress/progress_screen_golden_test.dart` (visual parity goldens, light/dark × 7 states)

**Related wireframes:**

- `docs/wireframes/01-dashboard.md` — Dashboard engagement streak is a separate metric
- `docs/wireframes/06-flashcard-list.md` — Future suspended/buried links navigate there (filtered)
