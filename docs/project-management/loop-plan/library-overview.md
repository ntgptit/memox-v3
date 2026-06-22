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
| Search-mode bottom dock (rev. 3) | `library_search_dock.dart`, `library_search_field.dart` | Implemented (WP-L10) |
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
| `03e` Search | `LibrarySearchDock` (bottom dock) + filtered rows + `{n} FOLDERS` overline | Current |
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
- [x] **WP-L6a — Folder due-count F13 correctness fix (BE)** — **Implemented (2026-06-21).**
      Drift-check during this object found `folder_queries.drift` due-count predicates did NOT apply
      the F13 suspended/currently-buried exclusion even though the `is_suspended`/`buried_until`
      columns shipped (WBS 4.0.2) — `bury-suspend.md` §238 mandates due-count badges exclude them.
      Fixed all four queries (root/child folder summaries, folder subtree counts, deck summaries) to
      `COALESCE(is_suspended,0)=0 AND (buried_until IS NULL OR buried_until <= now)`, mirroring
      `study_scope_queries.drift`. Updated drift comment + `folder_summary.dart` doc + F12/F13
      decision rows + added the exclusion test. verify PASS.
- [x] **WP-L6b — Folder `mastery` + `newCount` read model (BE)** — **Implemented (2026-06-21).**
      Extended the `rootFolderSummaries` + `childFolderSummaries` `subtree_counts` CTE with
      `new_count` (active cards never yet studied: `due_at IS NULL` + F13 exclusion — a stricter
      set than the study new-queue, surfaces unseen cards) and
      `avg_box` (`AVG(COALESCE(box_number,1))` over subtree cards). Added `FolderSummary.newCount`
      (int, default 0) + `mastery` (double?, `avg_box / SrsBox.max`, null when empty). Repo
      `_summary` mapper computes mastery; both call sites pass the new columns. BE tests
      (newCount-excludes-suspended, mastery = mean box / 8, null when empty). No schema. verify PASS.
- [ ] WP-L6c — Deck-digest `subtitle` read model (BE) — **DEFER (mock-doc-conflict).** The current
      kit mock `03a` renders a single `{n} decks · {m} cards` digest, **not** a deck-name subtitle;
      building `subtitle` adds a read-model field with no FE consumer in the current design.
- [ ] WP-L6d — Library `dueToday` due-summary total (BE) — **DEFER (mock-doc-conflict).** The
      current kit mock `03a` shows **no** top due-summary card; not in scope.
- [ ] WP-L7 — Due-summary card FE — **DEFER (mock-doc-conflict).** Not in the current kit mock `03a`
      (the loaded shot has no due-summary card). The §Scope Decision "Current" row is stale
      prior-iteration design.
- [ ] WP-L8 — Folder-tile enrichment FE (mastery bar / new badge / subtitle) — **DEFER
      (mock-doc-conflict).** Verified against `shots/03-library-overview--loaded--{light,dark}.png`
      (2026-06-21): the rebuilt calm-app mock renders **minimal** folder rows (icon + name +
      `{n} decks · {m} cards` + chevron) with **no** mastery bar, new badge, or subtitle.
      `library_folder_tile.dart` already matches the mock. Building these = inventing UI the redesign
      dropped. The WP-L6b `mastery`/`newCount` read-model fields are correct + tested but have no
      current FE consumer (available for a future WBS 3.2.3 / Progress design).
- [ ] WP-L9 — `03j` Archive folder action + dialog — **DEFER (Future / needs-approval).** The
      Library visual contract marks archive **Future / out-of-scope** (no archive use case / repo /
      DAO / schema column; product scope decision, not just missing BE). Building it = inventing
      product scope; needs an approved task.
- [x] **WP-L10 — Library search bottom-dock (kit `03` Search) — Implemented (2026-06-22).**
      **RE-AUDIT finding (TRUST POLICY):** the prior "DONE per current mock" claim was wrong for the
      Search state. `ui-parity-checker` + the kit spec `specs/03-library-overview.md` §State: Search
      (the `+ search-dock` node, `abs:[1,636 388x69]`, `border-t:1px divider`, FAB removed) show the
      search field as a **flat bottom dock** with the regular `Library` + sort app bar retained —
      not the app-bar swap the code shipped. This matches the IA-redesign direction (bottom dock).
      Per PRECEDENCE #2 (visual → mock wins over the derived visual-contract), built the dock:
      new `library_search_dock.dart` (`LibrarySearchDock`, surface fill + top hairline, hosts the
      autofocused `LibrarySearchField`), mounted in the `bottomNavigationBar` slot while searching;
      the app-bar `Icons.search` now toggles search on/off; deleted the dead
      `library_search_app_bar.dart`. Regenerated the 2 search + 2 search-no-results goldens; added
      dock-present/absent + toggle-exit widget tests. verify PASS.
      **Activation note (minor divergence):** the kit loaded state `03a` shows only the sort icon
      (search is reached via the not-yet-built bottom-nav Search tab / kit `05`); the app-bar search
      icon is kept as the pragmatic activation bridge until the app-shell bottom-nav lands.

Note: Folder-row tap → folder detail navigation is **object 2 (Folder detail, WBS 3.2.2)**,
not Library; the interim tap→action-sheet keeps the chevron live and is correct for this object.

**Rules updated 2026-06-21 (vertical-slice loop):** BE may be added to unblock FE.

**Mock-parity correction 2026-06-21:** verified the Library tile against the actual kit mock `03a`
(not just the prose tables). The rebuilt calm-app mock dropped the prior iteration's folder-row
enrichments (mastery bar / new badge / deck-name subtitle / top due-summary card). The current
`library_folder_tile.dart` ALREADY matches `03a`, so WP-L6c/L6d/L7/L8 are DEFERred
(mock-doc-conflict) and **object 1 is DONE per the current mock**. Lesson: check the mock image
before building enrichment BE — WP-L6a (F13 correctness) + WP-L6b (read-model fields) are correct
and kept, but L6b's fields are currently unrendered.

## Status: DONE (per current kit mock 03a)

All in-mock Library FE is Implemented + verified; the tile matches `03a`. Remaining items are
DEFERred (mock-doc-conflict: enrichments not in the rebuilt mock; or Future archive). Next object
(outer→inner): **Folder (detail)** — WP-FD5a deck-move-targets BE.

## Conclusion

Object 1 (Library overview) is **DONE** per the current kit mock `03a`: the screen + all 11 states
+ the minimal folder tile match the rebuilt calm-app mock. The prior-iteration enrichments
(mastery bar / new badge / deck-name subtitle / due-summary card) are **not in the current mock**
and are DEFERred (mock-doc-conflict); WP-L6a (F13 fix) + WP-L6b (read-model fields) shipped as
correct BE. Next object (outer→inner): **Folder (detail)** — first work-package WP-FD5a
deck-move-targets BE.
