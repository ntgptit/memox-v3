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
- [ ] **WP-FD5 — Deck move FE (WBS 2.19.2)** — eligible (BE `move_deck_usecase.dart` Implemented).
      Add a `Move` action to `deck_actions_sheet.dart` (`DeckAction.move`) → a decks-allowing
      folder picker (reuse `folder_move_picker_sheet` pattern / move-targets use case) →
      `MoveDeckUseCase`. Snackbar on success/failure. Widget tests + goldens (sheet w/ move row,
      picker). **Depends-on: none open. NEXT.**
- [ ] WP-FD6 — Deck reorder FE (WBS 2.10.2) — eligible (BE `2.10.1` Implemented). Manual-sort
      drag reorder of deck rows → reorder use case; persist `sort_order`. Only active when sort
      mode = manual. Widget test for reorder gesture.
- [ ] WP-FD7 — Folder (subfolder) reorder FE (WBS 2.5.2) — eligible (BE `2.5.1` Implemented).
      Manual-sort drag reorder of subfolder rows → reorder use case. Widget test.
- [ ] WP-FD8 — Folder detail new-vs-due study split (WBS 3.2.3) — **DEFER (needs-schema:
      migration v11 + `new_count` read model + data fix; BE+FE row, BE not shipped).**

## Notes

- WBS rows 2.7.2 / 2.8.2 / 2.9.2 are still marked `Specified` though the code + tests are
  screen-hosted and live; flip them to Implemented when the next code work-package verifies
  (avoid a status-only flip without re-running the targeted tests).
- Object 2 leaves for object 3 (Sub-folder / nested) only after WP-FD5…FD7 are Implemented or
  DEFERred. WP-FD8 is already DEFER.

## Conclusion

Object 2 is **IN PROGRESS**. Next work-package: **WP-FD5 Deck move FE (2.19.2)** — smallest,
fully-unblocked, reuses the move-picker pattern. Then WP-FD6 / WP-FD7 (reorder).
