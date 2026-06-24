---
last_updated: 2026-06-24
route: /progress
source_specs:
  - docs/business/srs/srs-review.md
  - docs/business/system/overview.md
  - docs/contracts/repository-contracts/progress-repository.md
---

# 18 — Stats

## Purpose

The bottom-nav **Stats** tab — a quiet, read-only summary surface: this week's review activity
(a column chart) and per-deck mastery. It is the tab landing screen (no back button, shell bottom
nav visible). The deeper Progress analytics (range tabs, accuracy, box distribution, streak) live
on a separate Progress detail (screen 19 / `docs/wireframes/03-progress.md`), which is still
pending — do not conflate the two.

> **Status (2026-06-24):** Stats V1 is implemented. The `/progress` shell branch renders
> `StatsScreen` (`lib/presentation/features/stats/screens/stats_screen.dart`), backed by
> `LoadStatsOverviewUseCase` → `ProgressRepository.loadStatsOverview`. Canonical visual reference:
> `docs/system-design/MemoX Design System/ui_kits/mobile/shots/18-stats--default--light|dark.png`
> (DOM spec `…/specs/18-stats.md`); goldens at `test/presentation/features/stats/goldens/`.

## Tab label note

The bottom-nav tab is labelled **"Stats"** with a bar-chart icon (per the kit mock + `overview.md`).
The route keeps its internal `progress` name/path (`RouteNames.progress` / `RoutePaths.progress`) —
renaming the route is deferred; the deeper analytics screen is still titled "Progress".

## Layout

```
┌───────────────────────────────────────┐
│ Stats                                 │  ← App bar, large title (no back)
├───────────────────────────────────────┤
│ ┌───────────────────────────────────┐ │
│ │ 📅 CARDS THIS WEEK           132  │ │  ← week card (overline + total)
│ │  18 24 12 31 22  9 16             │ │     value labels
│ │  ▄  ▆  ▂  █  ▅  ▁  ▃              │ │     accent bars
│ │  M  T  W  T  F  S  S              │ │     local weekday labels
│ └───────────────────────────────────┘ │
│ Per-deck mastery                      │  ← section header
│ ┌───────────────────────────────────┐ │
│ │ ▢ Japanese · N5    ▓▓▓▓▓░░   72%  │ │  ← mastery rows (tinted tile +
│ │ ──────────────────────────────    │ │     name + mastery bar + %)
│ │ ▢ Organic chemistry ▓▓░░░░░  38%  │ │
│ │ ▢ World capitals   ▓▓▓▓▓▓▓  91%  │ │
│ │ ▢ SAT vocabulary   ▓▓▓▓░░░  56%  │ │
│ └───────────────────────────────────┘ │
├───────────────────────────────────────┤
│ 🏠 Home  📚 Library  🔍 Search  📊 Stats  ⚙️ │  ← shell bottom nav
└───────────────────────────────────────┘
```

## Data loading

One `LoadStatsOverviewUseCase.call()` (owns the `now` clock) composes everything the screen renders
(`StatsOverview`): the current local week's activity (`WeekActivity`) + per-deck mastery
(`List<DeckMastery>`). The repository runs the two reads; an empty database yields a zero-filled
week and an empty deck list. Reload by invalidating `statsOverviewProvider`.

| Data                  | Source                                                                                     |
|-----------------------|---------------------------------------------------------------------------------------------|
| Cards this week       | `attemptsSince` over `study_attempts` (from local Monday midnight), bucketed per **local** day in Dart (decision P20) |
| Per-deck mastery      | `deckMastery` over `flashcard_progress` (AVG box per deck), mapped to a 0..1 fraction (decision P21) |

Local-day grouping happens in Dart (`toLocal()`), not SQL — the sqlite3 build used by Flutter tests
on Windows returns NULL for the `'localtime'` modifier
(`lib/data/datasources/local/drift/progress_queries.drift`).

## V1 metric semantics

| Metric            | Empty value     | Calculation / source                                                                 |
|-------------------|-----------------|---------------------------------------------------------------------------------------|
| Cards this week   | 7× `0` stubs    | Count of `study_attempts` per local day, Mon→Sun of the current week; total = the sum |
| Mastery (per deck)| no rows         | `(avgBox − SrsBox.min) / (SrsBox.max − SrsBox.min)` → 0..1; box 1 → 0%, box 8 → 100%   |

## Components

| Component         | Spec                                                                                                |
|-------------------|------------------------------------------------------------------------------------------------------|
| Week card         | `MxCard` with an overline (`CARDS THIS WEEK`) + weekly total, over `MxBarChart` (7 bars, accent).    |
| Bar chart         | `MxBarChart` (shared) — value label, accent bar scaled to the week peak, local weekday label; zero days render a thin stub. |
| Section header    | "Per-deck mastery" (`MxText` titleMedium).                                                            |
| Mastery list      | `MxCard` of `DeckMasteryRow`s separated by inset `MxDivider`s.                                        |
| Mastery row       | `MxIconTile` (tint cycles the SRS-status scale) + deck name + `MxMasteryBar` + trailing percent.      |
| Mastery bar       | `MxMasteryBar` (shared) — fill tinted low (<50%) / mid (50–79%) / high (≥80%) per the mastery scale.  |

## States

| State    | Trigger                       | Behavior                                                            |
|----------|-------------------------------|---------------------------------------------------------------------|
| Loading  | Initial fetch                 | `MxLoadingState` (the kit ships only the loaded "default" state).   |
| Loaded   | Overview resolved             | Week card + per-deck mastery list.                                  |
| No decks | No deck has cards yet         | Week card renders; the mastery card shows `statsNoDecksHint`.       |
| Empty    | Empty database                | Week chart renders all-zero stubs; no deck rows (no-decks hint).    |
| Error    | Overview load fails           | `MxErrorState` (`statsLoadFailed*`) + Retry; retry reloads.         |

> The kit ships a single `default` state (`shots/18-stats--default--*`). Loading / error / no-decks
> are FE-necessary states driven by data availability, not separate kit mocks.

## Forbidden

- ❌ Add edit actions. Stats is strictly read-only.
- ❌ Group attempts by local day in SQL; the test-environment sqlite returns NULL for `'localtime'`.
  Group in Dart via `toLocal()`.
- ❌ Sort the weekly chart by value; it is fixed Monday→Sunday.
- ❌ Fabricate per-deck icons; decks carry no stored icon (only folders do) — see Parked gaps.

## Parked / known gaps

- **Per-deck icon/colour:** decks have no stored icon or colour in the schema (only folders do,
  `deck.dart`). The mock shows distinct per-deck glyphs (languages / flask / landmark / book); the
  FE uses one generic deck glyph and cycles the four SRS-status tints by row index to echo the
  mock's varied chips. A per-deck custom icon/colour is a **schema gap** (needs a `decks.icon` /
  `decks.color` migration) — deferred.
- **Stats vs Progress route:** both the Stats tab (18) and the Progress detail (19) currently target
  the `/progress` branch. Screen 19 will be wired as a pushed detail (or the route renamed) when it
  lands; tracked in `state.md` Parked questions.
- **Type-scale weight gaps (minor):** the mock's overline (12/700 + 1px tracking), per-deck percent
  (14/800 extrabold), and section header (16/700) are each one weight step heavier than the nearest
  `MxTextRole` (`labelMedium` 12/600, `labelLarge` 14/600, `titleMedium` 16/600). `MxText` exposes
  semantic roles only (no raw `fontWeight`/letterSpacing override by design), so closing these needs
  new type-scale roles (overline / numeric-label / section-title) — a design-system change pending
  approval. Visual impact is small (deterministic parity verdict OK, diff ~11%/14%). Reason:
  "design token/component not available yet" (visual-drift policy).

## Implementation refs

**Business specs:** `docs/business/srs/srs-review.md` (box / mastery semantics).
**Decision rows:** P20 (weekly activity), P21 (per-deck mastery) in
`docs/decision-tables/progress-history.md`.
**Contracts:** `docs/contracts/repository-contracts/progress-repository.md` (`loadStatsOverview`).

**Schema / storage:** `study_attempts` (weekly activity), `flashcard_progress` + `decks` +
`flashcards` (per-deck mastery). Queries: `lib/data/datasources/local/drift/progress_queries.drift`
(`attemptsSince`, `deckMastery`). No schema change.

**Code paths:**

- `lib/presentation/features/stats/routes/stats_routes.dart` → `/progress` branch
- `lib/presentation/features/stats/screens/stats_screen.dart`
- `lib/presentation/features/stats/widgets/stats_body.dart`, `…/widgets/deck_mastery_row.dart`
- `lib/presentation/features/stats/viewmodels/stats_viewmodel.dart`
- `lib/presentation/shared/widgets/feedback/mx_bar_chart.dart`, `…/mx_mastery_bar.dart`
- `lib/domain/usecases/progress/load_stats_overview_usecase.dart`
- `lib/domain/models/{stats_overview,week_activity,deck_mastery}.dart`
- `lib/data/repositories/progress_repository_impl.dart`, `…/daos/progress_dao.dart`

**Tests:**

- `test/data/repositories/progress_repository_stats_test.dart` (BE: weekly buckets, mastery fraction)
- `test/presentation/features/stats/stats_test.dart` (screen states + goldens, light/dark)
- `test/presentation/features/stats/stats_parity_test.dart` (data-mx-node identity contract)

**Related wireframes:**

- `docs/wireframes/03-progress.md` — the deeper Progress analytics detail (screen 19, pending)
