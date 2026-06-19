---
last_updated: 2026-06-06
status: contract
---

# Folder Repository Contract

> **Implemented surface (v3 rebuild, 2026-06-20, WBS 2.1.1/2.2.1/2.3.1/2.6.1/3.1.1/3.2.1):** the
> live `FolderRepository` (`lib/domain/repositories/folder_repository.dart`,
> `FolderRepositoryImpl` + `folder_repo_impl_mutation_helpers.dart` part) uses the existing record
> `Result<T>` contract (not `Either`/`fpdart`) and these **folders-only** members:
> `watchLibraryOverview()` → `Stream<LibraryOverview>`,
> `watchFolderDetail(id)` → `Stream<FolderDetail?>`,
> `createRootFolder({name})`, `createSubfolder({parentId, name})`,
> `renameFolder({id, newName})` → `Result<Folder>`, and `deleteFolder({id})` → `Result<void>`.
> Backed by `FolderDao` (recursive/aggregate reads in
> `lib/data/datasources/local/drift/folder_queries.drift`: `rootFolderSummaries`,
> `childFolderSummaries`, `breadcrumb`, `descendantFolderIdsDeepestFirst`; single-table mutations via
> the query builder) + `FolderMapper` + injectable `IdGenerator`/clock. Create-subfolder locks an
> `unlocked` parent to `subfolders`; delete cascades descendant **folders** deepest-first and reverts
> an emptied parent to `unlocked`, one transaction. Tests:
> `test/data/repositories/folder_repository_impl_test.dart` (mutations, F1-F4/F8/F9),
> `test/data/repositories/folder_read_queries_test.dart` (reads).
>
> **Deferred until the decks/flashcards tables ship (WBS 2.7.x/2.11.x):** `move`/`reorder`/
> `updateContentMode` members; deck/flashcard/progress/session delete cascade; child **decks** + the
> non-zero `deckCount`/`cardCount`/`dueCount` on the read models (F12/F13); the deck-side content
> guard (`folder_contains_subfolders`, F6). The remaining `Either`/`Unit` signatures and methods
> below are the **target** style/surface, intentionally ahead of the current code.

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

`abstract class FolderRepository` in `lib/domain/repositories/folder_repository.dart`.
Implementation `FolderRepositoryImpl` in `lib/data/repositories/folder_repository_impl.dart`.

## Methods

### Queries (return Future or Stream)

```dart
Stream<List<Folder>> watchRootFolders();
Stream<List<Folder>> watchSubfolders(FolderId parentId);
Stream<FolderDetail?> watchFolderDetail(FolderId id);
Future<Either<Failure, Folder>> findById(FolderId id);
Future<Either<Failure, List<Folder>>> resolveBreadcrumb(FolderId id);
Future<Either<Failure, int>> countDescendantFlashcards(FolderId id);
Future<Either<Failure, int>> countDescendantDueFlashcards(FolderId id);
```

### Mutations

```dart
Future<Either<Failure, Folder>> create({
  required String name,
  required FolderId? parentId,
});

Future<Either<Failure, Folder>> rename(FolderId id, String newName);
Future<Either<Failure, Folder>> move(FolderId id, FolderId? newParentId);
Future<Either<Failure, Unit>> delete(FolderId id);
Future<Either<Failure, Unit>> reorder(FolderId? parentId, List<FolderId> orderedIds);
Future<Either<Failure, Unit>> updateContentMode(FolderId id, ContentMode newMode);
```

## Transaction requirements

| Operation | Tables touched in single transaction |
| --- | --- |
| `create` (subfolder) | `folders` INSERT + parent `content_mode` UPDATE if unlocked |
| `move` | `folders` UPDATE + new parent mode + old parent mode (if children=0 → unlocked) |
| `delete` | `folders` recursive cascade: subfolders, decks under them, flashcards, flashcard_progress, flashcard_tags, study_attempts referencing those flashcards, study_sessions referencing this folder |
| `reorder` | `folders` batch UPDATE of `sort_order` |
| `renameDeck` | `decks` UPDATE |
| `reorderDecks` | `decks` batch UPDATE of `sort_order` |

## Constraints enforced at repo layer

- `parent_id` MUST reference existing folder OR be NULL.
- Folder cannot reference itself as parent.
- `content_mode` ∈ {`unlocked`, `subfolders`, `decks`}.
- Sibling name uniqueness (case-insensitive) enforced at INSERT/UPDATE.
- Move that would create cycle MUST fail. Cycle check via descendant traversal BEFORE update.

## Forbidden patterns

- ❌ Return Drift row type. Always map to `Folder` entity.
- ❌ Mix presentation models (e.g., `FolderCard`) into return types.
- ❌ Return deleted orphan records.
- ❌ Allow `content_mode` corruption (e.g., subfolders mode with deck children).
- ❌ Recurse outside transaction.

## Required mappers

`FolderMapper` in `lib/data/mappers/folder_mapper.dart`:

- `Folder fromRow(FolderRow row)`
- `FolderRow toRow(Folder entity)`
- `ContentMode fromString(String value)` / `String toStorage(ContentMode mode)`

## Test contract

- Repository test (real in-memory Drift):
  - Create root folder.
  - Create subfolder + verify parent mode update.
  - Create deck in folder + verify parent mode update.
  - Rename deck + verify folder ownership and `sort_order` stay intact.
  - Move folder + cycle detection.
  - Delete cascade.
  - Reorder folders and decks.
  - Sibling uniqueness rejection.
- Domain test (mock repo):
  - Use case orchestration tested with mocktail.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/folder/folder-management.md`
**Use cases:** `docs/contracts/usecase-contracts/folder.md`
**Schema:** `docs/database/schema-contract.md` `folders` table
**Code paths:**

- `lib/domain/repositories/folder_repository.dart` (interface)
- `lib/data/repositories/folder_repository_impl.dart`
- `lib/data/datasources/local/daos/folder_dao.dart`
- `lib/data/mappers/folder_mapper.dart`
