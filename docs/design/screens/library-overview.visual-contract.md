---
last_updated: 2026-06-06
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
4. Visual reference: `docs/system-design/MemoX Design System/ui_kits/mobile/index.html` -
   `03 · Library overview` (`03a`-`03f`).
5. Design tokens and shared components: `docs/design/design-token-mapping.md`,
   `docs/design/component-visual-contract.md`, `docs/ui-ux/ui-ux-contract.md`.
6. Current Flutter implementation.

If these sources conflict, do not guess. Follow `CLAUDE.md` drift detection.

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
| Due summary card             | Current partial                  | Renders `{n} cards due today`, the subtitle `Across {n} folders · ~{m} min`, and a non-launch chevron; the card itself is non-interactive. |
| Folder cards                 | Current                          | Root renders top-level folders only.                                                                               |
| Folder progress/mastery bar  | Future                           | No approved progress/mastery field in current Library read model.                                                  |
| Folder due badge             | Current                          | Show only when `dueCount > 0`.                                                                                     |
| Folder new badge             | Future                           | No approved new-card field in current Library row contract.                                                        |
| Folder kebab affordance      | Current                          | Visible trailing `Icons.more_vert`; tap (and row long-press) open the folder action sheet.                         |
| Folder action sheet          | Current                          | Rename / Move to folder / Import flashcards (decks-mode only) / Delete. Backed by real use cases + tests.          |
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
| Due summary       | Card with bolt icon and due count                          | `LibraryDueSummaryCard`                | `MxCard`, `MxIconTile`, `MxText`                 | Non-interactive; show subtitle `Across {n} folders · ~{m} min` and chevron when due summary is present. |
| Section header    | `{n} folders` overline/count                               | `LibraryFolderCountHeader`             | `MxSectionHeader`                                | Render the mock-aligned `Recent` pill as current visual parity, but keep it non-interactive. |
| Folder card       | Card surface, icon tile, title, metadata, due badge, kebab | `LibraryFolderTile`                    | `MxCard`, `MxIconTile`, `MxIconButton`, `MxText` | No chevron.                                     |
| Metadata row      | Deck/subfolder count plus card count                       | `LibraryFolderTile`                    | Theme text/icon roles                            | Use recursive counts from read model.           |
| Due badge         | Compact primary-tint pill                                  | `LibraryFolderTile`                    | Tokenized opacity/radius/text                    | Show only when `dueCount > 0`.                  |
| Loading           | Skeleton folder rows                                       | `LibrarySkeleton`                      | `MxSkeleton` in `MxCard`                         | No tappable folder while data absent.           |
| True empty        | Empty state with create-folder CTA                         | `LibraryEmptyStateSection`             | `MxEmptyState`                                   | No root deck/import CTA.                        |
| Search no results | Search empty state with Clear CTA                          | `LibrarySearchNoResultsSection`        | `MxEmptyState`                                   | Only when search active and total folders > 0.  |
| Error             | Error state with Retry                                     | `LibraryErrorSection`                  | `MxErrorState`                                   | Localized message; no raw failure text.         |
| FAB               | Extended `New folder` pill                                 | `MxFab.extended`                       | Themed FAB                                       | Opens create-folder dialog.                     |
| Bottom nav        | Rounded shared nav with selected state                     | `AppShell`, `MxBottomNavigationBar`    | Shared navigation component                      | Preserve tab behavior.                          |

## State Matrix

| Mock ID | State             | Trigger                                                     | Required UI                                                                                     | Actions                                                           | Data dependency                                                  | Implementation notes                                              |
|---------|-------------------|-------------------------------------------------------------|-------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|------------------------------------------------------------------|-------------------------------------------------------------------|
| `03a`   | Loaded            | Query returns folders                                       | Header, inline search, optional due summary, folder count header, folder cards, FAB, bottom nav | Tap folder navigates to folder detail; create folder opens dialog | `LibraryOverviewReadModel.folders`, `dueToday`, recursive counts | Hide unsupported sort/filter/root-deck controls.                  |
| `03b`   | Loading           | Initial query pending                                       | Inline search shell plus skeleton folder rows                                                   | No folder tap                                                     | Async query pending                                              | Use `MxRetainedAsyncState.skeletonBuilder` and `LibrarySkeleton`. |
| `03c`   | True empty        | `totalFolderCount == 0`                                     | Empty state with create-folder CTA                                                              | Create folder opens dialog                                        | `totalFolderCount`                                               | Do not expose New deck or Import from root.                       |
| `03d`   | Error             | Query failure                                               | `MxErrorState` with retry                                                                       | Retry invalidates query                                           | Async error/failure                                              | No raw exception text.                                            |
| `03e`   | Search no-results | Search active, total folders > 0, visible folder list empty | Search empty state with Clear CTA                                                               | Clear search term                                                 | `searchTerm`, `folders`, `totalFolderCount`                      | Do not navigate to Global Search.                                 |
| `03f`   | Overflow sheet    | Kebab tap or folder-row long-press                          | Folder action sheet: Rename / Move / Import flashcards (decks-mode only) / Delete                | Each action dispatches its dialog/picker/navigation               | Folder mutation use cases + `getFolderMoveTargets`               | Current. "Study due cards" / "Archive folder" stay out of scope.  |

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
- Do not expose a sort UI control.
- Do not claim deck/card/tag search in Library Overview V1; that scope is Future.
- Do not fake progress, mastery, folder-span subtitle, study duration, or new-card data.
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
