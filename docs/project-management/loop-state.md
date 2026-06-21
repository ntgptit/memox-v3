# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 5 — Flashcard (list + editor) (IN PROGRESS; WP-FL1 SHIPPED → **WP-FL2a (editor
  screen shell) build next**).
- **Current work-package:** WP-FL2a — editor screen shell (scope locked in
  `loop-plan/flashcard-list-editor.md`): new routes `flashcardCreate`/`flashcardEdit`
  (route_names/paths + router) + `flashcard_editor_screen.dart` (X/Cancel + Save app bar + breadcrumb
  + FRONT/BACK + front-required validation + create/update use case — BE ready), wiring
  `runAddCard`/`runEditCard` to push the route instead of the dialog. Details expander + full 07/08
  state matrix = WP-FL2b.
- **Branch:** `feat/loop-library`; latest code commits `c16ea0a` (WP-D2), `94de1f4` (WP-FL1).
- **Last verify:** PASS (code chain, guard 0 errors) — marker bound to the WP-FL1 tree.

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
| 5 | Flashcard (list + editor) | IN PROGRESS — WP-FL3 (reorder) + WP-FL4 (delete) verified; **WP-FL1 (card-row SRS subtitle) SHIPPED** (`94de1f4`, ui-parity PASS; chip = mock visual gap). **WP-FL2a (editor screen shell) remains** before DONE. |
| 6 | Study — Review | BUILD (greenfield FE; BE ready; split route→gate→shell→grade→result) |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6) |

## Next action

**Build WP-FL2a (card editor screen shell)** — scope in `loop-plan/flashcard-list-editor.md`:
1. Routes: add `flashcardCreate` (deckId) + `flashcardEdit` (deckId, cardId) to `route_names.dart` +
   `route_paths.dart`; register in the router (`app_router.dart` / folder/deck routes).
2. New `flashcard_editor_screen.dart` (MxScaffold): app bar X/Cancel (left) + Save (right) + breadcrumb
   + FRONT + BACK `MxTextField`s + front-required validation; create vs edit by presence of cardId.
3. Wire `runAddCard`/`runEditCard` (`flashcard_list_actions.dart`) to `pushNamed` the route instead of
   `showCardDialog`; remove/retire the dialog. BE: `CreateFlashcardUseCase`/`UpdateFlashcardUseCase`
   already support all fields.
4. Tests: editor widget (create empty/valid/save, edit loaded/save) + goldens for `07` (create empty +
   valid) and `08` (edit loaded) base states. Details expander + full state matrix = WP-FL2b.
Advance to object 6 (greenfield Study build, BE ready) only when object 5 is DONE.
