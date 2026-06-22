# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 8 — Study — Guess — **objects 6 (Review) + 7 (Match) are COMPLETE** (playable
  end-to-end). Objects 8-10 reuse the SR2/Match session shell + the SR5 result + the SRS finalization;
  each adds its own grade grammar. Audit the Guess BE first (does `StudyMode.guess` have an option-set
  builder / read model? — see `study_mode_strategy.dart` `GuessStudyModeStrategy`), then CHẺ. Plans:
  `loop-plan/study-review.md` (Review anchor) + `loop-plan/study-match.md` (Match anchor).
- **Current work-package:** **OBJECT 8 (Guess) — WP-SG1 SHIPPED (shell).** Audit found the Guess BE
  Implemented (WBS 4.5.6 `buildOptions`, no drift) → FE-only. `?mode=guess` → `GuessSessionScreen` (S94);
  `GuessSessionController` builds the per-card option set; prompt card (front + reading) + static lettered
  option grid + ✕/progress/count + states (`88f906a`). WBS 4.5.7 Partial. **NEXT: WP-SG2 — select-to-grade
  + advance + finalize→result.** Tap an option → `isCorrect` → `RecordStudySessionAnswerUseCase(studyMode:
  guess, result: perfect|forgot)`; reveal the correct (green) + the wrong pick (red); auto-advance
  (`AppMotion.*`) to the next card; the last card → `FinalizeStudySessionUseCase` → `pushReplacementNamed(studyResult)`
  (reuse SR5). The controller needs a `grade(optionId)` + advance (mirror Review's `StudySessionController.grade`
  + the SR5a `_finish`). Tests per branch (correct/wrong + record + advance; last card → finalize→route) +
  goldens (answered-correct, answered-wrong). Then **object 8 COMPLETE** → object 9 (Recall). **WP-SM4b
  (Match deferred polish):** Shuffle & restart + mistake counter + timer. Deferred: WP-SR4b-2 (Edit),
  WP-SR1b-2c, WP-SR2b; object-5 WP-FL2b2b (Tags).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `88f906a` (WP-SG1 — Guess shell; prior
  `b9cec66` WP-SM5 Match done, `a2ac51b` WP-SM4).
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
| 7 | Study — Match | **DONE (V1, 2026-06-22).** BE (WP-SM1a/1b/2, 4.5.4 Implemented, S54–S57) + FE board shell (WP-SM3, S94) + tap-pair FSM (WP-SM4, S95) + **progression + finalize→result (WP-SM5, S96/S97)** — **playable end-to-end** (`?mode=match` → board → match all pairs across boards → finalize → SR5 result). WBS 4.5.5 Implemented (V1). Deferred polish: WP-SM4b (Shuffle&restart / mistake counter / timer). |
| 8 | Study — Guess | **ACTIVE — BE done; FE in progress.** BE Implemented (4.5.6 `buildOptions`); **shell SHIPPED (WP-SG1, S94)** — `?mode=guess` → `GuessSessionScreen` (prompt + lettered option grid). WBS 4.5.7 Partial. Next: **WP-SG2 (select-to-grade + record + auto-advance + finalize→result → object 8 COMPLETE)**. |
| 9–10 | Study — Recall/Fill | BUILD (reuse the session shell + SR5 result; each adds its grade grammar) |

## Next action

**Build WP-SG2 — select-to-grade + advance + finalize → result (FE)** (object 8; the shell WP-SG1 + the
Guess BE are done — this makes Guess end-to-end). Read FIRST: `docs/project-management/loop-plan/study-guess.md`,
`lib/presentation/features/study/controllers/guess_session_controller.dart` (`GuessView`, `_viewFor`),
`lib/presentation/features/study/screens/guess_session_screen.dart` (the `_OptionRow` to make tappable),
`lib/presentation/features/study/controllers/study_session_controller.dart` (Review's `grade`+advance to
mirror), `lib/presentation/features/study/screens/study_session_screen.dart` (the SR5a `_finish` —
finalize + `pushReplacementNamed(studyResult)`), `docs/wireframes/15-study-session-guess.md` §States
(reveal + auto-advance) + the mock `14-study-guess` answered state (green ✓ correct / red ✗ wrong + Next).
Build:
1. `GuessSessionController.grade(GuessOption picked)`: record via `RecordStudySessionAnswerUseCase`
   (`studyMode: StudyMode.guess`, `result: picked.isCorrect ? perfect : forgot`); hold a "revealed"
   state on the view (the picked option + which is correct) so the screen colors the correct option
   green ✓ and a wrong pick red ✗; then advance (`currentIndex+1`, rebuild options) — manual **Next**
   and/or an auto-advance countdown (`AppMotion.*`). On the last card → finalize + route to SR5 result.
2. `_OptionRow` gains tap + the correct/wrong/idle/disabled states (reuse the Match status-color
   pattern); a **Next** button after answering (mock). Reuse `_finish` mirroring SR5a.
3. Tests per branch (correct → perfect+advance; wrong → forgot+reveal; last card → finalize→route) +
   goldens (answered-correct, answered-wrong). Then **object 8 COMPLETE** → object 9 (Recall).
PRECEDENCE: behavior → study-flow.md + wireframe 15; mock wins visual (PRECEDENCE #2). **Deferred:**
WP-SM4b (Match: Shuffle&restart/timer/mistake counter), WP-SR4b-2 (Edit), WP-SR1b-2c, WP-SR2b; object-5
WP-FL2b2b (Tags).
