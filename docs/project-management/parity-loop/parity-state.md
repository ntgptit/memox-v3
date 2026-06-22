# Parity Loop — State (pointer / HINT only)

> This file is a **cursor**, not a source of truth about DONE. "Parity OK" here is a
> hint; the only proof of parity is `python tool/golden_diff/diff.py <golden> <shot>`
> PASS + `ui-parity-checker` PASS + full INVENTORY/STATE coverage. Re-verify, don't trust.

Loop goal: bring each FE-built screen to pixel parity with the UI kit
(`docs/system-design/MemoX Design System/ui_kits/mobile/`), one smallest work-package
per loop. Visual-only; behavior is docs-owned.

## Active screen

- **04 — Folder detail** — AUDIT done; empty/error card-wrap DONE (shared `MxStateCard`, used by
  03+04). See `docs/project-management/parity-loop/screen-plans/04-folder-detail.md`.
  DeckTile + FolderStatsCard done. Next WP candidates: GAP #2 DECKS overline count color (text-3
  suffix; `_Overline` duplicated in library+folder → candidate to share); GAP #5/6 delete-confirm +
  move-sheet goldens (missing states). Then screen 04 essentially done modulo needs-token (label
  13/600, empty inner-panel 56/22-800).

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
| 04 | Folder detail | yes | done 2026-06-23 | in-progress | card-wrap; DeckTile chevron+solid-chip; StatsCard value 18→26; 6/8 goldens |
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
