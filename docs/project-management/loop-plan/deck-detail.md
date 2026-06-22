---
last_updated: 2026-06-21
object: Deck (detail)
loop_order: 4 of 10 (outer→inner)
route: /library/deck/:deckId/flashcards
status: DONE — re-audit-confirmed 2026-06-22 (container WBS 3.4.2 + WP-D1 due badge + WP-D2 persistent search dock)
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
| Search cards (persistent bottom dock) | `FlashcardListSearchDock` (WP-D2) | Current |
| Card rows (icon + front—back + Box/due + status chip) | `flashcard_tile` (front/back only today) | **object 5** |

## Gap-checklist (work-package queue)

- [x] **WP-D1 — Count-overline `{m} due` badge (BE+FE)** — **Implemented (2026-06-21).**
      `FlashcardListDetail.dueCount` (full-deck active due, computed in `watchFlashcardList` via the
      existing `_matchesStatus(due)` over each card's progress — F13-consistent with
      `folderDeckSummaries`; progress now loaded whenever the deck has cards). `flashcard_list_body`
      renders a `{m} due` pill (reused `_DueBadge` style) beside the `{n} CARDS` overline when
      `> 0`, independent of search. BE test (active-due only, suspended excluded, search-invariant)
      + overline widget tests (badge present / absent) + `loaded-due` golden (light+dark). verify PASS.

- [x] **WP-D2 — Persistent flashcard-list search dock (kit `06`) — Implemented (2026-06-22).**
      **RE-AUDIT finding (TRUST POLICY):** flashcard-list search shipped as an **app-bar swap**
      (`FlashcardListSearchAppBar` + a `FlashcardSearchActive` toggle), but the kit `06` Loaded base
      tree ships a **persistent** bottom `search-dock` (`abs:[1,700 388x69]`) — always present while
      the deck has cards, removed only in reorder. So this dock differs from the Library/Folder
      **toggle** docks (WP-L10/WP-FD10): it is persistent, not toggled. Per PRECEDENCE #2 (visual →
      mock), rebuilt: `FlashcardListSearchDock` (surface fill + top hairline, hosts the
      provider-synced `FlashcardListSearchField`, no autofocus) mounted in the `bottomNavigationBar`
      slot **only when `detail.totalCount > 0 && !reordering`** (hidden in empty/loading/error/
      reorder per spec). Removed the app-bar search icon + the now-dead `FlashcardSearchActive`
      notifier (filtering keys on `flashcardSearchQueryProvider` alone; the body's no-results state
      already keyed on `term.isNotEmpty`). FAB + breadcrumb no longer hide on "search". Regenerated
      6 goldens (loaded/loaded-due/search-no-results gained the dock; empty/loading/error lost the
      app-bar search icon); added dock present (loaded) / absent (empty, reorder) tests. verify PASS.

## Conclusion

Object 4 (Deck detail = the deck container on the Flashcard-list screen) is **DONE — re-audit-
confirmed 2026-06-22**: WBS 3.4.2 container + WP-D1 overline due badge + **WP-D2 persistent search
dock** (the re-audit found the app-bar-swap-vs-dock gap, same class as objects 1–2 but the kit `06`
dock is persistent). All card-level work (SRS row enrichment, the `07`/`08` editor, card CRUD/
reorder) is **object 5**. Next object (outer→inner): **Flashcard (list + editor)**.
