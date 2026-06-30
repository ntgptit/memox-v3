# Flutter widget gaps — kit primitives without a shared `Mx*` widget

> Status: **handoff spec** (authored 2026-06-30). Implementation requires the
> Flutter toolchain (`flutter analyze` / `flutter test` / goldens) which was NOT
> available in the authoring environment — so this file is an implementation-ready
> brief, not the code. Execute + verify each widget on a Flutter-capable machine
> via `node tool/verify/run.mjs --test <paths>` (CLAUDE.md hard rule: no UI widget
> is "done" without analyze + per-state goldens).

## Why this exists

The MemoX UI kit (`docs/system-design/MemoX Design System/ui_kits/mobile`) is the
design source of truth. Its `window.MX` primitives are meant to map **1:1** to a
shared Flutter `Mx*` widget so screen conversion is mechanical and parity is
checkable by identity. Five kit primitives still have **no shared Flutter widget**,
so the Flutter app re-implements them ad hoc at the feature level — exactly the
drift the design system is meant to prevent.

Authoritative kit↔Flutter map: `tool/parity/symbol-map.json`. These five are the
remaining `MISSING` rows.

| Kit primitive (`_shared.jsx`) | CSS contract | Proposed Flutter widget | Currently hand-rolled at feature level |
| --- | --- | --- | --- |
| `Chip` | `.chip` (memox-components.css:321) | `MxChip` | `lib/presentation/features/flashcards/widgets/deck_import_file_chip.dart`, `flashcard_tile.dart`, `card_history_header_card.dart` |
| `Banner` | `.banner` (…:681) | `MxBanner` | `learning_goal_card.dart`, `deck_import_body.dart`, study/result inline notices |
| `Segmented` | `.segmented` (…:820) | `MxSegmented` | progress range toggle (inline) |
| `StatSummary` | inline (token-driven) | `MxStatSummary` | dashboard / progress KPI / study-result inline strips |
| `ListGroup` / `ListCard` | `.list-card` + `.hr inset` | `MxListGroup` | folder / settings / search list-cards (inline `MxCard`+`MxListTile`+`MxDivider`) |

When you implement each one: add the class under `lib/presentation/shared/widgets`,
migrate the feature hand-rolls to it, then re-run `node tool/parity/symbol_lint.mjs
--write` so `symbol-map.json` flips the row from `MISSING` to `ok` (and drop any
matching alias from `tool/parity/symbol-aliases.json`). Update
`tool/parity/parity-map.json` if a new golden screen/state is added.

---

## 1. `MxChip` ← kit `Chip` (`.chip`)

**Kit source:** `_shared.jsx` `Chip({ status, solid, icon, children, node })`.
**CSS:** `.chip` — `inline-flex`, `gap space-1`, `height size-chip-sm`,
`padding 0 space-3`, `radius-full`, `fs-label-small`, `weight-bold`,
`letter-spacing 0.01em`. Tonal fill = `color-mix(--chip, op-selected)`, text =
`--chip`. `.solid` → background `--chip`, text `surface-raised`.

**Status → tint token** (the `--chip` value):

| status | token |
| --- | --- |
| (none) | `text-secondary` |
| `new` / `learning` / `reviewing` / `mastered` | `status-*` |
| `due` | `primary` |
| `correct` / `wrong` | `rating-*` |
| `missed` / `partial` / `got` | `self-*` |

**Flutter API:**
```dart
MxChip({
  String? label,          // child text
  MxChipStatus status = MxChipStatus.neutral,
  bool solid = false,
  IconData? icon,         // optional leading glyph
  Key? key,               // pass ValueKey('mx-node:<id>') where the kit tags it
})
```
Resolve `status` → tint via an `MxColors` extension getter (mirror the table); do
NOT hardcode hex. Use `MxSpacing`/`MxRadius`/`MxTypography` for the rest.

**Golden states (light + dark, per CLAUDE.md gate map):** neutral tonal, one
`status` tonal, `solid`, with-icon, long-label (ellipsis/no-overflow at narrow
width + scaled text).

**Migrate:** `deck_import_file_chip.dart` (→ `MxChip`), flashcard status chips in
`flashcard_tile.dart`, the `Box n` chip in `card_history_header_card.dart`.

---

## 2. `MxBanner` ← kit `Banner` (`.banner`)

**Kit source:** `_shared.jsx` `Banner({ tone, icon, tint, action, children, node })`.
**CSS:** `.banner` — `flex`, `align-center`, `gap space-3`, `padding space-3
space-4`, `radius-md`, tonal fill `color-mix(--bn, op-selected)`, text `--bn`,
`fs-label-large`, `weight-semibold`. Icon `icon-md`. Optional trailing **solid**
`pill-btn sm` tone-matched (`--btn: var(--bn)`).

**tone → `--bn`:** `warn` → `status-learning`, `danger` → `danger`, `info` →
`info`. `tint` overrides `--bn` with any token.

**Flutter API:**
```dart
MxBanner({
  required Widget child,             // or String message
  MxBannerTone tone = MxBannerTone.info,
  Color? tint,                       // overrides tone
  IconData? icon,
  ({String label, VoidCallback onTap})? action,  // trailing solid button
  Key? key,
})
```

**Golden states:** info, warn, danger, with-action (button), no-icon, long body
(wraps, button stays), light + dark.

**Migrate:** settings sync-error / learning perm-denied / account failed +
token-expired / flashcard-edit validation / tag rename-merge notices.

---

## 3. `MxSegmented` ← kit `Segmented` (`.segmented`)

**Kit source:** `_shared.jsx` `Segmented({ options, value })` — `role=tablist`.
**CSS:** `.segmented` pill track (`surface-2`, `border-ghost`, `radius-full`,
`padding space-1`, `gap space-1`). `.segmented-item` `height size-chip-sm`,
`padding 0 space-4`, `fs-label-medium`, `weight-bold`, `text-secondary`. `.active`
→ `surface-raised` bg, `text-primary`, `shadow-sm`.

**Flutter API:**
```dart
MxSegmented({
  required List<String> options,
  required int selectedIndex,            // or String value
  required ValueChanged<int> onChanged,
  Key? key,
})
```
Use `Semantics`/`ToggleButtons`-style a11y (tablist + selected). Animate the
active pill with the kit's `.12s` ease.

**Golden states:** 2-option (Week|Month) each option active, light + dark.

**Migrate:** the Progress range toggle (kit screen 19).

---

## 4. `MxStatSummary` ← kit `StatSummary`

**Kit source:** `_shared.jsx` `StatSummary({ stats, node })` — a `.card` with
evenly-spaced centered metrics. Each stat = `[value, label, accent?]`. The
`accent` column sits in a soft `primary` tinted box
(`color-mix(primary, op-selected)`); value uses `size-title`, `weight-extrabold`,
`tracking-tight`, `tabular-nums`; accent value/label use `primary`, else
`text-primary` / `text-secondary`.

**Flutter API:**
```dart
MxStatSummary({
  required List<MxStat> stats,   // MxStat(value, label, {accent = false})
  Key? key,
})
```

**Golden states:** 3 stats no-accent, 3 stats with one accent column, light + dark.
a11y: each metric a labelled `Semantics` node (value + label), not color-only.

**Migrate:** dashboard / progress KPI strip / study-result stat strip.

---

## 5. `MxListGroup` ← kit `ListGroup` / `ListCard`

**Kit source (phase-2):** `_shared.jsx` `ListCard({ rows | items+row, inset, node,
style })` = the `.list-card` rounded surface with a `.hr inset` (or plain `.hr`)
between keyed row cells; `ListGroup({ heading, items, kind, node })` = optional
overline heading + count above a `ListCard` of `ListRow`s.

**Flutter API:**
```dart
MxListGroup({
  String? heading,                 // overline; trailing count = children.length
  required List<Widget> children,  // already-built rows (MxListTile, etc.)
  bool inset = true,               // MxDivider inset vs full-bleed
  Key? key,
})
// thin shorthand over: MxCard( column of children with MxDivider between )
```
Compose from the existing `MxCard` + `MxListTile` + `MxDivider` (all present under
`lib/presentation/shared/widgets/surfaces`). The divider inset must match the
kit `.hr inset` geometry — push this into `MxDivider` (lowest layer) so every
consumer is consistent (bug-CLASS: spacing/alignment → invariant in shared widget
+ golden).

**Golden states:** 2-row group with heading+count, without heading, `inset=false`,
single row, light + dark.

**Migrate:** folder / settings / search list-cards currently composing
`MxCard`+`MxListTile`+`MxDivider` inline.

---

## Bug-CLASS gate map (applies to all five)

Per `CLAUDE.md` "Catch the bug CLASS, not the instance":

| Bug class | Prevent (lowest layer) | Detect (gate) |
| --- | --- | --- |
| spacing/colour (static visual) | token invariant inside the `Mx*` widget | golden per state, light+dark, 390×780 |
| overflow / scaled text | `Flexible`/ellipsis in the widget | widget test at narrow width + textScaleFactor |
| wrong tint for status/tone | a single resolver (`MxColors` ext) | unit test on the resolver table |
| a11y (label, target size) | `Semantics` in the widget | semantics test |
| design-system bypass | — | `memox.*` guard rule (e.g. `no_raw_chip`) |

## Definition of done (each widget)

1. `Mx*` widget under `lib/presentation/shared/widgets` built from tokens +
   existing primitives (no raw hex / `px`).
2. Feature-level hand-rolls migrated to it (see each section's "Migrate").
3. Goldens (light+dark) per state + the widget/unit/semantics tests above.
4. `node tool/parity/symbol_lint.mjs --write` → row flips to `ok`; alias removed.
5. `node tool/verify/run.mjs --test <paths>` PASS (writes the pass-marker).
6. Doc parity: this file's row + `symbol-map.json` updated in the same commit.
