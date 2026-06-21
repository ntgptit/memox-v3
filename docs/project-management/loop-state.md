# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 5 — Flashcard (list + editor) (IN PROGRESS; WP-FL1 + WP-FL2a + WP-FL2b1 +
  WP-FL2b2 + WP-FL2b3a (saving + save-failed) + **WP-FL2b3b (loading skeleton + load-error/Retry)**
  SHIPPED → **WP-FL2b2b (Tags chip input) build next — the LAST object-5 node**).
- **Current work-package:** WP-FL2b2b (see `loop-plan/flashcard-list-editor.md`): the `07`/`08` Tags
  section — a chip row of the card's tags + an "Add tag" affordance (add/remove). Business model has
  tags (`flashcard-management.md` §238); edit currently **preserves** tags untouched. The editor's
  create/update already forward `tags`; wire a tag-editing UX (chip display + add-tag input/validate
  via `TagValidator`) into `FlashcardEditorForm`. After this → object 5 evidence-DONE → object 6
  (Study — Review, greenfield, BE ready): CHẺ route → entry gate → session create/resume → review
  shell → grade → result.
- **Branch:** `feat/loop-library`; latest code commit `d3aa162` (WP-FL2b3b; prior `6437f66` WP-FL2b3a,
  `34ae424` l10n rename).
- **Last verify:** PASS (code chain, guard 0 errors) — marker bound to the WP-FL2b3b tree. 3-reviewer
  fan-out folded (code-reviewer APPROVE; ui-parity blocker breadcrumb-during-loading fixed; drift = §10 logged here).

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
| 6 | Study — Review | BUILD (greenfield FE; BE ready; split route→gate→shell→grade→result) |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6) |

## Next action

**Build WP-FL2b2b (editor Tags chip input)** — the LAST object-5 node. Read the `07`/`08` Tags
section in the specs + `docs/business/tags/tag-system.md` + `docs/business/flashcard/flashcard-management.md` §238 first (PRECEDENCE #2 for visual; #1 for validation):
- The editor's create/update **already forward `tags`** (BE done; edit currently preserves them
  untouched). Wire a tag-editing UX into `FlashcardEditorForm`: a chip row of the card's current
  tags (each removable) + an "Add tag" affordance that validates via `TagValidator` (rows C20/C21 —
  add appends + normalizes on save, tapping a chip removes it).
- Use the existing `Mx*` chip/input components (check `component-visual-contract.md` for the chip
  primitive; do NOT invent a new shared chip if one exists). Dirty-tracking must include the tag set
  (it already does for the discard-confirm). Tests: add/remove chip, save persists tags, golden of
  the Tags section (light+dark). Decision rows C20/C21 (currently TBD) get their tests.
After object 5 is evidence-confirmed DONE → **object 6 (Study — Review, greenfield, BE ready)**: CHẺ
route → entry gate → session create/resume → review shell → grade → result. Do NOT defer for greenfield.
