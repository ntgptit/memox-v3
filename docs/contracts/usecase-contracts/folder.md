---
last_updated: 2026-06-06
status: contract
---

# Folder Use Cases Contract

> **Implementation status (v3 rebuild, 2026-06-20, WBS 2.1.1/2.2.1/2.3.1/2.4.1/2.5.1/2.6.1/3.1.1/3.2.1):**
> Implemented over the record `Result<T>` contract (not `Either`/`fpdart`) and wired in
> `lib/app/di/folder_providers.dart`:
> `CreateRootFolderUseCase`, `CreateSubfolderUseCase`, `RenameFolderUseCase`, `DeleteFolderUseCase`,
> `MoveFolderUseCase`, `GetFolderMoveTargetsUseCase`, `ReorderFoldersUseCase`,
> `WatchLibraryOverviewUseCase`, `WatchFolderDetailUseCase`
> (`lib/domain/usecases/folder/*_usecase.dart`), backed by
> `FolderRepository.{createRootFolder,createSubfolder,renameFolder,deleteFolder,moveFolder,getFolderMoveTargets,reorderFolders,watchLibraryOverview,watchFolderDetail}`.
> Move/reorder are folders-only V1 (no deck subtree relocation yet). Move-target model:
> `lib/domain/models/folder_move_target.dart` (`FolderMoveTarget` + `FolderMoveBlock`).
> Tests: `test/data/repositories/folder_repository_impl_test.dart` (F1-F4/F7-F11/F14-F19) +
> `test/data/repositories/folder_read_queries_test.dart` +
> `test/domain/usecases/folder/{move_folder,reorder_folders}_usecase_test.dart`.
>
> **Not yet implemented (target, deferred):** `ListAllFoldersUseCase`, `CreateDeckInFolderUseCase`
> and the deck-side of the read models / cascade — these depend on the decks/flashcards tables
> (WBS 2.7.x/2.11.x). The signatures below use the **target** `Either<Failure, T>`/`Unit` style;
> the live code uses `Result<T>` (`Result<void>` where the target shows `Unit`). Names also differ
> where the rebuild split create into root/subfolder use cases.

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

All folder-mutation logic lives in use cases. Widgets and notifiers MUST NOT call `FolderRepository` directly for mutations.

Each section below specifies: signature, preconditions, rules, side effects, errors, test refs.

## CreateRootFolderUseCase

```dart
Future<Either<Failure, Folder>> call({required String name});
```

**Preconditions:** none.

**Rules:**

- Trim `name`.
- Reject empty after trim → `ValidationFailure(field: 'name', code: empty)`.
- Reject duplicate name among root folders (case-insensitive) → `ValidationFailure(code: duplicate)`.
- Insert with `parent_id = NULL`, `content_mode = unlocked`, `sort_order = MAX(sort_order)+1` among root.

**Side effects:**

- INSERT into `folders`.

**Errors:** `ValidationFailure`, `StorageFailure`.

**Test refs:** F1-F3 in decision table; `test/domain/usecases/folder/create_root_folder_test.dart`.

## CreateSubfolderUseCase

```dart
Future<Either<Failure, Folder>> call({required FolderId parentId, required String name});
```

**Preconditions:**

- Parent folder exists.
- Parent `content_mode` ∈ (`unlocked`, `subfolders`).

**Rules:**

- Trim name. Reject empty.
- Reject duplicate name among siblings.
- INSERT child folder with `parent_id`, `content_mode=unlocked`, next `sort_order`.
- UPDATE parent `content_mode` to `subfolders` if currently `unlocked`.
- Atomic (single transaction). Detail in `docs/contracts/repository-contracts/folder-repository.md`.

**Errors:** `NotFoundFailure` (parent), `UnsupportedActionFailure` (parent locked to decks), `ValidationFailure`, `StorageFailure`.

**Test refs:** F4-F7.

## CreateDeckInFolderUseCase

See `docs/contracts/usecase-contracts/deck.md` §CreateDeckUseCase. The use case lives there but updates folder `content_mode` to `decks` if parent currently `unlocked`. Single transaction.

## RenameFolderUseCase

```dart
Future<Either<Failure, Folder>> call({required FolderId id, required String newName});
```

**Rules:**

- Trim name. Reject empty.
- Reject duplicate among siblings (same `parent_id`).
- No-op (return `Right(folder)`) if new name equals current after trim.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.

**Test refs:** F8.

## MoveFolderUseCase

```dart
Future<Either<Failure, Folder>> call({required FolderId id, required FolderId? newParentId});
```

**Preconditions:**

- Folder exists.
- New parent exists (or null for root).
- New parent's `content_mode` allows subfolders.
- Move does NOT create a cycle (new parent is not the folder itself OR any of its descendants).

**Rules:**

- Atomic update of folder + parent modes; recompute `sort_order`. See `docs/contracts/repository-contracts/folder-repository.md` for table list.

**Errors:** `NotFoundFailure`, `ValidationFailure(code: cycleDetected | duplicate)`, `UnsupportedActionFailure`, `StorageFailure`.

**Test refs:** F7, F14-F17, F19; `test/data/repositories/folder_repository_impl_test.dart`, `test/domain/usecases/folder/move_folder_usecase_test.dart`.

## DeleteFolderUseCase

```dart
Future<Either<Failure, Unit>> call({required FolderId id});
```

**Rules:**

- Atomic recursive cascade (descendants + their content + sessions targeting them). Full cascade list in `docs/contracts/repository-contracts/folder-repository.md`.
- UPDATE old parent's `content_mode` to `unlocked` if no more children remain.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Test refs:** F12.

**Caution:** Destructive. Caller MUST confirm via §delete-confirm dialog before invoking.

## GetFolderMoveTargetsUseCase

```dart
Future<Result<List<FolderMoveTarget>>> call({required FolderId folderId});
```

**Rules:**

- Returns the Library root (`id == null`) plus **every** folder as a candidate destination, each
  annotated with `isCurrentParent` and a non-null `block` reason when it cannot accept the move.
- Blocked, never hidden (`docs/wireframes/25-shared-bottom-sheets.md` §folder-picker): the folder
  itself and its descendants are `FolderMoveBlock.cycle`; folders locked to `decks` mode are
  `FolderMoveBlock.lockedToDecks`.
- Pure read; performs the same descendant + mode checks that `MoveFolderUseCase` enforces, so the
  picker can disable invalid rows up front.

**Errors:** `StorageFailure`.

**Code:** `lib/domain/usecases/folder/get_folder_move_targets_usecase.dart`;
`FolderRepositoryImpl.getFolderMoveTargets`; model `lib/domain/models/folder_move_target.dart`.

## ReorderFoldersUseCase

```dart
Future<Either<Failure, Unit>> call({required FolderId? parentId, required List<FolderId> orderedIds});
```

**Rules:**

- Atomic batch `sort_order` UPDATE. All ids MUST belong to the same parent (else `ValidationFailure`).

**Errors:** `ValidationFailure`, `StorageFailure`.

**Test refs:** `test/domain/usecases/folder/reorder_folders_usecase_test.dart`.

## GetFolderDetailUseCase

```dart
Future<Either<Failure, FolderDetail>> call({required FolderId id});
```

`FolderDetail` = folder + breadcrumb path + child counts.

**Errors:** `NotFoundFailure`, `StorageFailure`.

## WatchRootChildrenUseCase

```dart
Stream<Either<Failure, RootChildren>> call();
```

`RootChildren` = `{ folders: List<FolderWithCount>, decks: List<DeckWithCount> }`.

Used by Library screen.

## WatchFolderChildrenUseCase

```dart
Stream<Either<Failure, FolderChildren>> call({required FolderId id});
```

Returns folder + appropriate children based on `content_mode`. Used by Folder detail screen.

## ListAllFoldersUseCase

```dart
Future<List<FolderScopeOption>> execute();
```

`FolderScopeOption` = `{ id: FolderId, name: String, breadcrumb: List<String> }` (breadcrumb is root→leaf including the folder itself; `parentBreadcrumb` drops the leaf for parent context).

Pure read path that lists **every** folder as a flat scope option. Unlike `GetFolderMoveTargetsUseCase`, it performs **no** move validation and **no** descendant exclusion. Backed by the existing `FolderDao.listAllFolders()` + `getBreadcrumbNames()` (no schema change). Used by the Dashboard "Start new learning" scope picker (Folder scope). Impl: `FolderRepositoryImpl.listAllFolders`; provider `listAllFoldersUseCaseProvider`.

## Forbidden patterns

- ❌ Update `content_mode` without a transaction that also touches children.
- ❌ Allow `content_mode` transition that violates the lock rule.
- ❌ Delete without confirming via dialog (caller responsibility).
- ❌ Move folder into a `decks`-mode parent.
- ❌ Skip `sort_order` recomputation on move/insert.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/folder/folder-management.md`
**Repository:** `docs/contracts/repository-contracts/folder-repository.md`
**Wireframes:** `docs/wireframes/02-library.md`, `docs/wireframes/05-folder-detail.md`
**Decision table:** rows F1-F13
**Code paths:** `lib/domain/usecases/folder/**`
