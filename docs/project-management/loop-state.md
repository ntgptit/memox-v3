# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 5 — Flashcard (list + editor) (IN PROGRESS; WP-FL1 + WP-FL2a SHIPPED →
  **WP-FL2b (editor Details + trash/delete + non-base states) build next**).
- **Current work-package:** WP-FL2b (see `loop-plan/flashcard-list-editor.md`): the editor Details
  expander (tags/note/example/pronunciation/hint — BE ready), the edit-mode **trash/delete-from-
  editor** affordance (reuse `runDeleteCard` + pop), and the `07`/`08` non-base states
  (details-open / saving / save-failed / load-error-full / delete). Likely splits into 2+ slices
  (e.g. WP-FL2b1 Details+delete, WP-FL2b2 save/load state surfaces). NOT validly deferrable
  (BE-ready, mock-specified) — build to complete object 5's editor state coverage.
- **Branch:** `feat/loop-library`; latest code commits `94de1f4` (WP-FL1), `ce07ee1` (WP-FL2a).
- **Last verify:** PASS (code chain, guard 0 errors) — marker bound to the WP-FL2a tree.

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
| 5 | Flashcard (list + editor) | IN PROGRESS — WP-FL3 (reorder) + WP-FL4 (delete) verified; **WP-FL1 (card-row SRS subtitle, `94de1f4`)** + **WP-FL2a (editor screen shell, `ce07ee1`)** SHIPPED (ui-parity PASS). **WP-FL2b (editor Details + trash/delete + non-base `07`/`08` states) remains** before DONE. |
| 6 | Study — Review | BUILD (greenfield FE; BE ready; split route→gate→shell→grade→result) |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6) |

## Next action

**Build WP-FL2b (editor Details + delete + non-base states)** — split into the smallest runnable
slices (each its own iteration, all in `flashcard_editor_body.dart`/screen):
1. **WP-FL2b1 — edit trash/delete-from-editor:** add an `Icons.delete_outline` `MxIconButton` to the
   edit app bar (before Save); tap → `runDeleteCard`-style confirm → delete → pop. Golden update `08`.
2. **WP-FL2b2 — Details expander:** a collapsed `Details` row (chevron + "Details" + "Optional") under
   the Back field; expand → tags / note (hint) / example / pronunciation `MxTextField`s (BE
   `Create/UpdateFlashcardUseCase` already accept them). Goldens `07`/`08` details-open.
3. **WP-FL2b3 — save/load state surfaces:** saving (disabled + spinner), save-failed (inline banner
   vs the current snackbar), `08` loading + full load-error (single-card read path for deep-link).
After object 5 is evidence-confirmed DONE → **object 6 (Study — Review, greenfield, BE ready)**:
CHẺ route → entry gate → session create/resume → review shell → grade → result. Do NOT defer for
greenfield.
