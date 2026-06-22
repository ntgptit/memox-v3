# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 7 — Study — Match (next inner study mode) — **object 6 (Study — Review) is
  COMPLETE** (all WP-SR slices shipped; Review loop end-to-end). Objects 7-10 reuse the SR2 session
  shell + SR5 result; each adds its own grade grammar. See `loop-plan/study-review.md` (the shared
  Review anchor) + read the Match wireframe/shots before building.
- **Current work-package:** **OBJECT 7 (Match) — WP-SM4 SHIPPED (tap-pair FSM).** `MatchBoardController`
  Fisher-Yates-shuffles board 0's 10 cells; one-selection FSM → valid pair locks green ✓ / wrong flashes
  red then reverts, each pair → `RecordMatchEvaluationUseCase`; interactive status-colored cells;
  `_evaluating` re-entrancy guard; new `AppMotion` token (`a2ac51b`, S95). WBS 4.5.5 Partial (SM3+SM4).
  **NEXT: WP-SM5 (FE) — board progression + finalize → result** (makes Match end-to-end + reuses the SR5
  result; higher value than the WP-SM4b chrome). When a board is complete (`MatchBoardView.boardComplete`,
  all pairs matched): if more cards remain → advance to the next board (`_buildBoard(boardIndex+1)`,
  rebuild the cells); on the **last** board → `FinalizeStudySessionUseCase(sessionId)` (the Match
  finalize branch derives terminals from the evals — already built WP-SM2) → `pushReplacementNamed`
  to the **SR5 result route** (`RouteNames.studyResult`, reused). Tests: multi-board advance +
  finalize-on-last-board → result. Then **object 7 COMPLETE** → objects 8-10 (Guess/Recall/Fill) reuse
  this shell + the result. **WP-SM4b (deferred polish):** Shuffle & restart bar + mistake counter + timer.
  Plan: `docs/project-management/loop-plan/study-match.md`. Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c,
  WP-SR2b; object-5 WP-FL2b2b (Tags).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `a2ac51b` (WP-SM4 — Match tap-pair FSM; prior
  `6abbe2b` WP-SM3 board shell, `219c272` WP-SM2 Match BE complete).
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
| 7 | Study — Match | **ACTIVE — BE complete; FE board playable.** BE (WP-SM1a/1b/2, 4.5.4 Implemented, S54–S57) + FE board shell (WP-SM3, S94) + **tap-pair FSM (WP-SM4, S95)** SHIPPED — one board is fully playable (select → match/wrong → record). WBS 4.5.5 Partial. Next: **WP-SM5 (board progression + finalize → reuse SR5 result → object 7 COMPLETE)**; WP-SM4b (Shuffle&restart/timer/mistake counter) = deferred polish. Plan: `loop-plan/study-match.md`. |
| 8–10 | Study — Guess/Recall/Fill | BUILD (independent FE grammar; reuse SR2 shell + SR5 result) |

## Next action

**Build WP-SM5 — board progression + finalize → result (FE)** (object 7; the board plays one board —
this makes Match end-to-end + reuses the SR5 result). Read FIRST: `docs/project-management/loop-plan/study-match.md`,
`lib/presentation/features/study/controllers/match_board_controller.dart` (`MatchBoardView.boardComplete`,
`_buildBoard(boardIndex)`), `lib/presentation/features/study/screens/match_session_screen.dart`,
`lib/presentation/features/study/screens/study_session_screen.dart` (the WP-SR5a `_finish` that finalizes
+ `pushReplacementNamed(RouteNames.studyResult)` — mirror it), `lib/app/di/study_providers.dart`
(`finalizeStudySessionUseCaseProvider`). Build:
1. In `MatchBoardController`, when the board completes (all pairs matched), advance: if more cards remain
   (`(boardIndex+1)*5 < review.total`) → rebuild the board for `boardIndex+1` (`_buildBoard`, fresh
   shuffled cells, board count advances); on the **last** board, expose a "finished" signal.
2. On finished → the screen calls `FinalizeStudySessionUseCase(sessionId)` (the Match finalize branch
   already derives terminals from the evals — WP-SM2) then `pushReplacementNamed(RouteNames.studyResult,
   {sessionId})` → the SR5 `StudyResultScreen` (reused as-is). Guard `context.mounted`.
3. The board count (`{boards_done*5 + matched}/{total}`) + board indicator update across boards. Consider
   a brief cross-fade on board change (optional; wireframe `14` §Layout board-clear).
4. Tests: a 2-board session advances after clearing board 1; the last board → finalize called + navigates
   to the result. Then **object 7 COMPLETE** → objects 8-10 (Guess/Recall/Fill) reuse this shell + result.
**WP-SM4b (deferred polish):** Shuffle & restart bar + mistake counter (ICU plural) + count-up timer.
PRECEDENCE: behavior → wireframe 14 + study-flow.md. Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c, WP-SR2b;
object-5 WP-FL2b2b (Tags).
