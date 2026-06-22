# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **🏁 FE-COMPLETION LOOP DONE (owner ruling 2026-06-22): the redesign mock is AUTHORITATIVE.** All
  autonomous-safe work is committed; the owner ruled the remaining backlog: affordances the mock dropped
  are **Rejected/out-of-scope** (the redesign intentionally simplified each mode), conflicts resolve
  toward the **mock + the built behavior**, and the **FE is complete**. The loop is **STOPPED** — do not
  self-pace further. See [[fe-loop-complete-mock-authoritative]] + [[study-mode-chain-complete]].
- **Built FE (kept):** 5 study modes end-to-end (Review/Match/Guess/Recall/Fill) + SR5 result; object 5
  library FE incl. per-card Tags; Fill `recovered` (Mark-correct WP-FI2a + Hint WP-FI2b) + 0.8s
  auto-advance (WP-FI2c); shared `MxScopedSearchDock` (deduped 3 docks). Spine: session shell +
  exit-confirm + `MxLinearProgress` + `?mode=` dispatch + SRS finalization + SR5.
- **Rejected per the ruling (do NOT build):** Fill Finish-callout (S73) + Edit/TTS (WP-FI2e); Recall
  countdown/auto-reveal (WP-RC2, S63/S64) + Edit/TTS (WP-RC3, S65); Guess long-press (WP-SG3); Match
  Shuffle&restart/timer/mistake (WP-SM4b); Review Edit (WP-SR4b-2), WP-SR1b-2c, WP-SR2b.
- **Conflicts resolved (mock + built):** Fill grades the FRONT (mock's "reading" copy not adopted);
  Recall is BINARY (mock's "Partial" Rejected); progress bars BLUE (wireframe green-family superseded);
  finalize-fail = route-to-SR5 + save-failed banner (WP-SR5b; S9/S10/S75 stay-on-session superseded);
  `recovered` = single hint/mark-correct pass (redefined). **Accepted deviation:** Library/Folder
  search-mode keeps the search-toggle icon (exit affordance; the mock hides it — exit-rewire not worth it).
- **Still-deferred (NOT a mock-cut, separate owner decision):** WP-FL1 card-row SRS-state chip — its
  box→state mapping is genuinely undocumented (needs a spec, not a build call).
- **Polish progress:** Fill `recovered` path + auto-advance **done** — **WP-FI2a (Mark-correct, S72)**
  (`f1625b1`) + **WP-FI2b (Hint-taint, S69)** (`3466204`) + **WP-FI2c (0.8s auto-advance countdown, S68)**
  (`42104ce`; a depleting bar over Next via `AppMotion.fillAutoAdvance` + `TweenAnimationBuilder.onEnd`,
  widget-driven). **WP-FI2d finalize-fail (S75) is covered-by-design** (audit 2026-06-22): Fill inherits
  the shared route-to-SR5 + `failed_to_finalize` save-failed banner (WP-SR5b) like every mode — NOT a
  todo; the S9/S10/S75 "stay-on-session" wording is superseded (flagged for owner). Remaining Fill: only
  the **low-value** last-card Finish callout (S73) + **FI2e** Edit/TTS (large / mock-dropped). **Fill's
  high-value polish is DONE.**
- **Branch:** `feat/loop-library`; latest code commit `42104ce` (WP-FI2c — Fill auto-advance; prior
  `3466204` WP-FI2b Hint, `f1625b1` WP-FI2a Mark-correct).
- **Last verify:** PASS (code chain, guard 0 errors) — WP-SR1b-2b tree + review-fix. **Fan-out now
  complete:** docs-drift PASS; code-reviewer APPROVE + ui-parity PASS (re-ran after the 529 overload
  cleared). Folded 2 Importants: fallback-Back `fullWidth`, + a "Study new instead" navigation test
  (`_reenterWithNewCards`). ~25 gate tests + 10 goldens.

## Follow-up cleanups (logged, not blocking)

- ✅ **DONE (2026-06-22):** Shared-dock dedup — extracted `MxScopedSearchDock({child})`
  (`lib/presentation/shared/widgets/inputs/mx_scoped_search_dock.dart`); `LibrarySearchDock` +
  `FolderDetailSearchDock` + `FlashcardListSearchDock` (a **third** near-identical dock the fan-out caught)
  are now thin wrappers. Behavior-preserving (no golden changes); test in `mx_inputs_test.dart`.
  (`MxSearchDock` stays separate — its onChanged-only API can't host the synced field.)
- ✅ **RESOLVED (2026-06-22, mock-authoritative ruling) — accepted deviation:** the Library/Folder
  search-mode app bar keeps the **search-toggle** icon (the mock `03`/`04` search state hides it,
  keeping only sort). Audit found the toggle is the *only* exit from search mode (the dock ✕ clears the
  term but does not deactivate), so hiding it would trap the user without an exit rewire. Kept as the
  explicit exit affordance; the mock's icon-hiding is **not adopted** (the rewire isn't worth it).
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

**None — the FE-completion loop is COMPLETE and STOPPED (owner ruling 2026-06-22: mock authoritative).**
All autonomous-safe work is committed; the remaining wireframe affordances the redesign mock dropped are
**Rejected/out-of-scope** (see the Cursor block + [[fe-loop-complete-mock-authoritative]]). The conflict
flags are **resolved** toward the mock + the built behavior. There is no further loop work to self-pace.

**If the owner later wants more:** the only non-rejected open item is **WP-FL1** (card-row SRS-state chip)
— blocked on a documented box→state mapping (thresholds + chip tokens), not a mock-cut; and the
create-editor **save-and-add-another** (WBS 2.11.2 remaining) if desired. Both need a fresh decision/spec.
