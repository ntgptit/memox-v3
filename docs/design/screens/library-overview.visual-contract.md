---
last_updated: 2026-06-13
status: contract
route: /library
screen: Library Overview
---

# Library Overview Visual Contract

This is the source of truth for mapping the approved Library Overview mock to
Flutter implementation. It narrows mock visuals through current MemoX product
scope, wireframes, shared components, and design tokens.

## Source Priority

1. Business and route scope: `docs/business/folder/folder-management.md`,
   `docs/business/deck/deck-management.md`, `docs/business/search/global-search.md`,
   `docs/business/navigation/navigation-flow.md`.
2. Current screen behavior and state scope: `docs/wireframes/02-library.md`.
3. Mock group mapping: `docs/system-design/mock-design-doc-mapping.md`.
4. Visual reference: `docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md`
   §`03 — Library overview` (11 kit states: `03a` Loaded · `03b` Loading · `03c` Empty ·
   `03d` Error · `03e` Search · `03f` Overflow sheet · `03g` Create folder · `03h` Rename
   folder · `03i` Move folder · `03j` Archive folder · `03k` Delete folder), and the measured
   DOM spec `docs/system-design/MemoX Design System/ui_kits/mobile/specs/03-library-overview.md`.
5. Design tokens and shared components: `docs/design/design-token-mapping.md`,
   `docs/design/component-visual-contract.md`, `docs/ui-ux/ui-ux-contract.md`.
6. Current Flutter implementation.

If these sources conflict, do not guess. Follow `CLAUDE.md` drift detection.

The auto-generated DOM spec may still contain stale mock copy such as `Search
decks, cards, tags`. For V1 behavior, this visual contract plus
`docs/wireframes/02-library.md` override that copy until the source design/spec
is regenerated.

## Implementation Files

| Concern                                         | File                                                                           |
|-------------------------------------------------|--------------------------------------------------------------------------------|
| Screen shell, app bar, FAB                      | `lib/presentation/features/folders/screens/library_overview_screen.dart`       |
| Query and toolbar state                         | `lib/presentation/features/folders/viewmodels/library_overview_viewmodel.dart` |
| Loaded/empty/search-no-results body switch      | `lib/presentation/features/folders/widgets/library_overview_body.dart`         |
| Folder card row                                 | `lib/presentation/features/folders/widgets/library_folder_tile.dart`           |
| Due summary, count header, empty/error sections | `lib/presentation/features/folders/widgets/library_sections.dart`              |
| Inline search                                   | `lib/presentation/features/folders/widgets/library_search_field.dart`          |
| Loading skeleton                                | `lib/presentation/features/folders/widgets/library_skeleton.dart`              |
| Folder action sheet                             | `lib/presentation/features/folders/widgets/library_folder_actions_sheet.dart`  |
| Move destination picker                         | `lib/presentation/features/folders/widgets/folder_move_picker_sheet.dart`      |
| Modal sheet host / delete confirm               | `lib/presentation/shared/dialogs/mx_bottom_sheet.dart`, `mx_confirm_dialog.dart` |
| Folder mutation use cases                       | `lib/domain/usecases/folder/{rename,move,delete,get_folder_move_targets}_*.dart` |
| Top-level shell navigation                      | `lib/app/app_shell.dart`                                                       |

## Scope Decision

| Mock element                 | V1 status                        | Reason                                                                                                             |
|------------------------------|----------------------------------|--------------------------------------------------------------------------------------------------------------------|
| Header title `Library`       | Current                          | Existing route title.                                                                                              |
| Header sliders/filter icon   | Current visual-only              | No approved filter/sort sheet; render disabled.                                                                    |
| Inline search field          | Current                          | Library-local folder search only.                                                                                  |
| Search decks/cards/tags hint | Approved mock/spec variance      | Canonical PNG/spec text still shows `Search decks, cards, tags`, but V1 search is folder-only and uses `Search folders`. The variance is documented until source design regeneration. |
| Due summary card             | Current partial                  | Renders `{n} cards due today`, the subtitle `Across {n} folders · ~{m} min`, and a non-launch chevron inside a flat `MxCard`; the card itself is non-interactive. |
| Folder cards                 | Current                          | Root renders top-level folders only.                                                                               |
| Folder progress/mastery bar  | Future                           | No approved progress/mastery field in current Library read model.                                                  |
| Folder due badge             | Current                          | Show only when `dueCount > 0`.                                                                                     |
| Folder new badge             | Future                           | No approved new-card field in current Library row contract.                                                        |
| Folder kebab affordance      | Current                          | Visible trailing `Icons.more_vert`; tap (and row long-press) open the folder action sheet.                         |
| Folder action sheet          | Current                          | Rename / Move to folder / Import flashcards (decks-mode only) / Delete. Backed by real use cases + tests.          |
| Overflow "Study due cards"   | Future / visual-only             | No approved Library study-launch route; the action is not exposed in the implemented sheet.                        |
| Overflow "Archive folder"    | Future / visual-only             | No archive use case / repository method / DAO / schema column exists; the action is not exposed in the implemented sheet. |
| Create-folder modal          | Current                          | `showMxFolderCreateDialog` → `createFolder`. Mock color/icon pickers map to the existing dialog fields.            |
| Rename-folder modal          | Current                          | `showMxFolderRenameDialog` → `renameFolder` (sibling-name uniqueness, no-op on unchanged name).                    |
| Move-folder modal            | Current                          | `getFolderMoveTargets` + `showFolderMovePicker` → `moveFolder` (cycle / decks-lock destinations shown disabled).   |
| Archive-folder modal         | Future / visual-only             | Confirm dialog has no backend; not reachable because the overflow Archive action is not exposed.                   |
| Delete-folder modal          | Current                          | `showMxFolderDeleteDialog` → `deleteFolder` (cascade). Mock's type-to-confirm maps to the shared confirm dialog.   |
| Sort pill `Recent`           | Current visual parity, non-interactive | Sort exists in data/use-case layer and the header renders the mock-aligned `Recent` pill as a visual-only control. |
| Filter chips                 | Future                           | Removed from loaded header; real filter UI needs a promoted task.                                                  |
| New folder FAB               | Current                          | Root folder creation through existing dialog.                                                                      |
| Root New deck                | Rejected                         | Decks must belong to a folder.                                                                                     |
| Root Import                  | Rejected                         | Import is owned by folder/detail deck flows, not Library root.                                                     |
| Root-level deck rows         | Rejected                         | `LibraryOverviewReadModel` carries folders only.                                                                   |
| Bottom navigation            | Current                          | Four top-level tabs via shared shell navigation.                                                                   |

## Visual Mapping Table

| Mock area         | Required visual                                            | Existing component/code                | Token/component rule                             | Notes                                           |
|-------------------|------------------------------------------------------------|----------------------------------------|--------------------------------------------------|-------------------------------------------------|
| Screen background | Full-screen themed surface                                 | `MxScaffold`                           | Theme surface role only                          | No raw hex in feature widgets.                  |
| Header            | Large `Library` title, left aligned                        | `MxAppBar`                             | App bar theme                                    | Use l10n title.                                 |
| Header action     | Sliders/tune icon on right                                 | `MxIconButton(Icons.tune_rounded)`     | Disabled while visual-only                       | No fake filter behavior.                        |
| Search field      | Rounded full-width field below title                       | `LibrarySearchField` + `MxSearchField` | Shared input component                           | Hint must say `Search folders`; PNG/spec text is stale for V1. |
| Search shortcut   | Right-side `K` keycap when the field is empty              | `LibrarySearchField`                  | Local keycap surface                             | Visual parity only; it disappears once the user types. |
| Due summary       | Card with bolt icon and due count                          | `LibraryDueSummaryCard`                | `MxCard`, `MxIconTile`, `MxText`                 | Non-interactive; show subtitle `Across {n} folders · ~{m} min` and chevron when due summary is present. |
| Section header    | `{n} folders` overline/count                               | `LibraryFolderCountHeader`             | `MxSectionHeader`                                | Render the mock-aligned `Recent` pill as current visual parity, but keep it non-interactive. |
| Folder card       | Card surface, icon tile, title, metadata, due badge, kebab | `LibraryFolderTile`                    | `MxCard`, `MxIconTile`, `MxIconButton`, `MxText` | No chevron.                                     |
| Metadata row      | Deck/subfolder count plus card count                       | `LibraryFolderTile`                    | Theme text/icon roles                            | Use recursive counts from read model.           |
| Due badge         | Compact primary-tint pill                                  | `LibraryFolderTile`                    | Tokenized opacity/radius/text                    | Show only when `dueCount > 0`.                  |
| Loading           | Loading overline + skeleton folder rows                    | `LibrarySkeleton`                      | `MxSkeleton` in `MxCard`                         | No tappable folder while data absent; label uses `libraryLoadingFoldersLabel`. |
| True empty        | Large empty card with create-folder CTA                    | `LibraryEmptyStateSection`             | Custom `MxCard` composition                     | No root deck/import CTA.                        |
| Search no results | Large search-empty card with Clear CTA                     | `LibrarySearchNoResultsSection`        | Custom `MxCard` composition                     | Only when search active and total folders > 0.  |
| Error             | Large error card with Retry                                | `LibraryErrorSection`                  | Custom `MxCard` composition                     | Localized message; no raw failure text.         |
| FAB               | Minimal icon FAB with `New folder` tooltip                 | `MxFab`                                | Themed FAB                                       | Opens create-folder dialog.                     |
| Bottom nav        | Rounded shared nav with selected state                     | `AppShell`, `MxBottomNavigationBar`    | Shared navigation component                      | Preserve tab behavior.                          |

## State Matrix

This table maps every one of the 11 Library Overview kit states from
`docs/system-design/MemoX Design System/ui_kits/mobile/shots/INDEX.md` §`03 — Library overview`.
Mock IDs follow the INDEX order; there is exactly one row per state.

| Mock ID | State          | Trigger                                            | Required UI                                                                                                                              | Runtime action                                                                                  | Data dependency                                                  | Implementation status                                                                                                                              |
|---------|----------------|----------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| `03a`   | Loaded         | Query returns folders                              | Header, inline search (`Search folders` hint + right-side `K` keycap while the field is empty), optional due summary, `{n} folders` count header + non-interactive `Recent` pill, folder cards, icon FAB with `New folder` tooltip, bottom nav | Tap folder → folder detail; kebab / row long-press → overflow sheet; FAB → create-folder dialog | `LibraryOverviewReadModel.folders`, `dueToday`, recursive counts | **Current.** Sort/filter/root-deck stay hidden or non-interactive; folder progress bar / new-card dot render only when the read model carries the value. |
| `03b`   | Loading        | Initial query pending                              | Inline search shell + `Loading folders` overline + skeleton folder rows (`ValueKey('library_skeleton')`)                                  | None — no folder row is tappable while data is absent                                            | Async query pending                                              | **Current.** `MxRetainedAsyncState.skeletonBuilder` → `LibrarySkeleton`.                                                                          |
| `03c`   | Empty          | `totalFolderCount == 0`                            | Large empty card with create-folder CTA                                                                                                   | Create folder → `showMxFolderCreateDialog`                                                       | `totalFolderCount`                                               | **Current.** No root New deck / Import CTA (Rejected). Distinct from search no-results (see Derived states).                                       |
| `03d`   | Error          | Query failure                                      | Large error card with localized title/message + Retry                                                                                     | Retry → `ref.invalidate(libraryOverviewQueryProvider)`                                           | Async error / failure                                            | **Current.** No raw exception text surfaced.                                                                                                      |
| `03e`   | Search         | Search term active, ≥1 matching folder             | Inline field + filtered folder rows only; due summary and folder-count header hidden                                                     | Tap folder / kebab; clear field restores the loaded list; never navigates to Global Search      | `searchTerm`, `folders`                                          | **Current but folder-only.** Hint is `Search folders`; the kit/spec text `Search decks, cards, tags` is an approved stale variance. Deck/card/tag search is Future. |
| `03f`   | Overflow sheet | Kebab tap or folder-row long-press                 | Folder action sheet header (name + subtitle) and rows: Rename / Move to folder / Import flashcards (decks-mode only) / Delete folder     | Each row dispatches its dialog / picker / navigation and pops the sheet                          | Folder mutation use cases + `getFolderMoveTargets`               | **Current** for the supported subset. Mock's "Open folder" = the row tap itself; "Study due cards" and "Archive folder" are **not exposed** (see `03j` / Derived note). |
| `03g`   | Create folder  | FAB icon or empty-state CTA                        | Create-folder dialog: name field, color + icon pickers, Cancel / Create                                                                 | `showMxFolderCreateDialog` → `libraryActionController.createFolder` → Drift stream refreshes     | `createRootFolderUseCase`                                        | **Current.** Blank name rejected by the dialog; mutation failure → localized error snackbar.                                                      |
| `03h`   | Rename folder  | Overflow sheet → Rename                             | Rename dialog: pre-filled name field, helper line, Cancel / Rename                                                                       | `showMxFolderRenameDialog` → `renameFolder` (sibling-name uniqueness, no-op on unchanged name)  | `renameFolderUseCase`                                            | **Current.** Success / failure → localized snackbar.                                                                                              |
| `03i`   | Move folder    | Overflow sheet → Move to folder                    | Move destination picker: Library (root) + candidate folders, blocked destinations shown disabled with a reason, Cancel / Move here       | `getFolderMoveTargets` → `showFolderMovePicker` → `moveFolder`                                   | `getFolderMoveTargetsUseCase`, `moveFolderUseCase`              | **Current.** Self / descendant (cycle) and decks-locked destinations are disabled, never hidden.                                                  |
| `03j`   | Archive folder | Mock: overflow sheet → Archive (confirm dialog)    | Mock-only: archive confirm dialog with restore reassurance, Cancel / Archive                                                             | None reachable — the overflow Archive action is not exposed                                      | None — no archive read/write path exists                         | **Future / visual-only.** No archive use case / repository method / DAO / schema column. Building it requires an approved backend task.            |
| `03k`   | Delete folder  | Overflow sheet → Delete folder                     | Destructive confirm dialog: subtree-removal copy, reassurance, type-to-confirm, Cancel / Delete folder                                   | `showMxFolderDeleteDialog` → `deleteFolder` (cascades the subtree)                               | `deleteFolderUseCase`                                            | **Current.** Mock's type-to-confirm maps to the shared `MxConfirmDialog` confirm hint.                                                            |

### Derived states (not separate kit shots)

- **Search no-results** — search term active, `totalFolderCount > 0`, zero visible folders →
  `LibrarySearchNoResultsSection` (`ValueKey('library_search_no_results')`) with a Clear CTA.
  This is the search counterpart of `03e`; the kit ships it only as the separate
  `05 — Library search` no-results shot, so it has no `03x` ID here. It must stay distinct from the
  true-empty `03c` state and must not navigate to Global Search.

## Folder Card Contract

Required structure:

1. Outer card.
    - Use `MxCard`.
    - Flat surface with ghost border.
    - No heavy shadow.
    - Comfortable tokenized padding.

2. Leading icon tile.
    - Use `MxIconTile`.
    - Folder icon.
    - Fixed visual role; do not resize per row.

3. Main content.
    - Folder name, one line with ellipsis.
    - Metadata row from available counts:
        - subfolder or deck count, based on `ContentMode`
        - card count
        - due badge when `dueCount > 0`
    - Do not show progress/mastery/new-card data unless the read model provides it.

4. Trailing action.
    - Use `Icons.more_vert`.
    - Tooltip from l10n.
    - Visible as the row action affordance.
    - Tap (and a row long-press) open the folder action sheet (Rename / Move / Import / Delete).

Forbidden:

- Do not show a chevron on Library folder cards.
- Do not show a root-level deck row.
- Do not expose root New deck or Import.
- Do not expose an interactive sort sheet/control; the non-interactive
  `Recent` pill is allowed as current visual parity.
- Do not keep the overview summary card or folder-count header visible while
  a search term is active and matching rows are shown.
- Do not claim deck/card/tag search in Library Overview V1; that scope is Future.
- Do not fake progress, mastery, new-card data, or unsupported study-launch
  data. The due summary subtitle/duration may be shown only when derived from
  the approved aggregate read model.
- Do not expose the mock's "Study due cards" / "Archive folder" overflow actions (out of scope).

## Acceptance Criteria For Future UI Work

The screen is accepted only when:

- Every visible mock element is mapped to Current, Future, Rejected, Unknown, or Visual-only.
- Header, inline search, loaded list, FAB, and bottom nav visually resemble the approved mock within
  current design-system tokens.
- Folder cards look like card rows, not simple list items.
- Folder rows use a visible kebab, not a chevron.
- Due badge appears only when `dueCount > 0`.
- Due summary appears only when `dueToday > 0`.
- Empty, search no-results, error, and loading states remain distinct.
- No unsupported V1 behavior is exposed.
- `dart fix --apply` and `dart format .` run before `flutter analyze`, targeted widget tests, and
  guard checks pass for UI code changes.

## Related

- `docs/design/mock-design-index.md`
- `docs/design/design-token-mapping.md`
- `docs/design/component-visual-contract.md`
- `docs/design/visual-parity-checklist.md`
- `docs/wireframes/02-library.md`
- `docs/system-design/mock-design-doc-mapping.md`
