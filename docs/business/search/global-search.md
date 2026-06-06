---
last_updated: 2026-06-06
applies_to: V1 global search (folders/decks/flashcards) + inline/scope-local search
status: Current — global search screen for folders/decks/flashcards; tags + recent + popular are Future Proposal
related_decision: docs/checklist/product-decisions-pending-2026-05-29.md
---

# Search

## V1 decision (promoted 2026-06-06)

MemoX V1 **implements** a dedicated global search screen at `/library/search` covering three
sections — **folders, decks, and flashcards** — with all five states (empty/hint, loading, results,
no-results, error). See `docs/wireframes/11-library-search.md`.

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
| Library overview | Visible/root folders and decks | folder name, deck name                                          |
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
| Special chars    | Escape `%` and `_` before LIKE queries.                            |

## Inline scope-local search rules

These rules govern the **inline** filters on existing screens (not the global screen):

- Search/filter must not mutate data.
- Inline search must stay inside the current screen's scope.
- No recent-search persistence yet (needs `shared_preferences`).
- No popular-tags landing section yet (needs the tag subsystem).
- Inline filters do not group cross-scope results; cross-scope grouping lives in the global
  `/library/search` screen.
- Use existing route constants for any result navigation.

## V1 result behavior

| Result type | Behavior                                                       |
|-------------|----------------------------------------------------------------|
| Folder      | Open folder detail.                                            |
| Deck        | Open deck flashcard list.                                      |
| Flashcard   | Open/select card inside current deck.                          |
| Tag         | Open/select tag management action depending on current screen. |

## Global Library search — Current

Implemented at `/library/search` (`GlobalSearchUseCase` over `SearchRepository`):

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

The global search screen is Current for folders/decks/flashcards. Treat the Tags section, recent
searches, and popular-tags landing as Future Proposal until the tag subsystem and a
`shared_preferences` dependency are approved.
