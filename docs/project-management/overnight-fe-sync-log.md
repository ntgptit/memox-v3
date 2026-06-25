# Overnight FE-sync loop — log

Autonomous loop (branch `feat/overnight-fe-sync`, not pushed). One screen per
iteration: bring the Flutter FE into sync with the latest kit specs, gate-driven.
Each entry the owner should review before merging.

## Synced

| # | Screen | Commit | What | Note |
| --- | --- | --- | --- | --- |
| 1 | 03-library-overview | 8756363 | binding-contract test | FE already realized kit components (lock-in). |
| 2 | 04-folder-detail | 6ddb440 | binding-contract test | both content modes; FE already correct. |
| 3 | 06-flashcard-list | 4bd8717 | binding-contract test | ⚠ see decision below (search-dock alias). |
| 4 | 20-settings | 3a2c8e3 | binding-contract test | account-card → MxCard; FE already correct. |
| 5 | 21-account-sync | adeec33 | binding-contract test | signin-card → MxCard, signin-button → MxPrimaryButton; FE already correct. |
| 6 | 09-flashcard-history | (this commit) | binding-contract test | header → MxCard; FE already correct. |

## Decisions needing owner confirmation

- **06-flashcard-list / search-dock — component alias (NOT a raw bypass).**
  The kit's generic `search-dock` maps to `MxSearchDock`, but the FE realizes it
  with the deck-scoped sibling **`MxScopedSearchDock`** (`FlashcardListSearchDock`).
  This is deliberate and required: `MxScopedSearchDock`'s own doc states plain
  `MxSearchDock` *"cannot host an external controller"*, which deck-scoped search
  needs. Resolved by aliasing `MxSearchDock → MxScopedSearchDock` in the screen's
  binding test (same mechanism as learning-settings' `MxBottomNav` alias) — the
  assertion stays strong (must be the scoped dock, not a raw widget). **Owner: OK
  to accept this variant, or reconcile the kit's `search-dock` mapping?**

## Skipped (owner decision / blocked)

_(none yet)_
