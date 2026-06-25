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
| 6 | 09-flashcard-history | 3ed00ea | binding-contract test | header → MxCard; FE already correct. |
| 7 | 23-audio-speech | 5f4a844 | binding-contract test | preview-card → MxCard, preview-button → MxSecondaryButton; FE already correct. |
| 8 | 17-study-result | a87fa79 | binding-contract test | done-button → MxPrimaryButton, close-btn → MxIconButton; FE already correct. |
| 9 | 11-tag-management | 51b30f0 | binding-contract test | search-dock → MxScopedSearchDock (scoped variant, aliased — same as 06). |
| 10 | 05-library-search | 006110c | binding-contract test | search-dock → MxSearchDock (global dock, no alias); FE already correct. |
| 11 | 10-deck-import | bdf46d3 | binding-contract test | empty-card/file-chip/result-card → MxCard, choose-file → MxPrimaryButton (per-state); FE already correct. |

## Decisions needing owner confirmation

- **06-flashcard-list & 11-tag-management / search-dock — component alias (NOT a raw
  bypass).** The kit's generic `search-dock` maps to `MxSearchDock`, but both FEs
  realize it with the scoped sibling **`MxScopedSearchDock`** (deck-scoped /
  tag-scoped search). This is deliberate and required: `MxScopedSearchDock`'s own
  doc states plain `MxSearchDock` *"cannot host an external controller"*, which the
  scoped searches need. Resolved by aliasing `MxSearchDock → MxScopedSearchDock` in
  each screen's binding test (same mechanism as learning-settings' `MxBottomNav`
  alias) — the assertion stays strong (must be the scoped dock, not a raw widget).
  05-library-search, by contrast, uses the plain global `MxSearchDock` directly (no
  alias). **Owner: OK to accept the scoped variant on 06/11, or reconcile the kit's
  `search-dock` mapping (e.g. a distinct scoped class in the kit)?**

## Skipped — no binding test (intentional, not a defect)

These screens have a parity test (presence is covered) but their kit nodes carry
**no concrete component** in the binding contract (all `component: null` — content
containers / rows / sections only), so a binding-contract test would assert nothing.
Per the loop's rule, no empty test was added:

- **flashcard-editor** (create + edit) — form fields only, no kit component nodes.
- **25-language** — selectable list rows only, no kit component nodes.
- **24-appearance** — theme-list only (content container, null component).
- **dashboard** — its parity test keys nodes without a screen-id-prefixed binding
  entry; covered by its own parity test (PR #-engagement). Revisit if its binding
  contract gains concrete components.

18-stats was NOT done: its `mastery-section` binds **MxSectionHeader**, a KNOWN gap
(no Flutter class yet — `tool/parity/symbol-aliases.json` componentGaps). It needs
an owner decision (build `MxSectionHeader`, or retag the kit) before a binding test
can assert that node. **Owner: decide MxSectionHeader (affects 04,05,11,13,18,19,23
specs).**

## Final summary (loop ended)

Branch `feat/overnight-fe-sync`, 11 commits, NOT pushed — review + merge to main.

**Outcome:** every built screen with a concrete kit-component binding now has an
enforced **binding-contract test** (`expectGeneratedBindingContract`) that fails if
the FE keeps a node's `ValueKey` but swaps in the wrong widget (a design-system
bypass the presence contract can't catch). 11 screens locked in:
03-library, 04-folder-detail, 06-flashcard-list, 20-settings, 21-account-sync,
09-flashcard-history, 23-audio-speech, 17-study-result, 11-tag-management,
05-library-search, 10-deck-import. All FEs already realized the kit components —
this run found **zero raw bypasses** and surfaced **two intentional scoped-dock
variants** (06, 11) for confirmation. Remaining screens are all-null (nothing to
assert) or owner-decision (MxSectionHeader gap). The binding contract is wired into
`tool/verify/run.mjs`, so these stay enforced on every future change.
