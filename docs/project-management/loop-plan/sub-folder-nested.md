---
last_updated: 2026-06-21
object: Sub-folder (nested)
loop_order: 3 of 10 (outer→inner)
route: /library/folder/:id (at nested depth)
status: DONE — re-audit-confirmed 2026-06-22 (covered by object 2; nested-breadcrumb screen test — WP-N1)
---

# Loop plan — Object 3: Sub-folder (nested)

A "nested sub-folder" is the **same `FolderDetailScreen`** (object 2) rendered for a folder that
is itself a child — there is no separate screen, route, or kit mock. Sources audited:
`shots/04-folder-detail--subfolders--{light,dark}.png`, `docs/wireframes/05-folder-detail.md`,
`docs/business/folder/folder-management.md`, the breadcrumb code.

## Audit — nested behaviors are all built (via object 2)

| Nested behavior | As-built | Verdict |
|---|---|---|
| Multi-level breadcrumb (Root › … › leaf) | `buildLibraryBreadcrumb` (root → `goNamed(library)`, each ancestor → `pushNamed(folderDetail)`, deepest folder = non-tappable current) | Implemented |
| Breadcrumb overflow at depth | `MxBreadcrumb` = horizontal `SingleChildScrollView` (scrolls, never overflows) | Implemented |
| Subfolder rows (`{n} decks · {m} cards`) | `LibraryFolderTile` / `folderMetaLine` (decks-mode) | Implemented |
| Stats card (Subfolders / Decks / Due) | `folder_stats_card` + `folder_detail_body._stats` (subfolders mode) | Implemented |
| Nested navigation (subfolder tap → push nested detail) | `folder_detail_body._openSubfolder` → `pushNamed(folderDetail)` | Implemented |
| Content-aware create at depth (create subfolder / deck) | content-aware FAB + `createSubfolder`/`createDeck` use cases (parent-mode lock enforced) | Implemented |
| Folder actions at depth (rename / move / delete cascade) | `runFolderActions` + recursive delete; move picker shows nested folders w/ breadcrumb | Implemented |

## MAP — kit `04 · subfolders` state

The subfolders state shows breadcrumb `Library › Languages` + a Subfolders/Decks/Due stats card +
`{n} decks · {m} cards` subfolder rows + create-subfolder FAB — all rendered by object 2's code at
any depth. No nested-specific mock state exists in `shots/INDEX.md`.

## Gap-checklist (work-package queue)

- [x] **WP-N1 — Nested breadcrumb FE test** — **Implemented (2026-06-21).** Audit found
      `buildLibraryBreadcrumb` **structure** (multi-level Root › ancestors › current, tappability,
      leaf handling) is **already** fully covered by `test/presentation/shared/navigation/
      library_breadcrumb_test.dart`. The only gap was the **screen-level** render at depth (the
      `folder_detail_test` fixtures used a single crumb). Added a `_nested` fixture (East Asian under
      Languages) + a test asserting `FolderDetailScreen` docks the trail `Root › Languages › East
      Asian` (root + ancestor crumbs render; current folder is the leaf + app-bar title). verify PASS.

## Conclusion

Object 3 is **DONE — re-audit-confirmed 2026-06-22** (evidence on the current tree). No missing
feature — nested sub-folders are fully handled by object 2's `FolderDetailScreen`. Re-audit
(`Explore` + `tool/verify`) verified every nested behavior has code + passing test backing:

- Subfolder-tap → nested push: `folder_detail_body.dart` `_openSubfolder` (`pushNamed(folderDetail)`)
  + screen test `folder_detail_test.dart` 'nested folder shows the multi-level ancestry breadcrumb'.
- Multi-level breadcrumb tappability: `library_breadcrumb.dart` `buildLibraryBreadcrumb` (root→
  `goNamed(library)`, ancestors→`pushNamed(folderDetail)`, current=non-tappable leaf) +
  `library_breadcrumb_test.dart` (root/ancestor tappable, current non-tappable) — PASS.
- Content-aware create-at-depth + parent mode-lock: `_fab` switch + `folder_repository`
  create-subfolder/create-deck mode guards (`UnsupportedActionFailure`) + FAB tests.
- Folder actions at depth (rename/move/delete-cascade): `runFolderActions` + recursive delete;
  move picker shows nested breadcrumb-path subtitles (`move_picker_golden_test` `_folderTargets`).
- Kit `04 subfolders` state goldened (`folder_detail_subfolders` light+dark) + parity-confirmed in
  object 2's ui-parity pass. No nested-specific kit state exists to add.

`folder_detail_test.dart` + `library_breadcrumb_test.dart` PASS (21 tests, analyze clean). Next
object (outer→inner): **Deck (detail)** — object 4.
