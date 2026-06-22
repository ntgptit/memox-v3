# Screen 06 — Flashcard list — parity plan

Source: `docs/system-design/MemoX Design System/ui_kits/mobile/specs/06-flashcard-list.md`
+ `.../shots/06-flashcard-list--*--{light,dark}.png`.
FE: `lib/presentation/features/decks/screens/flashcard_list_screen.dart`
+ `lib/presentation/features/decks/widgets/flashcard_list_body.dart` (+ flashcard_tile, flashcard_list_actions, flashcard_list_search).
Audit: 2026-06-23.

## diff.py baseline (golden ↔ kit shot, tolerance 16, threshold 100)

> % inflated by Ahem text rendering; relative signal only.

| Kit state | golden (name) | light | dark |
| --- | --- | --- | --- |
| loaded | flashcard_list_loaded | 14.73% | 20.04% |
| empty | flashcard_list_empty | 17.12% | 19.69% |
| loading | flashcard_list_loading | 2.10% | 6.17% |
| error | flashcard_list_error | 14.02% | 16.83% |
| reorder | flashcard_list_reorder | 10.00% | 18.74% |
| search-empty | flashcard_list_search-no-results | 10.05% | 12.47% |
| delete-card | **shared** | — | — |
| delete-deck | **shared** | — | — |

## STATE COVERAGE (kit = 8 states)

| Kit state | golden | FE branch | Note |
| --- | --- | --- | --- |
| loaded | yes | `_content` → `_groupedCard` (FlashcardTile) | + loaded-due extra golden |
| empty | yes | `MxEmptyState` (bare) | **bare; kit = CENTERED card** |
| search-empty | yes | `MxNoResultsState` | |
| loading | yes | `LibraryLoadingSkeleton` | closest |
| error | yes | `MxErrorState` (bare) | **bare; kit = CENTERED card** |
| reorder | yes | `_reorderContent` (`ReorderableListView`, `_ReorderRow`) | drag handle |
| delete-card | covered (shared) | `runDeleteCard` → `MxConfirmDialog` destructive | shared `mx_confirm-destructive` golden |
| delete-deck | covered (shared) | deck delete → `MxConfirmDialog` destructive | shared `mx_confirm-destructive` golden |

## INVENTORY — Loaded base state

| Node (spec) | mx / token | font | FE widget | Divergence | Scope |
| --- | --- | --- | --- | --- | --- |
| appbar back | MxIconButton arrow-left 20 | — | `MxAppBar` back | verify | Current |
| appbar-title "Japanese · N5" | color:text | 24/700 -0.5 | `MxAppBar title` | verify | Current |
| appbar overflow | MxIconButton more-vertical 20 | — | `flashcard_list_actions` | verify glyph/size | Current |
| breadcrumb (3 levels) | row gap4, crumb 14/600 text-2, active 14/700 text, chevron16 | — | breadcrumb (shared) | verify | Current |
| overline "142 CARDS" | 12/700 tracking1 text-2 | — | `_Overline` (labelMedium) | verify 12/700 tracking1 | Current |
| due badge "23 due" | solid accent pill, accent-contrast text | 11/700 | `_DueBadge` (already SOLID accent ✓) | verify pad/weight | Current |
| list-card | MxCard pad 8/16 r20 border shadow-sm | — | `_groupedCard` MxCard | matches | Current |
| flashcard row | gap12 pad12/8 minh48 r14 | — | `FlashcardTile` | audit (chevron/status chip/icon-tile) | Current |
| row icon-tile | MxIconTile 40 r14 tint icon20 | — | FlashcardTile tile | verify glyph + tint | Current |
| row main | col gap3 | front—back 16/600 text; meta "Box N · due in Nd" 13/400 text-2 | FlashcardTile | verify | Current |
| row status chip | "Review/Learning/New/Mastered" colored pill | 11/700 | FlashcardTile status chip | audit chip color tokens + typography | Current |
| row chevron | chevron-right 20 | — | FlashcardTile chevron | likely 24→20 (cf. 03/04) | Current |
| FAB (add card) | bg accent r18 shadow md, + icon 24 | — | FAB | verify | Current |
| search dock | bottom search field "Search cards" r14 border | — | `flashcard_list_search` | verify persistent bottom field | Current |
| bottom-nav | shell-owned | — | shell | not in screen golden | Current |

## Non-base state deltas

- **Empty** (kit): **CENTERED** card (outer `grid align:center grow:1`; card rel y151 in 614-tall body), card 330w pad24 r20 border shadow-sm; tile-lg 56 solid accent + `square-stack` icon; title 22/800 -0.4 "No cards yet"; muted 14/400/21; two buttons (Add card primary + Import cards secondary). FE `MxEmptyState` **bare** + tile 48 + title titleLarge18 → needs CENTERED card-wrap + shared inner-panel token fixes.
- **Error** (kit): CENTERED card, danger-tonal tile + alert-triangle, title + Retry. FE `MxErrorState` bare + cloud_off icon.
- **Loading**: `LibraryLoadingSkeleton` (shared) — closest (2-6%).
- **Search-empty**: `MxNoResultsState`.
- **Reorder**: `_ReorderRow` with trailing `drag_indicator` (textTertiary, default 24) — kit drag handle likely 20.
- **Delete-card / delete-deck**: `MxConfirmDialog` destructive → shared `mx_confirm-destructive` golden.

## GAP checklist (ordered)

1. **Empty + error CENTERED card-wrap** — ✅ WP DONE (2026-06-23): added `centered` (scroll-safe) variant
   to shared `MxStateCard` (`LayoutBuilder → SingleChildScrollView → ConstrainedBox(minHeight) → Center`);
   applied to flashcard empty + error. Card now renders centered like the kit. diff.py ~flat (empty
   17.12→17.54, error 14.02→14.31) because the FE content was ALREADY centered (MxEmptyState's Center) —
   the change adds the card chrome; remaining inner-panel gaps + missing button offset it under Ahem.
   REMAINING for 06 empty: (a) **missing "Import cards" secondary button** — kit empty has TWO buttons
   (Add card primary + Import cards secondary outlined); FE has only "Add card" → NEW GAP (see #6 below);
   (b) inner-panel 56 tile (solid accent) / 22-800 title → needs-token (shared, deferred).
2. **FlashcardTile audit** — ✅ DONE (2026-06-23): chevron ALREADY `MxIconSize.md` (20) ✓; title
   "front — back" 16/600 ✓; meta "Box N · due in Nd" / "New · not studied" 13/400 text-2 ✓; icon-tile
   accent + copy_all glyph ✓. REMAINING = needs-schema (documented in `flashcard_tile.dart`): the kit
   draws a status **chip** (Review/Learning/Mastered) + per-status tile color, but the SRS model is
   New/Due only (`docs/business/srs/srs-review.md`) — no taxonomy to back it. DEFER needs-schema.
3. **Reorder drag-handle** — ✅ WP DONE (2026-06-23): `_ReorderRow` `Icons.drag_indicator` 24→20
   (`MxIconSize.md`) — kit `grip-vertical` rel 20x20. diff.py reorder 10.00→9.96 / 18.74→18.72.
4. **Search dock**: confirm `flashcard_list_search` renders the persistent bottom "Search cards"
   field (kit loaded shows it pinned) — field r14 + border.
5. **_Overline count-suffix shade** (same as 04 GAP #2; deferred low-value).
6. **Empty-state "Import cards" secondary button** (NEW) — kit empty has Add card (primary) + Import
   cards (secondary outlined); FE empty has only Add card. Add an `MxSecondaryButton(outlined)` calling
   the deck-import entry — verify the import action/route is reachable from here first (may be
   behavior/needs-verification). WP candidate.

## Behavior-owned / shared deltas
- Error icon cloud_off vs kit alert-triangle (Lucide↔Material accepted); error copy from ARB.
- delete-card/deck → shared confirm golden (no 06-framed golden needed).
- Inner-panel 56 tile / 22-800 title / 13-600 label → needs-token (shared, see parity-deferred).
