---
last_updated: 2026-06-21
object: Library (overview)
loop_order: 1 of 10 (outer→inner)
route: /library
status: DONE (all eligible FE Implemented; remaining gaps BE-blocked → DEFER)
---

# Loop plan — Object 1: Library (overview)

FE-completion loop plan for the outermost object. Sources audited:
`docs/business/folder/folder-management.md`, `docs/wireframes/02-library.md`,
`docs/design/screens/library-overview.visual-contract.md` (State Matrix §03a–03k),
`docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md` §`03 — Library overview`,
WBS rows 3.1.x / 2.1.2 / 2.23.1 / 3.1.3.

## Objective

Bring Library Overview to full FE parity with the kit `03` mock across all 11 states.
Audit result: **the screen is already at V1 FE parity** — every kit state is mapped to a
built widget, and every remaining visual element is gated on a read-model field that the
BE has not shipped (BE-blocked → DEFER, not FE-eligible).

## Audit — current implementation

| Area | As-built | Verdict |
|---|---|---|
| Screen shell + app-bar mode toggle (search / sort) | `library_overview_screen.dart` | Implemented |
| Search-mode app bar (field + Cancel) | `library_search_app_bar.dart`, `library_search_field.dart` | Implemented |
| States body (loading / loaded / empty / search / no-results / error) | `library_overview_body.dart` | Implemented |
| Loading skeleton | `library_loading_skeleton.dart` | Implemented |
| Folder row (tinted tile + meta + chevron) | `library_folder_tile.dart`, `folder_icon_tile.dart` | Implemented |
| Grouped list-card + inset hairlines | `library_overview_body._groupedCard`, `mx_divider.dart` | Implemented |
| Create folder (FAB + empty CTA → dialog, color+icon pickers) | `folder_create_dialog.dart`, `library_create_folder_action.dart` | Implemented (WBS 2.1.2) |
| Overflow action sheet (rename/move/import/delete) | `library_folder_actions_sheet.dart` | Implemented |
| Rename / Delete / Move modals | `folder_rename_dialog.dart`, `MxConfirmDialog`, `folder_move_picker_sheet.dart` | Implemented |
| Per-scope sort sheet | `content_sort_sheet.dart`, `library_sort_provider.dart` | Implemented (WBS 2.23.1) |
| Root anchor dock | `library_root_anchor.dart` | Implemented (WBS 3.1.3) |
| Goldens (6 states × light+dark) | `test/presentation/features/folders/library_overview_test.dart` | Implemented |

## MAP — all 11 kit states (`shots/INDEX.md` §03)

| Mock state | Component / behavior | Scope |
|---|---|---|
| `03a` Loaded | grouped folder card + root anchor + FAB + sort/search icons | Current |
| `03b` Loading | `LibraryLoadingSkeleton` | Current |
| `03c` Empty | `MxEmptyState` + Create-folder CTA | Current |
| `03d` Error | `MxErrorState` + Retry | Current |
| `03e` Search | `LibrarySearchAppBar` + filtered rows + `{n} FOLDERS` overline | Current |
| `03f` Overflow sheet | `showFolderActionsSheet` (rename/move/import/delete) | Current |
| `03g` Create folder | `showFolderCreateDialog` (name + color + icon pickers) | Current |
| `03h` Rename folder | `folder_rename_dialog.dart` | Current |
| `03i` Move folder | `folder_move_picker_sheet.dart` | Current |
| `03j` Archive folder | overflow Archive action **not exposed** | Future (no archive BE) |
| `03k` Delete folder | `MxConfirmDialog` destructive + cascade | Current |
| Derived: Search no-results | `LibrarySearchNoResultsSection` | Current |

## Gap-checklist (work-package queue)

Every FE work-package for this object is already shipped; the only open items are
BE-blocked enrichment fields, deferred (not FE-eligible). No eligible FE work-package
remains → object is **DONE** for the FE loop.

- [x] WP-L1 — Library overview screen + 6 states (WBS 3.1.2) — **Implemented**
- [x] WP-L2 — Folder create FE (dialog + color/icon pickers, FAB + empty CTA) (WBS 2.1.2) — **Implemented**
- [x] WP-L3 — Per-scope content sort sheet wired to Library scope (WBS 2.23.1) — **Implemented**
- [x] WP-L4 — Root anchor dock (WBS 3.1.3) — **Implemented**
- [x] WP-L5 — Overflow action sheet + rename/move/delete modals — **Implemented**
- [ ] WP-L6 — Due-summary card (`dueToday`) — **DEFER (needs-BE: read-model field absent)**
- [ ] WP-L7 — Folder mastery bar (`mastery`) — **DEFER (needs-BE)**
- [ ] WP-L8 — Folder new-card badge (`newCount`) — **DEFER (needs-BE)**
- [ ] WP-L9 — Deck-digest subtitle (`subtitle`) — **DEFER (needs-BE)**
- [ ] WP-L10 — `03j` Archive folder action + dialog — **DEFER (needs-schema/needs-BE: no archive column/use case)**

Note: Folder-row tap → folder detail navigation is **object 2 (Folder detail, WBS 3.2.2)**,
not Library; the interim tap→action-sheet keeps the chevron live and is correct for this object.

## Conclusion

Object 1 (Library overview) is **DONE** for the FE-completion loop: all eligible FE
work-packages Implemented + verified + docs-synced; the 5 remaining gaps (WP-L6…L10) are
BE/schema-blocked and recorded in `docs/project-management/loop-deferred.md`. Next object
(outer→inner): **Folder (detail)**.
