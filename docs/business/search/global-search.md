---
last_updated: 2026-06-20
applies_to: global search (folders/decks/flashcards) + inline/scope-local search
status: In-place folder search is Current; the dedicated global Search screen is being (re)built as a top-level /search destination by the design redesign — domain+data ready, UI not yet wired
related_decision: docs/project-management/wbs.md (§6 Deferred / Future / Rejected register)
---

# Search

## Current state & redesign decision

Current code ships **in-place folder search** inside Library Overview (search-mode app bar,
`librarySearchActiveProvider`). The `GlobalSearchUseCase` / `SearchRepository` domain+data layer
(folders/decks/flashcards) **exists and is tested but is not wired to any screen**, and there is no
search route in the current router.

The design redesign promotes global search to a **top-level `/search` destination** — a primary
bottom-nav tab with a **bottom-anchored search dock** (`SearchDock`/`SearchField`, thumb-reachable),
not a top-app-bar field. It covers three sections — **folders, decks, and flashcards** — with all
five states (empty/hint, loading, results, no-results, error). See
`docs/wireframes/11-library-search.md`. When that screen ships it wires the existing
`GlobalSearchUseCase`.

Still **Future Proposal** (each needs its own approval before implementation):

- The **Tags** result section (needs the tag subsystem — `docs/business/tags/tag-system.md`).
- **Recent searches** persistence (needs a `shared_preferences` dependency).
- The **popular-tags** landing section in the empty state.

V1 also keeps **inline/scope-local search** on existing screens (Library overview, Folder detail,
Flashcard list, Tag management); that is independent of the global screen.

## V1 purpose

Users should be able to narrow the content they are currently viewing without leaving the current
screen.

## V1 scopes

| Surface          | Scope                          | Searchable fields                                               |
|------------------|--------------------------------|-----------------------------------------------------------------|
| Library overview | Visible/root folders only      | folder name                                                     |
| Folder detail    | Current folder content         | folder name, deck name                                          |
| Flashcard list   | Current deck only              | front, back, note, pronunciation, example, hint where supported |
| Tag management   | Tags only                      | tag name                                                        |

## V1 query input

| Aspect           | Behavior                                                           |
|------------------|--------------------------------------------------------------------|
| Min characters   | 2 chars before database-backed filtering; empty query resets list. |
| Debounce         | 300ms when repository/database work is triggered.                  |
| Case sensitivity | Case-insensitive.                                                  |
| Whitespace       | Trim around query; collapse repeated internal whitespace.          |
| Partial match    | Substring match.                                                   |
| Special chars    | Escape `%`, `_`, and the escape character `\` itself before LIKE queries (declare `ESCAPE '\'`). |

## Inline scope-local search rules

These rules govern the **inline** filters on existing screens (not the global screen):

- Search/filter must not mutate data.
- Inline search must stay inside the current screen's scope.
- Library overview V1 inline search is folder-only; deck/card/tag search is Future.
- No recent-search persistence yet (needs `shared_preferences`).
- No popular-tags landing section yet (needs the tag subsystem).
- Inline filters do not group cross-scope results; cross-scope grouping lives in the global
  `/search` screen (redesign).
- Use existing route constants for any result navigation.

## V1 result behavior

| Result type | Behavior                                                       |
|-------------|----------------------------------------------------------------|
| Folder      | Open folder detail.                                            |
| Deck        | Open deck flashcard list.                                      |
| Flashcard   | Open/select card inside current deck.                          |
| Tag         | Open/select tag management action depending on current screen. |

## Global Search screen — target (redesign)

Built at top-level `/search` (`GlobalSearchUseCase` over `SearchRepository`), bottom search dock:

- Grouped results by Folders / Decks / Flashcards (Tags section is Future).
- Cross-scope navigation: folder → folder detail, deck → flashcard list, flashcard → owning deck.
- Ranking: exact match → starts-with → substring → recency tie-break.
- Escaped `LIKE` queries (no FTS5); per-section cap of 5 with un-capped totals for "+N more".
- 2-character minimum; 300ms debounce; case-insensitive, whitespace-collapsed query.

## Future Proposal: remaining global-search scope

Each needs its own approval before implementation:

- Recent searches in SharedPreferences, capped at 5 (needs the `shared_preferences` dependency).
- Popular-tags shortcut section in the empty state (needs the tag subsystem).
- **Tags** result section + cross-scope tag deep link (needs the tag subsystem).
- Per-card scroll/select on flashcard results.

## Forbidden patterns

- Do not persist recent searches until a `shared_preferences` dependency is approved.
- Do not add a Tags section / popular tags until the tag subsystem ships.
- Do not introduce FTS5 without an ADR/performance task.
- Do not use a raw user query as a LIKE pattern — escape `%` / `_` / `\` first (`SearchRepositoryImpl`).
- Do not add a flat/recursive toggle without product approval.

## Agent rule

The dedicated global Search screen is being (re)built as a top-level `/search` destination by the
design redesign; its domain+data layer (`GlobalSearchUseCase`/`SearchRepository`) is ready. Until
that screen is wired, the only Current search UI is in-place folder search in Library Overview.
Treat the Tags section, recent searches, and popular-tags landing as Future Proposal until the tag
subsystem and a `shared_preferences` dependency are approved.
