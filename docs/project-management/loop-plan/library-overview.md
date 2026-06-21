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
- [ ] **WP-L6 — Library read-model enrichment (BE) — `dueToday` / `mastery` / `newCount` /
      `subtitle`** — eligible under the **vertical-slice rule** (BE may be added in dev). Extend the
      `watchLibraryOverview` Drift query + `LibraryOverview`/`FolderSummary` model to carry the four
      per-folder subtree aggregates the mock (shot `03a`) + visual-contract §Folder Card Contract
      already specify: `dueToday` (active, non-suspended/non-buried, `due_at <= now`), `mastery`
      (`AVG(COALESCE(box_number,1))/8` over subtree), `newCount` (cards with no progress / `due_at`
      NULL), `subtitle` (`GROUP_CONCAT` of ≤3 deck names). Pure read-model query extension — **no
      schema** (dev DB has no data to migrate). BE query/repo unit tests. **NEXT.**
- [ ] WP-L7 — Due-summary card FE (`dueToday`) — depends on WP-L6. Render the non-interactive
      due-summary `MxCard` (title + `Across {n} folders · ~{m} min` subtitle + chevron) when
      `dueToday > 0`. Widget + golden.
- [ ] WP-L8 — Folder-tile enrichment FE (`mastery` bar / `newCount` badge / `subtitle`) — depends
      on WP-L6. Wire `MxLinearProgress` mastery bar, new-card badge, and deck-digest subtitle into
      `library_folder_tile.dart`, each rendered only when its field is set. Widget + golden.
- [ ] WP-L9 — `03j` Archive folder action + dialog — **DEFER (Future / needs-approval).** The
      Library visual contract marks archive **Future / out-of-scope** (no archive use case / repo /
      DAO / schema column; product scope decision, not just missing BE). Building it = inventing
      product scope; needs an approved task.

Note: Folder-row tap → folder detail navigation is **object 2 (Folder detail, WBS 3.2.2)**,
not Library; the interim tap→action-sheet keeps the chevron live and is correct for this object.

**Rules updated 2026-06-21 (vertical-slice loop):** BE may now be added to unblock FE, so the
former needs-BE DEFERs (WP-L6…L8) are re-opened as buildable read-model slices. Only WP-L9
(archive) stays DEFER — it is a Future product-scope decision, not a missing-BE gap.

## Conclusion

Object 1 (Library overview) was DONE under the FE-only rules, but the **vertical-slice rules
(2026-06-21)** re-open WP-L6…L8 (read-model enrichment — `dueToday`/`mastery`/`newCount`/
`subtitle`), which the mock + visual contract already specify and which were only blocked on the
read model. Object 1 is therefore **IN PROGRESS** again. Next work-package: **WP-L6 Library
read-model enrichment (BE)**. Only WP-L9 (archive) stays DEFER (Future product scope). Per the
outer→inner rule, object 1 must complete these before object 2 advances.
