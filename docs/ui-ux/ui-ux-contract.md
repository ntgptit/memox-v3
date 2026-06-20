---
last_updated: 2026-06-08
applies_to: all UI/UX, shared widgets, theme, l10n
---

# UI UX Contract

## Source files to inspect

- `docs/system-design/MemoX Design System/README.md`
- `lib/core/theme/**`
- `lib/presentation/shared/**`
- `lib/l10n/*.arb`
- Related feature screens/widgets

## UX principles

- Mobile-first.
- Calm and focused.
- Fast daily usage.
- Clear primary action per screen.
- No crowded screen.
- No raw technical errors shown to user.
- No destructive action without confirmation.

## Required screen states

Every screen should handle relevant states:

- Loading.
- Empty.
- Error.
- Saving.
- Disabled action.
- Validation failure.
- Retry/recovery.

Missing any applicable state is a bug.

## Shared widget rule

Use shared `Mx*` widgets first.

Shared design-system widgets stay controlled and mostly
`StatelessWidget`. Hook adoption belongs in presentation wiring only, not in
shared `Mx*` controls, unless there is a strong documented exception.

Preferred primitives:

- `MxAdaptiveScaffold`
- `MxScaffold`
- `MxListScaffold`
- `MxFormScaffold`
- `MxStudyScaffold`
- `MxContentShell`
- `MxRetainedAsyncState`
- `MxEmptyState`
- `MxErrorState`
- `MxLoadingState`
- `MxCard`
- `MxSliderField`
- `MxActionButton` (semantic, intent-driven — prefer over raw buttons)
- `MxCardActions` (card-level action layout)
- `MxPrimaryButton` (low-level primitive)
- `MxSecondaryButton` (low-level primitive)

The full kit (built from the "0 · Foundations · Shared widgets" handoff in
`docs/system-design/MemoX Design System/ui_kits/mobile/index.html`) lives under
`lib/presentation/shared/**` and is re-exported from the barrel
`lib/presentation/shared/mx_widgets.dart`. Beyond the primitives above it also
provides, by handoff section:

- Chrome/nav: `MxIconButton`, `MxBreadcrumb`, `MxStudyTopBar`.
- Surfaces: `MxIconTile`, `MxSectionHeader`, `MxSettingsTile`, `MxAvatar`,
  `MxListTile`.
- Status & data viz: `MxStatusBadge` (+ `MxCardStatus`, `masteryColor`),
  `MxMasteryRing`, `MxLinearProgress`, `MxStatDisplay`, `MxStreakChip`,
  `MxBarChart`.
- Study modes: `MxFlashcard`, `MxRatingBar`, `MxSelfAssessment`,
  `MxChoiceOption`, `MxMatchTile`.
- Feedback/overlays: `MxOfflineBanner`, `MxCallout`, `MxSkeleton`,
  `showMxSnackbar` (the sanctioned snackbar helper — feature code must not use
  raw `SnackBar`/`ScaffoldMessenger`).
- Chrome/nav (feature-safe wrappers): `MxAppBar`, `MxFab`.
- Inputs: `MxSearchField`, and `MxText` (the only shared widget with a public
  `MxTextRole` API — feature code must not read `context.textTheme` directly).
- Dialogs: `showMxNameDialog` (single-field create/rename).
- Interaction: `MxTappable` (the single shaped tap primitive — feature/shared
  code must not hand-roll `InkWell`/`GestureDetector`).
- Async rendering: `AppAsyncBuilder` and `MxRetainedAsyncState` (in
  `shared/async`) — the sanctioned alternatives to `AsyncValue.when`, retaining
  data on refetch with a skeleton-first first load.

Shared-widget architecture checks may use the lightweight capability contracts
in `lib/presentation/shared/contracts/mx_component_contracts.dart` to verify shared
component intent without depending on widget build methods.

Navigation uses the `AppNavigation` `BuildContext` extension
(`lib/app/router/app_navigation.dart`) — UI code must not call raw `GoRouter`
APIs.

Material widgets already styled by `MxComponentThemes` (FilledButton, Card,
Chip, Switch, Slider, SegmentedButton, BottomSheet, NavigationBar, Divider,
LinearProgressIndicator) are used directly inside shared widgets — they are
intentionally not re-wrapped. Feature code, however, must use the `Mx*`
wrappers above (the guard bans raw Material in `features/**`).

## Button and action density rule

Action density is governed by `docs/ui-ux/action-hierarchy-contract.md`. Read it
before adding any button, CTA, or card action.

Mandatory minimums:

- Prefer the semantic `MxActionButton` (intent-driven) and `MxCardActions` over
  raw `MxPrimaryButton` / `MxSecondaryButton` `size` + `fullWidth`.
- Card-level actions must not use `MxButtonSize.large` and must not be
  full-width by default.
- Full-width is allowed only for: bottom action area, form submit/footer,
  full-screen empty state, onboarding/hero, and specified study submit/final
  actions.
- At most one visually dominant primary action per screen.
- Secondary actions are visually lighter than the primary.
- Compact visual height is fine only while the touch target stays ≥ 48dp.
- "Quizlet-mobile energy" does not mean an oversized full-width CTA everywhere —
  dashboard/library/settings cards use dense card actions.
- Frozen mobile density: card/study actions use `40dp` compact visual height;
  medium `48dp` stays for form/dialog/bottom action contexts; regular cards use
  the design-system card surface — `16dp` radius (`lg`) and `16dp` padding
  (`--memox-space-card`); compact icon buttons are `36dp` with a `20dp` icon.
- This density freeze does not alter business scope: Library root contains
  folders only, root-level decks remain Rejected / Out of Scope, and nullable
  deck parent migration remains Rejected / Not Applicable.

## Theme rule

Use:

- Theme color scheme.
- Theme extensions.
- Text theme.
- App spacing/radius/motion tokens. The Dart token classes under `lib/core/theme/`
  mirror the `--memox-*` scales in
  `docs/system-design/MemoX Design System/colors_and_type.css`: `MxSpacing`
  (`--memox-space-*`), `MxRadius` (`--memox-radius-*`), `MxColors` (color roles),
  `MxOpacity` (`--memox-op-hover`/`-selected`/`-disabled` — derived tints, e.g. a
  soft icon-tile background), `MxIconSize` (`--memox-icon-sm`/`-md`/`-lg` — every
  `Icon(size:)` must use these), and `MxStroke` (`hairline`/`emphasis` — divider /
  border widths). Add to the matching token class (never hardcode) when a new
  weight/size is needed.
- ARB localization for every user-facing string.

Device chrome (status bar / safe area):

- The OS status bar (clock, signal, battery) is **not** app content — the mock's
  `9:41` + battery row is the device's. Never reproduce it; design the app's top
  to sit *below* it.
- Status-bar icon brightness is **theme-driven**: `AppBarTheme.systemOverlayStyle`
  in `MxTheme` sets dark icons on the light theme / light icons on dark, with a
  transparent status bar + edge-to-edge (`SystemUiMode.edgeToEdge` in
  `AppBootstrap`) so the app background fills behind it (no seam). Do not set
  `SystemUiOverlayStyle` per screen.
- Use a real app bar (`MxAppBar`) or `MxScaffold`'s `SafeArea` for the top inset —
  never a hand-rolled fixed-height top bar with manual `SafeArea` padding (it
  overflows once the device adds status-bar padding). The kit's `--memox-safe-top`
  (`env(safe-area-inset-top)`) corresponds to this top inset — in Flutter it is the
  `SafeArea`/`MediaQuery.padding.top`, not a Dart constant (mirrors how
  `--memox-safe-bottom` is the home-indicator inset).

Redesign tokens & components (design redesign):

- New kit size token `--memox-size-search-dock` (64) sizes the bottom-anchored
  search dock; it lands as a documented min-height on the `MxSearchDock` widget
  (no nav/appbar size token class exists — those follow Material defaults).
- New kit shared components are built as MemoX shared widgets (token-driven, golden
  tested light + dark): `SearchField`/`SearchDock` → `MxSearchField` + `MxSearchDock`
  (wired into global Search `/search`); `Breadcrumb` → `MxBreadcrumb` (wired into
  nested screens); `ShortcutRow`/`DueSummary` → `MxShortcutRow`/`MxDueSummary`;
  `Insight`/`GoalRing` → `MxInsight`/`MxGoalRing`; the kit `IconTile` → `MxIconTile`.
  The `MxShortcutRow`/`MxDueSummary`/`MxInsight`/`MxGoalRing` widgets exist and are
  golden-tested, but their consuming **Dashboard (`/home`) and Progress (`/progress`)
  screens are deferred** — they need read-model BE and (for goal/streak) the
  engagement persistence subsystem, which is Future/Target pending approval. Shared
  widgets that show counts/labels accept caller-localized strings (own no copy).

Avoid:

- Raw colors (`Color(0xFF...)`, `Colors.red`).
- Raw text styles (`TextStyle(fontSize: 14)`).
- Raw durations (`Duration(milliseconds: 300)`).
- Hardcoded layout constants (`SizedBox(width: 16)` outside spacing tokens).
- Hardcoded user-facing strings.
- Raw route strings.

## Responsive rule

- Must work on narrow mobile (360dp width).
- Must not stretch reading content too wide on desktop (use max content width from shell).
- Use shared layout shell/content width.
- Overflow is a bug.
- Breakpoints: 600dp and 1024dp (mobile / tablet / desktop).

## Performance rule

| Scenario                    | Rule                                                    |
|-----------------------------|---------------------------------------------------------|
| List > 50 items             | `ListView.builder`, never `Column` + `map`              |
| List > 200 items            | Consider pagination or sliver virtualization            |
| Search input                | Debounce 300ms                                          |
| Tag/autocomplete input      | Debounce 200ms                                          |
| Image (network/asset cache) | Use cached image widget; do not rebuild every frame     |
| Heavy compute               | `compute()` or isolate; never on UI thread              |
| Animation                   | Use AnimatedX widgets; avoid manual setState in tickers |
| Stream listeners            | Always cancel in dispose; prefer Riverpod auto-dispose  |

## Accessibility rule

- Min touch target: 48dp.
- Semantic label for every interactive widget.
- Contrast ratio meets WCAG AA.
- Form errors announced via Semantics.
- Long press alternatives for swipe actions.

## Confirmation rule

Destructive actions require confirmation dialog:

- Delete folder.
- Delete deck.
- Delete flashcard.
- Cancel study session.
- Discard unsaved form changes.

Confirmation dialog must use `MxConfirmDialog` or equivalent shared widget.
Current V1 implementation uses `MxConfirmationDialog`; destructive confirmations are not
barrier-dismissible and must provide an explicit Cancel path.

## Loading state rule

- For lists: skeleton placeholder, not full-screen spinner.
- For full-screen load: `MxLoadingState` only when no content exists yet.
- For action in progress: in-button spinner or disabled state, not blocking overlay.
- For background sync: subtle indicator, not modal.

## Empty state rule

- `MxEmptyState` with illustration + message + CTA.
- CTA leads to the primary action that resolves empty state.
- Place CTA in thumb-reach zone on mobile.

## Error state rule

- `MxErrorState` with message + retry action.
- Map `Failure` to user-friendly message via l10n.
- Never show stack trace or technical error to user.
- Log technical detail for diagnostics.

## Agent rule

Do not build anonymous `Container + Row + hardcoded style` UI when a shared component exists or
should be promoted.

When introducing a new shared widget, name it `Mx<Name>` and place in
`lib/presentation/shared/widgets/**`.

## Related

**Wireframes:**

- `docs/wireframes/index.md` — all 25 wireframes follow the tokens defined here (Slate Meridian
  theme, Plus Jakarta Sans, breakpoints 600dp / 1024dp)
- `docs/wireframes/24-shared-dialogs.md` — reusable dialogs
- `docs/wireframes/25-shared-bottom-sheets.md` — reusable bottom-sheets

**Architecture:**

- `docs/architecture/clean-architecture-contract.md` — presentation layer scope

**Repo-level:**

- `CLAUDE.md` — hardcoded styles/colors/durations forbidden

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "UI/UX" (touch target,
  accessibility, l10n)

**Source files to inspect:**

- `lib/core/theme/**`
- `lib/presentation/shared/**` (Mx* shared widgets)
- `lib/l10n/**` (ARB sources)
