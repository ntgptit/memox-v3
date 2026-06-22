# Parity Loop — State (pointer / HINT only)

> This file is a **cursor**, not a source of truth about DONE. "Parity OK" here is a
> hint; the only proof of parity is `python tool/golden_diff/diff.py <golden> <shot>`
> PASS + `ui-parity-checker` PASS + full INVENTORY/STATE coverage. Re-verify, don't trust.

Loop goal: bring each FE-built screen to pixel parity with the UI kit
(`docs/system-design/MemoX Design System/ui_kits/mobile/`), one smallest work-package
per loop. Visual-only; behavior is docs-owned.

## Active screen

- **FE inventory confirmed**: only 5 feature areas have FE screens — dashboard, decks, folders, search,
  study. Screens WITHOUT FE (no `lib/presentation/features/**` screen) → no-FE-yet, out of scope:
  01 onboarding, 09 history, 10 import, 11 tags, 18 stats, 19 progress, 20-25 settings/account/learning/
  audio/appearance/language. (See parity-deferred no-FE-yet block.)
- **NEXT: 05 Library search** — last remaining FE-built screen to audit (`global_search_screen`).
  02 Dashboard audited (done modulo redesign-deferred — see below). After 05, all FE screens covered →
  sanity check + terminal summary.

### Screen 02 — Dashboard: AUDITED, done (modulo redesign-deferred)
FE = redesigned quiet surface (MxDueSummary + Progress/Library shortcuts); its states (loading/error/
due/caught-up) are golden-covered. Kit 02 = pre-redesign engagement dashboard (streak/accuracy/
continue-studying/recent-decks) → scope/redesign-owned divergence, deferred. See
`screen-plans/02-dashboard.md`.

### Screen 12–17 — Study modes + result: AUDITED, done (modulo deferred)

State coverage complete (12/14/15/16 goldens; 17 loading added; 17 goal-off/tough-empty Future). The FE
study spine intentionally diverges from several kit per-mode mocks at the INTERACTION level (swipe/board/
reveal vs flip+Next) — documented behavior-owned visual gaps (study-flow.md + wireframes 13-17,
`[[study-mode-chain-complete]]`). Shared-token visuals close. Deferred: 17 Future blocks (needs-schema),
per-mode interaction divergences (behavior-owned), per-mode token INVENTORY (low-priority). See
`screen-plans/12-17-study.md`.

### Screen 07/08 — Flashcard editor: DONE (modulo deferred)

All states covered (07 empty/valid/details-open/saving/save-failed + 08 loaded/loading/load-error/
saving/save-failed + delete via shared confirm). create-valid golden added. validation = behavior-owned
(disable-Save, no inline errors). Deferred: field-fill (app-wide), DECK selector (Future), Note→3 fields
(business). dark≈2× = general Ahem amplification. See `screen-plans/07-08-flashcard-editor.md`.

- **07/08 — Flashcard editor** — AUDIT done (see
  `docs/project-management/parity-loop/screen-plans/07-08-flashcard-editor.md`). One shared
  `FlashcardEditorForm`; 7 goldens cover most states. KEY finding: **dark ≈2× light** across editor
  states. INVESTIGATED: dark≈2× is general Ahem-on-dark amplification (all screens), NOT editor-specific;
  the real gap is `MxTextField` fill = surfaceMuted vs kit accent-contrast (=surface) — DEFERRED
  app-wide-coordinated (~20 field goldens). Next WP candidates: 07 valid + 07/08 validation goldens
  (missing states) — these don't need the field-fill change. Deferred: DECK selector (Future), Note→3
  fields (business), field-fill (app-wide).

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
| 07/08 | Flashcard editor | yes | done 2026-06-23 | done (modulo deferred) | create-valid golden added; validation behavior-owned; field-fill/deck-selector/Note deferred |
| 12-17 | Study modes + result | yes | done 2026-06-23 | done (modulo deferred) | states covered; mode interactions behavior-owned (swipe/board vs kit flip); 17 Future blocks deferred |
| 02 | Dashboard | yes | done 2026-06-23 | done (modulo deferred) | FE states golden-covered; kit-02 engagement layout = redesign-deferred (scope-owned) |
| 05 | Library search | yes | — | — | next: audit global_search_screen |
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
