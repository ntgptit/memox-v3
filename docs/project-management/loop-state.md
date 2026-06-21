# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 2 — Folder detail (RE-AUDIT IN PROGRESS; WP-FD10 done, **WP-FD11 next**).
- **Current work-package:** WP-FD11 — move-sheet picker goldens (deck + folder move picker have
  no golden; ui-parity Gap #1). Build next, then object 2 is evidence-confirmed DONE.
- **Branch:** `feat/loop-library`; commits `5c16d05` (WP-L10), `ecbd6cd` (WP-FD10).
- **Last verify:** PASS (code chain, guard 0 errors) — marker bound to the WP-FD10 tree.

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
| 2 | Folder detail | RE-AUDIT IN PROGRESS — code+test+golden verified; search-state diverged (app-bar swap vs kit bottom dock) → fixed in WP-FD10 (`FolderDetailSearchDock`). **WP-FD11 (move-sheet goldens) remains** before DONE. |
| 3 | Sub-folder (nested) | RE-AUDIT-PENDING |
| 4 | Deck detail | RE-AUDIT-PENDING |
| 5 | Flashcard (list + editor) | RE-AUDIT-PENDING |
| 6 | Study — Review | BUILD (greenfield FE; BE ready; split route→gate→shell→grade→result) |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6) |

## Next action

Re-audit object 2 (Folder detail) — read `loop-plan/folder-detail.md`, `specs/04-folder-detail.md`
(+ shots), audit BE+FE via `Explore`, run `tool/verify` on folder tests + `ui-parity-checker`
(golden↔`04` shots, 8 states). Confirm or find gaps; build the first eligible gap; advance only when
object 2 is evidence-confirmed DONE.
