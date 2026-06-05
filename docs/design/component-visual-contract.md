---
last_updated: 2026-06-05
status: contract
applies_to: UI mock-to-code implementation
---

# Component Visual Contract

Feature screens should compose MemoX shared widgets first. The mock defines
visual intent; production code maps that intent to existing `Mx*` components,
theme tokens, l10n, and route contracts.

## Required Component Mapping

| UI need | Required shared component or owner | Do not use directly in feature widgets |
| --- | --- | --- |
| Screen scaffold | `MxScaffold`, `MxAdaptiveScaffold`, `MxListScaffold`, or another approved layout shell | Raw `Scaffold` for feature screens when an `Mx*` shell fits |
| App bar | `MxAppBar` | Raw `AppBar` |
| Search input | `MxSearchField` | Raw `TextField`, raw `SearchBar` |
| Card surface | `MxCard` | Raw `Container(decoration: ...)`, raw `Card` in feature widgets |
| Row/card tap target | `MxTappable` through shared surfaces | Raw `InkWell` / `GestureDetector` |
| Icon tile | `MxIconTile` | Custom repeated icon box |
| Section header | `MxSectionHeader` | Hand-rolled all-caps text |
| FAB | `MxFab` / `MxFab.extended` | Raw `FloatingActionButton` |
| Text with role | `MxText` | Raw `Text` where role, token, or contrast matters |
| Empty state | `MxEmptyState` | Custom empty-state layout |
| Error state | `MxErrorState` | Raw exception text or one-off error card |
| Loading list state | `MxSkeleton`, `MxRetainedAsyncState`, or approved async shared component | Full-screen spinner for list first load |
| Snackbar/toast | `showMxSnackbar` | Raw `SnackBar` / `ScaffoldMessenger` |
| Dialog | Shared `Mx*` dialog such as `showMxNameDialog` | One-off dialog layout |
| Bottom navigation | `MxBottomNavigationBar` | Raw `NavigationBar` when visual parity is required |
| Bottom sheet | Existing shared sheet from `docs/wireframes/25-shared-bottom-sheets.md` when available | One-off sheet for a documented shared pattern |

## Promotion Rule

If a required shared component does not exist:

- First check `lib/presentation/shared/mx_widgets.dart` and `lib/presentation/shared/**`.
- Use an existing component with the closest documented role when it preserves behavior and accessibility.
- Create a new shared widget only when the task explicitly requires the repeated pattern or the repo docs approve that promotion.
- Do not create a shared widget only to mirror mock CSS.
- Do not implement unsupported behavior just to make a mock control look active.

## Screen Contract Rule

Every screen visual contract should map:

- Mock element.
- Route/screen/component.
- Current implementation file.
- Shared component/token to use.
- State visibility.
- Behavior scope: Current, Future, Rejected, Unknown, or Visual-only.
- Reason for every visible mock element that is not implemented.

## Library Overview Current Mapping

Library Overview is the first fully mapped example:

- Visual contract: `docs/design/screens/library-overview.visual-contract.md`
- Wireframe: `docs/wireframes/02-library.md`
- Screen: `lib/presentation/features/folders/screens/library_overview_screen.dart`
- Body/state owner: `lib/presentation/features/folders/widgets/library_overview_body.dart`
- Folder card: `lib/presentation/features/folders/widgets/library_folder_tile.dart`
- Sections/states: `lib/presentation/features/folders/widgets/library_sections.dart`
- Search: `lib/presentation/features/folders/widgets/library_search_field.dart`
- Shell bottom navigation: `lib/app/app_shell.dart`

## Forbidden

- Do not bypass `Mx*` components in feature widgets when a documented component fits.
- Do not hardcode strings instead of ARB/l10n.
- Do not hardcode route strings or call raw router APIs.
- Do not introduce mock-only local state flags instead of viewmodel/provider state.
- Do not replace a visible mock element with a different UI pattern without documenting why.
- Do not silently skip visible mock elements.

## Related

- `docs/design/design-token-mapping.md`
- `docs/design/visual-parity-checklist.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/contracts/code-style.md`
- `lib/presentation/shared/mx_widgets.dart`
