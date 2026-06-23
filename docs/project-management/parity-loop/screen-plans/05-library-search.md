# Screen 05 — Library / Global search — parity plan

Source: `docs/system-design/MemoX Design System/ui_kits/mobile/specs/05-library-search.md`
+ `.../shots/05-library-search--*--{light,dark}.png`.
FE: `lib/presentation/features/search/screens/global_search_screen.dart`
+ `widgets/global_search_body.dart` + `global_search_results_view.dart` + shared `MxSearchDock`.
Audit: 2026-06-23.

## diff.py baseline (golden ↔ kit shot, tolerance 16, threshold 100)

| State | light | dark |
| --- | --- | --- |
| results | 12.74% | 17.12% |
| no-results | 9.96% | 10.97% |
| empty | 11.86% | 14.24% |
| loading | 3.72% | 12.36% |
| error | 12.01% | 14.59% |

All Ahem range; dark = general amplification (seen on every screen). No structural outlier.

## STATE COVERAGE (kit = 5 states)

| Kit state | golden | FE branch |
| --- | --- | --- |
| results | global_search_results | results view (grouped) |
| no-results | global_search_no-results | MxNoResultsState |
| empty | global_search_empty | empty/initial prompt |
| loading | global_search_loading | MxLoadingState |
| error | global_search_error | MxErrorState |

**Full coverage** — all 5 kit states have goldens (light+dark). The FE is the redesigned top-level
`/search` with a bottom `MxSearchDock` (`[[design-redesign-ia-2026-06-21]]`).

## GAP checklist
1. No missing states; no structural outlier in diff.py. Residual % is Ahem text rendering.
2. The search field fill (kit `accent-contrast` vs `MxSearchField`→`MxTextField` `surfaceMuted`) is part
   of the shared app-wide field-fill divergence (see parity-deferred) — the search dock field inherits it.
3. Per-node INVENTORY (results-row layout, section headers, dock chrome) — token-level; no concrete
   divergence surfaced; low-priority.

## Status: AUDITED; done (modulo deferred)
Full state coverage; redesigned global search; residual diff is Ahem-noise; field-fill is the shared
app-wide deferred item. No screen-05-specific concrete pixel gap found.
