# Parity Loop — State (pointer / HINT only)

> This file is a **cursor**, not a source of truth about DONE. "Parity OK" here is a
> hint; the only proof of parity is `python tool/golden_diff/diff.py <golden> <shot>`
> PASS + `ui-parity-checker` PASS + full INVENTORY/STATE coverage. Re-verify, don't trust.

Loop goal: bring each FE-built screen to pixel parity with the UI kit
(`docs/system-design/MemoX Design System/ui_kits/mobile/`), one smallest work-package
per loop. Visual-only; behavior is docs-owned.

## Active screen

- **06 — Flashcard list** (decks feature) — AUDIT done (see
  `docs/project-management/parity-loop/screen-plans/06-flashcard-list.md`). 8 kit states; 6 goldens +
  delete-card/deck via shared confirm. Key finding: empty/error are bare-centered AND the kit card is
  **vertically CENTERED** (unlike 03/04 top-anchored) → next WP = add a `centered` variant to shared
  `MxStateCard` + apply to flashcard empty/error. Then FlashcardTile audit (chevron 24→20, status
  chip, icon-tile) + reorder drag-handle. `_DueBadge` here already solid accent ✓.

### Screen 04 — Folder detail: DONE (modulo deferred)

All 8 kit states covered (6 folder_detail_* goldens + delete-confirm via shared mx_confirm-destructive
+ move-sheet via shared folder_move_picker). Parity done: empty/error card-wrap (MxStateCard), DeckTile
chevron 24→20 + solid due chip, FolderStatsCard value 18→26 + col pad. Remaining = deferred only:
move-sheet full visual (behavior-conflict + needs-schema), DECKS overline shade (low-value), label
13/600 + empty inner-panel + due-chip 11/700 (needs-token), error icon/button (behavior/copy-owned).
See `screen-plans/04-folder-detail.md`.

### Screen 03 — Library overview: DONE (modulo deferred)

WP-1 empty/error card-wrap · WP-2 overflow-sheet golden (6/6 kit states covered) · WP-3 loaded
chevron 24→20 + loaded metrics audited (card/row/tile/typography all match spec). Loaded/loading/
search residual diff is Ahem test-font noise (structurally correct). Remaining = deferred only:
empty inner-panel (56 tile / 22-800 title, needs-token), modal sheet shadow:8/28 (needs-token),
Lucide↔Material icons (accepted). See `screen-plans/03-library-overview.md`.

## Priority order (FE-built first)

03 Library → 04 Folder → 06 Flashcard list → 07/08 editor → 12 Review → 13 Match →
14 Guess → 15 Recall → 16 Fill → 17 Result → other FE screens.

## Per-screen status

| # | Screen | FE? | Audit | Parity | Notes |
| --- | --- | --- | --- | --- | --- |
| 03 | Library overview | yes | done 2026-06-23 | done (modulo deferred) | WP-1 card-wrap; WP-2 overflow-sheet golden 6/6; WP-3 chevron 24→20 + metrics audited |
| 04 | Folder detail | yes | done 2026-06-23 | done (modulo deferred) | card-wrap; DeckTile chevron+solid-chip; StatsCard value 18→26; 8/8 states covered |
| 06 | Flashcard list | yes | done 2026-06-23 | in-progress | plan written; empty/error bare (kit=CENTERED card); 8/8 states have goldens/shared |
| 06 | Flashcard list | yes (decks) | — | — | |
| 07/08 | Flashcard create/edit | yes (decks) | — | — | |
| 12–17 | Study modes | yes (study) | — | — | |
| 02 | Dashboard | yes | — | — | visual-contract exists |

## Cross-screen note (read before judging "missing" nodes)

The kit shots predate the **2026-06-21 IA redesign** (`[[design-redesign-ia-2026-06-21]]`,
`[[fe-loop-complete-mock-authoritative]]`). Some FE nodes are **approved redesign additions**
absent from the kit (e.g. Library's app-bar search toggle + `LibraryRootAnchor`). These are
behavior/nav-owned: classify as intentional deltas, do NOT delete to match the older kit.
Pixel parity work targets nodes the kit and FE BOTH have.
