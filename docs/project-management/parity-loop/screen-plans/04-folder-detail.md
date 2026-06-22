# Screen 04 — Folder detail — parity plan

Source: `docs/system-design/MemoX Design System/ui_kits/mobile/specs/04-folder-detail.md`
+ `.../shots/04-folder-detail--*--{light,dark}.png`.
FE: `lib/presentation/features/folders/screens/folder_detail_screen.dart`
+ `lib/presentation/features/folders/widgets/folder_detail_body.dart` (+ deck_tile, folder_stats_card,
folder_detail_actions, folder_detail_search).
Audit: 2026-06-23.

## diff.py baseline (golden ↔ kit shot, tolerance 16, threshold 100)

> Same caveat as screen 03: % inflated by Ahem test-font block rendering; use as relative signal.

| Kit state | golden (name) | light | dark |
| --- | --- | --- | --- |
| decks | folder_detail_decks | 12.82% | 15.20% |
| subfolders | folder_detail_subfolders | 10.96% | 13.56% |
| empty-unlocked | folder_detail_empty | 20.85% | 24.41% |
| loading | folder_detail_loading | 1.71% | 5.86% |
| error | folder_detail_error | 17.00% | 20.59% |
| search-empty | folder_detail_search-no-results | 8.27% | 10.27% |
| delete-confirm | **MISSING golden** | — | — |
| move-sheet | **MISSING golden** | — | — |

## STATE COVERAGE (kit = 8 states)

| Kit state | golden | FE branch | Note |
| --- | --- | --- | --- |
| decks | yes | `_content` decksMode → `_groupedCard` (DeckTile rows) | |
| subfolders | yes | `_content` subfoldersMode → `_groupedCard` (LibraryFolderTile rows) | |
| empty-unlocked | yes | `MxEmptyState` (bare) | **bare-centered, no card** → biggest gap |
| loading | yes | `LibraryLoadingSkeleton` | closest to parity |
| error | yes | `MxErrorState` (bare) | **bare-centered, no card** |
| search-empty | yes | `MxNoResultsState` | |
| delete-confirm | **MISSING** | `MxConfirmDialog` (folder delete) | add golden |
| move-sheet | **MISSING** | `showFolderMovePicker` (`folder_move_picker_sheet.dart`) | add golden |

## INVENTORY — Decks base state

| Node (spec) | rel bbox | mx / token | font | FE widget | Divergence | Scope |
| --- | --- | --- | --- | --- | --- | --- |
| appbar back | 20,8 40x40 | MxIconButton, arrow-left 20 | — | `MxAppBar` leading back | verify | Current |
| appbar-title | 76,13 …x30 | color:text | 24/700 -0.5 | `MxAppBar title` | verify 24/700 -0.5 | Current |
| appbar overflow | 328,8 40x40 | MxIconButton, more-vertical 20 | — | `folder_detail_actions` overflow | verify glyph/size | Current |
| breadcrumb row | 0,56 388x26 | pad 0/20/8/20, row gap4 | — | breadcrumb (shared) | verify: Library (icon16 + 14/600 text-2) > chevron16 > current (14/700 text) | Current |
| body div | 0,82 388x610 | pad 12/20/40/20, col gap16 | — | ListView | verify outer pad + gap16 | Current |
| stats card | 20,12 348x80 | MxCard, row gap4, pad8, r20/border/shadow-sm | — | `FolderStatsCard` | verify 3 cols equal; Due col tint accent@12% r14; value 26/800 -0.5, label 13/600; Due value+label color accent | Current |
| decks overline "DECKS {n}" | 0,0 348x15 | row gap8 | 12/700 tracking1 color text-2; count span color text-3 | `_Overline` (labelMedium) | verify 12/700 tracking1; **count suffix color text-3** (FE may not split color) | Current |
| list-card | 0,23 348x… | MxCard pad 8/16, r20/border/shadow-sm | — | `_groupedCard` MxCard | matches (same as 03) | Current |
| deck row | 9,9 330x64 | gap12, pad12/8 margin0/-8, minh48, r14 | — | `DeckTile` | verify (audit DeckTile separately) | Current |
| deck icon-tile | 8,12 40x40 | MxIconTile r14 tint@8% icon20 | — | DeckTile tile | verify | Current |
| deck main | 60,12 …x40 | col gap3 | title 16/600 text; meta 13/400 text-2 ("{n} cards · last {t} ago") | DeckTile | verify; meta copy from ARB | Current |
| deck trail chip "{n} due" | — | accent pill, pad0/12, r999 | 11/700 tracking0.1 color accent-contrast | DeckTile due chip | verify chip style + chevron 20 (cf. 03 WP-3) | Current |
| FAB (decks) | — | bg accent r18 shadow md, layers/create-deck icon 24 | — | FAB (decks-mode) | verify | Current |
| bottom-nav | 0,692 388x64 | shell-owned | 11/600 | shell | not in screen golden | Current |

Subfolders state: rows are folder rows (`LibraryFolderTile`, already audited in 03) + stats card shows Subfolders/Decks/Due.

## Non-base state deltas

- **Empty-unlocked**: card (pad 24) + tile-lg 56 solid accent + folder-open icon; title 22/800 -0.4 "Empty folder"; muted 14/400 lh21; two buttons (Create deck primary + Create subfolder secondary outlined). FE `MxEmptyState` **bare-centered** (no card) + tile 48 (same shared-widget gaps as 03).
- **Error**: card + tile-lg 56 danger-tonal + alert-triangle; title 22/800 "Folder not found"; muted; one button "Back to library". FE `MxErrorState` **bare-centered**; icon cloud_off (vs alert-triangle); button is Retry (vs kit "Back to library" — copy from ARB, behavior-owned).
- **Loading**: `LibraryLoadingSkeleton` (shared) — closest (1.7-5.9%).
- **Search-empty**: `MxNoResultsState`.
- **Delete-confirm**: confirm dialog (kit) → FE `MxConfirmDialog`. Add golden.
- **Move-sheet**: move picker bottom sheet → FE `showFolderMovePicker`. Add golden.

## GAP checklist (ordered by impact)

1. **Empty + error card-wrap** (highest %, RECURRING from 03) — folder_detail_body renders `MxEmptyState`/`MxErrorState` bare-centered; kit wraps in the content card anchored top (kit 04 empty-unlocked + error, identical to 03b/03c). **← Decision point: consolidate into shared widget, do NOT add a second `_panelInCard` copy (anti-pattern).** See "Consolidation decision" below. **WP candidate.**
2. **Decks overline count color**: kit splits "DECKS" (text-2) + count suffix (text-3); FE `_Overline` likely single color. Verify/fix (shared `_Overline` is duplicated in library + folder bodies — candidate to share).
3. **DeckTile audit**: chevron size 20 (cf. 03 WP-3 — DeckTile may also default to 24), due chip style (accent pill 11/700 tracking0.1), title/meta typography. Audit `deck_tile.dart`.
4. **FolderStatsCard audit**: 3 equal cols, Due col tint accent@12%, value 26/800 -0.5, label 13/600, Due color accent.
5. **delete-confirm golden** (missing state).
6. **move-sheet golden** (missing state).

## Consolidation decision (empty/error card-wrap) — KEY

The card-wrapped, top-anchored empty/error panel is now confirmed in BOTH screen 03 and 04
(and the same pattern is in the kit's other screens). Library WP-1 implemented it via a local
`_panelInCard` in `library_overview_body.dart`. Repeating that in `folder_detail_body.dart`
would be the "vá lẻ" anti-pattern CLAUDE.md forbids. Preferred lowest-layer fix:

1. Cross-consumer audit (Explore): check the empty/error mocks of the OTHER `MxEmptyState`/
   `MxErrorState` consumers (dashboard, decks/flashcard-list, search, study screens 12-17) —
   do they ALL card-wrap empty/error, or do some (e.g. full-screen study) render bare-centered?
2. If universal → push the card-wrap into shared `MxEmptyState`/`MxErrorState` (or a shared
   `MxStatePanelCard` wrapper) and retire library's local `_panelInCard`. One change fixes all.
3. If NOT universal → add an opt-in `card: true` flag (or shared wrapper) used by 03 + 04, keep
   bare default for full-screen consumers.

This is bigger than a 1-screen WP; do it as a deliberate shared-widget WP next.

## Behavior-owned deltas (do NOT "fix" to kit)
- Error button: kit "Back to library"; FE "Retry" → behavior-owned (copy from ARB). Visual gap noted.
- Error icon: cloud_off vs kit alert-triangle (cf. 03 GAP #2; Lucide↔Material accepted repo-wide).
