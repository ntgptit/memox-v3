# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 5 — Flashcard (list + editor) (IN PROGRESS; WP-FL1 + WP-FL2a + WP-FL2b1 SHIPPED
  → **WP-FL2b2 (editor Details expander) build next**).
- **Current work-package:** WP-FL2b2 — Details expander (see `loop-plan/flashcard-list-editor.md`):
  a collapsed `Details · Optional` row under the Back field; expand → tags / note (hint) / example /
  pronunciation `MxTextField`s (BE `Create/UpdateFlashcardUseCase` already accept them). Goldens
  `07`/`08` details-open. Then WP-FL2b3 (save/load state surfaces).
- **Branch:** `feat/loop-library`; latest code commits `ce07ee1` (WP-FL2a), `583d347` (WP-FL2b1).
- **Last verify:** PASS (code chain, guard 0 errors) — marker bound to the WP-FL2b1 tree.

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
| 5 | Flashcard (list + editor) | IN PROGRESS — FL3 (reorder) + FL4 (delete) + **FL1 (SRS subtitle `94de1f4`)** + **FL2a (editor shell `ce07ee1`)** + **FL2b1 (edit delete `583d347`)** SHIPPED (ui-parity PASS). **WP-FL2b2 (Details expander) + WP-FL2b3 (save/load states) remain** before DONE. |
| 6 | Study — Review | BUILD (greenfield FE; BE ready; split route→gate→shell→grade→result) |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6) |

## Next action

**Build WP-FL2b2 (editor Details expander)** in `flashcard_editor_body.dart`:
1. Under the Back field, add a collapsed `Details · Optional` row (chevron + label) — a tap toggles
   the expander open/closed (local hook state).
2. Expanded → `MxTextField`s for example / pronunciation / hint (note) + a tag input. BE:
   `CreateFlashcardUseCase`/`UpdateFlashcardUseCase` already accept `exampleSentence` / `pronunciation`
   / `hint` / `tags`; wire them into `save()` (and prefill from `card` in edit).
3. Tests: expander toggles; fields prefill in edit; save passes the Details fields. Goldens `07`/`08`
   details-open (light+dark). Check spec `07`/`08` for the exact field set + tag-chip pattern.
Then **WP-FL2b3** (save/load state surfaces: saving spinner, save-failed banner, `08` loading + full
load-error via a single-card read path). After object 5 is evidence-confirmed DONE → **object 6
(Study — Review, greenfield, BE ready)**: CHẺ route → entry gate → session create/resume → review
shell → grade → result. Do NOT defer for greenfield.
