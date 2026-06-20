---
last_updated: 2026-06-19
source: split from memox-core-decision-table.md
applies_to: Deck behavior branches
---

# MemoX Decision Table — Deck

## Convention
- `ID` is stable. Tests reference it by ID (e.g. `// decision: D1`).
- `Coverage`: C0 = happy path, C1 = branch coverage.
- `Test` column: `TBD` until the implementing agent writes the test.
  Tests must be derived from the Expected column, NOT from code.

| ID | Event | Condition | Expected | Coverage | Test |
|----|-------|-----------|----------|----------|------|
| D1 | Create deck | Valid folder/name | Persist deck (append `sort_order`, lock unlocked folder to decks) | C0+C1 | `folder_repository_impl_deck_test.dart` |
| D2 | Create deck | Empty name | Reject | C1 | `folder_repository_impl_deck_test.dart` |
| D3 | Delete deck | Confirmed | Delete deck and dependent data (flashcards + progress + tags via ON DELETE CASCADE); revert source folder to `unlocked` when its last deck leaves; missing deck → `NotFoundFailure` | C0+C1 | `folder_repository_impl_delete_deck_test.dart`, `test/domain/usecases/deck/delete_deck_usecase_test.dart` |
| D4 | Reorder | Manual sort active | Persist deterministic `sort_order` transactionally | C0+C1 | `folder_repository_impl_deck_test.dart` |
| D5 | Start study | Empty deck | Do not create session | C1 | TBD (deferred — study flow, WBS 4.x) |
| D6 | Rename deck | Trimmed valid title | Update name only; preserve folder ownership and `sort_order` | C0+C1 | `folder_repository_impl_deck_test.dart` |
| D7 | Rename deck | Blank title | Reject | C1 | `folder_repository_impl_deck_test.dart` |
| D8 | Reorder decks | Duplicate/missing/cross-folder/partial list | Reject and preserve the previous order | C1 | `folder_repository_impl_deck_test.dart` |
| D9 | Move deck | Target folder allows decks | Move to the target folder, append at the end, and update source/target folder modes transactionally | C0+C1 | `folder_repository_impl_move_deck_test.dart` |
| D10 | Move deck | Target folder missing / subfolders / duplicate sibling / same folder | Reject missing or disallowed destinations, reject duplicate sibling names case-insensitively, and no-op on same folder | C1 | `folder_repository_impl_move_deck_test.dart` |
