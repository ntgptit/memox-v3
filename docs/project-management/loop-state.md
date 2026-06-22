# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 7 — Study — Match (next inner study mode) — **object 6 (Study — Review) is
  COMPLETE** (all WP-SR slices shipped; Review loop end-to-end). Objects 7-10 reuse the SR2 session
  shell + SR5 result; each adds its own grade grammar. See `loop-plan/study-review.md` (the shared
  Review anchor) + read the Match wireframe/shots before building.
- **Current work-package:** **OBJECT 7 (Match) — WP-SM3 SHIPPED (board shell FE).** `?mode=match` route
  dispatch (S94) → `MatchSessionScreen` (mock-aligned: ✕ + blue progress + `{matched}/{total}` count,
  "Match the pairs" title + prompt, static 2×5 board-fresh grid, "{matched} matched · {left} left" line,
  states) over `studySessionReviewProvider` (`6abbe2b`). A **mock↔wireframe conflict** (no pill / no
  board-indicator in the kit shot) was caught by ui-parity + reconciled to the mock (PRECEDENCE #2).
  WBS 4.5.5 → Partial. **NEXT: WP-SM4 (FE) — board grid + tap-pair state machine.** Add the select→
  match/wrong FSM (idle / selected=solid blue / matched=green ✓ / wrong-flash ~600ms red), the
  Fisher-Yates shuffle (cells currently row-paired), one-selection-at-a-time, lock matched; each pair
  (right/wrong) → `RecordMatchEvaluationUseCase` (append-only, persist immediately); the **Shuffle &
  restart** bar + mistake counter (ICU plural) + count-up timer (M:SS). Needs a board-state controller
  (a new MatchBoardController) for the board/selection state. Tests per cell state + grade→record + goldens (mid-board/matched/
  wrong-flash). Then WP-SM5 (board progression + reuse SR5 finalize/result → object 7 COMPLETE). Plan:
  `docs/project-management/loop-plan/study-match.md`. Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c, WP-SR2b;
  object-5 WP-FL2b2b (Tags).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `6abbe2b` (WP-SM3 — Match board shell FE; prior
  `219c272` WP-SM2 Match BE complete, `a99cdc8` WP-SM1b).
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
| 7 | Study — Match | **ACTIVE — BE complete; FE in progress.** BE (WP-SM1a/1b/2, WBS 4.5.4 Implemented, S54–S57) + **FE board shell (WP-SM3, WBS 4.5.5 Partial, S94)** SHIPPED (`?mode=match` → `MatchSessionScreen`, mock-aligned). Next: **WP-SM4 (tap-pair FSM + shuffle + `RecordMatchEvaluationUseCase` wiring)** → WP-SM5 (progression + reuse SR5 result). Plan: `loop-plan/study-match.md`. |
| 8–10 | Study — Guess/Recall/Fill | BUILD (independent FE grammar; reuse SR2 shell + SR5 result) |

## Next action

**Build WP-SM4 — board grid + tap-pair state machine (FE)** (object 7; the shell WP-SM3 + the whole BE
are done). Read FIRST: `docs/project-management/loop-plan/study-match.md`, `docs/wireframes/14-study-session-match.md`
(§Layout mid-board, §Components — cell states + Shuffle&restart bar + timer + mistake counter),
`docs/system-design/MemoX Design System/ui_kits/mobile/shots/13-study-match--matching*` (the cell-state
tints), `lib/presentation/features/study/screens/match_session_screen.dart` (the shell to fill),
`lib/domain/usecases/study/record_match_evaluation_usecase.dart` + `lib/app/di/study_providers.dart`
(`recordMatchEvaluationUseCaseProvider`). Build:
1. A new board-state controller (MatchBoardController, `@riverpod` family on sessionId) holding the board state: the current board's
   **10 cells** (5 fronts + 5 backs of the board's 5 cards, **Fisher-Yates shuffled** — seed for testability),
   each cell's state (idle / selected / matched), the current selection, mistake count.
2. The grid cells become interactive: **one selection at a time** — tap one → `selected` (solid blue);
   tap a second → if a valid pair (same flashcard) → both `matched` (green ✓, locked); else **wrong-flash**
   (~600ms red on both) then deselect. Each pair-tap (right OR wrong) → `RecordMatchEvaluationUseCase.call`
   (append-only, persisted immediately; pass boardIndex/pairId/cell ids/expected ids/isCorrect).
3. The **Shuffle & restart** secondary button (mock) + the mistake counter (ICU plural) + the count-up
   timer (M:SS, non-blocking). Update the `{matched}/{total}` count + the "{matched} matched · {left} left"
   line live as pairs lock.
4. Widget tests per cell state + the select→match / select→wrong→record paths (fake the use case) +
   goldens (mid-board: one selected + one matched; wrong-flash). PRECEDENCE: behavior → wireframe 14 +
   study-flow.md; one-selection-only, matched-locked, no TTS on cells, **blue** family.
Then WP-SM5 (board progression: clear → next board → last board finalizes via `FinalizeStudySessionUseCase`
→ reuse the SR5 result route → **object 7 COMPLETE**). Deferred: WP-SR4b-2 (Edit), WP-SR1b-2c, WP-SR2b;
object-5 WP-FL2b2b (Tags).
