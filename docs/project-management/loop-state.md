# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 6 — Study — Review (greenfield FE; BE fully ready) — **owner redirected the
  loop here (2026-06-22) ahead of object-5's last node WP-FL2b2b (Tags), which is parked.** Entered
  via BƯỚC 2 (re-audit + plan): the prior DEFER is **overturned** (greenfield→split, flip-vs-swipe→
  PRECEDENCE #1 swipe wins, "shipped" drift→fixed). See `loop-plan/study-review.md`.
- **Current work-package:** **Entry gate functionally COMPLETE** — WP-SR1a + 1b-1 + 1b-2a + **1b-2b**
  SHIPPED (routes + gate + today + `?study_type=` + per-reason empty matrix + Study-new/Done CTAs +
  start-over confirm). WP-SR1b-2c (scope-specific CTA polish: Add-flashcards / View-suspended / Open-
  folder / Create-deck + "Next due in {X}" + streak) is **deferred below WP-SR2** (lower value).
  **WP-SR2 builds next — the review session shell + card** (`study_session_screen.dart`, replacing the
  placeholder): app bar (`✕` + **blue** progress bar + `{answered}/{total}`) + the card (front-side
  label from `deck.target_language`, front large, divider, back-side label, back, example pill when
  present) via `LoadStudySessionReviewUseCase`; loading/error/empty. No grading yet (WP-SR3). Then
  WP-SR3 swipe-grade → WP-SR4 exit/actions → WP-SR5 finalize→result(17, 6 states).
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `935e630` (WP-SR1b-2b; prior `427d392` WP-SR1b-2a,
  `c5b2a25` WP-SR1a).
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
| 6 | Study — Review | **ACTIVE — BUILD (greenfield FE; BE ready).** Entry gate functionally COMPLETE (WP-SR1a + 1b-1 + 1b-2a + 1b-2b: routes + gate + today + study_type + empty matrix + CTAs + start-over confirm; WBS 4.1.2 Implemented). Next: **WP-SR2 (review session shell + card)**, then SR3 swipe-grade / SR4 / SR5. WP-SR1b-2c CTA polish deferred. Swipe per PRECEDENCE #1 (mock-12 flip = visual gap). |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6; reuse SR2 shell + SR5 result) |

## Next action

**Build WP-SR2 (review session shell + card)** — the entry gate is functionally complete; this is the
first real study surface. Read `docs/wireframes/13-study-session-review.md` + `docs/business/study/study-flow.md`
+ the spec `specs/12-study-review.md` (PRECEDENCE #2 visual; #1 behavior = both-sides, no reveal):
- Replace the `StudySessionScreen` placeholder: load `LoadStudySessionReviewUseCase(sessionId)` →
  `StudySessionReview` (session + ordered items + answeredCount/total + firstUnansweredIndex) via an
  `AppAsyncBuilder` (loading skeleton / load-error / empty). App bar: `✕` (exit) + a **blue** progress
  bar (`answered/total`, recognition family) + `{answered} / {total}` count — no mode pill (Review is default).
- The card (current item = `items[firstUnansweredIndex]`): front-side label from `deck.target_language`
  (KOREAN/ENGLISH/… fallback FRONT) → front (display-large, centered) → divider → back-side label
  (MEANING/BACK) → back → **example pill** when `exampleSentence` non-empty. NO `note`/`pronunciation`/
  `hint` (Phase 1). NO reveal/Show-answer step (both sides visible). Tokens + `Mx*`; copy → ARB.
- No grading yet (static current card) — swipe-grade is WP-SR3. Goldens for the card (light+dark).
Then WP-SR3 (swipe-grade) → WP-SR4 (exit/actions) → WP-SR5 (finalize→result 17, 6 states). Deferred:
WP-SR1b-2c (gate CTA polish); object-5 WP-FL2b2b (Tags). Do NOT defer for greenfield.
