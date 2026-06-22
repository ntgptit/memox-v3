# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Context — the 5 study modes (objects 6-10)** all play end-to-end on one shared spine (session shell +
  exit-confirm + `MxLinearProgress` + the `?mode=` dispatch + SRS finalization + the SR5 result). Plans:
  `loop-plan/study-{review,match,guess,recall,fill}.md`. See [[study-mode-chain-complete]] memory.
- **🎉 MILESTONE — ALL GREENFIELD OBJECTS COMPLETE (2026-06-22):** the 5 study modes (objects 6-10) AND
  object 5 (library FE, incl. the last node WP-FL2b2b Tags chip input) are done. No greenfield object node
  remains — only the deferred study-mode **polish** backlog (the WP-*2/3 items below).
- **Current work-package:** **OBJECT 5 (Tags) — COMPLETE (WP-FL2b2b, `13e0fe8`).** The flashcard editor's
  Details § TAGS chip row (`#` + name + ✕ remove) + a "+ Add tag" inline field; add validates + lowercases
  + dedupes (`TagValidator`); the editor manages the full set + **replaces** wholesale on save — wired into
  **both** create (previously omitted tags — a real bug) + update. WBS 2.15.2 → Implemented; C20/C21. The
  tag-assignment BE (Flashcard.tags, Create/UpdateFlashcardUseCase, TagValidator) was already built → FE-only.
  **NEXT — only the deferred study-mode polish remains (pick the highest-value):**
  1. **WP-FI2 (Fill polish)** — Hint char-reveal + Mark-correct (both → `recovered`, S69/S72), the 0.8s
     auto-advance countdown, the last-card Finish callout (S73), finalize-fail surface (S75), Edit/TTS.
     The richest remaining item; the evaluator already supports `recovered`. Plan: `loop-plan/study-fill.md`.
  2. **WP-RC2** (Recall Show-answer countdown + auto-reveal-on-timeout, S63/S64; needs a `recallAnswerTimeout`
     constant), **WP-RC3** (Recall Edit/TTS, S65), **WP-SG3** (Guess long-press card-actions), **WP-SM4b**
     (Match Shuffle&restart/timer/mistake counter), **WP-SR4b-2** (Review Edit), WP-SR1b-2c, WP-SR2b.
  Recommend **WP-FI2 first** (closes the most spec gaps + the only `recovered`-bearing mode). Audit-first
  as always; re-confirm the Fill front-vs-reading conflict with the owner before extending Fill.
- **Parked (object 5):** none — WP-FL2b2b shipped (`13e0fe8`); object 5 (library FE) is complete.
- **Polish progress:** Fill `recovered` path **complete** — **WP-FI2a (Mark-correct, S72)** (`f1625b1`) +
  **WP-FI2b (Hint-taint, S69)** (`3466204`): a wrong answer can be overridden, and a hint reveals a
  `·`-masked front prefix that caps a clean match at `recovered` (retained across Retry). Remaining WP-FI2:
  **FI2c** auto-advance countdown (S68), **FI2d** last-card Finish callout (S73) + finalize-fail (S75),
  **FI2e** Edit/TTS.
- **Branch:** `feat/loop-library`; latest code commit `3466204` (WP-FI2b — Fill Hint; prior
  `f1625b1` WP-FI2a Mark-correct, `13e0fe8` WP-FL2b2b Tags / object 5 done).
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
| 5 | Flashcard (list + editor) | **DONE (2026-06-22).** FL3/FL4 + FL1 + FL2a shell + FL2b1 delete + FL2b2 Details + FL2b3a saving+save-failed + FL2b3b loading+load-error + **FL2b2b Tags chip input (`13e0fe8`, WBS 2.15.2)** — the editor manages the card's tag set (validate/lowercase/dedup, replace-wholesale on save). Library FE complete. |
| 6 | Study — Review | **DONE (2026-06-22).** Gate (WP-SR1a..1b-2b) + session (WP-SR2) + swipe-grade (WP-SR3) + exit-confirm (WP-SR4a) + card-actions Bury/Suspend (WP-SR4b) + finalize→result V1 incl. save-failed/defensive (WP-SR5a+5b) — **Review loop end-to-end + code+test+golden verified.** WBS 4.1.2/4.7.2 Implemented; 4.5.3 Partial (WP-SR2b language labels + WP-SR4b-2 Edit deferred polish). |
| 7 | Study — Match | **DONE (V1, 2026-06-22).** BE (WP-SM1a/1b/2, 4.5.4 Implemented, S54–S57) + FE board shell (WP-SM3, S94) + tap-pair FSM (WP-SM4, S95) + **progression + finalize→result (WP-SM5, S96/S97)** — **playable end-to-end** (`?mode=match` → board → match all pairs across boards → finalize → SR5 result). WBS 4.5.5 Implemented (V1). Deferred polish: WP-SM4b (Shuffle&restart / mistake counter / timer). |
| 8 | Study — Guess | **DONE (V1, 2026-06-22).** BE Implemented (4.5.6 `buildOptions`) + shell (WP-SG1, S94) + **select-to-grade (WP-SG2, S60–S62)** — tap an option → binary record (correct→`perfect`/wrong→`forgot`), reveal green ✓ / red ✗ + dim others, auto-advance countdown footer (`AppMotion.guessReveal*`, tap-to-skip), last card finalizes → SR5 result. **Playable end-to-end.** WBS 4.5.7 Implemented (V1). Deferred: WP-SG3 (long-press option card-actions). |
| 9 | Study — Recall | **DONE (V1, 2026-06-22).** Audit corrected the type: Recall = **flip-card self-grade** (`BinaryGradeStudyModeStrategy`), not typed. WP-RC1 (S66, S94): `?mode=recall` → `RecallSessionScreen`; front → **Show answer** → green ANSWER card → binary **Missed**(`forgot`)/**Got it**(`perfect`) → record + advance → SR5. **Playable end-to-end.** WBS 4.5.11 Partial. Mock conflict flagged (3-way Partial not built). Deferred: WP-RC2 (countdown/timeout S63/S64), WP-RC3 (Edit/TTS S65). |
| 10 | Study — Fill | **DONE (V1, 2026-06-22).** WP-FI1 (S67/S68/S70/S71/S74, S94): `?mode=fill` → `FillSessionScreen`; hint (back) → type the front → **Check** strict trim-only match via `FillStudyModeStrategy.evaluate` → `perfect`(✓+Next) / `forgot`(CORRECT ANSWER + Retry/Next) → record + advance → SR5. **Playable end-to-end.** WBS 4.5.9 Partial. Front-graded per S68 (mock reading-grading flagged). Deferred WP-FI2: Hint/Mark-correct (`recovered`), countdown, Finish callout, finalize-fail, Edit/TTS. |

## Next action

**All greenfield objects are COMPLETE** — the 5 study modes (6-10) + object 5 (library FE, incl. Tags).
Only the deferred study-mode **polish** backlog remains. Pick the highest-value item (audit-first as always):

**RECOMMENDED NEXT — continue WP-FI2 (Fill polish); WP-FI2a (Mark-correct) + WP-FI2b (Hint) are done —
the `recovered` path is complete.** Remaining slices (CHẺ ~1/iter), read `loop-plan/study-fill.md` +
`docs/wireframes/17-study-session-fill.md` + decision S68/S73/S75: **WP-FI2c — 0.8s auto-advance countdown**
on correct (S68, reuse Guess's `_CountdownFooter`/timer pattern + `AppMotion`; add a `recallAnswerTimeout`-
style constant if needed); **WP-FI2d — last-card Finish callout** (S73) + explicit **finalize-fail** surface
(S75 — note: all modes currently tolerate finalize failure + route regardless, so S75 is a cross-cutting
change; consider applying to all modes or keep Fill-only + flag); **WP-FI2e — Edit ✎ / TTS 🔊**. Each adds
UI the redesign mock dropped → build the documented behavior + flag the visual variance (as FI2a/b did).
**Re-confirm the Fill front-vs-reading mock↔doc conflict + the S20 `recovered`-redefinition drift with the
owner before extending further.** (Other backlog: WP-RC2/RC3, WP-SG3, WP-SM4b, WP-SR4b-2.)

**ALSO PENDING (pick by value):** WP-RC2 (Recall Show-answer countdown + auto-reveal-on-timeout, S63/S64;
needs a `recallAnswerTimeout` constant), WP-RC3 (Recall Edit/TTS, S65), WP-SG3 (Guess long-press
card-actions), WP-SM4b (Match Shuffle&restart/timer/mistake counter), WP-SR4b-2 (Review Edit + deckId),
WP-SR1b-2c, WP-SR2b; the create-editor **save-and-add-another** (WBS 2.11.2 remaining).

PRECEDENCE unchanged: behavior → business docs + decision tables win over the mock; mock wins VISUAL;
tokens; copy → ARB. Audit-first (TRUST POLICY) on every pickup.
