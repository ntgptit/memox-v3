# Screen 03 — Library overview — parity plan

Source: `docs/system-design/MemoX Design System/ui_kits/mobile/specs/03-library-overview.md`
+ `.../shots/03-library-overview--*--{light,dark}.png`.
FE: `lib/presentation/features/folders/screens/library_overview_screen.dart`
+ `lib/presentation/features/folders/widgets/library_overview_body.dart` (+ tiles/states).
Audit: 2026-06-23.

## diff.py baseline (golden ↔ kit shot, tolerance 16, threshold 100)

> NOTE: existing goldens render text with the Flutter test font (Ahem-style boxes),
> so % is inflated by glyph rendering vs the real-text shots. Use it as a **relative**
> per-state signal + structural cross-check, not an absolute pixel verdict.

| State | light | dark |
| --- | --- | --- |
| loaded | 14.19% | 17.24% |
| loading | 2.49% | 4.34% |
| empty | 18.36% | 21.43% |
| error | 17.49% | 20.93% |
| search | 6.34% | 8.21% |
| overflow-sheet | (no golden yet) | (no golden yet) |

## STATE COVERAGE (kit = 6 states)

| Kit state | golden present | FE branch | Note |
| --- | --- | --- | --- |
| loaded | yes | `_content` → `_groupedCard` | + root-anchor row (redesign) |
| loading | yes | `LibraryLoadingSkeleton` | closest to parity (2–4%) |
| empty | yes | `MxEmptyState` | highest divergence |
| error | yes | `MxErrorState` | icon/retry-icon differ |
| search | yes | `_CountOverline` + `LibrarySearchDock` | |
| overflow-sheet | **MISSING golden** | `showFolderActionsSheet` | add golden (`library_overview_overflow-sheet__{light,dark}`) |
| (extra) search-no-results | yes | `MxNoResultsState` | app state, not a kit state — keep |

## INVENTORY — Loaded base state (canonical structure)

| Node (spec) | rel bbox | mx / token | font | FE widget | Divergence | Scope |
| --- | --- | --- | --- | --- | --- | --- |
| appbar | 0,0 388x56 | MxAppBar, pad 0/20, gap8 | — | `MxAppBar` | — | Current |
| appbar-title "Library" | 20,13 78x30 | color:text | 24/700 tracking -0.5 | `MxAppBar title` | verify size 24/700 + tracking -0.5 | Current |
| icon-btn (sort) | 328,8 40x40 | MxIconButton r999 | — | `MxIconButton swap_vert` | glyph: kit `arrow-up-down`; FE `Icons.swap_vert` (≈) | Current |
| icon-btn (search) | — (NOT in kit) | — | — | `MxIconButton search` | **EXTRA** redesign affordance → behavior-owned, keep | Current/redesign |
| (root anchor row) | — (NOT in kit) | — | — | `LibraryRootAnchor` | **EXTRA** redesign breadcrumb root → nav-owned, keep | Current/redesign |
| body div | 0,56 388x636 | pad 12/20/40/20, col gap16 | — | `ListView` + Column | verify outer pad 20/H, top 12, bottom 40; inter-block gap 16 | Current |
| list-card | 20,12 348x342 | bg accent-contrast, r20, border 1px divider, shadow 1/2, pad 8/16 | — | `MxCard` (pad H=card, V=space2) | verify r20 / border divider / shadow `sm` / pad 8 V & 16 H | Current |
| list-row | 9,9 330x64 | r14, pad 12/8, margin 0/-8, gap12, align center, minh48 | — | `LibraryFolderTile` | verify gap 12, row pad 12 V / 8 H, minh 48 | Current |
| icon-tile | 8,12 40x40 | MxIconTile r14, bg folder-color @8% | — | `LibraryFolderTile` icon tile | verify 40x40, r14, tint @8% per folder color | Current |
| icon (folder glyph) | 10,10 20x20 | per-folder lucide | — | folder icon | size 20; glyph mapping per folder | Current |
| list-row-main | 60,12 230x40 | col gap3 | — | tile main col | verify gap 3 | Current |
| list-row-title | 0,0 230x21 | color:text | 16/600 | title text | verify 16/600 | Current |
| list-row-meta "N decks · N cards" | 0,24 230x16 | color:text-2 | 13/400 | meta text | verify 13/400, color text-2 | Current |
| list-row-trail chevron-right | 302,22 20x20 | — | — | trailing chevron | size 20, glyph chevron-right | Current |
| hr (inter-row) | margin-left 52 | bg divider 1px | — | `MxDivider indent: space10+space3=52` | inset 52 ✓ | Current |
| fab | 312,620 56x56 | bg accent, r18, shadow 2/8, icon folder-plus 24 | — | `MxFab create_new_folder_outlined` | verify 56x56, r18, shadow `md`, icon 24 | Current |
| bottom-nav | 0,692 388x64 | MxBottomNavigationBar, h64, border-t 1px divider, bg white@88% | 11/600 (active 700 accent) | shell-owned `MxBottomNavigationBar` | NOT in screen golden (shell scope); verify in shell | Current |

## Non-base state deltas

- **Empty** (`MxEmptyState`): card pad **24**; `tile-lg` 56x56 r14 **bg accent**, icon `folder-open` 24; title **22/800 tracking -0.4**; muted **14/400 lh21** color text-2 maxw 280; `pill-btn` "Create folder" bg accent r999 **14/700** color accent-contrast, icon `folder-plus` 16. → verify MxEmptyState matches tile size 56/r14, title 22/800/-0.4, body lh21/maxw280, button pill 14/700 + leading icon 16.
- **Error** (`MxErrorState`): same shell as empty but `tile-lg` **bg danger@12%**, icon `alert-triangle`; title "Couldn't load library"; `pill-btn` "Retry" icon `rotate-ccw`. → FE uses `Icons.cloud_off_outlined` (vs alert-triangle) + `Icons.refresh` (vs rotate-ccw). Icon-glyph divergence (visual) — candidate fix.
- **Loading** (`LibraryLoadingSkeleton`): card 4 skeleton rows; each = skeleton tile 40x40 r14 bg surface-2 + 2 skeleton lines (144x14, 100x11) r10, row gap12, inner gap8. → verify count 4, sizes, surface-2, r10/r14.
- **Search**: count overline "N folders" **12/700 tracking 1** color text-2 above card; `search-dock` pinned bottom: field r14 border, search icon left 20, x icon right 20, dock pad 12/20 bg white@88% border-t divider. → FE `_CountOverline` uses `labelMedium`; verify it resolves to 12/700 tracking 1. `LibrarySearchDock` verify field r14/border + icons.
- **Overflow-sheet**: bottom sheet r28 shadow 8/28, grabber 40x4 r999 bg border; header row = folder icon-tile + title/meta; hr; then Rename (`pencil`), Move to… (`folder-input`), Delete folder (`trash-2`, title color **danger**) action rows, each icon-tile neutral @8% (delete = danger@8%). → verify `showFolderActionsSheet` (in `library_folder_actions_sheet.dart`) sheet radius 28, grabber, action glyphs + danger color; **add golden**.

## GAP checklist (concrete, ordered by impact)

1. **Empty + error empty-state visual** — ✅ WP-1 DONE (2026-06-23): card-wrap + top-anchor at library body (`_panelInCard`); error 17.49→8.73% / 20.93→10.46%, empty 18.36→16.04% / 21.43→19.03%. REMAINING (deferred → shared-widget WP, needs-token): tile-lg 56/r14 (no 56 token), solid-accent empty tile vs tonal error, title 22/800 tracking -0.4 (no slot), body lh21 maxw280, pill 14/700 + 16px icon.
2. **Error icon glyphs** (visual): `cloud_off_outlined`→`alert-triangle` equivalent; `refresh`→`rotate-ccw` equivalent (subject to available Material/icon set; if no close glyph → needs-token/icon defer).
3. **Loaded list-row/card metrics**: confirm card r20 + divider border + shadow `sm`, row gap12/pad, title 16/600, meta 13/400 text-2, chevron 20.
4. **Loading skeleton**: confirm 4 rows + skeleton sizes + surface-2 + radii.
5. **Search**: confirm overline 12/700 tracking 1; search-dock field r14/border + icons.
6. **Overflow-sheet golden**: add light+dark golden + confirm sheet r28, grabber, action glyphs, delete danger color.

## Behavior-owned visual deltas (do NOT "fix" to kit — see parity-deferred.md)

- App-bar **search icon** (kit loaded has only sort) — mounts in-screen folder-search dock (redesign).
- **LibraryRootAnchor** row under app bar (kit loaded has none) — breadcrumb root (redesign).
