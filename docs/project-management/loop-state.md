# Loop state — FE-completion vertical-slice loop

> Cold-read pointer. One small file the next loop iteration reads FIRST (cheap) before anything else.
> Keep terse. Update at the end of every iteration. Tick/status here is a HINT, not proof (TRUST POLICY).

last_updated: 2026-06-22

## Cursor

- **Active object:** 5 — Flashcard (list + editor) (RE-AUDIT IN PROGRESS; both prior DEFERs
  OVERTURNED → **WP-FL1 (card-row SRS subtitle) build next**, then WP-FL2a editor screen shell).
- **Current work-package:** WP-FL1 — see `loop-plan/flashcard-list-editor.md` for the locked scope
  (read-model `progressById` + `{front} — {back}` title + `Box N · due in Xd`/`New · not studied`
  meta + ARB; chip = PRECEDENCE-resolved mock visual gap; isolated tile golden for the now-dependent
  due-in, screen golden uses New cards).
- **Branch:** `feat/loop-library`; latest code commits `c16ea0a` (WP-D2); plan commit pending.
- **Last verify:** PASS (docs chain) — object-5 re-audit plan locked; no code shipped this iteration.

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
| 5 | Flashcard (list + editor) | RE-AUDIT IN PROGRESS — WP-FL3 (reorder) + WP-FL4 (delete) verified; both prior DEFERs OVERTURNED (re-audit: chip = mock visual gap per PRECEDENCE #1; editor screen mock-specified + BE-ready). **WP-FL1 (subtitle) + WP-FL2a (editor shell) to BUILD.** |
| 6 | Study — Review | BUILD (greenfield FE; BE ready; split route→gate→shell→grade→result) |
| 7–10 | Study — Match/Guess/Recall/Fill | BUILD (independent FE grammar; not blocked by object 6) |

## Next action

**Build WP-FL1 (card-row SRS subtitle)** — scope is locked in `loop-plan/flashcard-list-editor.md`:
1. `FlashcardListDetail` += `progressById: Map<id, FlashcardProgress>`; repo
   (`flashcard_repository_impl.dart:108`) maps the already-loaded `FlashcardProgressRow`s → domain
   `FlashcardProgress` (`due_at` int-ms → UTC DateTime) and passes them through (no schema).
2. ARB en+vi: `flashcardStateNew`, `flashcardStateBoxDueIn(box,days)`, `flashcardStateBoxDueToday(box)`.
3. `flashcard_tile.dart`: title `{front} — {back}`, meta = SRS subtitle (inject `now`); NO chip
   (PRECEDENCE #1 mock visual gap — business model is New/Due only).
4. `flashcard_list_body.dart`: pass `detail.progressById[card.id]` + now to the tile.
5. Tests: BE (read-model carries progress), FE isolated `flashcard_tile` golden (due-in variants, fixed
   now) + update screen loaded golden (New cards → deterministic `New · not studied`).
Then WP-FL2a (editor screen shell). Advance to object 6 (Study) only when object 5 is DONE.
