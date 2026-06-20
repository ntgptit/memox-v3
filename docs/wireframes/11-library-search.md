---
last_updated: 2026-06-21
status: Current — top-level global Search screen (folders/decks/flashcards) at /search with a bottom search dock; tags section + recent/popular are Future Proposal. Inline/scope-local search guidelines also retained.
route: /search
source_specs:
  - docs/business/search/global-search.md
related_decision: docs/project-management/wbs.md (§6 Deferred / Future / Rejected register)
---

# 11 — Library Search

## V1 decision (promoted 2026-06-06)

V1 **implements** a dedicated global search screen. Per the design redesign it is the top-level
**`/search`** destination (a primary bottom-nav tab) with a **bottom search dock**, not a route
opened from a Library app-bar action. The promoted scope covers three sections — **folders, decks,
and flashcards** — and renders all five states (empty/hint, loading, results, no-results, error).

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
- These inline rules govern **scope-local** search only; cross-scope grouped results live on the
  top-level `/search` screen (see below), not in the in-screen inline filters.

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

The global screen now exists, so `GlobalSearchUseCase`, the `GlobalSearchScreen`, the top-level
`/search` route, and cross-scope grouped results (folders/decks/flashcards) are **Current**.
The following remain forbidden until separately approved:

- Do not add a **Tags** result section (no tag subsystem yet — `docs/business/tags/tag-system.md`).
- Do not persist `SharedPreferences search.recent` (no `shared_preferences` dependency approved).
- Do not add a popular-tags search landing section (depends on the tag subsystem).
- Do not use FTS5 without a separate ADR and performance task — the implementation uses escaped
  `LIKE` queries.

## Global Search screen — Current (design redesign)

Route: top-level **`/search`** (`RouteNames.search`), a primary bottom-nav destination (Home ·
Library · Search · Progress · Settings). Search input lives in a **bottom-anchored dock**
(`MxSearchDock`, the kit `.search-dock`) so it stays thumb-reachable; there is no app-bar search
field. The body above the dock renders the states; the shell's bottom nav sits below the dock. The
screen shell (`GlobalSearchScreen`) stays provider-watch-free — the dock drives the query via
`ref.read`, and `GlobalSearchBody` owns the results watch.

### States (all implemented)

| State       | Trigger                                  | UI                                                                |
|-------------|------------------------------------------|-------------------------------------------------------------------|
| Empty/hint  | Normalized query `< 2` chars             | `MxEmptyState` — "Search your library" + "Find folders, decks, and cards." (recent searches + popular tags are Future, so not shown). |
| Loading     | Debounced (300ms) query in flight        | `MxLoadingState` (first load only; previous data retained otherwise). |
| Results     | One or more matches                      | Grouped sections Folders → Decks → Flashcards, each capped at 5 with a "+N more" trailing count. |
| No results  | Query ran, matched nothing in any section| `MxNoResultsState` — "No results" with the query echoed.          |
| Error       | Use-case failure (in-band `Result`)      | `MxErrorState` — localized title/message + retry (re-runs query). |

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
