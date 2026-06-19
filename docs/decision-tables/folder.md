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
| F12 | Deck counts | Suspended/currently-buried cards present | `cardCount` includes all cards; `dueCount` excludes suspended/currently-buried and still counts expired buried cards | C0+C1 | TBD |
| F13 | Recursive counts | Suspended/currently-buried cards present | Recursive folder overview counts include all cards in `cardCount`; `dueCount` excludes suspended/currently-buried and still counts expired buried cards | C0+C1 | TBD |
| F14 | Move folder | Valid new parent (unlocked/subfolders) or root; not a no-op | Move; recompute `sort_order` (append); lock an unlocked destination to `subfolders`; revert the emptied old parent to `unlocked` | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F15 | Move folder | New parent locked to `decks` | Reject with typed `folder_contains_decks` (`UnsupportedAction`) | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F16 | Move folder | Duplicate name among destination siblings | Reject with `duplicate` | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F17 | Move folder | Folder or destination missing | Reject with `NotFound` | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F18 | Move targets | List destinations for a folder | Library root + every folder; folder itself and descendants blocked `cycle`; `decks`-locked folders blocked `lockedToDecks`; current parent annotated; blocked never hidden | C0+C1 | `test/data/repositories/folder_repository_impl_test.dart` |
| F19 | Move folder | New parent equals current parent | No-op: return the unchanged folder, no `sort_order` churn | C1 | `test/data/repositories/folder_repository_impl_test.dart` |
