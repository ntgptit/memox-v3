# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 5 — Flashcard (list + editor) (IN PROGRESS; WP-FL1 + WP-FL2a + WP-FL2b1 +
  WP-FL2b2 + **WP-FL2b3a (saving spinner + save-failed banner)** SHIPPED → **WP-FL2b3b (load-state
  surfaces) build next**, then WP-FL2b2b Tags — the last two object-5 nodes).
- **Current work-package:** WP-FL2b3b (see `loop-plan/flashcard-list-editor.md`): the `07`/`08`
  loading skeleton + full load-error. The editor currently reuses `flashcardListStreamProvider`; a
  **single-card read path** (find one card by id) lets a deep-link edit (`/…/:id/edit`) show a real
  loading skeleton + load-error surface instead of the list stream's bare shell. Then WP-FL2b2b
  (Tags chip input) → object 5 evidence-DONE → object 6 (Study — Review, greenfield, BE ready).
- **Branch:** `feat/loop-library`; latest code commit `6437f66` (WP-FL2b3a; prior `23a4193` WP-FL2b2).
- **Last verify:** PASS (code chain, guard 0 errors) — marker bound to the WP-FL2b3a tree. 3-reviewer
  fan-out clean (ui-parity PASS, drift none, code-reviewer fixes folded).

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
| 5 | Flashcard (list + editor) | IN PROGRESS — FL3/FL4 + **FL1 SRS subtitle** + **FL2a editor shell** + **FL2b1 edit-delete** + **FL2b2 Details expander** + **FL2b3a saving+save-failed (`6437f66`)** SHIPPED (ui-parity PASS). **WP-FL2b3b (load states) + WP-FL2b2b (Tags input) remain** before DONE. |
| 6 | Study — Review | BUILD (greenfield FE; BE ready; split route→gate→shell→grade→result) |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6) |

## Next action

**Build WP-FL2b3b (editor load-state surfaces)** — the last non-base `07`/`08` states (saving +
save-failed shipped in `6437f66`). Read spec `07`/`08` loading + load-error layout first (PRECEDENCE #2):
- The editor reuses `flashcardListStreamProvider(deckId)` and finds the card by id in the list; for a
  **deep-link edit** (`/…/:flashcardId/edit`) this yields no loading skeleton / proper load-error.
- Add a **single-card read path** (find one flashcard by id — repo method + use case + provider) so the
  editor screen drives the `08` loading skeleton + full load-error surface (the bare async shells in
  `flashcard_editor_screen.dart` exist; flesh them to the mock). G1-split: BE read path first, then FE.
Then **WP-FL2b2b** (Tags chip input — the `07`/`08` Tags section, the last object-5 node). After
object 5 is evidence-confirmed DONE → **object 6 (Study — Review, greenfield, BE ready)**: CHẺ
route → entry gate → session create/resume → review shell → grade → result. Do NOT defer for greenfield.
