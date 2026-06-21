# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 4 — Deck detail (RE-AUDIT-PENDING; advance here next iteration).
- **Current work-package:** none in flight (objects 1–3 DONE).
- **Branch:** `feat/loop-library`; commits `5c16d05` (WP-L10), `ecbd6cd` (WP-FD10), `db3d948` (WP-FD11).
- **Last verify:** PASS — object-3 re-audit (folder_detail + breadcrumb tests, 21 pass) needed no
  code change; object 3 evidence-confirmed DONE (docs-only commit).

## Follow-up cleanups (logged, not blocking)

- Shared-dock dedup: `LibrarySearchDock` + `FolderDetailSearchDock` are near-identical (dock chrome
  + a provider-synced field). Extract a shared `MxScopedSearchDock({child})` once both consumers are
  stable. (`MxSearchDock` stays separate — its onChanged-only API can't host the synced field.)
- Search-mode app-bar icons: kit Decks/loaded states show only overflow (folder) / sort (library);
  the search-toggle + sort icons are kept as post-redesign affordances (documented variance). A
  future pass could hide search+sort while `searching` to match the mock exactly — apply to BOTH
  Library + folder together.

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
| 4 | Deck detail | RE-AUDIT-PENDING (next) |
| 5 | Flashcard (list + editor) | RE-AUDIT-PENDING |
| 6 | Study — Review | BUILD (greenfield FE; BE ready; split route→gate→shell→grade→result) |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6) |

## Next action

Re-audit object 4 (Deck detail) — read `loop-plan/deck-detail.md`, `specs/06-*.md` (8 states; deck
actions also host in `04`) + shots, audit BE+FE via `Explore`. The deck-detail surface is the
flashcard list screen (`lib/presentation/features/decks/**`) — header/stats, card rows with SRS
state, deck overflow (rename/move/delete/reorder), 8 states. Run `tool/verify` on deck/flashcard
tests + `ui-parity-checker` (golden↔`06` shots). Watch for the same app-bar-swap-vs-dock search
class already fixed in objects 1–2. Confirm or find gaps; build the first eligible gap; advance only
when object 4 is evidence-confirmed DONE.
