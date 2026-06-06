---
last_updated: 2026-06-06
status: Current — GlobalSearchUseCase (folders/decks/flashcards); tags + recent + popular are Future Proposal
---

# Search Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

The global search use case below is **Current** for three sections (folders/decks/flashcards). The
recent-search and popular-tags use cases, and the Tags result section, remain **Future Proposal**
pending a `shared_preferences` dependency and the tag subsystem.

## V1 inline search

V1 also keeps inline/scope-local search on existing screens — reuse screen-level providers/widgets
and keep that filtering inside the current screen scope. This is independent of the global screen.

## Current: GlobalSearchUseCase

Implemented in `lib/domain/usecases/search/global_search_usecase.dart` over
`lib/domain/repositories/search_repository.dart` (Drift-backed `SearchRepositoryImpl`). Uses the
existing `Result<T>` pattern (not `Either`, per the architecture note).

```dart
Future<Result<SearchResults>> call({required String query});
```

**Rules (implemented):**

- Normalize query via `StringUtils.normalizeQuery` (trim, lowercase, collapse internal whitespace).
- Reject if normalized length `< 2` → `ValidationFailure(field: 'query', code: tooShort)` — the repo
  is never called.
- The repository escapes special LIKE chars (`%`, `_`, `\`) before binding.
- Runs 3 parallel section queries (folders, decks, flashcards) via record `.wait`; each section is
  LIKE-based. The **Tags** section is deferred until the tag subsystem ships.
- Sort within each section: exact match → starts-with → substring → recency tiebreak.
- Cap each section at `GlobalSearchUseCase.sectionCap` (5); `SearchResults` carries per-section
  totals (`folderTotal` / `deckTotal` / `flashcardTotal`) for the "+N more" affordance.

**Returns:** `SearchResults { folders, decks, flashcards, folderTotal, deckTotal, flashcardTotal }`
with `isEmpty` / `totalCount` getters. (The Future `tags` section and `queryDuration` are not yet
included.)

**Errors:** `ValidationFailure(tooShort)`, `StorageFailure(read)`.

**Test refs:** `test/domain/usecases/global_search_usecase_test.dart`,
`test/data/repositories/search_repository_impl_test.dart`,
`test/presentation/features/search/global_search_test.dart`.

> The `deckScope` pre-filter and a `tags` section are Future refinements — not part of the promoted
> scope.

## Future Proposal: GetRecentSearchesUseCase

```dart
Future<List<String>> call();
```

Read SharedPreferences `search.recent` (capped 5).

## Future Proposal: SaveRecentSearchUseCase

```dart
Future<void> call(String query);
```

**Rules:**

- Trim. Skip if < 2 chars.
- Insert at top. Dedup case-insensitive. Trim list to 5.
- Persist to SharedPreferences.

## Future Proposal: RemoveRecentSearchUseCase

```dart
Future<void> call(String query);
```

## Future Proposal: GetPopularTagsUseCase

```dart
Future<Either<Failure, List<TagWithCount>>> call({int limit = 5});
```

Top tags by usage. Cached in screen state.

## Still-forbidden patterns (post-promotion)

- ❌ Do not add a Tags result section until the tag subsystem ships.
- ❌ Do not persist `search.recent` until a `shared_preferences` dependency is approved.
- ❌ Do not add a popular-tags landing section until the tag subsystem ships.

## Forbidden patterns

- ❌ Add flat/recursive toggle. Search is always recursive.
- ❌ Pass raw user query to LIKE without escaping (`SearchRepositoryImpl` escapes `%` / `_` / `\`).
- ❌ Cache search results across queries.
- ❌ Implement FTS (full-text search) without explicit ADR — keep LIKE for Phase 1.
- ❌ Fire query at < 2 chars.
- ❌ Store > 5 recent searches (when recent searches are eventually promoted).

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/search/global-search.md`
**Repository:** `docs/contracts/repository-contracts/folder-repository.md`, `docs/contracts/repository-contracts/deck-repository.md`, `docs/contracts/repository-contracts/flashcard-repository.md`, `docs/contracts/repository-contracts/tag-repository.md`
**Wireframes:** `docs/wireframes/11-library-search.md`
**Decision table:** SR1-SR10
**Code paths:** `lib/domain/usecases/search/**`
