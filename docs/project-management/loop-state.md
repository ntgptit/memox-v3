# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 9 — Study — Recall — **objects 6 (Review) + 7 (Match) + 8 (Guess) are COMPLETE**
  (all playable end-to-end). Objects 9-10 reuse the session shell + the SR5 result + the SRS finalization;
  each adds its own grade grammar. Audit the Recall BE first (`StudyMode.recall` — a `TypedAnswerStudyModeStrategy`
  leaf; does an answer-check / normalization read model exist? — see `study_mode_strategy.dart`), then CHẺ.
  Plans: `loop-plan/study-{review,match,guess}.md` (anchors).
- **Current work-package:** **OBJECT 8 (Guess) — COMPLETE (WP-SG1 shell + WP-SG2 select-to-grade).** Tap
  an option → `RecordStudySessionAnswerUseCase` (correct→`perfect`/wrong→`forgot`, `studyMode: guess`);
  reveal correct green ✓ / wrong red ✗ + dim the rest; the `_CountdownFooter` (depleting `MxLinearProgress`
  + tap-to-skip) auto-advances (`AppMotion.guessReveal*` 0.8/1.5s); last card → `FinalizeStudySessionUseCase`
  + `pushReplacementNamed(studyResult)` (reused SR5) (`6d2ad59`). WBS 4.5.7 → Implemented (V1); S60–S62.
  **NEXT: object 9 — Study — Recall (BE-first audit, then CHẺ).** Recall = typed free-recall: a prompt
  (the front) + a text field; type the back → checked against the expected answer (a `TypedAnswerStudyModeStrategy`).
  Audit the BE: does an answer **normalization/equality** read model exist (case/whitespace/diacritics fold)?
  Grep `lib/domain/study/modes/` + `study_repository*` for typed/recall/normalize; **if missing the first
  slice is BE.** Read `docs/wireframes/16-study-session-recall.md` + shots + `study-flow.md` (S63–S6x). Then
  FE reuses the session shell + `RecordStudySessionAnswerUseCase` (binary self-grade or exact-match) + SR5.
  **Deferred:** WP-SG3 (Guess long-press card-actions); WP-SM4b (Match Shuffle&restart/timer/mistake counter);
  WP-SR4b-2 (Edit), WP-SR1b-2c, WP-SR2b; object-5 WP-FL2b2b (Tags).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `6d2ad59` (WP-SG2 — Guess select-to-grade,
  **Guess done end-to-end**; prior `88f906a` WP-SG1 shell, `b9cec66` WP-SM5 Match done).
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
| 8 | Study — Guess | **DONE (V1, 2026-06-22).** BE Implemented (4.5.6 `buildOptions`) + shell (WP-SG1, S94) + **select-to-grade (WP-SG2, S60–S62)** — tap an option → binary record (correct→`perfect`/wrong→`forgot`), reveal green ✓ / red ✗ + dim others, auto-advance countdown footer (`AppMotion.guessReveal*`, tap-to-skip), last card finalizes → SR5 result. **Playable end-to-end.** WBS 4.5.7 Implemented (V1). Deferred: WP-SG3 (long-press option card-actions). |
| 9 | Study — Recall | **ACTIVE next — BUILD (audit-first).** Typed free-recall (`TypedAnswerStudyModeStrategy`): prompt + text field; type the back → answer-check. Audit the BE (normalization/equality read model?) → BE-first if missing. Reuse the session shell + `RecordStudySessionAnswerUseCase` + SR5. Wireframe `16`. |
| 10 | Study — Fill | BUILD (reuse the session shell + SR5 result; the last grade grammar). |

## Next action

**Start object 9 — Study — Recall (AUDIT-FIRST, then CHẺ + build).** Objects 6 (Review) + 7 (Match) + 8
(Guess) are DONE end-to-end. Recall = typed **free-recall**: a prompt card (the front) + a text field;
the learner types the back → it's checked against the expected answer (a `TypedAnswerStudyModeStrategy`
leaf — the same family Fill uses). It reuses the session shell + `RecordStudySessionAnswerUseCase` + the
SR5 result. **BƯỚC 1 audit (TRUST POLICY — confirm by evidence):**
1. Read `docs/wireframes/16-study-session-recall.md` + the shots (`shots/INDEX.md` — likely `15-study-recall`
   given the offset) + `docs/business/study/study-flow.md` (recall flow + result grammar) + decision rows
   S63–S6x.
2. Audit the **Recall BE**: `StudyMode.recall` + its `TypedAnswerStudyModeStrategy`. Does an **answer
   normalization / equality** read model exist (case / whitespace / diacritics fold; "almost-correct"?)?
   Grep `lib/domain/study/modes/` + `study_repository*` + `lib/core/util/string_utils.dart` (`upperFold`)
   for typed/recall/normalize/compare. **If missing, the first slice is BE** (the answer check — pure
   domain + tests, a vertical slice) per BE-first; the grade itself reuses `RecordStudySessionAnswerUseCase`
   (exact-match → `perfect`, else `forgot`, or a self-grade per study-flow).
3. CHẺ into slices (mode dispatch `?mode=recall` → shell + text field → submit-to-grade + reveal → reuse
   SR5 finalize/result), mirroring the Guess slicing (WP-SG1 shell → WP-SG2 grade). Watch the
   mock↔wireframe offset-numbering conflict the prior audits hit (PRECEDENCE #2 mock wins visual).
PRECEDENCE: behavior → study-flow.md + wireframe 16 win over mock. Reuse the session shell, exit-confirm,
`MxLinearProgress`, `AppMotion`, the SR5 result + finalize. **Deferred:** WP-SG3 (Guess long-press
option card-actions); WP-SM4b (Match: Shuffle&restart/timer/mistake counter); WP-SR4b-2 (Edit), WP-SR1b-2c,
WP-SR2b; object-5 WP-FL2b2b (Tags). Do NOT defer for greenfield.
