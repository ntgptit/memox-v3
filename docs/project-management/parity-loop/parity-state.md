# Parity Loop — State (pointer / HINT only)

> This file is a **cursor**, not a source of truth about DONE. "Parity OK" here is a
> hint; the only proof of parity is `python tool/golden_diff/diff.py <golden> <shot>`
> PASS + `ui-parity-checker` PASS + full INVENTORY/STATE coverage. Re-verify, don't trust.

Loop goal: bring each FE-built screen to pixel parity with the UI kit
(`docs/system-design/MemoX Design System/ui_kits/mobile/`), one smallest work-package
per loop. Visual-only; behavior is docs-owned.

## Active screen

- **03 — Library overview** — AUDIT done (see `docs/project-management/parity-loop/screen-plans/03-library-overview.md`).
  Next work-package: TBD from the plan's GAP checklist.

## Priority order (FE-built first)

03 Library → 04 Folder → 06 Flashcard list → 07/08 editor → 12 Review → 13 Match →
14 Guess → 15 Recall → 16 Fill → 17 Result → other FE screens.

## Per-screen status

| # | Screen | FE? | Audit | Parity | Notes |
| --- | --- | --- | --- | --- | --- |
| 03 | Library overview | yes | done 2026-06-23 | in-progress | plan written; diff.py baseline captured |
| 04 | Folder detail | yes | — | — | |
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
