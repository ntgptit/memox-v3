---
last_updated: 2026-06-21
object: Deck (detail)
loop_order: 4 of 10 (outer→inner)
route: /library/deck/:deckId/flashcards
status: IN PROGRESS (deck-container FE mostly built; count-overline due badge gap)
---

# Loop plan — Object 4: Deck (detail)

A deck's detail **is the Flashcard List screen** (kit `06`, `flashcard_list_screen.dart`) — there
is no separate deck-detail route. This object scopes the **deck-level container**; the card-level
surface (card rows' SRS enrichment, the card create/edit editor `07`/`08`, card delete/reorder) is
**object 5 (Flashcard list + editor)**. Sources: `shots/06-flashcard-list--*`, WBS 3.4.x,
`docs/wireframes/06-flashcard-list.md`.

## Scope boundary (object 4 vs object 5)

| Concern | Object | Status |
|---|---|---|
| App bar (deck name + search + sort + overflow) | 4 | Implemented |
| Breadcrumb (Library › … › deck leaf) | 4 | Implemented |
| Count overline `{n} CARDS` | 4 | Implemented |
| **`{m} due` badge on the overline** (mock `06` shows `142 CARDS · 23 due`) | 4 | **Missing-BE** |
| Add-card FAB | 4 | Implemented |
| Inline search + states (loaded/empty/search-empty/loading/error) | 4 | Implemented |
| Per-deck sort | 4 | Implemented (WBS 2.23.1) |
| Deck overflow → delete deck | 4 | Implemented (kebab → `runDeleteDeck`; matches `06` delete-deck state) |
| Card row SRS enrichment (`Box N · due in Xd` + Review/Learning/New/Mastered chip) | **5** | card-level |
| Card create / edit editor (`07`/`08`), card delete, card reorder | **5** | card-level |

## Audit — deck container is built (WBS 3.4.2)

`flashcard_list_screen.dart` + `flashcard_list_body.dart` render the deck app bar (name + search +
`swap_vert` sort + `more_vert` → delete deck), the docked breadcrumb with the deck as the current
leaf, the `{n} CARDS` overline, the grouped card list, the add-card FAB, and the
loaded/empty/search-no-results/error states. Deck rename/move are **not** on this screen — the kit
`06` states don't show them (they live on Folder-detail's deck action sheet, object 2); the `06`
kebab maps to delete-deck only, which the impl matches.

## MAP — kit `06` deck-level elements

| Mock element | Component | Scope |
|---|---|---|
| App bar deck name + back + kebab | `MxAppBar` + `more_vert` → delete | Current |
| Breadcrumb `Library › Languages › Japanese · N5` | `MxBreadcrumb` + `buildLibraryBreadcrumb` (deck leaf) | Current |
| `142 CARDS` overline | `flashcard_list_body._Overline` | Current |
| `23 due` badge (overline, top-right) | — | **WP-D1 (missing)** |
| Add-card FAB | `MxFab(Icons.add)` | Current |
| Search cards (bottom field / mode) | `flashcard_list_search` | Current |
| Card rows (icon + front—back + Box/due + status chip) | `flashcard_tile` (front/back only today) | **object 5** |

## Gap-checklist (work-package queue)

- [ ] **WP-D1 — Count-overline `{m} due` badge (BE+FE)** — eligible vertical slice. The mock `06`
      overline reads `142 CARDS · 23 due`; the read model has no due count. Extend the
      flashcard-list query / `FlashcardListDetail` with `dueCount` (active, F13 suspended/buried
      exclusion — same predicate as `folderDeckSummaries`), render a `{m} due` badge beside the
      `{n} CARDS` overline (reuse the `_DueBadge` pill style; show only when `> 0`). BE query test +
      overline widget test + golden. **NEXT.**

## Conclusion

Object 4 (Deck detail = the deck container on the Flashcard-list screen) is mostly Implemented
(WBS 3.4.2); the one deck-level mock gap is the overline due badge (**WP-D1**). All card-level
work (SRS row enrichment, the `07`/`08` editor, card CRUD/reorder) is **object 5**. Once WP-D1
lands, object 4 is DONE → object 5.
