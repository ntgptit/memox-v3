---
last_updated: 2026-06-20
route: /library
source_specs:
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/search/global-search.md
---

# 02 — Library

> ## ⚠️ As-built banner (2026-06-20, rev. 2 — full mock parity, WBS 3.1.2 + 2.1.2)
>
> The rebuilt + full-parity screen behaves as follows; this banner and
> `docs/design/screens/library-overview.visual-contract.md` §V1 status (rev. 2) are
> **authoritative** over the prompt-era prose below where they differ:
>
> - **Search is a mode toggle**, not an always-visible inline field: the app bar shows
>   `Icons.search` (→ `LibrarySearchAppBar` with an autofocused field + Cancel) and a
>   visual-only `Icons.swap_vert` sort icon. (Supersedes "always-visible inline (no toggle)".)
> - **Folder rows use a chevron** (`Icons.chevron_right`), **no kebab**; a row tap opens the
>   action sheet (interim, until folder-detail nav lands — WBS 3.2.2) and a long-press also
>   opens it. (Supersedes all "kebab" / `Icons.more_vert` references.)
> - Loaded state is a **single grouped card** of rows (tinted `FolderIconTile`) separated by
>   `MxDivider` inset hairlines, with **no count overline and no sort pill**; the `{n} FOLDERS`
>   overline appears **only in the search state**.
> - **Root anchor (owner-requested, 2026-06-21):** the loaded-with-folders state docks a
>   `LibraryRootAnchor` under the app bar — a single non-tappable `Library` breadcrumb crumb (the
>   root of the same trail nested screens show) plus a `{n} folders` count — so the root carries the
>   same "you are here" dock as Folder Detail. Hidden in search / loading / empty / error (matches
>   the FAB gating). Not part of the kit `03a` mock; see
>   `docs/design/screens/library-overview.visual-contract.md` §Scope Decision.
> - **Loading** is a skeleton card (`LibraryLoadingSkeleton`); **empty** is `MxEmptyState` +
>   `Create folder` CTA; **error** is `MxErrorState` + full-width Retry.
> - **`New folder` FAB + create dialog with color + icon pickers are Current** (WBS 2.1.2):
>   `MxFab` (shown only in loaded-with-folders) and the empty-CTA both call `runCreateFolder`
>   → `folder_create_dialog.dart`. Color/icon use the OQ-2 palette via `folder_visual_tokens.dart`.
> - **Not built:** due-summary card, sort sheet, mastery bar, new-card badge, deck-digest
>   subtitle (read-model fields absent). The per-row **due badge** *is* built (shows when `dueCount > 0`).
> - As-built file map: `library_overview_screen.dart` · `library_overview_body.dart` ·
>   `library_folder_tile.dart` · `folder_icon_tile.dart` · `library_loading_skeleton.dart` ·
>   `library_search_app_bar.dart` · `library_folder_actions_sheet.dart` ·
>   `folder_create_dialog.dart` · `library_create_folder_action.dart` ·
>   `library_overview_viewmodel.dart` (`libraryOverviewStreamProvider` /
>   `librarySearchQueryProvider` / `librarySearchActiveProvider`). The old
>   `library_sections.dart` / `library_skeleton.dart` / `content_query_usecases.dart` /
>   `libraryOverviewQueryProvider` names below are **ghost refs** from the prior iteration.

## V1 verification status (2026-05-31, Prompt 18/18B; root-deck decision updated 2026-06-03, Prompt 43A; 6-state visual parity 2026-06-04, Prompt 49; loaded-state visual fix 2026-06-04, Prompt 49B; mock mapping docs 2026-06-05; overflow sheet implemented + 6 states Current 2026-06-06, Prompt 49D)

This screen is **partially Current**. The recursive folder counts (verified Prompt 14) plus the
aspects below are verified by code and tests; the remainder is **Future** and intentionally not
exposed in V1. Do NOT mark the whole screen Current. The §Layout / §Components / §Actions / §Sort
options blocks below describe the **target** design; where they conflict with this section, this
section is the current truth.

Screen-level visual contract: `docs/design/screens/library-overview.visual-contract.md`.

**Prompt 49 scope (2026-06-04):** visual/layout parity for the Library Overview mock states (
loaded · loading · empty · error · search · overflow reference) against
`docs/system-design/MemoX Design System/ui_kits/mobile/index.html` §"03 · Library overview". No
schema/SRS/domain/repository/use-case behavior change. Library search stays inline/scope-local and
is V1 folder-only; the inline hint is `Search folders`. The `/library/search` global-search route
is separate from Library Overview and is not exposed from this app bar. Root-level decks remain
**Rejected / Out of Scope**. The mock's overflow sheet is now **implemented and Current** (see
"Overflow sheet — now Current" below, Prompt 49D); the row kebab and long-press open the folder
action sheet. Card padding/radius and bottom-nav density remained a separate Design Token /
Density Foundation follow-up and were not changed in Prompt 49. **Resolved (2026-06-05):** card
surface aligns to the design system — `16dp` radius (`lg`) + `16dp` padding (`--memox-space-card`),
applied in `MxCard`. Bottom-nav density is still open. The current PNG/spec text
`Search decks, cards, tags` is an approved stale mock/spec variance for V1 until the source design
is regenerated.

**Prompt 49B scope (2026-06-04):** fixes the **loaded-state visual drift** left by Prompt 49 against
the same mock §"03 · Library overview". No schema/SRS/repository/use-case change. Changes are
presentation-only:

- Header right control is a sliders/filter affordance (`Icons.tune_rounded`). It is a **visual-only
  target** — rendered disabled because Library has no approved filter/sort sheet yet (no unsupported
  action is exposed).
- Search below the title is **always-visible inline** scope-local search (no toggle). The inline
  field itself never navigates. It is the only visible search entry on Library Overview. V1 search
  targets folders only; deck/card/tag search is Future.
- The static `All` filter chip is **removed** from the loaded header.
- Loaded state renders a `{n} FOLDERS` section header with the mock sort pill on the right
  (`librarySortRecentLabel` / "Recent"). The pill is visual parity only; it is non-interactive
  and the sort sheet remains Future.
- A **due summary card** (`{n} cards due today`) is rendered when `dueToday > 0` and hidden
  otherwise. It includes a subtitle derived from the aggregate model (`Across {n} folders · ~{m}
  min`) and a chevron; the card itself is non-interactive and there is no study-launch navigation.
- The FAB is now a minimal **icon button** with a `New folder` tooltip wired to the existing create-folder flow. **New
  deck / Import are not exposed** from Library root.

**Overflow sheet — now Current (2026-06-06, Prompt 49D — 6-state parity completion):** the folder
action sheet is **implemented and Current**. The earlier "Future / deferred" decision is
**superseded**. All six mock states (loaded · loading · empty · error · search · overflow sheet) are
**Current target scope**.

**11-state mapping completed (2026-06-13):** the canonical kit ships **11** Library Overview states
(`shots/INDEX.md` §`03 — Library overview`): loaded · loading · empty · error · search · overflow
sheet · create folder · rename folder · move folder · archive folder · delete folder. The full
mock-to-code matrix (with per-state status) is mapped in
`docs/design/screens/library-overview.visual-contract.md` §State Matrix — the authority for the
state list. Create / Rename / Move / Delete are the modal states of the actions already documented
below and are **Current** (real dialogs + use cases). **Archive folder** is **Future / visual-only**:
no archive use case / repository method / DAO / schema column exists, so the overflow Archive action
is not exposed and the archive confirm dialog is not reachable.

- Both the kebab (`onPressed`) and the row long-press (`onLongPress`) open the folder action sheet
  via `onShowActions` (no longer `null`, never disabled).
- Sheet actions (mock-approved set): **Rename**, **Move to folder**, **Import flashcards**
  (decks/unlocked folders only — hidden for subfolder-mode), and **Delete folder** (destructive).
  The mock's "Open folder" is the row tap itself; "Study due cards" and "Archive folder" remain
  **out of scope** (not exposed).
- Backing use cases now exist and are wired in `lib/app/di/folder_providers.dart`:
  `RenameFolderUseCase`, `MoveFolderUseCase`, `DeleteFolderUseCase`, `GetFolderMoveTargetsUseCase`
  (over new `FolderRepository.renameFolder/moveFolder/deleteFolder/getFolderMoveTargets`). The DAO
  mutation methods (`updateFolderName`, `updateFolderParent`, `deleteFolderById`,
  `descendantFolderIdsDepthFirst`, `siblingFolderNames`) back them.
- **Rename** opens `showMxFolderRenameDialog` pre-filled with the current name → `renameFolder` (sibling-name
  uniqueness, no-op on unchanged name). **Move** loads candidates via `getFolderMoveTargets` and
  opens the move picker (`docs/wireframes/25-shared-bottom-sheets.md` §folder-picker): blocked
  destinations (self/descendants = cycle, decks-locked folders) are shown disabled with a reason,
  never hidden; the destination locks to `subfolders` and an emptied old parent reverts to
  `unlocked`. **Import flashcards** navigates into the folder (`pushFolderDetail`) where the existing
  per-deck import flow lives — there is no folder-level import target, so this opens the folder to
  pick/create a deck. **Delete** confirms via the destructive `MxConfirmDialog`
  (`docs/wireframes/24-shared-dialogs.md` §delete-confirm) then cascades the subtree.
- Asserted by widget tests (`test/presentation/features/folders/library_overview_test.dart`: kebab
  enabled, kebab/long-press both open the sheet, action set, subfolder-mode hides Import, Delete
  opens the confirm dialog) and repository tests
  (`test/data/repositories/folder_repository_impl_test.dart`: rename/move/delete/move-targets,
  cycle + decks-lock rejection, cascade).

**Verified Current (behaviour + tests):**

- Route `/library` opens `LibraryOverviewView` (also `initialLocation`). Folder row →
  `pushFolderDetail` → `/library/folder/:id`. The always-visible inline search field filters
  scope-locally and does not navigate; Library Overview no longer exposes a search affordance in the
  app bar.
- Renders **top-level folders only**. Recursive subtree counts per folder (subfolders · decks ·
  cards · due) are Current from Prompt 14 and isolated between sibling roots.
- States:
    - **Loaded** — `LibraryOverviewBody` list of `LibraryFolderTile` rows; no root-level deck card.
    - **Loading** — `MxRetainedAsyncState.skeletonBuilder` → `LibrarySkeleton` (skeleton folder
      rows, `ValueKey('library_skeleton')`), not a full-screen spinner; no folder row is tappable
      while data is absent.
    - **Error** — `MxRetainedAsyncState.errorBuilder` → `MxErrorState` with localized
      `libraryLoadFailedTitle` / `libraryLoadFailedMessage`, `Icons.cloud_off_outlined`, Retry →
      `ref.invalidate(libraryOverviewQueryProvider)`; no raw exception text surfaced.
    - **True empty library** — `totalFolderCount == 0`, regardless of search term →
      `LibraryEmptyStateSection` "Create folder" CTA.
    - **Search no-results** — `folders.isEmpty && searchTerm` active **&& `totalFolderCount > 0`** →
      `LibrarySearchNoResultsSection`, `ValueKey('library_search_no_results')`, "Clear" CTA.
      Distinct from true empty (Prompt 18; classification corrected Prompt 18B — counts driven by
      `LibraryOverviewState.totalFolderCount` from `LibraryOverviewReadModel.totalFolderCount`).
    - **Overflow sheet** — each folder row carries a visible kebab (`Icons.more_vert`, tooltip
      `libraryOverflowTooltip`); the kebab **and** a row long-press open the folder action sheet
      (Rename / Move / Import flashcards / Delete). **Current** — see "Overflow sheet — now Current".
- Inline search (Prompt 49B: always visible below the title, no toggle): scope-local within Library.
  When a term is active the query broadens to match **any folder by name across the tree** (
  `listAllFolders` + normalized contains); empty term restores top-level folders. Never routes to
  Global Search; does not mutate persisted `sort_order`. When search is active and results exist,
  the overview summary card and folder-count header are hidden so the screen matches the search
  mock's simplified list layout. The supported hint is `Search folders`.
- Loaded section header: `{n} FOLDERS` overline with the mock sort pill (`librarySortRecentLabel`)
  on the right. Its horizontal inset is intentionally tight so it does not feel double-padded
  inside the shared screen shell; the pill is visual parity only and non-interactive.
- Due summary card (Prompt 49B): rendered when `dueToday > 0` (`libraryDueSummaryTitle` plus
  `libraryDueSummarySubtitle`), hidden otherwise. Non-interactive — the subtitle is derived from
  the aggregate model, the card shows a chevron, and there is no study-launch.
- Create folder: FAB is a minimal **icon button** (`MxFab`,
  `Icons.create_new_folder_outlined`, `libraryNewFolderLabel` as tooltip); the empty-state CTA and the icon
  both open `showMxFolderCreateDialog` → `createFolderUseCase.createRoot`. Blank name rejected by dialog;
  direct mutation failures map to a localized error snackbar. If the create mutation commits but the
  retained library query refresh fails, the previous list remains visible and a localized error
  snackbar is shown instead of relying on logs only. No New deck / Import entry on Library root.
- Folder row overflow action sheet is **Current** (Rename / Move / Import flashcards / Delete) — see
  "Overflow sheet — now Current". The mock's "Study due cards" / "Archive folder" actions remain
  **not exposed** (out of current scope).
- Sort (`ContentSortMode`: manual/name/newest/lastStudied) is implemented and tested at the *
  *repository + use-case** layer (`folder_repository_impl`, `content_repository_test`). The
  viewmodel exposes `setSortMode`. The mock-style sort pill is now rendered in the header; a
  dedicated sort sheet remains Future.

**Future / not exposed in V1:**

- **Root-level decks are Rejected / Out of Scope.** `LibraryOverviewReadModel` carries `folders`
  only. The §Layout "Top-level deck" rows and the "Tap deck row → /library/deck/:deckId/flashcards"
  action are visual history only, not target scope.
- FAB create flow — V1 FAB is a `New folder` pill that creates a folder directly; there is no New
  deck or Import entry on Library Overview. Deck creation/import remain owned by Folder Detail /
  Flashcard List / Deck Import.
- Filter chips (All / Folders / Decks) — removed in Prompt 49B (the previous static,
  non-functional "All" chip is gone). A dedicated filter sheet behind the header sliders icon
  remains Future.
- Drag-to-reorder of root items, pull-to-refresh, and grid/multi-column responsive layout.
- Global Search screen / `/library/search` route is a separate search surface for
  folders/decks/flashcards. Only the in-search **Tags** section, recent searches, and popular tags
  remain Future.

**Prompt 42/42B superseded (2026-06-03, Prompt 43A):** Product ownership rejected
root-level decks and nullable deck parent migration. Keep `decks.folder_id`
non-null, keep deck APIs folder-bound, and keep Library root folders-only. The
rejected nullable-parent direction is recorded in
`docs/database/schema-contract.md`.

## Purpose

Root content browser. Current V1 shows top-level folders only. Root-level decks are Rejected / Out
of Scope and are not rendered in the current app. Entry point for content management and a launch
point for study.

## Layout

```
┌───────────────────────────────────────┐
│ Library                     ⋮         │  ← App bar; sliders/filter only
├───────────────────────────────────────┤
│                                       │     sliders/filter target (disabled)
│ ┌─[ All ]─[ Folders ]─[ Decks ]─────┐ │  ← Optional filter chips (top-level)
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 📁 Korean              5 decks ▸ │ │  ← Folder row
│ ├───────────────────────────────────┤ │
│ │ 📁 English             3 decks ▸ │ │
│ ├───────────────────────────────────┤ │
│ │ 📁 Misc                1 deck  ▸ │ │
│ ├───────────────────────────────────┤ │
│ │ 📚 Quick vocab        42 cards ▸ │ │  ← Top-level deck
│ ├───────────────────────────────────┤ │
│ │ 📚 IELTS words       180 cards ▸ │ │
│ └───────────────────────────────────┘ │
│                                       │
│                            ┌───┐      │
│                            │ + │      │  ← FAB
│                            └───┘      │
├───────────────────────────────────────┤
│ 🏠 Home  📚 Library  📈 Progress  ⚙️  │
└───────────────────────────────────────┘
```

## Layout — empty state

```
┌───────────────────────────────────────┐
│ Library                  🔍   ⋮       │
├───────────────────────────────────────┤
│                                       │
│              📁                        │
│                                       │
│      Start your library              │
│                                       │
│   Folders keep related decks         │
│   together. Add one to organize      │
│   your decks.                        │
│                                       │
│          ┌────────────────┐          │
│          │ + Create folder │          │
│          └────────────────┘          │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param                           | Source                   | Notes                                      |
|---------------------------------|--------------------------|--------------------------------------------|
| `filter` (optional query param) | URL                      | `all` / `folders` / `decks`; default `all` |
| `sort` (optional query param)   | URL or SharedPreferences | persisted                                  |

## Data to load

| Data                                    | Source                               | Refresh trigger                                       |
|-----------------------------------------|--------------------------------------|-------------------------------------------------------|
| Top-level folders (`parent_id IS NULL`) | `folders` table                      | stream from DB                                        |
| Top-level decks (`folder_id IS NULL`)   | Rejected / Out of Scope              | do not query; decks must belong to exactly one folder |
| Per-row card count (decks)              | `flashcards` aggregate cached        | invalidated on flashcard change                       |
| Per-row subfolder/deck count (folders)  | aggregates cached                    | invalidated on folder/deck change                     |
| Sort preference                         | SharedPreferences key `library.sort` | watch                                                 |

## Forbidden

- ❌ Query DAO from widget. Use `LibraryNotifier`.
- ❌ Mix folder and deck rows alphabetically when sort is manual. Folders MUST appear above decks in
  manual sort.
- ❌ Recompute aggregate counts on every render. Cache 60s.
- ❌ Lose drag-reorder on app restart. Persist to `sort_order` column.
- ❌ Show a root "New deck" action on Library Overview. Deck creation stays owned by folder/detail flows.

## Components

| Component       | Spec                                                                            |
|-----------------|---------------------------------------------------------------------------------|
| App bar         | Title "Library". Right side: sliders/filter icon (disabled).                    |
| Filter chips    | Optional. Three chips: All / Folders / Decks. Default: All.                     |
| Item row        | Accent tile + name + optional subtitle + counts row + due badge + progress bar + kebab. Card padding is `14dp` on all sides, with `14dp` gaps between the leading tile, body, and trailing action, and `8dp` internal rhythm between subtitle/counts/progress. |
| Folder subtitle | Direct child names joined with ` · ` when available; fallback is the count row. |
| Folder new      | `{n} new` from `flashcard_progress` rows where `due_at IS NULL`.                |
| Deck subtitle   | "{n} cards" (total) and optional "{m} due" badge in theme color.                |
| FAB             | Plus button (bottom-right). Tap → create-folder dialog. |

### Count semantics

- Folder-row counts are recursive over the folder subtree: descendant subfolders, decks in any
  descendant folder, and flashcards inside those decks are included.
- Root-level sibling folder trees are isolated; counts from one root folder do not leak into
  another.
- Empty nested folders contribute `0` deck/card/due/new-card counts.
- Deck/card counts are derived from deck and flashcard rows in the subtree and are not recomputed in
  presentation.

## States

| State       | Trigger                           | Behavior                                               |
|-------------|-----------------------------------|--------------------------------------------------------|
| Loading     | Initial query                     | Shimmer rows.                                          |
| Populated   | Normal                            | List shown.                                            |
| Empty       | No folders AND no top-level decks | Empty state layout.                                    |
| Error       | Query failure                     | Inline error card with retry.                          |
| Sort active | User picked a sort                | Items reordered; chip in app bar showing current sort. |

## Sort options (from overflow)

| Sort             | Stored as               |
|------------------|-------------------------|
| Manual (default) | `sort_order`            |
| Name A→Z         | `name` ascending        |
| Name Z→A         | `name` descending       |
| Recently updated | `updated_at` descending |
| Most cards       | computed                |

Sort preference persists per user via SharedPreferences (key `library.sort`).

## Actions

| Action                        | Trigger                  | Result                                                                                                                                                                                    |
|-------------------------------|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Tap folder row                | Tap                      | Navigate to `/library/folder/:id`.                                                                                                                                                        |
| Tap deck row                  | Tap                      | Navigate to `/library/deck/:deckId/flashcards`.                                                                                                                                           |
| Long-press folder/deck        | Long-press               | Enter selection mode (multi-select) OR open context bottom-sheet (Rename / Move / Delete). Decide via UI/UX contract; recommend context sheet here since multi-select on folders is rare. |
| Tap header sliders icon       | Tap                      | Visual-only disabled affordance; no sheet.                                                                                                                                                 |
| Tap FAB                       | Tap                      | Create-folder dialog (`docs/wireframes/24-shared-dialogs.md` §folder-form).                                                                                                               |
| Pull to refresh               | Pull                     | Re-run queries.                                                                                                                                                                           |
| Reorder (drag) in Manual sort | Long-press handle + drag | Update `sort_order` of dragged item; persist on drop.                                                                                                                                     |

## Dialogs and bottom-sheets used

- Library create-folder dialog — see `docs/wireframes/24-shared-dialogs.md` §folder-form.
- Item context sheet (Rename / Move / Delete) — see `docs/wireframes/25-shared-bottom-sheets.md`
  §item-context.
- Delete confirm dialog — see `docs/wireframes/24-shared-dialogs.md` §delete-confirm.
- Move-to-folder picker — see `docs/wireframes/25-shared-bottom-sheets.md` §folder-picker.

## Navigation in

- Bottom nav tap "Library".
- App launch when user has explicit deep-link.
- From Settings → Manage data → back to Library.

## Navigation out

- Folder row → `/library/folder/:id`.
- Deck row → `/library/deck/:deckId/flashcards`.
- No Library Overview app-bar search entry; use the inline field below the title.
- Tabs → other top-level destinations.

## Responsive

- ≥600dp: grid layout, 2 columns of cards instead of single-column list.
- ≥1024dp: 3 columns; FAB stays bottom-right.

## Performance

- Stream-based query via Drift `watchTopLevelFoldersAndDecks`. Re-renders on data change.
- Reorder writes batched; one transaction per drop.
- Card-count subtitle uses cached counts (avoid count per row on every render).

## Accessibility

- Item rows: announce "{Folder|Deck} {name}, {subtitle}".
- FAB icon button with `Add content` tooltip.
- Filter chips selectable via keyboard nav on tablet.

## Rules

- Top-level items are folders + decks whose `folder_id` is null.
- Decks at root are allowed (Library is treated as an implicit unlocked root container; "decks can
  be in folders that are unlocked or `decks` mode" — root is conceptually unlocked).
- Library Overview FAB must stay create-folder only; Import remains owned by folder/detail flows.
- Sort default is Manual (user-controlled order via `sort_order`).

## Agent rule

- Do NOT create a separate route for "folder/0" or root folder. Library IS the root.
- Do NOT mix folder and deck rows visually in confusing ways; keep folders above decks when sorting
  by manual order.
- Reorder MUST persist; do not lose order on app restart.
- Empty state CTAs MUST be clearly distinct visually from FAB to avoid duplicate paths confusion.

## Implementation refs

**Business specs:**

- `docs/business/folder/folder-management.md`
- `docs/business/deck/deck-management.md`
- `docs/business/search/global-search.md` (global search route contract)

**Decision rows:**

- Folder management, Deck management (top-level rules)

**Schema / storage:**

- `folders` (parent_id = null = root), `decks` (folder_id = null = root)
- SharedPreferences: `library.sort`

**Contracts:** `docs/contracts/usecase-contracts/folder.md`,
`docs/contracts/usecase-contracts/deck.md`,
`docs/contracts/repository-contracts/folder-repository.md`,
`docs/contracts/repository-contracts/deck-repository.md`

**Code paths (verified Prompt 18):**

- `lib/presentation/features/folders/screens/library_overview_screen.dart`
- `lib/presentation/features/folders/viewmodels/library_overview_viewmodel.dart` (
  `libraryOverviewQuery`, `LibraryToolbarState`, `LibraryOverviewActionController`)
- `lib/presentation/features/folders/widgets/library_overview_body.dart` (
  loaded/empty/search-no-results switch)
- `lib/presentation/features/folders/widgets/library_folder_tile.dart` (folder card row + kebab /
  long-press → folder action sheet)
- `lib/presentation/features/folders/widgets/library_folder_actions_sheet.dart` (Rename / Move /
  Import flashcards / Delete action sheet)
- `lib/presentation/features/folders/widgets/folder_move_picker_sheet.dart` (move destination picker)
- `lib/presentation/shared/dialogs/mx_bottom_sheet.dart` (modal sheet host),
  `lib/presentation/shared/dialogs/mx_confirm_dialog.dart` (delete confirm)
- `lib/domain/usecases/folder/{rename_folder,move_folder,delete_folder,get_folder_move_targets}_usecase.dart`
- `lib/presentation/features/folders/widgets/library_sections.dart` (`LibraryDueSummaryCard`,
  `LibraryFolderCountHeader`, `LibraryEmptyStateSection`, `LibrarySearchNoResultsSection`,
  `LibraryErrorSection`)
- `lib/presentation/features/folders/widgets/library_search_field.dart` (inline scope-local search)
- `lib/presentation/features/folders/widgets/library_skeleton.dart` (`LibrarySkeleton`, Prompt 49)
- `lib/presentation/features/folders/routes/folder_routes.dart` (`libraryBranchRoutes`)
- `lib/domain/usecases/content_query_usecases.dart` → `WatchLibraryOverviewUseCase`
- `lib/data/repositories/folder_repository_impl.dart` → `getLibraryOverview`
- `lib/app/router/route_names.dart` → `RouteNames.library`
- `docs/design/screens/library-overview.visual-contract.md` — mock-to-code visual mapping

**Related wireframes:**

- `docs/wireframes/05-folder-detail.md` — child folder detail
- `docs/wireframes/06-flashcard-list.md` — deck content
- `docs/wireframes/11-library-search.md` — search target
- `docs/wireframes/24-shared-dialogs.md` §folder-form, §delete-confirm
- `docs/wireframes/25-shared-bottom-sheets.md` §library-fab, §deck-create, §item-context,
  §folder-picker
