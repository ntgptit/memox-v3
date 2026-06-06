---
last_updated: 2026-06-06
status: Current — global search screen (folders/decks/flashcards); tags section + recent/popular are Future Proposal. Inline/scope-local search guidelines also retained.
route: /library/search
source_specs:
  - docs/business/search/global-search.md
related_decision: docs/checklist/product-decisions-pending-2026-05-29.md
---

# 11 — Library Search

## V1 decision (promoted 2026-06-06)

V1 **implements** a dedicated global search screen at `/library/search`, opened from the Library
Overview app-bar search action. The promoted scope covers three sections — **folders, decks, and
flashcards** — and renders all five states (empty/hint, loading, results, no-results, error).

Still **Future Proposal** (not yet built, pending the tag subsystem and a `shared_preferences`
dependency — both require their own approval):

- The **Tags** result section.
- **Recent searches** (SharedPreferences, capped 5).
- The **popular-tags** landing section in the empty state.

While that scope is pending, the empty state shows a neutral "Search your library" prompt plus the
2-character hint rather than recent/popular shortcuts.

This document also remains the canonical UX guideline for **inline/scope-local search** still used
inside existing screens (Library overview, Folder detail, Flashcard list, Tag management) — those are
independent of the global screen and unchanged.

## V1 purpose

Help users find content inside the screen/scope they are already using, without introducing a new
global route or persistence model.

## V1 supported scopes

| Surface          | Scope                                                                                       | V1 behavior                                                           |
|------------------|---------------------------------------------------------------------------------------------|-----------------------------------------------------------------------|
| Library overview | Root folders + root decks shown on Library                                                  | Filter visible rows. No cross-deck flashcard search.                  |
| Folder detail    | Direct/recursive content under current folder, depending on existing folder screen behavior | Filter visible folders/decks; keep breadcrumb context.                |
| Flashcard list   | Flashcards in current deck only                                                             | Filter by front/back/note/pronunciation/example/hint where available. |
| Tag management   | Tags only                                                                                   | Filter tags by tag name.                                              |

## V1 rules

- Minimum 2 characters before filtering, unless the existing screen already supports empty-query
  reset.
- Debounce text input by 300ms when the query hits repository/database work.
- Case-insensitive match.
- Trim surrounding whitespace and collapse repeated whitespace.
- Escape special LIKE characters (`%`, `_`) before database search.
- Do not persist recent searches in V1.
- Do not show global result groups in V1.
- Do not navigate to `/library/search` in V1.

## V1 states

| State       | Trigger                   | Behavior                                                               |
|-------------|---------------------------|------------------------------------------------------------------------|
| Empty query | Field cleared             | Show normal screen content.                                            |
| Too short   | Query length = 1          | Show existing content or a small hint: `Type at least 2 characters.`   |
| Loading     | Query triggers async work | Show the screen's normal loading style or lightweight inline progress. |
| Results     | Matches found             | Show filtered list in the current screen only.                         |
| No results  | No match in current scope | Show local empty state: `No results in this {scope}.`                  |
| Error       | Search/filter failure     | Keep the user on the current screen and show inline error/toast.       |

## V1 result behavior

| Surface          | Tap result                                                                                |
|------------------|-------------------------------------------------------------------------------------------|
| Library overview | Open folder or deck.                                                                      |
| Folder detail    | Open folder or deck.                                                                      |
| Flashcard list   | Open flashcard detail/editor or keep row selected, depending on existing screen behavior. |
| Tag management   | Select/open tag action menu, depending on existing screen behavior.                       |

## Still-forbidden behavior (post-promotion)

The global screen now exists, so `GlobalSearchUseCase`, the `GlobalSearchScreen`, the
`/library/search` route, and cross-scope grouped results (folders/decks/flashcards) are **Current**.
The following remain forbidden until separately approved:

- Do not add a **Tags** result section (no tag subsystem yet — `docs/business/tags/tag-system.md`).
- Do not persist `SharedPreferences search.recent` (no `shared_preferences` dependency approved).
- Do not add a popular-tags search landing section (depends on the tag subsystem).
- Do not use FTS5 without a separate ADR and performance task — the implementation uses escaped
  `LIKE` queries.

## Global search screen — Current

Route: `/library/search` (`RouteNames.librarySearch`), shell visible, pushed from the Library
Overview app-bar search action.

### States (all implemented)

| State       | Trigger                                  | UI                                                                |
|-------------|------------------------------------------|-------------------------------------------------------------------|
| Empty/hint  | Normalized query `< 2` chars             | `MxEmptyState` — "Search your library" + 2-character hint.        |
| Loading     | Debounced (300ms) query in flight        | `MxLoadingState` skeleton (first load only; previous data retained otherwise). |
| Results     | One or more matches                      | Grouped sections Folders → Decks → Flashcards, each capped at 5 with a "+N more" trailing count. |
| No results  | Query ran, matched nothing in any section| `MxEmptyState` (search-off glyph) — "No results".                 |
| Error       | Repository `StorageFailure`              | `MxErrorState` — localized title/message + retry (re-runs query). |

### Query rules (implemented)

- Minimum 2 characters (normalized) before the query fires; otherwise the empty/hint state shows.
- 300ms debounce on the in-flight query.
- Case-insensitive, trimmed, internal whitespace collapsed (`StringUtils.normalizeQuery`).
- User-typed `%` / `_` / `\` are escaped before the `LIKE` query (matched literally).
- Per-section cap of 5; totals beyond the cap drive the "+N more" affordance.

### Result actions (implemented)

| Result type | Behavior                                                        |
|-------------|-----------------------------------------------------------------|
| Folder      | Navigate to `/library/folder/:id`.                              |
| Deck        | Navigate to `/library/deck/:deckId/flashcards`.                 |
| Flashcard   | Navigate to the card's owning deck (`/library/deck/:deckId/flashcards`). Per-card scroll/select is a Future refinement. |

## Future Proposal — remaining global-search scope

Not yet built; each needs its own approval:

- **Empty query**: recent searches + popular tags (needs `shared_preferences` + the tag subsystem).
- **Tags** result section + tag action (`Open a global tag-filtered flashcard list`) — needs the tag
  subsystem (`docs/business/tags/tag-system.md`).
- Per-card scroll/select on flashcard results.

## Agent rule

The global search screen is Current for folders/decks/flashcards. Treat the Tags section, recent
searches, and popular-tags landing as Future Proposal until the tag subsystem and a
`shared_preferences` dependency are approved. Inline/scope-local search guidance above still applies
to in-screen filters.
