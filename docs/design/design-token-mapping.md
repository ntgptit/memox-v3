---
last_updated: 2026-06-25
status: contract
applies_to: UI mock-to-code implementation
---

# Design Token Mapping

Maps mock visual intent (kit specs/PNGs) to the **real** Flutter theme tokens and
shared components. Do not copy raw CSS values from the mock HTML into feature widgets.

> **2026-06-25 — corrected.** This doc previously referenced a token API that no
> longer exists (`SpacingTokens.*`, `RadiusTokens.*`, `SizeTokens.*`,
> `TypographyTokens`, `OpacityTokens`, `BorderTokens`, `MxTextRole`, and a
> `lib/core/theme/tokens/**` + `theme_context.dart` layout). That drift is the
> exact reason mock→code mapping went wrong (agents coded against phantom
> symbols, then improvised). The names below are the **actual** API in
> `lib/core/theme/*.dart` + `lib/presentation/shared/**`, and they are now
> machine-enforced — see "Enforcement" at the bottom.

## Source priority

| Concern | Source |
| --- | --- |
| Product behavior & route scope | `docs/business/**`, `docs/wireframes/**` |
| Visual token VALUES (source of truth) | `docs/system-design/MemoX Design System/colors_and_type.css` (kit) |
| Flutter token symbols | `lib/core/theme/*.dart` (flat: `mx_colors.dart`, `mx_spacing.dart`, …) |
| Kit-symbol → Flutter-symbol map (generated, authoritative) | `tool/parity/symbol-map.json` |
| Feature implementation | `lib/presentation/features/**` |
| Shared widgets | `lib/presentation/shared/**` |

## Color

Read MemoX colors via the `MxColors` theme extension — `context.mxColors.<member>`
(the dominant pattern in the codebase). Never hardcode a hex; never read a MemoX
tone off Material's `ColorScheme`.

| Kit token (`color:`/`bg:`/`border:`) | Flutter |
| --- | --- |
| `bg` | `context.mxColors.bg` |
| `surface` / `surface-2` | `context.mxColors.surface` / `.surfaceMuted` |
| `text` / `text-2` / `text-3` | `context.mxColors.text` / `.textSecondary` / `.textTertiary` |
| `accent` / `accent-soft` / `accent-contrast` | `context.mxColors.accent` / `.accentSoft` / `.accentContrast` |
| `border` / `border-strong` / `divider` | `context.mxColors.border` / `.borderStrong` / `.divider` |
| `success` / `warn` / `danger` / `info` (+ `*-soft`) | `context.mxColors.success` / `.warn` / `.danger` / `.info` (+ `*Soft`) |
| `note-*`, `status-*`, `mastery-*`, `rating-*`, `self-*` | matching `context.mxColors.note*/status*/mastery*/rating*/self*` member |
| `transparent` | `Colors.transparent` (sanctioned keyword) |

The full, generated suffix → `MxColors` member list lives in
`tool/parity/symbol-map.json` (`colorTokens`). A bare `#rrggbb` in a spec means no
token matched — treat as a gap, not a license to hardcode.

## Spacing — `MxSpacing` (px → symbol)

`4 → space1`, `8 → space2`, `12 → space3`, `16 → space4`, `20 → space5`,
`24 → space6`, `32 → space8`, `40 → space10`, `48 → space12`. Roles:
`screen` (20, screen horizontal padding), `card` (16, card inner padding),
`gapSection` (16, between stacked sections), `minTouchTarget` (48, a11y floor).

## Radius — `MxRadius` (px → symbol)

`6 → xs`, `10 → sm`, `14 → md`, `20 → lg`, `28 → xl`, `999 → pill`, `18 → fab`.
Roles: `card` (= lg), `button` (= pill). Prefer the ready-made `BorderRadius`
values `MxRadius.mdAll` / `.lgAll` / `.cardAll` / `.pillAll` / `.fabAll` /
`.topSheet` over constructing `BorderRadius.circular(...)`.

## Icon size — `MxIconSize`

`16 → MxIconSize.sm`, `20 → MxIconSize.md`, `24 → MxIconSize.lg`.

## Typography — `MxTypography` / Material `TextTheme`

`MxTypography` builds the Material `TextTheme`; read a role via
`Theme.of(context).textTheme.<role>` or the `MxText` widget — never a raw
`TextStyle`. Map the kit's `font:<size>/<weight>` to the role whose size/weight
match in `lib/core/theme/mx_typography.dart` (e.g. `34/800 → displayLarge`,
`24/700 → headlineLarge`, `18/600 → titleLarge`, `16/600 → titleMedium`,
`14/600 → titleSmall`/`labelLarge`, `16/400 → bodyLarge`, `14/400 → bodyMedium`,
`13/400 → bodySmall`). Weights: `MxTypography.regular/medium/semibold/bold/extrabold`;
line-heights: `MxTypography.leadingTight/leadingSnug/leadingNormal`. There is no
`MxTextRole` and no `MxSectionHeader` — a section overline is an `MxText` with a
label/title role, not a dedicated widget.

## Opacity / stroke / elevation

- State layers / disabled / tints → `MxOpacity.hover/selected/disabled`.
- Hairline vs emphasis borders → `MxStroke.hairline/emphasis`.
- Elevation → `MxShadows.light/dark` (via shared component themes); do not add
  one-off shadows in feature widgets.

## Components (kit `mx:` → real class)

Resolve every `mx:<Component>` suggestion against `tool/parity/symbol-map.json`.
Real shared components include: `MxScaffold`, `MxAppBar`, `MxContentShell`,
`MxCard`, `MxIconTile`, `MxPrimaryButton` / `MxSecondaryButton` / `MxActionButton`
/ `MxIconButton` / `MxFab`, `MxBottomNav` (+`MxBottomNavItem`), `MxSearchField` /
`MxSearchDock`, `MxText`. The kit emits these real class names directly (the
`mx:` hints come from `tool/ui_kit_shots/component-map.json`, whose values are
verified to exist by `symbol_lint`). Known gap: `mx:MxSectionHeader` is a design
directive with no real class yet — build it or treat it as an `MxText` overline.

## Forbidden

- Raw hex / `Colors.*` (except sanctioned `transparent`) in feature widgets.
- Random `SizedBox`/`EdgeInsets` numbers instead of `MxSpacing`.
- One-off `BorderRadius.circular(...)` where an `MxRadius` token exists.
- Raw `TextStyle(...)` where `MxText` or a theme `textTheme` role applies.
- Copying mock CSS gradients/shadows/demo data into Flutter.

## Enforcement (this contract is machine-checked)

- `node tool/parity/gen_tokens.mjs --check` — token VALUES in `lib/core/theme/*.dart`
  must equal the kit CSS (colors, spacing, radius, type).
- `node tool/parity/symbol_lint.mjs --check` — every kit `mx:<Component>` resolves
  to a real class in `lib/` and every kit color token is a real `--memox-*` token;
  regenerates the authoritative `tool/parity/symbol-map.json`. Documented
  exceptions live in `tool/parity/symbol-aliases.json`.
- Both run inside `node tool/verify/run.mjs` (docs + code chains).

## Related

- `docs/design/component-visual-contract.md`
- `docs/design/visual-parity-checklist.md`
- `docs/ui-ux/ui-ux-contract.md`
- `docs/system-design/MemoX Design System/README.md`
- `tool/parity/symbol-map.json` (generated), `tool/parity/symbol-aliases.json` (curated)
