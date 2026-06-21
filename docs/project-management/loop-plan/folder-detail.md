---
last_updated: 2026-06-21
object: Folder (detail)
loop_order: 2 of 10 (outer→inner)
route: /library/folder/:id
status: IN PROGRESS (core FE Implemented; 3 deck/folder-management FE work-packages eligible)
---

# Loop plan — Object 2: Folder (detail)

FE-completion loop plan. Sources audited:
`docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md`,
`docs/wireframes/05-folder-detail.md`,
`docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md` §`04 — Folder detail`,
WBS rows 3.2.x / 2.7.2 / 2.8.2 / 2.9.2 / 2.19.2 / 2.5.2 / 2.10.2 / 3.2.3.

## Objective

Bring Folder Detail to full FE parity with the kit `04` mock and complete the deck/folder
management surface it hosts. The screen shell + 6 states + create/rename/delete are built;
the open FE work is **deck move** and **manual reorder** (both have Implemented BE).

## Audit — current implementation

| Area | As-built | Verdict |
|---|---|---|
| Screen shell + app bar (search / sort / overflow) | `folder_detail_screen.dart` | Implemented |
| Breadcrumb ancestry dock | `MxBreadcrumb` + `buildLibraryBreadcrumb` | Implemented |
| States body (decks / subfolders / empty-unlocked / search-empty / loading / error) | `folder_detail_body.dart` | Implemented |
| Stats summary card | `folder_stats_card.dart` | Implemented |
| Content-aware create FAB (deck / subfolder / none) | `folder_detail_screen._fab` | Implemented |
| Create deck (FAB → dialog) | `deck_create_dialog.dart` (WBS 2.7.2) | Implemented |
| Create subfolder | `runCreateSubfolder` | Implemented |
| Deck row + tap → flashcard list | `deck_tile.dart` | Implemented |
| Deck actions sheet — Rename / Delete | `deck_actions_sheet.dart`, `folder_detail_actions.dart` (WBS 2.8.2 / 2.9.2) | Implemented |
| Folder actions (Rename / Move / Delete) | `folder_detail_actions.dart` → shared sheet + picker | Implemented |
| Per-scope sort sheet | `content_sort_sheet.dart` (WBS 2.23.1) | Implemented |
| Delete-folder auto-pop on viewed-folder removal | `folder_detail_screen` `ref.listen` | Implemented |
| Goldens (kit-04 states × light+dark) | `test/presentation/features/folders/folder_detail_test.dart` | Implemented |

## MAP — kit `04` states (`shots/INDEX.md` §04)

| Mock state | Component / behavior | Scope |
|---|---|---|
| Decks | `folder_detail_body` decks-mode list of `deck_tile` | Current |
| Subfolders | `folder_detail_body` subfolders-mode list | Current |
| Empty / unlocked | empty state w/ both create CTAs | Current |
| Search empty | `folder_detail_search` no-results | Current |
| Loading | skeleton | Current |
| Error | `MxErrorState` + Retry | Current |
| Delete confirm | `MxConfirmDialog` destructive | Current |
| Move sheet | folder move picker (`folder_move_picker_sheet.dart`) | Current (folder); **deck move missing** |

## Gap-checklist (work-package queue, Depends-on order)

- [x] WP-FD1 — Folder detail screen + 6 states + nav (WBS 3.2.2) — **Implemented**
- [x] WP-FD2 — Deck create FE (FAB → dialog) (WBS 2.7.2) — **Implemented**
- [x] WP-FD3 — Deck rename FE (sheet → dialog → BE) (WBS 2.8.2) — **Implemented**
- [x] WP-FD4 — Deck delete FE (sheet → confirm → BE) (WBS 2.9.2) — **Implemented**
- [x] **WP-FD5a — Deck move-targets BE (WBS 2.19.2, vertical slice)** — **Implemented (2026-06-21).**
      Verified deck move IS in the kit mock (`04-folder-detail--move-sheet` lists the deck's current
      parent as a selectable destination → it's a deck move, not a folder move). Built the read path:
      `DeckMoveTarget` model + `DeckMoveBlock.lockedToSubfolders` enum, `FolderRepository
      .getDeckMoveTargets(deckId)` (all folders, no Library-root; annotated `isCurrentParent` +
      `block` when content_mode == subfolders, mirroring `_deckParentGuard` / `getFolderMoveTargets`),
      `GetDeckMoveTargetsUseCase` + DI. BE tests (repo: not-found + current-parent/decks/unlocked/
      subfolders-locked annotation; use case forwarding). Contract `deck.md` §GetDeckMoveTargetsUseCase.
      verify PASS.
- [x] **WP-FD5b — Deck move FE (WBS 2.19.2)** — **Implemented (2026-06-21).** Added
      `DeckAction.move` + a Move row to `deck_actions_sheet.dart`; `runDeckActions` loads targets via
      `LibraryActionController.deckMoveTargets` → `showDeckMovePicker` (new
      `deck_move_picker_sheet.dart`, blocked/current rows disabled with reason) → `moveDeck` →
      localized snackbar. 4 ARB keys (en+vi). Behavior widget tests (sheet Move row + picker
      selectable/blocked/current/move). verify PASS. **Variance:** the picker reuses the established
      **tap-to-select** `folder_move_picker_sheet` pattern, not the kit's radio + "Move here" confirm
      styling — keeping one picker paradigm app-wide; the radio+confirm restyle is a deferred
      refinement that should apply to BOTH pickers together (documented in wireframe 25).
- [ ] WP-FD6 — Deck reorder FE (WBS 2.10.2) — **DEFER (spec-unclear: no UI design).** Reorder
      *behavior* is specified (`reorderDecksUseCaseProvider` wired), but the kit ships only the 8
      folder-detail states (no reorder/drag shot), the wireframe as-built banner explicitly defers
      reorder, the business docs give no drag-handle/affordance spec, and the app has no reorderable-
      list pattern. Building it means inventing the drag affordance + restructuring the approved
      grouped-card loaded state (regressing its goldens) with no mock/golden to validate against —
      mock-doc-conflict, a standing DEFER exception even under the vertical-slice rule. Needs an
      approved reorder-state mock + an `MxReorderableList` design decision.
- [ ] WP-FD7 — Folder (subfolder) reorder FE (WBS 2.5.2) — **DEFER (spec-unclear: no UI design).**
      Same blocker as WP-FD6.
- [ ] WP-FD8 — Folder detail new-vs-due study split (WBS 3.2.3) — **DEFER (mock-doc-conflict).**
      Audited against `shots/04-folder-detail--decks--{light,dark}.png` (2026-06-21): the rebuilt
      calm-app mock shows a **Decks / Cards / Due** stats card and deck rows with `{n} cards · last
      {time} ago` + due badge — **no `{n} new` count, no new badge, no Study-new / Review-due CTAs.**
      3.2.3's new-vs-due UI is the prior iteration the rebuild dropped (same pattern as the Library
      mastery/newCount enrichments). The `FolderSummary.newCount` field already shipped (WP-L6b) but
      stays read-model-only. Building the badges/CTAs = inventing UI not in the mock.
- [ ] **WP-FD9 — Deck-row "last studied" line (new gap)** — eligible vertical slice. The mock deck
      rows show `{n} cards · last {time} ago`, but `deck_tile.dart` renders only `{n} cards` →
      the last-studied timestamp is a **missing visible mock element**. Build: extend
      `folderDeckSummaries` with `last_studied_at` = `MAX(study_session_items.answered_at)` over the
      deck's cards; `DeckSummary.lastStudiedAt`; a localized relative-time formatter (no helper
      exists yet — needs ARB plural keys for minutes/hours/days/weeks) + ARB; `deck_tile` shows
      `{n} cards · {rel}` when non-null. BE query + helper + tile tests + golden (fixed `now`).
      **NEXT.**

## Notes

- WBS rows 2.7.2 / 2.8.2 / 2.9.2 are still marked `Specified` though the code + tests are
  screen-hosted and live; flip them to Implemented when the next code work-package verifies
  (avoid a status-only flip without re-running the targeted tests).
- Object 2 leaves for object 3 (Sub-folder / nested) only after every gap-checklist item is
  Implemented or DEFERred.
- **Rules updated 2026-06-21 (vertical-slice loop):** BE (incl. schema/migration) may now be added
  to unblock FE. WP-FD5 un-DEFERred (was needs-BE) and split into BE (FD5a) + FE (FD5b). FD6/FD7
  stay DEFER — their blocker is mock-doc-conflict (no reorder design), still an exception.

## Conclusion

Object 2 is **IN PROGRESS**. Next work-package: **WP-FD5a Deck move-targets BE** (vertical slice
— new read model/use case mirroring folder-move-targets), then **WP-FD5b** FE wiring. FD6/FD7
(reorder) DEFERred for missing UI design; FD8 (new-vs-due) is a larger later slice.
