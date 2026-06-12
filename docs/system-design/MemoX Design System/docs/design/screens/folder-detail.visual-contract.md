---
last_updated: 2026-06-06
status: contract
route: /library/folder/:id
screen: Folder Detail
mock_source: "docs/system-design/MemoX Design System/ui_kits/mobile/index.html — 04 · Folder detail"
---

# Folder Detail Visual Contract

Source of truth for mapping the approved **Folder Detail** mock to the existing
Flutter implementation. This contract is written against the **code on this ref**
(`folder_detail_screen.dart` and the `features/folders/**` widgets), not the
aspirational sections of `docs/wireframes/05-folder-detail.md`.

> ⚠️ **Read this first — doc/code conflict.** `05-folder-detail.md` ("Prompt
> 45/47/50") describes a **hero mastery card**, **Study folder / Today CTAs**,
> a **Resume banner**, and an **overflow ⋮ action menu** as *Current*. The
> shipped `folder_detail_screen.dart` now renders the overflow folder actions
> sheet, plus the mastery shell, search/sort affordances, and a Start study CTA
> shell. The study layer itself is still not built, so the mastery value and
> Start study flow remain **visual-only**. This contract follows the **current
> code path** plus the canonical PNG mock. See §16.

## 1. Screen identity

- **Screen name:** Folder Detail
- **Route:** `/library/folder/:id` (`RoutePaths.folderDetailTemplate`,
  `RouteNames.folderDetail`); built via `RoutePaths.folderDetail(folderId)`.
- **Feature / module:** `folders` (`lib/presentation/features/folders/**`).
- **User purpose:** Browse the children of one folder - **either** subfolders
  **or** decks, never both - with breadcrumb navigation, a mode-constrained
  create action, and visible search/sort affordances.
- **Mock source:** `index.html` group `04 · Folder detail` (states: decks ·
  subfolders · unlocked · search empty · loading · error · delete · move sheet).
- **Related business docs:** `docs/business/folder/folder-management.md`,
  `docs/business/deck/deck-management.md`.
- **Related wireframe:** `docs/wireframes/05-folder-detail.md`.
- **Related UI/UX docs:** `docs/ui-ux/ui-ux-contract.md`,
  `docs/design/design-token-mapping.md`, `docs/design/component-visual-contract.md`.
- **Related state docs:** `docs/state/state-management-contract.md`;
  `folder_detail_viewmodel.dart` (toolbar + query + action providers).
- **Existing Flutter implementation files:**
  - `lib/presentation/features/folders/screens/folder_detail_screen.dart`
  - `lib/presentation/features/folders/widgets/folder_detail_body.dart`
  - `lib/presentation/features/folders/widgets/folder_deck_tile.dart`
  - `lib/presentation/features/folders/widgets/folder_subfolder_tile.dart`
  - `lib/presentation/features/folders/widgets/folder_unlocked_empty.dart`
  - `lib/presentation/features/folders/widgets/library_folder_tile.dart` (Library Overview rows)
  - `lib/presentation/features/folders/widgets/library_folder_actions_sheet.dart`
  - `lib/presentation/features/folders/widgets/folder_move_picker_sheet.dart`
  - `lib/presentation/features/folders/widgets/library_skeleton.dart`
  - `lib/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart`
  - `lib/presentation/features/folders/routes/folder_routes.dart`
- **Scope status:** **Partial.**
- **Out-of-scope items (Future / Visual-only):** study routing and session
  behavior. The visible mastery card, "{n} new" subtitle, Start study CTA,
  search icon, sort pill, and overflow sheet are currently shell UI here.

## 2. Source priority

1. V1 scope / business: `docs/business/folder/folder-management.md`,
   `docs/business/deck/deck-management.md`.
2. Wireframe behavior/states: `docs/wireframes/05-folder-detail.md` (heed its
   `Forbidden`/`Rules`/`Agent rule`, but see the conflict note for its
   over-claimed "Current" sections).
3. State: `folder_detail_viewmodel.dart`, `docs/state/state-management-contract.md`.
4. Route/navigation: `RoutePaths`/`RouteNames`, `folder_routes.dart`,
   `docs/business/navigation/navigation-flow.md`.
5. **Existing Flutter implementation** (`folder_detail_screen.dart` + widgets) —
   on this screen the code is currently *narrower* than the wireframe; prefer
   the code for "what is Current."
6. Shared widgets: `lib/presentation/shared/**` (`mx_widgets.dart`).
7. Theme/tokens: `lib/core/theme/**`.
8. Mock visual intent: `index.html` `04`.
9. This contract.

The mock is **visual intent only**. It must not be used to introduce the study
layer, hero card, or overflow actions before those are promoted in code.

## 3. Screen layout overview

Top → bottom. Root is `MxScaffold` with an `MxAppBar` and a mode-dependent
`MxFab.extended`. The body is a `Column`: breadcrumb, then an `Expanded` async
region that holds the summary shell, search icon / sort pill header, and the
loaded rows or empty states.

| Region | Position | Fixed/Scrollable | Visual weight | Token mapping | Shared widget | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| App bar | Top | Fixed | Low–medium | `SizeTokens.appbar`; app-bar theme surface; title = `MxTextRole` title | `MxAppBar` (`titleText: folder.name`) | Back affordance auto from router. Trailing overflow ⋮ opens the folder action sheet. |
| Breadcrumb | Below app bar | Fixed | Low | bottom gap `SpacingTokens.sm`; `onSurfaceVariant` text | `MxBreadcrumb` (`MxBreadcrumbSegment[]`) | First segment = `Library` → `context.goLibrary()`; then each ancestor → `context.pushFolderDetail(id)`. Hidden until folder loads. |
| Content (async) | Fills remainder | Scrollable | High | screen horizontal padding via owning shell; row gap `SpacingTokens.sm` | `MxRetainedAsyncState<FolderDetail>` → `FolderDetailBody` | Switches loading (skeleton) / error / data. Data branch renders the summary shell, search/sort affordances, rows, or empty/search-empty per `FolderDetailBody`. |
| Children list | Inside content | Scrollable | High | card padding `cardPadding`/`lg`; row gap `sm`; radius `RadiusTokens.brLg` | `LibraryFolderTile` (subfolders), `FolderDeckTile` (decks) | One mode only, from `folder.contentMode`. |
| Unlocked empty | Inside content (unlocked) | Fixed/centered | Medium | section gap `xl`/`sectionGap`; icon `SizeTokens.iconXl` | `FolderUnlockedEmpty` | Mode-choice chip + info card + "New subfolder" / "New deck" buttons and mode-lock explanation. |
| FAB | Bottom-right, over content | Fixed | Medium (accent) | `SizeTokens.fab`; radius `RadiusTokens.brXl` (xxl 28) | `MxFab.extended` | subfolders → `create_new_folder_outlined` + `folderNewSubfolderLabel`; decks → `add` + `folderNewDeckLabel`; unlocked → **no FAB** (choice lives in body). |

`SafeArea`: provided by `MxScaffold`; wrap body content in `SafeArea` and keep
the FAB clear of the home-indicator inset. No arbitrary pixel values — use the
token names above.

## 4. State matrix

Driven by `folderDetailQueryProvider(folderId)` (`AsyncValue<FolderDetail>`) +
`folderDetailToolbarProvider(folderId).isSearching` + `folder.contentMode`.

| State | Trigger | Visible regions | Hidden regions | Primary CTA | Secondary CTA | Shared state widget | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Initial / Loading | Query pending | App bar, breadcrumb*, **skeleton rows** | Real rows, FAB (FAB null until `detail` loads) | — | — | `MxRetainedAsyncState.skeletonBuilder` → `LibrarySkeleton` | *Breadcrumb renders only once `detail` is available. No tappable rows while loading. |
| Loaded — decks | Query returns folder with `contentMode == decks` | App bar, breadcrumb, mastery summary shell, search icon, sort pill, deck rows, `add` FAB | Subfolder rows, unlocked choice | `MxFab.extended` New deck | Start study CTA shell | — | Deck rows = `FolderDeckTile`. Tap → flashcard list (Future target). |
| Loaded — subfolders | `contentMode == subfolders` | App bar, breadcrumb, stat summary strip, search icon, sort pill, subfolder rows, New-subfolder FAB | Deck rows, unlocked choice | `MxFab.extended` New subfolder | — | — | Subfolder rows = `FolderSubfolderTile`. Tap → child `pushFolderDetail`. |
| Empty — unlocked | `contentMode == unlocked` (no children) | App bar, breadcrumb, empty chip/card/buttons/banner | Rows, FAB | "New subfolder" | "New deck" | `FolderUnlockedEmpty` | Choice locks mode on first create. Must NOT auto-unlock or show both in a FAB. |
| Empty — locked | Locked but zero children (all deleted) | App bar, breadcrumb, "empty" message + FAB | Rows | mode FAB | — | (empty surface) | Do not auto-unlock; keep mode FAB only. |
| Search active | `isSearching == true`, matches exist | App bar, breadcrumb, search icon, sort pill, filtered rows | Unlocked choice | mode FAB | — | — | Filtering is folder-scope-local. |
| Search — no results | `isSearching == true`, no matches but children exist | App bar, breadcrumb, search icon, sort pill, **search-empty** w/ Clear | Rows | "Clear search" (`onClearSearch`) | — | `MxEmptyState` (via `FolderDetailBody`) | Do not route to Global Search. |
| Error / not found | Query error (invalid/deleted `:id`) | App bar, breadcrumb*, search shell, **error state** | Rows, FAB | "Retry" (`commonRetry`) | back | `MxErrorState` (`Icons.folder_off_outlined`, `folderNotFoundTitle/Message`) | Retry = `ref.invalidate(folderDetailQueryProvider)`. No raw exception text. |
| Submitting (create) | `folderActionController` loading | unchanged list + dialog busy | — | dialog confirm (busy) | dialog cancel | `showMxFolderCreateDialog` / `showMxFolderRenameDialog` busy + `showMxSnackbar` on failure | Drift stream refreshes list on success; failure → localized snackbar. |
| Resume present / Study CTAs | (mock) folder has session/due | — | — | — | — | — | **Future** — not rendered in code. Do not implement from the mock. |

## 5. Element mapping

Every visible mock element. `Needs design-system decision` is written where no
existing widget/token covers an element.

| Mock element | Purpose | Existing shared widget | Token/theme mapping | State visibility | Behavior scope | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| App bar title (folder name) | Identify current folder | `MxAppBar(titleText:)` | App-bar theme; title type role; `onSurface` | All loaded states | **Current** | One line, ellipsis; from `detail.folder.name`. |
| Back affordance | Pop to parent | `MxAppBar` default leading + router | App-bar theme; `iconMd` | All | **Current** | Router-provided; pops to parent/Library. |
| Overflow ⋮ (app bar) | Folder actions (rename/move/delete/sort) | `MxIconButton(Icons.more_vert)` | `SizeTokens.iconMd`/`touch`; `onSurfaceVariant` | All loaded | **Current** | Opens the folder action sheet with Rename / Move / Delete. |
| Breadcrumb | Show + jump ancestor path | `MxBreadcrumb` / `MxBreadcrumbSegment` | `SpacingTokens.sm` gap; `onSurfaceVariant`; `labelMedium` | Loaded (hidden until data) | **Current** | `Library` + ancestors; middle-ellipsis past ~3 levels (do not lose first/last). |
| Search icon | Folder-scope-local search affordance | `MxIconButton(Icons.search)` | `SizeTokens.iconMd`/`touch`; `onSurfaceVariant` | Loaded | **Visual-only** | Hint `folderDetailSearchHint`; no inline field is rendered on this ref. |
| Sort pill | Folder-sort affordance | local pill | surface container; `onSurfaceVariant` | Loaded | **Visual-only** | Shows `Recent` in decks mode and `Most due` in subfolders mode. |
| Subfolder row | Open child folder | `FolderSubfolderTile` | custom 36×36 leading tile with `RadiusTokens.brSm`; `MxCard` padding `12px 14px`; text roles | subfolders mode | **Current** | Folder icon + name + optional `{m} due` badge on the top row, `{n} decks · {c} cards` metadata, compact progress bar, and chevron. Tap → child folder detail. |
| Deck row | Open deck's flashcards | `FolderDeckTile` | custom 36×36 leading tile with `RadiusTokens.brSm`; `MxCard` padding `12px 14px`; text/icon roles | decks mode | **Current** | Icon tile + name + optional `{m} due` badge on the top row, `{n} cards · last {relative time}` meta when `lastStudiedAt` is present, compact progress bar, and chevron. Tap → flashcard list (Future target screen). |
| Deck due badge | Show due count | within `FolderDeckTile` | 18px chip height; `0 7px` inset; `brFull`/text | decks mode, when `due > 0` | **Current** | Show only when due > 0; never "0 due". Uses the deck aggregate `dueCount`. |
| Deck last studied | Show recency metadata | within `FolderDeckTile` | `RelativeTime` formatter + l10n suffix | decks mode, when `lastStudiedAt` is present | **Current** | Rendered as `last {relative time}` in English and localized equivalent in Vietnamese; null collapses to cards-only meta. |
| Deck compact progress bar | Show deck progress hint | within `FolderDeckTile` | `MxLinearProgress` height `4px`; meta→bar gap `6px` | decks mode | **Current** | Derived from loaded deck aggregates; visual-only summary bar, not the folder mastery ring. |
| Row chevron | Affordance into child | row trailing | `iconSm`/`iconMd`; `onSurfaceVariant` | rows present | **Current** | Folder Detail rows DO use a chevron (unlike Library Overview cards, which use a kebab). |
| Long-press row → item context sheet | Rename/Move/Delete child | `library_folder_actions_sheet.dart`, `folder_move_picker_sheet.dart`, `MxConfirmationDialog` | shared sheet/dialog themes; scrim 32% | rows present | **Current** (verify wiring on Folder Detail) | Item-context sheet (`wireframes/25 §item-context`). Confirm long-press is wired here as it is on Library rows. |
| Mode-choice empty | Pick subfolders or decks | `FolderUnlockedEmpty` | `iconXl`; `sectionGap`; secondary buttons | unlocked empty | **Current** | "New subfolder" / "New deck" + lock explanation copy (l10n). |
| Search-no-results empty | Tell user nothing matched | `MxEmptyState` (via `FolderDetailBody`) | `iconXl`; empty-state theme | search active, 0 matches | **Current** | "Clear search" CTA → `onClearSearch`. |
| Loading skeleton | First-load placeholder | `LibrarySkeleton` (`MxSkeleton` in `MxCard`) | `MxSkeleton`; `brLg` | loading | **Current** | Per-row skeleton, not a full-screen spinner. |
| Error / not-found | Safe failure surface | `MxErrorState` | error-state theme; `iconXl` `folder_off_outlined` | error | **Current** | Localized title/message + Retry. |
| Create FAB | Add child by mode | `MxFab.extended` | `SizeTokens.fab`; `RadiusTokens.brXl`; primary/onPrimary | decks/subfolders loaded | **Current** | Mode-locked label & icon. Unlocked → no FAB. |
| New folder / deck dialog | Name the new child | `showMxFolderCreateDialog` / `showMxFolderRenameDialog` for folder cases; `showMxNameDialog` remains for deck naming | dialog theme `brLg`; level2–3; scrim 32% | on FAB / choice tap | **Current** | Folder dialog is mock-aligned with preview tile + color/icon pickers on create and helper text on rename; duplicate/mode-lock errors → `showMxSnackbar`. |
| Hero mastery card | Folder mastery ring + counts | `MxMasteryRing` exists in kit | `MxCard` + `MxMasteryRing` | decks mode | **Visual-only** | Rendered as a shell using loaded deck totals; mastery value itself is not backed by a folder read model. |
| Study folder / Today CTAs | Launch folder-scoped study | `MxActionButton` / `MxCardActions` | card-action tokens | decks mode | **Visual-only** | Study layer not built; the visible button remains disabled until the study entry flow exists. |
| Resume banner (+ Discard) | Continue/cancel paused session | `MxCallout` + `MxConfirmationDialog` | callout/dialog themes | (mock) | **Future** | No session layer on this ref. |
| "{n} new" subtitle | New-card count | — | — | decks mode | **Visual-only** | Rendered as shell copy for the mock; no folder-scope new-card read model exists. |
| Sort control | Reorder rows | local pill | — | loaded | **Visual-only** | `ContentSortMode` still exists in toolbar state, but no interactive sort menu is wired. |

## 6. Typography contract

Use `MxText` roles / `TextTheme` (collapsed scale 48/32/24/20/16/14/12). No raw
`TextStyle` where a role applies. All user-facing strings via l10n.

| Text element | UI role | Typography token/role | Color role | Max lines | Overflow | l10n required | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Folder name (app bar) | Screen title | App-bar title role (`MxAppBar`) | `onSurface` | 1 | ellipsis | yes (value is data) | From `detail.folder.name`. |
| Breadcrumb segments | Navigational labels | `MxTextRole.labelMedium` | `onSurfaceVariant` (current segment emphasized) | 1 each | middle-ellipsis past ~3 | `Library` from `l10n.libraryTitle`; names are data | Segments are buttons. |
| Search hint | Input placeholder | input hint role | `onSurfaceVariant` | 1 | ellipsis | `l10n.folderDetailSearchHint` | Folder scope wording. |
| Row title (folder/deck) | List item title | `MxTextRole.titleSmall`/`titleMedium` | `onSurface` | 1 | ellipsis | data | Density per row. |
| Row subtitle (counts + recency) | Metadata | `MxTextRole.bodyMedium`/`labelMedium` | `onSurfaceVariant` | 1 | ellipsis | ICU plural ("{n} cards", "{n} decks") | Tabular figures for counts; deck rows collapse to cards-only when `lastStudiedAt` is null. |
| Due badge | Count chip | label role | primary tint content | 1 | clip | ICU plural ("{n} due") | Only when due > 0. |
| Empty/search-empty title + body | Guidance | empty-state roles | `onSurface` / `onSurfaceVariant` | 2–3 | wrap | yes | Calm, action-led copy. |
| Error title + message | Failure | error-state roles | `onSurface` / `onSurfaceVariant` | 2–3 | wrap | `folderNotFoundTitle`/`folderNotFoundMessage` | No raw failure text. |
| FAB label | Create action | button label role (bold, sentence case) | `onPrimary` | 1 | clip | `folderNewSubfolderLabel`/`folderNewDeckLabel` | — |

## 7. Color and surface contract

Theme roles only (Material 3 seeded scheme; Tokyo Pure Light / Tokyo Nebula).
**Never** hardcode hex; the mock hex below is reference, **not** implementation.

| Surface/role | Required role | Notes |
| --- | --- | --- |
| Page background | `context.colorScheme.surface` | via `MxScaffold`. |
| App bar surface | app-bar theme (glass: page surface @ `OpacityTokens.surfaceGlass` + blur) | through `MxAppBar`; do not re-tint. |
| Card surface (rows) | `surfaceContainerLowest` via `MxCard` | `1px` ghost border (15% outlineVariant); no shadow. |
| Search affordance | shared icon-button surface via `MxIconButton` | focus = `1px` solid `primary`. |
| Primary action (FAB, primary buttons) | `context.colorScheme.primary` / `onPrimary` | mock light primary ≈ `#5265F5` (ref only). |
| Secondary action | `secondary`/outline via `MxSecondaryButton` | for unlocked-choice buttons. |
| Overflow ⋮ | app-bar action surface | opens the folder action sheet; no disabled state on this ref. |
| Border / outline | ghost border via `MxCard`; `BorderTokens`/outlineVariant | never a hand-rolled border. |
| Divider | `outlineVariant` (low) | only if rows use dividers; cards prefer gaps. |
| Due-badge tint | `primaryContainer` / approved primary opacity | tokenized, not raw. |
| Error | `context.colorScheme.error` via `MxErrorState` | localized. |
| Dark mode | full parity (Tokyo Nebula) | outlines are faded indigo, never gray; primary lifts for AA. Verify both themes. |

## 8. Spacing, sizing, and radius contract

4dp grid. Use token names only.

| Area/element | Padding | Gap | Radius | Size token | Responsive behavior | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Screen horizontal | `SpacingTokens.screenPadding` (or owning shell) | — | — | — | wider gutters ≥600dp | Don't hardcode 24. |
| Breadcrumb block | — | bottom `SpacingTokens.sm` | — | — | wraps/ellipsis | Matches code (`EdgeInsets.only(bottom: sm)`). |
| Header controls | — | bottom `SpacingTokens.sm` | pill radius / icon touch | shared icon-button + local pill | full width | Search icon and sort pill replace the inline search field on this ref. |
| Row card | `12px 14px` | between rows `SpacingTokens.sm` (`listItemGap`) | `RadiusTokens.brLg` | — | 2-col grid ≥600dp | Ghost border. |
| Leading icon tile | — | tile→text `SpacingTokens.md`; tile `36px`, icon `17px` | `RadiusTokens.brSm` | custom local tile | fixed | Folder-detail rows use a compact custom tile, not the shared 44dp `MxIconTile`. |
| Due badge | `0 7px` inset | — | `RadiusTokens.brFull` | 18px height | — | Pill. |
| Empty-state icon | — | `SpacingTokens.lg`/`xl` | — | `SizeTokens.iconXl` | center | — |
| FAB | — | — | `RadiusTokens.brXl` (xxl 28) | `SizeTokens.fab` | bottom-right | `MxFab.extended`. |
| Touch targets | — | — | — | min `SizeTokens.touch` (48) | — | Icon buttons keep 48dp tap target. |

## 9. Interaction contract

Behavior must be backed by docs/code. Mock-only behavior is marked `Future`/`Visual-only`.

| Interaction | Trigger | Expected behavior | State change | Shared component/API | Scope | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Open folder | route `/library/folder/:id` | Stream folder detail; show loading→loaded/error | `folderDetailQueryProvider` (keepAlive stream) | `WatchFolderDetailUseCase` | **Current** | Invalid/deleted id → error state. |
| Tap back | app-bar back | Pop to parent/Library | nav | router | **Current** | — |
| Tap breadcrumb segment | tap | Go/push to that folder; `Library` → library root | nav | `context.goLibrary()` / `context.pushFolderDetail(id)` | **Current** | — |
| Tap subfolder row | tap | Push child folder detail | nav | `context.pushFolderDetail(childId)` | **Current** | — |
| Tap deck row | tap | Push deck flashcard list | nav | `RoutePaths.flashcardList(deckId)` | **Current** intent; **target screen Future** | Flashcard list not implemented; nav resolves to placeholder/none on this ref. |
| Long-press row | long-press | Open item context sheet (Rename/Move/Delete) | sheet | `library_folder_actions_sheet.dart`, `folder_move_picker_sheet.dart`, `MxConfirmationDialog` | **Current** (verify on Folder Detail) | Confirm wiring; same sheets used by Library rows. |
| Tap search icon | tap | (visual-only affordance) | — | `MxIconButton(Icons.search)` | **Visual-only** | No inline search field is rendered on this ref. |
| Tap sort pill | tap | (visual-only affordance) | — | local sort pill | **Visual-only** | Sort state exists, but the control is not interactive yet. |
| Tap FAB (decks) | tap | Open New deck name dialog | create deck | `createDeckDialog` → `folderActionController.createDeck` | **Current** | Success → stream refresh; failure → snackbar. |
| Tap FAB (subfolders) | tap | Open New subfolder name dialog | create subfolder | `createSubfolderDialog` → `createSubfolder` | **Current** | — |
| Unlocked choice tap | tap | Create first child, lock mode | create + mode lock | `onNewSubfolder` / `onNewDeck` | **Current** | First child locks `content_mode`. |
| Mode-lock violation | stale concurrent action | Reject + localized snackbar (not generic error) | — | `UnsupportedActionFailure` → `folderModeLockedError` | **Current** | Typed messages per direction. |
| Retry | error CTA | Re-run query | invalidate | `ref.invalidate(folderDetailQueryProvider)` | **Current** | — |
| Tap overflow ⋮ | tap | open folder action sheet | sheet | `MxIconButton(onPressed: showFolderDetailActions)` | **Current** | Rename / Move / Delete are available here. |
| Study folder / Today / Resume | tap | (not built) | — | — | **Future** | Not rendered; never start a session from this screen. |
| Pull to refresh | pull | (not specified for this screen) | — | — | **Unknown** | Stream auto-refreshes; confirm if a manual refresh is desired. |

## 10. Motion and animation contract

Use `DurationTokens` / `EasingTokens` only (`standard = easeInOut`, `enter =
easeOut`, `exit = easeIn`; **no `elasticOut`**).

| Motion | Token | Notes |
| --- | --- | --- |
| Page transition (push child / deck) | `DurationTokens.pageTransition` (300) + emphasized | Router default; keep standard. |
| Skeleton pulse | subtle, gated on reduced-motion | Respect `MediaQuery.disableAnimations`; neutralize on reduce. |
| Loaded content fade | `DurationTokens.contentSwitch` (200) | Async state swap. |
| Search filter update | `stateChange`/`contentSwitch` | No layout jank. |
| Sheet / dialog open | sheet/dialog theme + 32% scrim | `level2–3`. |
| FAB press | M3 state layer (no scale-down) | No bounce/shrink. |

No infinite decorative loops on content.

## 11. Accessibility contract

- **Screen-reader order:** app bar (title, back, overflow ⋮) → breadcrumb
  (single region; segments are buttons) → header controls → children list → FAB.
- **Semantic labels:** overflow ⋮ tooltip `libraryOverflowTooltip`; search icon
  tooltip `folderDetailSearchHint`; FAB label is its visible text. Row chevrons
  are decorative (`ExcludeSemantics`); the row itself is the control.
- **Touch targets:** min `SizeTokens.touch` (48dp); keep `IconButton` default
  padded target (do not shrink constraints).
- **Focus order:** matches DOM/visual order; visible focus ring = `primary`.
- **Contrast:** AA in both Tokyo Pure Light and Tokyo Nebula.
- **Text scaling:** rows/titles/counts must reflow (titles ellipsize at 1 line;
  empty/error copy wraps). Don't clip at large text scales.
- **Empty/error announcement:** `MxEmptyState` / `MxErrorState` announce via
  `role="status"`-equivalent semantics; Retry is reachable.

## 12. Responsive contract

Baseline 360×800dp portrait; breakpoints 600dp/1024dp (`breakpoints.dart`,
`app_layout.dart`).

| Context | Fixed | Scrolls | Wraps | Truncates | Never hidden | Denser |
| --- | --- | --- | --- | --- | --- | --- |
| Small mobile (≤360) | app bar, search, FAB | children list | breadcrumb (middle-ellipsis) | row titles | back, search, FAB | — |
| Normal mobile (360–412) | same | children list | breadcrumb | row titles | same | — |
| Large mobile | same | children list | breadcrumb | row titles | same | — |
| Tablet/≥600 | app bar, search | children grid | breadcrumb | row titles | same | **2-column row grid** (per wireframe `Responsive`); CTAs/inline buttons may sit above grid when study CTAs are promoted |

Breadcrumb must never overlap the title; truncate middle segments past ~3
levels keeping first + last.

## 13. Data/content contract

- **Real data:** `FolderDetail` (folder name, `content_mode`, parent chain /
  breadcrumb, child folders OR child decks, recursive counts, deck
  `lastStudiedAt` aggregate) via `WatchFolderDetailUseCase`; reacts to
  `folderDetailToolbar` (search/sort).
- **Mock/demo data (do NOT copy):** sample names ("Korean", "Grammar", "Korean
  N5"), fixed counts, "Today (12)", "{n} new" — all illustrative.
- **Empty value display:** unlocked → mode-choice; locked-empty → empty message
  + FAB; search-empty → Clear CTA. Never blank.
- **Count formatting:** ICU plurals ("{n} decks", "{n} cards", "{m} due");
  tabular figures; hide due badge at 0.
- **Date/time:** deck rows display relative last-studied metadata when the
  read model exposes `lastStudiedAt`; the current implementation formats it as
  a localized relative time string.
- **Sorting/grouping:** `ContentSortMode` exists in toolbar state; **no sort UI
  rendered** (Future). Default order = `sort_order` (manual).
- **Localization:** Korean + Vietnamese must fit; titles ellipsize, copy wraps.

## 14. Flutter implementation guidance

**Inspect before editing**

- `lib/presentation/features/folders/screens/folder_detail_screen.dart` (shell,
  app bar, FAB, async switch, create dialogs).
- `widgets/folder_detail_body.dart` (loaded vs empty vs search-empty switch).
- `widgets/folder_deck_tile.dart`, `widgets/library_folder_tile.dart`,
  `widgets/folder_unlocked_empty.dart`, `widgets/library_skeleton.dart`.
- `viewmodels/folder_detail_viewmodel.dart` (toolbar/query/action providers).
- `routes/folder_routes.dart`, `lib/app/router/route_paths.dart`,
  `route_names.dart`, `lib/app/router/app_navigation.dart`.
- `domain/models/folder_detail.dart`, `domain/types/content_mode.dart`,
  `domain/types/content_sort_mode.dart`.

**Reuse these shared widgets** (do not hand-roll): `MxScaffold`, `MxAppBar`,
`MxBreadcrumb`, `MxSearchField`, `MxRetainedAsyncState`, `MxErrorState`,
`MxEmptyState`, `MxSkeleton`, `MxCard`, `MxIconTile`, `MxIconButton`,
`MxFab.extended`, `showMxFolderCreateDialog`, `showMxFolderRenameDialog`, `showMxNameDialog`, `showMxSnackbar`, `MxConfirmationDialog`.

**Theme/token files:** `lib/core/theme/tokens/**`,
`lib/core/theme/extensions/theme_context.dart`,
`lib/core/theme/schemes/app_color_scheme.dart`,
`lib/core/theme/component_themes/component_themes.dart`.

**Files likely to change** when promoting Future items: `folder_detail_screen.dart`
(enable overflow ⋮; add hero/study sections), new `folder_hero_card.dart` /
`folder_study_entry_section.dart` (only when the study layer lands), `folder_detail_viewmodel.dart`.

**Must NOT change** for parity-only work: token classes, `Mx*` shared widget
internals, route path structure, l10n keys (add new keys, don't rename).

**New files allowed only if necessary:** a folder-level action sheet and the
hero/study widgets — and only when the corresponding business/state/route
support exists (Study Entry Gate, session layer, folder mastery read model).

**Forbidden assumptions**

- Do not assume the study layer exists — it does not on this ref.
- Do not render the hero mastery ring, "{n} new", or Study/Today/Resume from the
  mock; no read model backs them.
- Do not enable the overflow ⋮ without a real folder action sheet.
- Do not add a sort UI just because `ContentSortMode` exists in state.
- Do not show both "New subfolder" and "New deck" in a locked folder's FAB.
- Do not navigate past mode-lock without explicit choice in unlocked mode.
- Do not start a study session directly from this screen.

## 15. Visual parity checklist

- [ ] All mock elements documented (table §5).
- [ ] All Current-scope elements implementable with existing widgets/tokens.
- [ ] Future/Visual-only elements clearly marked (hero, study/resume CTAs,
      "{n} new", search icon, sort pill).
- [ ] No raw hex required.
- [ ] No random spacing values required (tokens only).
- [ ] No raw `TextStyle` where `MxText`/role applies.
- [ ] No raw `TextField` (uses `MxSearchField`).
- [ ] No raw `Card`/decorated `Container` (uses `MxCard`).
- [ ] No hardcoded user-facing strings (l10n + ICU plurals).
- [ ] Loading / empty(unlocked) / empty(locked) / search-empty / error states
      distinct.
- [ ] Dark mode (Tokyo Nebula) considered.
- [ ] Text scaling considered (titles ellipsize, copy wraps).
- [ ] Accessibility considered (order, labels, 48dp targets, focus).
- [ ] Conflicts documented (§16) and not silently implemented.

## 16. Open questions and conflicts

| Issue | Type | Affected element | Reason | Recommended action |
| --- | --- | --- | --- | --- |
| Wireframe says hero mastery card + Study/Today CTAs + Resume banner are Current (Prompt 45/47/50); code comment + render path say Future ("study layer is not built") | Business conflict / State conflict | Hero card, study/resume CTAs | Wireframe ahead of code on this ref | Reconciled 2026-06-10: `05-folder-detail.md` + related business docs corrected to Future; never fake mastery/new/due-from-session data |
| Overflow ⋮ opens folder action sheet | Mock-only element | App-bar overflow | Folder action sheet now wired on Folder Detail | Keep the same Rename/Move/Delete flow and avoid adding unrelated actions |
| `ContentSortMode` exists in toolbar state but no sort UI is wired | State conflict | Sort control | Code shows a local pill, not the full sort toolbar | Treat sort UI as visual-only until the menu is actually promoted |
| Deck row tap targets `/library/deck/:deckId/flashcards`, but Flashcard list is not implemented | Future scope | Deck row navigation | Flashcard feature absent on this ref | Acceptable as nav intent; flashcard list must land (P2) for the tap to resolve |
| Per-deck due badge depends on whether `FolderDeckItem` exposes a due count | Missing source | Deck due badge | Model field unconfirmed in this read | Verify `domain/models/folder_detail.dart`; if absent, mark badge Future |
| Long-press item-context sheet wiring on Folder Detail (vs Library Overview) unconfirmed | Unknown source | Row long-press | Not visible in `folder_detail_screen.dart` (handled in body/tiles) | Verify in `folder_deck_tile.dart` / `library_folder_tile.dart`; document actual behavior |

## Related

- `docs/design/README.md`, `docs/design/screen-index.md`
- `docs/design/design-token-mapping.md`, `docs/design/component-visual-contract.md`,
  `docs/design/visual-parity-checklist.md`
- `docs/design/screens/library-overview.visual-contract.md` (sibling screen)
- `docs/wireframes/05-folder-detail.md`, `docs/wireframes/02-library.md`,
  `docs/wireframes/06-flashcard-list.md`, `docs/wireframes/12-study-entry-gate.md`
- `docs/wireframes/24-shared-dialogs.md`, `docs/wireframes/25-shared-bottom-sheets.md`
