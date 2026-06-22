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

1. **Empty + error card-wrap** — ✅ WP DONE (2026-06-23): created shared `MxStateCard`
   (`lib/presentation/shared/widgets/states/mx_state_card.dart`), retired library's local
   `_panelInCard` (now uses `MxStateCard`), and applied it to folder_detail empty + error.
   diff.py: empty 20.85→17.24% (light) / 24.41→20.23% (dark); error 17.00→12.19% / 20.59→14.27%.
   Also fixed a latent WP-3 staleness: folder_detail_subfolders golden picked up the
   `LibraryFolderTile` chevron 24→20 (WP-3 only regenerated library goldens). Remaining empty
   residual = shared inner-panel (56 tile / 22-800 title, needs-token).
2. **Decks overline count color**: kit splits "DECKS" (text-2) + count suffix (text-3); FE `_Overline` likely single color. Verify/fix (shared `_Overline` is duplicated in library + folder bodies — candidate to share). NOTE (future): a `_DueBadge` now exists in 3 places — `deck_tile.dart` (solid, this WP), `flashcard_list_body.dart` (solid), `library_folder_tile.dart` (soft). Candidate to lift to a shared `MxDueBadge({variant: soft|solid})` alongside the `_Overline` dedup, to stop the three drifting.
3. **DeckTile audit** — ✅ WP DONE (2026-06-23): chevron 24→20 (`MxIconSize.md`); due chip soft→SOLID
   (was accentSoft bg + accent text; now `accent` bg + `accentContrast` white text + pad h12) to match
   kit `04 decks` (bg:accent, color:accent-contrast, pad 0/12). Title 16/600 (titleMedium) ✓, meta
   13/400 textSecondary (bodySmall) ✓, leading tile accent-tint icon20 ✓. Residual: chip weight is
   labelSmall 11/600 vs kit 11/700 (no 11/700 role; <neg). decks diff ~13% Ahem-noise-dominated;
   chip now visually solid-indigo matching the shot. Goldens: folder_detail_decks + deck_tile_studied.
4. **FolderStatsCard audit** — ✅ WP DONE (2026-06-23): value typography titleLarge(18/600)→
   displayMedium(26/700 -0.5) — kit value is 26/800 -0.5 (no 26/800 role; weight 700 residual).
   Col padding vertical12→ pad 8/4 (V space2 / H space1) per kit. 3 equal Expanded cols ✓; Due col
   highlighted accentSoft + accent value/label ✓. Residual: label 11/600 (labelSmall) vs kit 13/600
   — no 13/600 role (needs-token). NOTE: diff.py rose (decks 13.04→13.46, subfolders 10.96→11.39)
   because the now-correct 26px value renders as larger Ahem blocks — value size is RIGHT (verified
   visually); diff.py penalizes text enlargement under Ahem rendering.
5. **delete-confirm golden** (missing state).
6. **move-sheet golden** (missing state).

## Consolidation (empty/error card-wrap) — DONE (2026-06-23)

The card-wrapped, top-anchored empty/error panel recurs in screens 03 + 04. Library WP-1 first
implemented it via a local `_panelInCard` in `library_overview_body.dart`; repeating that in
`folder_detail_body.dart` would be the "vá lẻ" anti-pattern CLAUDE.md forbids. Resolved with an
**opt-in shared wrapper** `MxStateCard` (`lib/presentation/shared/widgets/states/mx_state_card.dart`)
= `ListView(vertical space3) → MxCard(padding: zero, child)`:

- Library now uses `MxStateCard` (local `_panelInCard` retired) — pure refactor, goldens unchanged.
- Folder detail empty + error now use `MxStateCard` (were bare-centered).
- Full-screen consumers (study modes) keep passing the bare `Mx*State` panel (no card) — the wrapper
  is opt-in, so pushing a card into the shared `MxEmptyState`/`MxErrorState` (which would break them)
  was deliberately avoided. No cross-consumer mock audit needed.

## Behavior-owned deltas (do NOT "fix" to kit)
- Error button: kit "Back to library"; FE "Retry" → behavior-owned (copy from ARB). Visual gap noted.
- Error icon: cloud_off vs kit alert-triangle (cf. 03 GAP #2; Lucide↔Material accepted repo-wide).
