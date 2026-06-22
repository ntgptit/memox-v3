# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 10 — Study — Fill — **objects 6 (Review) + 7 (Match) + 8 (Guess) + 9 (Recall) are
  COMPLETE** (all playable end-to-end). Object 10 reuses the session shell + the SR5 result + the SRS
  finalization. **Fill is the only TypedAnswer mode** (`FillStudyModeStrategy extends
  TypedAnswerStudyModeStrategy`, `evaluate(input, expected, hintUsed, markCorrect)` — strict trim-only
  match, hint-taint + mark-correct cap at `recovered`, WBS 4.5.8 Implemented). Audit FE-readiness, then CHẺ.
  Plans: `loop-plan/study-{review,match,guess,recall}.md` (anchors).
- **Current work-package:** **OBJECT 9 (Recall) — COMPLETE (WP-RC1, binary flip-card self-grade).**
  Audit-first corrected a wrong cursor assumption: Recall is a **flip-card self-grade** (`RecallStudyModeStrategy
  extends BinaryGradeStudyModeStrategy`), NOT typed free-recall (that's Fill). `?mode=recall` →
  `RecallSessionScreen` (S94); front prompt → **Show answer** reveals the green ANSWER card → binary
  **Missed**(`forgot`)/**Got it**(`perfect`) → record + advance → last card finalizes → SR5 (`85a2c67`, S66).
  WBS 4.5.11 → Partial (WP-RC1). **Mock conflict flagged:** revealed mock shows a 3-way Missed/Partial/Got-it;
  built binary per S66 (PRECEDENCE #1) — Partial would need a grade extension + decision update.
  **NEXT: object 10 — Study — Fill (BE-first audit, then CHẺ).** Fill = typed production: show the back
  (definition/hint), type the **front** in a free-text input; strict-match `TypedAnswerStudyModeStrategy.evaluate`
  (V1 case-sensitive trim-only) → `perfect`/`forgot`, with a **Mark-correct** override + **Hint** taint both
  capping at `recovered`. BE Implemented (WBS 4.5.8) — likely FE-only. Read `docs/wireframes/17-study-session-fill.md`
  + shots + `study-flow.md` (fill row) + decision rows. Reuse the session shell + a NEW grade path (typed
  evaluate, not `mapGotItAction`) + SR5. **Deferred:** WP-RC2 (Recall countdown/timeout, S63/S64), WP-RC3
  (Recall Edit/TTS, S65); WP-SG3 (Guess long-press); WP-SM4b (Match polish); WP-SR4b-2 (Edit), WP-SR1b-2c,
  WP-SR2b; object-5 WP-FL2b2b (Tags).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `85a2c67` (WP-RC1 — Recall flip-card self-grade,
  **Recall done end-to-end**; prior `6d2ad59` WP-SG2 Guess done, `b9cec66` WP-SM5 Match done).
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
| 9 | Study — Recall | **DONE (V1, 2026-06-22).** Audit corrected the type: Recall = **flip-card self-grade** (`BinaryGradeStudyModeStrategy`), not typed. WP-RC1 (S66, S94): `?mode=recall` → `RecallSessionScreen`; front → **Show answer** → green ANSWER card → binary **Missed**(`forgot`)/**Got it**(`perfect`) → record + advance → SR5. **Playable end-to-end.** WBS 4.5.11 Partial. Mock conflict flagged (3-way Partial not built). Deferred: WP-RC2 (countdown/timeout S63/S64), WP-RC3 (Edit/TTS S65). |
| 10 | Study — Fill | **ACTIVE next — BUILD (audit-first).** Typed production (`FillStudyModeStrategy`/`TypedAnswerStudyModeStrategy.evaluate`, WBS 4.5.8 BE Implemented): show back → type the front → strict match → `perfect`/`forgot`, with Mark-correct + Hint capping at `recovered`. Reuse the session shell + a NEW typed-grade path + SR5. Wireframe `17`. |

## Next action

**Start object 10 — Study — Fill (AUDIT-FIRST, then CHẺ + build) — the LAST study mode.** Objects 6
(Review) + 7 (Match) + 8 (Guess) + 9 (Recall) are DONE end-to-end. Fill = typed **production**: show the
**back** (definition / hint), type the **front** in a free-text input; the answer is graded by a strict
evaluator — `FillStudyModeStrategy extends TypedAnswerStudyModeStrategy`, `evaluate(input, expected,
hintUsed, markCorrect)` (V1 case-sensitive, trim-only) → `perfect` / `forgot`, with a **Mark-correct**
override + **Hint** taint both capping at `recovered`. This is the **only** typed mode + the only one that
emits `recovered`. **BƯỚC 1 audit (TRUST POLICY — confirm by evidence):**
1. Read `docs/wireframes/17-study-session-fill.md` + the shots (`shots/INDEX.md` — likely `16-study-fill`
   given the offset) + `docs/business/study/study-flow.md` (the `fill` row + `recovered` grammar) +
   decision rows for fill.
2. Audit the **Fill BE**: confirm `FillStudyModeStrategy.evaluate` (WBS 4.5.8) + how `recovered` is
   persisted (does `RecordStudySessionAnswerUseCase` take the evaluated `AttemptResult` directly, incl.
   `recovered`?). Grep `lib/domain/study/modes/` + `study_repository*` for `evaluate`/`recovered`/Fill.
   Likely **FE-only** (the evaluator is built). The grade is NOT `mapGotItAction` — it's the typed
   `evaluate(...)`, so the controller differs from Recall/Guess (no binary tap; a text submit).
3. CHẺ into slices (`?mode=fill` → shell + text input → submit→evaluate→reveal correct/wrong + Mark-correct
   + Hint → record `evaluate` result → advance → reuse SR5). Mirror the Guess/Recall slicing. Watch the
   mock↔wireframe offset-numbering + the mock↔doc behavior-conflict pattern (Recall had a 3-grade mock vs
   binary doc — re-check Fill's mock against the documented evaluate grammar before building).
PRECEDENCE: behavior → study-flow.md + wireframe 17 win over mock; mock wins VISUAL (no pill, blue
progress). Reuse the session shell, exit-confirm, `MxLinearProgress`, the SR5 result + finalize.
**Deferred:** WP-RC2 (Recall countdown/timeout S63/S64), WP-RC3 (Recall Edit/TTS S65); WP-SG3 (Guess
long-press); WP-SM4b (Match polish); WP-SR4b-2 (Edit), WP-SR1b-2c, WP-SR2b; object-5 WP-FL2b2b (Tags).
Do NOT defer for greenfield.
