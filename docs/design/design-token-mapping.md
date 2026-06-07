---
last_updated: 2026-06-07
status: contract
applies_to: UI mock-to-code implementation
---

# Design Token Mapping

Agents must map mock visual intent to existing Flutter theme roles and tokens.
Do not copy raw CSS values from the mock HTML into feature widgets.

## Source Priority

| Concern | Source |
| --- | --- |
| Product behavior and route scope | `docs/business/**`, `docs/wireframes/**` |
| Visual token intent | `docs/system-design/MemoX Design System/README.md`, `docs/system-design/MemoX Design System/colors_and_type.css` |
| Flutter token names | `lib/core/theme/tokens/**`, `lib/core/theme/extensions/theme_context.dart` |
| Feature implementation | `lib/presentation/features/**` |
| Shared widgets | `lib/presentation/shared/**` |

## Spacing

| Mock usage | Required token |
| --- | --- |
| Tiny icon/text gap | `SpacingTokens.xxs` or `SpacingTokens.xs` |
| Compact row gap | `SpacingTokens.sm` |
| Icon tile to text gap | `SpacingTokens.md` |
| Card inner padding | `SpacingTokens.cardPadding` or `SpacingTokens.lg` |
| Screen horizontal padding | `SpacingTokens.screenPadding` or the owning scaffold/content shell |
| Section gap | `SpacingTokens.lg`, `SpacingTokens.xl`, or `SpacingTokens.sectionGap` |
| List row separator | `SpacingTokens.sm` |

## Radius

| Mock usage | Required token |
| --- | --- |
| Card, dialog, sheet surface | `RadiusTokens.brLg` |
| Button, input, icon tile | `RadiusTokens.brMd` |
| Larger navigation container | `RadiusTokens.brXl` |
| FAB role | Shared `MxFab` / themed FAB radius |
| Pill chip, badge, search affordance | `RadiusTokens.brFull` |

## Size

| Mock usage | Required token/component |
| --- | --- |
| Small inline icon | `SizeTokens.iconXs` or `SizeTokens.iconSm` |
| Regular icon | `SizeTokens.iconMd` |
| Large empty-state icon | `SizeTokens.iconXl` |
| Micro status dot | `SizeTokens.dot` |
| Minimum touch target | `SizeTokens.touch` |
| Search field | `SizeTokens.input` via `MxSearchField` |
| Bottom navigation | `SizeTokens.bottomNav` via `MxBottomNavigationBar` |
| App bar | `SizeTokens.appbar` / `SizeTokens.appbarLg` via `MxAppBar` |
| FAB | `SizeTokens.fab` via `MxFab` |

## Typography

| Mock usage | Required rule |
| --- | --- |
| Screen title | `MxAppBar` or `MxText` using theme typography |
| Card title | `MxTextRole.titleSmall` / `MxTextRole.titleMedium` as density requires |
| Body and helper text | `MxTextRole.bodyMedium` / `MxTextRole.labelMedium` |
| Section overline | `MxSectionHeader`; do not hand-roll all-caps text |
| Count labels | Use l10n pluralization and tabular-number-friendly text roles when available |

Use `TypographyTokens` for weights and special letter spacing only inside shared
widgets or feature widgets that already use an approved `MxText` role.

## Color

Use `context.colorScheme` and theme extensions. Typical mappings:

| Mock intent | Required role |
| --- | --- |
| Page background | `context.colorScheme.surface` |
| Card surface | `context.colorScheme.surfaceContainerLowest` through `MxCard` |
| Raised/tonal surface | `context.colorScheme.surfaceContainer` or shared component theme |
| Primary action/accent | `context.colorScheme.primary` |
| Primary tint | `context.colorScheme.primaryContainer` or an approved opacity token |
| Main text | `context.colorScheme.onSurface` |
| Secondary text/icon | `context.colorScheme.onSurfaceVariant` |
| Border | shared ghost border via component theme or `BorderTokens` |
| Error | `context.colorScheme.error` and shared error components |

## Opacity, Elevation, And Borders

- Use `OpacityTokens` for intentional state layers, disabled content, fades, and focus tints.
- Use shared component themes for elevation; do not add one-off shadows in feature widgets.
- Cards use the design-system ghost border through `MxCard`; do not hand-roll card borders.
- Inputs use shared focus/outline behavior through `MxSearchField` or other shared inputs.

## Forbidden

- Raw hex colors in feature widgets.
- Raw `Colors.*` values for production UI, except transparent when explicitly sanctioned by a shared component.
- Random `SizedBox` values instead of spacing tokens.
- One-off `BorderRadius.circular(...)` where a radius token exists.
- Raw `TextStyle(...)` where `MxText` or theme typography applies.
- Raw durations or curves instead of motion tokens.
- Copying mock CSS gradients, shadows, demo data, or inline styles into Flutter.

## Related

- `docs/design/component-visual-contract.md`
- `docs/design/visual-parity-checklist.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/system-design/MemoX Design System/README.md`
- `lib/core/theme/tokens/spacing_tokens.dart`
- `lib/core/theme/tokens/radius_tokens.dart`
- `lib/core/theme/tokens/size_tokens.dart`
- `lib/core/theme/tokens/typography_tokens.dart`
