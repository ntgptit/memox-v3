---
last_updated: 2026-06-21
object: Sub-folder (nested)
loop_order: 3 of 10 (outer→inner)
route: /library/folder/:id (at nested depth)
status: IN PROGRESS (covered by object 2; one nested-breadcrumb test gap)
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

- [ ] **WP-N1 — Nested breadcrumb FE test (coverage gap)** — eligible. `folder_detail_test`
      fixtures use a **single-level** breadcrumb (`breadcrumb: [Languages]`), so the multi-level
      nested trail (Root › Languages › East Asian) + ancestor tappability + current-crumb
      non-tappability are FE-untested (the BE ancestor query is tested in `folder_read_queries`).
      Add a widget test pumping `FolderDetailScreen` for a nested folder (≥3 crumbs) asserting:
      Root + ancestor crumbs render and are tappable, the deepest crumb is the current location,
      and the trail matches `buildLibraryBreadcrumb` semantics. **NEXT.**

## Conclusion

Object 3 has **no missing feature** — nested sub-folders are fully handled by object 2's
`FolderDetailScreen` (breadcrumb nav + scroll, nested create/navigate/mode-lock/delete). The only
gap is a nested-breadcrumb **FE test** (WP-N1); once it lands, object 3 is DONE → object 4 (Deck
detail).
