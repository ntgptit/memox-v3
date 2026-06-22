# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 7 — Study — Match (next inner study mode) — **object 6 (Study — Review) is
  COMPLETE** (all WP-SR slices shipped; Review loop end-to-end). Objects 7-10 reuse the SR2 session
  shell + SR5 result; each adds its own grade grammar. See `loop-plan/study-review.md` (the shared
  Review anchor) + read the Match wireframe/shots before building.
- **Current work-package:** **OBJECT 7 (Match) — WP-SM2 SHIPPED; the Match BE is COMPLETE.** Finalization
  derivation: `finalizeStudySession` routes Match sessions (by presence of evaluations) → `finalize`
  derives one terminal `study_attempts` per item (first-eval-correct→`perfect`, else `forgot`) + the
  normal SRS transition, in one `finalizeMatchSession` txn (`219c272`). Shared `dueAtFor` extracted. S54–S57
  tested. **WBS 4.5.4 → Implemented.** **NEXT: WP-SM3 (FE) — mode dispatch + Match board shell.** Resolve
  the OPEN QUESTION (recommend `?mode=match` query → `RouteParams`/nav-flow); `StudySessionScreen` dispatches
  Review vs a new Match board body: app bar (✕ + **blue** MATCH mode pill + blue `MxLinearProgress` +
  `{boards_done*5+matched}/{total}` count) + the board indicator ("BOARD n OF m · k PAIRS LEFT") +
  loading/error/empty, reusing `studySessionReviewProvider` items batched into boards of 5. Goldens for the
  fresh board. Then WP-SM4 (grid + tap-pair state machine + `RecordMatchEvaluationUseCase` wiring) → WP-SM5
  (board progression + reuse SR5 finalize/result). Reuse object 6's shell/exit-confirm/result. Plan:
  `docs/project-management/loop-plan/study-match.md`. Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c (gate CTAs),
  WP-SR2b (language labels); object-5 WP-FL2b2b (Tags).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `219c272` (WP-SM2 — Match BE COMPLETE; prior
  `a99cdc8` WP-SM1b persistence, `a7b5cb9` WP-SM1a schema v8).
- **Last verify:** PASS (code chain, guard 0 errors) — WP-SR1b-2b tree + review-fix. **Fan-out now
  complete:** docs-drift PASS; code-reviewer APPROVE + ui-parity PASS (re-ran after the 529 overload
  cleared). Folded 2 Importants: fallback-Back `fullWidth`, + a "Study new instead" navigation test
  (`_reenterWithNewCards`). ~25 gate tests + 10 goldens.

## Follow-up cleanups (logged, not blocking)

- Shared-dock dedup: `LibrarySearchDock` + `FolderDetailSearchDock` are near-identical (dock chrome
  + a provider-synced field). Extract a shared `MxScopedSearchDock({child})` once both consumers are
  stable. (`MxSearchDock` stays separate — its onChanged-only API can't host the synced field.)
- Search-mode app-bar icons: kit Decks/loaded states show only overflow (folder) / sort (library);
  the search-toggle + sort icons are kept as post-redesign affordances (documented variance). A
  future pass could hide search+sort while `searching` to match the mock exactly — apply to BOTH
  Library + folder together.
- FAB in flashcard-list **empty** state: `flashcard_list_screen.dart` shows the add-card `MxFab`
  even when `totalCount == 0`, but kit `06` empty has no FAB (the empty state has an inline Add CTA);
  Library/folder empty states correctly hide the FAB. Pre-existing (not WP-D2). Small eligible fix:
  gate the FAB on `detail != null && detail.totalCount > 0`; regen the 2 empty goldens. Fold into the
  object-5 pass (same `06` screen).

## Loop is NOT terminal — prior "terminal" stop was invalidated

The previous iteration declared terminal on three reasons now disallowed by the loop rules:
greenfield/too-large (→ must split & build), mock↔docs flip-vs-swipe (→ PRECEDENCE: business
`study-flow.md` wins), wireframe "shipped" drift (→ stale doc-status, fix one line on build). Study
(object 6) BE is ready → it is a BUILD case, not a stop. Re-auditing 1→5 by evidence first.

## Object status (outer → inner) — TRUST POLICY: confirm by evidence on the current tree

| # | Object | Status |
|---|---|---|
| 1 | Library overview | **DONE (re-audit-confirmed 2026-06-22)** — code+test+golden verified; re-audit found the Search state diverged (app-bar swap vs kit bottom dock) → fixed in WP-L10 (`LibrarySearchDock`); ui-parity PASS. |
| 2 | Folder detail | **DONE (re-audit-confirmed 2026-06-22)** — code+25 tests+goldens verified; search-state app-bar-swap → bottom dock (WP-FD10); move-sheet golden gap closed (WP-FD11); ui-parity PASS. DEFERred: reorder (no mock), new-vs-due (not in mock), picker restyle (bundled). |
| 3 | Sub-folder (nested) | **DONE (re-audit-confirmed 2026-06-22)** — same `FolderDetailScreen` at depth (no separate screen/route/mock); nested-breadcrumb + tappability + create-mode-lock + actions-at-depth all code+test-verified (`Explore` + `tool/verify`, 21 tests). No gap to build. |
| 4 | Deck detail | **DONE (re-audit-confirmed 2026-06-22)** — deck container (WBS 3.4.2) + WP-D1 due badge + WP-D2 **persistent** search dock (kit `06` dock is persistent, not toggle). ui-parity PASS. |
| 5 | Flashcard (list + editor) | IN PROGRESS — FL3/FL4 + **FL1** + **FL2a shell** + **FL2b1 delete** + **FL2b2 Details** + **FL2b3a saving+save-failed** + **FL2b3b loading+load-error (`d3aa162`)** SHIPPED (ui-parity PASS). **Only WP-FL2b2b (Tags input) remains** before DONE. |
| 6 | Study — Review | **DONE (2026-06-22).** Gate (WP-SR1a..1b-2b) + session (WP-SR2) + swipe-grade (WP-SR3) + exit-confirm (WP-SR4a) + card-actions Bury/Suspend (WP-SR4b) + finalize→result V1 incl. save-failed/defensive (WP-SR5a+5b) — **Review loop end-to-end + code+test+golden verified.** WBS 4.1.2/4.7.2 Implemented; 4.5.3 Partial (WP-SR2b language labels + WP-SR4b-2 Edit deferred polish). |
| 7 | Study — Match | **ACTIVE — BE COMPLETE; FE next.** WP-SM1a schema v8 + WP-SM1b persistence + **WP-SM2 finalization** SHIPPED (S54–S57); **WBS 4.5.4 Implemented**. Next: **WP-SM3/4/5 (FE board)** — mode dispatch + board shell → grid + tap-pair (wires `RecordMatchEvaluationUseCase`) → progression + reuse SR5 finalize/result. Reuses SR2 shell + SR5 result. Plan: `loop-plan/study-match.md`. |
| 8–10 | Study — Guess/Recall/Fill | BUILD (independent FE grammar; reuse SR2 shell + SR5 result) |

## Next action

**Build WP-SM3 — mode dispatch + Match board shell (FE)** (object 7; the Match BE is COMPLETE). This
is the first FE slice — a greenfield board over ready BE, reusing object 6's session shell + result.
Read FIRST: `docs/project-management/loop-plan/study-match.md` (the OPEN QUESTION + slice plan),
`docs/wireframes/14-study-session-match.md` (§Layout board-fresh, §Components, §Board composition),
`lib/presentation/features/study/screens/study_session_screen.dart` (the Review shell to dispatch from),
`lib/presentation/features/study/routes/study_routes.dart` + `route_paths.dart`/`route_names.dart`.
Build:
1. **Resolve the OPEN QUESTION (mode selection):** recommend a `?mode=match` query param on the session
   route (add `RouteParams.modeQueryParam` + parse in `study_routes.dart`; default = review). Update
   `docs/business/navigation/navigation-flow.md`. (The full per-phase `current_mode` chain stays a
   separate object, WBS 4.5.12+.)
2. `StudySessionScreen` (or a dispatcher) renders the Review body for `mode=review` and a new Match
   board body for `mode=match`: the app bar (✕ exit reusing `_confirmExit` + a **blue** MATCH mode pill
   + blue `MxLinearProgress` + the `{boards_done*5 + matched}/{total}` count) + the board indicator
   caption ("BOARD n OF m · k PAIRS LEFT") + loading/error/empty shells. Reuse `studySessionReviewProvider`
   items (front/back are mode-agnostic), batched into boards of 5 (the grid itself = WP-SM4).
3. Tokens + `Mx*`; copy → ARB (en+vi). Golden(s) for the fresh board shell (light+dark).
Then WP-SM4 (the 2×5 grid + tap-pair state machine wiring `RecordMatchEvaluationUseCase`) → WP-SM5
(board progression + reuse SR5 finalize/result). PRECEDENCE: behavior → wireframe 14 + study-flow.md;
**blue** mode family (not green). Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c, WP-SR2b; object-5 WP-FL2b2b (Tags).
