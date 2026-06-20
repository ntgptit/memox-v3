---
last_updated: 2026-06-19
source: split from memox-core-decision-table.md
applies_to: Global and scope-local search behavior branches
---

# MemoX Decision Table — Search

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: SR1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

Global search is Current for folders/decks/flashcards at the top-level **`/search`** destination
(design redesign — bottom search dock). Rows SR7/SR8/SR10 stay Future until the tag subsystem and
`shared_preferences` are approved (`docs/wireframes/11-library-search.md`).

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| SR1 | Query < 2 chars | Below min (normalized) | `ValidationFailure(query, tooShort)`, no query fired | C1 | test/domain/usecases/global_search_usecase_test.dart::SR1 |
| SR2 | Query | Normalized substring | Trim + lowercase + collapse whitespace, substring `LIKE` match | C1 | test/data/repositories/search_repository_impl_test.dart::SR2 |
| SR3 | Query | Case-insensitive | Match regardless of case (diacritic folding is Future) | C1 | test/data/repositories/search_repository_impl_test.dart::SR2 (SR2 case covers both) |
| SR4 | Query with `%` or `_` | Special chars | Escape (`%`/`_`/`\`) before `LIKE`; matched literally | C1 | test/data/repositories/search_repository_impl_test.dart::SR4 |
| SR5 | Result tap | Folder | Navigate to folder detail (`/library/folder/:id`) | C0 | test/presentation/features/search/global_search_test.dart |
| SR6 | Result tap | Deck / Flashcard | Navigate to the deck's flashcard list (per-card scroll is Future) | C0 | test/presentation/features/search/global_search_test.dart |
| SR-screen | `/search` screen state | idle / loading / results / no-results / error | Idle prompt (recent/popular not shown — Future); spinner while debounced; grouped sections with "+N more"; no-results echoes query; failure → error state + retry | C0+C1 | test/presentation/features/search/global_search_test.dart |
| SR7 | Result tap | Tag | Future — open global tag-filtered list (tag subsystem) | — | Future |
| SR8 | Recent searches | Empty query | Future — show last 5 recent (`shared_preferences`) | — | Future |
| SR9 | Folder-detail search | Inside folder Korean | Recursive inline filter (separate from global screen) | C0+C1 | TBD |
| SR10 | Result row | Any | Future — breadcrumb path shown in result row | — | Future |
| SR-rank | Section ordering | Multiple matches | exact → starts-with → substring → recency tiebreak | C1 | test/domain/usecases/global_search_usecase_test.dart::SR5 |
| SR-cap | Section overflow | > 5 matches in a section | Cap at 5 rows; report true total via "+N more" | C1 | test/domain/usecases/global_search_usecase_test.dart::SR6 |
| SR-empty | No matches | Query ran, zero hits | Empty `SearchResults` (`isEmpty`), use case returns success | C1 | test/domain/usecases/global_search_usecase_test.dart |
| SR-err | Repo failure | `StorageFailure(read)` | Use case propagates the failure; no raw detail leaked | C1 | test/data/repositories/search_repository_impl_test.dart::SR-err, test/domain/usecases/global_search_usecase_test.dart |
