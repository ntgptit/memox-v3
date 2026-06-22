# Parity Loop — State (pointer / HINT only)

> This file is a **cursor**, not a source of truth about DONE. "Parity OK" here is a
> hint; the only proof of parity is `python tool/golden_diff/diff.py <golden> <shot>`
> PASS + `ui-parity-checker` PASS + full INVENTORY/STATE coverage. Re-verify, don't trust.

Loop goal: bring each FE-built screen to pixel parity with the UI kit
(`docs/system-design/MemoX Design System/ui_kits/mobile/`), one smallest work-package
per loop. Visual-only; behavior is docs-owned.

## Active screen

- **07/08 — Flashcard editor** — AUDIT done (see
  `docs/project-management/parity-loop/screen-plans/07-08-flashcard-editor.md`). One shared
  `FlashcardEditorForm`; 7 goldens cover most states. KEY finding: **dark ≈2× light** across editor
  states (details-open dark 27.58%) → systematic dark-mode divergence, likely `MxTextField` dark
  fill/border or scaffold bg. **Next WP = investigate + fix MxTextField dark parity** (shared → all
  forms). Deferred (behavior/data-owned): DECK selector (Future), Note→3 fields (business model).
  Missing goldens: 07 valid + 07/08 validation.

### Screen 06 — Flashcard list: DONE (modulo deferred)

All 8 kit states covered. Done: empty/error centered card-wrap (`MxStateCard(centered)`), FlashcardTile
audited (chevron 20 ✓), reorder grip 24→20, search dock built (shared `MxScopedSearchDock`), `_DueBadge`
solid. Remaining deferred: Import-cards button (behavior/no-entry), status chip (needs-schema),
inner-panel 56/22-800 + label 13/600 (needs-token), overline shade (low-value).
See `screen-plans/06-flashcard-list.md`.

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
| 06 | Flashcard list | yes | done 2026-06-23 | done (modulo deferred) | centered card-wrap; FlashcardTile audited; reorder grip 24→20; search dock built; 8/8 covered |
| 07/08 | Flashcard editor | yes | done 2026-06-23 | in-progress | audited; dark ≈2× light → MxTextField dark parity is next WP; deck-selector/Note deferred |
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
