# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 6 — Study — Review (greenfield FE; BE fully ready) — **owner redirected the
  loop here (2026-06-22) ahead of object-5's last node WP-FL2b2b (Tags), which is parked.** Entered
  via BƯỚC 2 (re-audit + plan): the prior DEFER is **overturned** (greenfield→split, flip-vs-swipe→
  PRECEDENCE #1 swipe wins, "shipped" drift→fixed). See `loop-plan/study-review.md`.
- **Current work-package:** **WP-SR1a + WP-SR1b-1 SHIPPED** (study routes + entry-gate controller/
  screen + session placeholder + the `today` route + `?study_type=` override via canonical
  `StudyType.storageValue`/`fromStorage`). **WP-SR1b-2 builds next:** the **8-variant per-reason empty
  matrix** (replace `_blockedBody`'s generic surface with deck-no-cards / *-no-due / today-all-done /
  all-buried / all-suspended / today-no-content → dedicated icon/title/message/CTA per wireframe `12`)
  + a start-over confirm dialog. Then WP-SR2 shell+card → WP-SR3 swipe-grade → WP-SR4 exit/actions →
  WP-SR5 finalize→result(17, 6 states). BE all Implemented.
- **Parked (object 5):** WP-FL2b2b (Tags chip input) — the only remaining object-5 node; resume
  after Study per owner. Object 5 otherwise evidence-confirmed through WP-FL2b3b.
- **Branch:** `feat/loop-library`; latest code commit `c5b2a25` (WP-SR1a; prior `ddca661` Study plan,
  `d3aa162` WP-FL2b3b).
- **Last verify:** PASS (code chain, guard 0 errors) — marker bound to the WP-SR1a tree. 7 gate
  tests + 4 goldens; nav-flow / wireframe-12 / decision S27 drift corrected on build.

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
| 6 | Study — Review | **ACTIVE — BUILD (greenfield FE; BE ready).** WP-SR1a + WP-SR1b-1 SHIPPED (study routes + entry gate + session placeholder + today route + study_type override; WBS 4.1.2 Implemented). Next: WP-SR1b-2 (8-variant empty matrix), then WP-SR2..SR5. Swipe-grade per PRECEDENCE #1 (mock-12 flip = visual gap). |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6; reuse SR2 shell + SR5 result) |

## Next action

**Build WP-SR1b-2 (per-reason empty matrix)** — object 6 (WP-SR1a + WP-SR1b-1 shipped the gate core +
the today route + `study_type` override). Read `docs/wireframes/12-study-entry-gate.md` §"empty state
matrix render" + `docs/business/study/study-flow.md` (empty-scope matrix):
- Replace `_blockedBody`'s generic `MxEmptyState` with a switch over the 8 `StudyScopeEmptyReason` →
  dedicated icon/title/message/CTA per wireframe `12`: deckNoCards → 🃏 "No cards in this deck." + Add
  flashcards (push `flashcardCreate`, deck scope); deck/folderNoDueCards → ✓ "All caught up!" + "Next
  due in {relativeTime}" (from `nextDueAt`) + Study new instead (re-enter gate `?study_type=new_cards`);
  folderNoCards; todayAllDone → 🎉 streak + Done (pop); todayNoContent → 🃏 Create your first deck;
  allBuried → 🌙 + Study new instead + Done; allSuspended → 🔇 + View suspended cards. ARB per variant
  (en+vi). Goldens per reason (light+dark). A start-over **confirm dialog** before cancel+create (S28).
Then WP-SR2 (shell+card) → WP-SR3 (swipe-grade) → WP-SR4 (exit/actions) → WP-SR5 (finalize→result 17,
6 states). Parked: object-5 WP-FL2b2b (Tags) — resume after Study per owner. Do NOT defer for greenfield.
