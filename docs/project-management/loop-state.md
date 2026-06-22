# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **🎉 MILESTONE — ALL 5 STUDY MODES COMPLETE (V1, 2026-06-22):** Review (6) + Match (7) + Guess (8) +
  Recall (9) + Fill (10) all play end-to-end on one shared spine (session shell + exit-confirm +
  `MxLinearProgress` + the `?mode=` dispatch + SRS finalization + the SR5 result). The study-mode chain
  (objects 6-10) is done. Plans: `loop-plan/study-{review,match,guess,recall,fill}.md`.
- **Current work-package:** **OBJECT 10 (Fill) — COMPLETE (WP-FI1, typed check/grade).** `?mode=fill` →
  `FillSessionScreen` (S94, `HookConsumerWidget` + `useMxTextSubmitState`); hint card (back) → free-text
  field → **Check** strict trim-only match of the front via `FillStudyModeStrategy.evaluate` (`studyMode:
  fill`) → `perfect`(✓+Next) / `forgot`(CORRECT ANSWER + Retry/Next) → record + advance → last card
  finalizes → SR5 (`a6f37b5`, S67/S68/S70/S71/S74). WBS 4.5.9 → Partial. **Conflicts flagged:** mock grades
  the reading (built front-graded per S68); the `recovered` path (Hint/Mark-correct) deferred WP-FI2.
  **NEXT — the study-mode chain is done; pick from the remaining backlog (greenfield first):**
  1. **Object-5 WP-FL2b2b (Tags chip input)** — the only remaining greenfield object node (parked "resume
     after Study" per owner; Study is now done). Read `docs/business/tags/tag-system.md` +
     `docs/contracts/usecase-contracts/tag.md` + the flashcard-edit wireframe. **Audit-first** (does the
     tag BE/read model exist?).
  2. **Study-mode polish (deferred WP-*2/3):** WP-FI2 (Fill: Hint + Mark-correct → `recovered`, countdown,
     Finish callout S73, finalize-fail S75, Edit/TTS), WP-RC2 (Recall countdown/timeout S63/S64), WP-RC3
     (Recall Edit/TTS S65), WP-SG3 (Guess long-press card-actions), WP-SM4b (Match Shuffle&restart/timer/
     mistake counter), WP-SR4b-2 (Review Edit), WP-SR1b-2c, WP-SR2b.
  Recommend **Tags first** (greenfield > polish, per the loop's outer→inner order).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — now the **top** next item (Study done). Object 5
  otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `a6f37b5` (WP-FI1 — Fill typed check/grade,
  **Fill done → all 5 modes done**; prior `85a2c67` WP-RC1 Recall done, `6d2ad59` WP-SG2 Guess done).
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
| 10 | Study — Fill | **DONE (V1, 2026-06-22).** WP-FI1 (S67/S68/S70/S71/S74, S94): `?mode=fill` → `FillSessionScreen`; hint (back) → type the front → **Check** strict trim-only match via `FillStudyModeStrategy.evaluate` → `perfect`(✓+Next) / `forgot`(CORRECT ANSWER + Retry/Next) → record + advance → SR5. **Playable end-to-end.** WBS 4.5.9 Partial. Front-graded per S68 (mock reading-grading flagged). Deferred WP-FI2: Hint/Mark-correct (`recovered`), countdown, Finish callout, finalize-fail, Edit/TTS. |

## Next action

**The study-mode chain (objects 6-10) is COMPLETE — all 5 modes play end-to-end.** Pick the next item
from the remaining backlog, **greenfield before polish** (the loop's outer→inner order):

**RECOMMENDED NEXT — Object-5 WP-FL2b2b (Tags chip input) (AUDIT-FIRST, then CHẺ).** The only remaining
greenfield object node; it was parked "resume after Study", and Study is now done.
1. Read `docs/business/tags/tag-system.md` + `docs/contracts/usecase-contracts/tag.md` + the
   flashcard create/edit wireframe (the tag field) + `where-is.md` row for tags.
2. **Audit the Tag BE (TRUST POLICY):** does a tag entity + read model + usecases (`tag.md`) + a
   `tags`/`flashcard_tags` schema exist? Grep `lib/domain/entities/`, `lib/domain/usecases/`,
   `lib/data/datasources/local/drift/` for `tag`. **If the BE is missing, the first slice is BE**
   (entity → schema + migration → repo/usecase → tests) per the BE-first invariant; if present, FE-only
   (a tag chip input on flashcard create/edit). Watch the mock↔doc conflict pattern the study modes hit.
3. CHẺ into slices; reuse existing chip / input components; copy → ARB; schema change ⇒ migration +
   schema/migration docs + test in the same commit.

**ALTERNATIVE — study-mode polish (deferred):** WP-FI2 (Fill: Hint + Mark-correct → `recovered`, the
0.8s countdown, the last-card Finish callout S73, finalize-fail S75, Edit/TTS), WP-RC2 (Recall countdown/
timeout S63/S64), WP-RC3 (Recall Edit/TTS S65), WP-SG3 (Guess long-press card-actions), WP-SM4b (Match
Shuffle&restart/timer/mistake counter), WP-SR4b-2 (Review Edit), WP-SR1b-2c, WP-SR2b.

PRECEDENCE unchanged: behavior → business docs + decision tables win over the mock; mock wins VISUAL;
tokens; copy → ARB. Do NOT defer for greenfield.
