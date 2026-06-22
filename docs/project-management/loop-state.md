# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 6 — Study — Review (greenfield FE; BE fully ready) — **owner redirected the
  loop here (2026-06-22) ahead of object-5's last node WP-FL2b2b (Tags), which is parked.** Entered
  via BƯỚC 2 (re-audit + plan): the prior DEFER is **overturned** (greenfield→split, flip-vs-swipe→
  PRECEDENCE #1 swipe wins, "shipped" drift→fixed). See `loop-plan/study-review.md`.
- **Current work-package:** **WP-SR4a SHIPPED — exit-confirm.** `✕` mid-session with `answeredCount>0`
  → `MxConfirmDialog` ("progress saved, resume later") before pop; pops directly when nothing answered.
  Gate (WP-SR1a..1b-2b) + session shell+card (WP-SR2) + grade (WP-SR3) + exit-confirm (WP-SR4a) done.
  **WP-SR4b builds next — card-actions sheet:** long-press the card → a bottom sheet (Edit / Bury until
  tomorrow / Suspend, shared sheet §25); Bury → `BuryStudySessionCardUseCase`, Suspend →
  `SuspendStudySessionCardUseCase` (both exist) → re-queue (remove card + advance, or invalidate the
  review); Edit → push the flashcard editor (returnable). Then WP-SR5 finalize→result(17, 6 states).
  Deferred polish: WP-SR1b-2c (gate CTAs), WP-SR2b (language labels).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `2983088` (WP-SR4a; prior `8549fb6` WP-SR3,
  `b69c2eb` WP-SR2).
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
| 6 | Study — Review | **ACTIVE — BUILD (greenfield FE; BE ready).** Gate (WP-SR1a..1b-2b) + session shell+card (WP-SR2) + swipe-grade (WP-SR3) + **exit-confirm (WP-SR4a)** SHIPPED (WBS 4.1.2 Implemented, 4.5.3 Partial). Next: **WP-SR4b (card-actions sheet)**, then WP-SR5 finalize→result(17). Deferred: WP-SR1b-2c (gate CTAs), WP-SR2b (language labels). Swipe per PRECEDENCE #1 (mock-12 flip = visual gap). |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6; reuse SR2 shell + SR5 result) |

## Next action

**Build WP-SR4b (card-actions sheet)** — WP-SR4a shipped the exit-confirm; now the long-press actions.
Read `docs/wireframes/13-study-session-review.md` §Actions + `docs/wireframes/25-shared-bottom-sheets.md`
§card-actions + `docs/business/study-actions/bury-suspend.md`:
- Long-press the card → a bottom sheet (reuse the shared §25 sheet primitive — check
  `docs/wireframes/25-shared-bottom-sheets.md` for the existing `Mx*` sheet): **Edit** (push the
  flashcard editor for `currentItem.flashcardId`'s deck, returnable), **Bury until tomorrow**
  (`BuryStudySessionCardUseCase`), **Suspend card** (`SuspendStudySessionCardUseCase`).
- After bury/suspend: **re-queue** — the simplest correct path is to add a controller method that
  removes the current item from the in-memory `StudySessionView` (advance without counting it as
  answered) AND fires the use case; or `ref.invalidate(studySessionReviewProvider)` so the reload
  excludes the now-buried/suspended card. Confirm which keeps `answeredCount` correct.
- Decision rows; tests per action (sheet opens; bury/suspend invoke + re-queue; edit navigates).
Then WP-SR5 (finalize→result 17, 6 states). Deferred: WP-SR1b-2c (gate CTAs), WP-SR2b (language
labels); object-5 WP-FL2b2b (Tags). Do NOT defer for greenfield.
