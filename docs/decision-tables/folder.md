---
last_updated: 2026-06-20
source: split from memox-core-decision-table.md
applies_to: Folder behavior branches
---

# MemoX Decision Table — Folder

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: F1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| F1 | Create root | Valid name | Create unlocked root folder | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F2 | Create root | Empty name | Reject | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F3 | Create subfolder | Parent unlocked/subfolders | Create child, parent becomes/stays subfolders | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F4 | Create subfolder | Parent decks | Reject with typed `folder_contains_decks`; Folder Detail stale path shows localized snackbar and creates no subfolder | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F5 | Create deck | Parent unlocked/decks | Create deck, parent becomes/stays decks | C0+C1 | TBD |
| F6 | Create deck | Parent subfolders | Reject with typed `folder_contains_subfolders`; Folder Detail stale path shows localized snackbar and creates no deck | C1 | TBD |
| F7 | Move folder | Target self/descendant | Reject with `cycleDetected`; source parent unchanged | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F8 | Delete folder | Confirmed | Delete nested content safely | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F9 | Delete last child | Folder becomes unlocked | Mode returns to unlocked | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F10 | Reorder folders | Full sibling list | Persist deterministic `sort_order` transactionally (position = list index) | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F11 | Reorder folders | Duplicate/missing/cross-parent/partial list | Reject (`invalidFormat`) and preserve the previous order | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F12 | Deck counts | Folder with direct decks + cards | `deckCount` = direct child decks; `cardCount` includes all cards (incl. NEW); `dueCount` = scheduled cards with `due_at <= now` (NEW excluded). Target also excludes suspended/currently-buried and still counts expired buried — trivially satisfied until those columns ship | C0+C1 | `folder_deck_due_counts_test.dart` |
| F13 | Recursive counts | Cards in descendant folders' decks | Recursive subtree counts: `cardCount` includes all subtree cards; `dueCount` = subtree cards with `due_at <= now` (NEW excluded). Target also excludes suspended/currently-buried and still counts expired buried — trivially satisfied until those columns ship | C0+C1 | `folder_deck_due_counts_test.dart` |
| F14 | Move folder | Valid new parent (unlocked/subfolders) or root; not a no-op | Move; recompute `sort_order` (append); lock an unlocked destination to `subfolders`; revert the emptied old parent to `unlocked` | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F15 | Move folder | New parent locked to `decks` | Reject with typed `folder_contains_decks` (`UnsupportedAction`) | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F16 | Move folder | Duplicate name among destination siblings | Reject with `duplicate` | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F17 | Move folder | Folder or destination missing | Reject with `NotFound` | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F18 | Move targets | List destinations for a folder | Library root + every folder; folder itself and descendants blocked `cycle`; `decks`-locked folders blocked `lockedToDecks`; current parent annotated; blocked never hidden | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F19 | Move folder | New parent equals current parent | No-op: return the unchanged folder, no `sort_order` churn | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F20 | Rename folder | Valid new name (trimmed), differs from current | Rename; reject empty/duplicate-sibling first; bump `updatedAt` | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F21 | Rename folder | Name unchanged AND no color/icon token supplied | No-op: return the unchanged folder | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F22 | Rename folder | Optional `color`/`icon` token supplied (WBS 2.22.1) | Overwrite only the non-null token(s); a null param leaves the stored token unchanged (clearing deferred); applies even when the name is unchanged | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
