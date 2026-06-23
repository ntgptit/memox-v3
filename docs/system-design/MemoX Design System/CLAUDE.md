# CLAUDE.md — MemoX Design System

Guidance for Claude Code (and humans) working in this folder. MemoX is a **calm
learning app**; visual restraint here is a hard requirement, not a preference.

## What this is

A **zero-build, token-driven UI kit** for a mobile flashcard app — no
`package.json`, no `node_modules`, no bundler. `ui_kits/mobile/index.html` loads
React 18 (UMD) + Babel standalone + Lucide from CDN and compiles `screens/*.jsx`
in the browser at runtime. 26 screens (00–25) + `screens/_shared.jsx` = 27 files,
~140 states. The canonical project lives on Claude Design ("MemoX Design System
v3"); this repo copy is kept in sync (see `docs/design/design-sync-process.md`).

## Quick start

```bash
# From this folder (docs/system-design/MemoX Design System):
python -m http.server 8753          # or: npx http-server -p 8753 .
# open http://127.0.0.1:8753/ui_kits/mobile/index.html   (Windows one-click: run.cmd)

node tools/check-ui-kit.js          # MUST be 0 errors before kit work is "done"
```

Needs an HTTP server (not `file://`) + internet (CDN). Serve from **this folder** —
`index.html` links `../../colors_and_type.css` relatively. `check-ui-kit.js` flags:
hardcoded colors, undefined tokens, missing bundle guard, raw `px`, re-declared
shared primitives, unused `window.MX`.

## Architecture — three layers, strict top-down cascade

**Always fix/extend the shared layer first.** Never patch one screen when the change
belongs to the system; if a repeated pattern appears in a screen, promote it into the
shared layer (a token / contract class / `_shared.jsx` primitive) once.

1. **Tokens** — `colors_and_type.css`: every `--memox-*` variable. Colors (light +
   a full `.memox-dark` remap — descendants change nothing), spacing
   (`--memox-space-1..12`, 4px base), type (Plus Jakarta Sans / Lora / JetBrains
   Mono), radii, shadows, semantic role aliases, component sizes, opacities.
2. **Component contract** — `memox-components.css` (~860 lines): class-based,
   100% token-driven, Material-3-flavored primitives — `.appbar`, `.bottom-nav`,
   `.search-dock`, `.card`, `.card-row`, `.pill-btn`, `.icon-btn`, `.icon-tile`,
   `.chip`, `.fab`, `.list-row`, `.sheet`, `.dialog`, `.choice`, `.match-grid`,
   `.rate-btn`, `.field`, `.segmented`, `.banner`, `.skeleton`, `.spinner`, `.hr`,
   `.avatar`, `.switch`, `.waveform`. State fills use `color-mix()` with tokenized
   opacities.
3. **Shared JSX primitives** — `screens/_shared.jsx` → `window.MX` (46 components
   every screen destructures): `Icon`, `S(n)` (→ `var(--memox-space-${n})`),
   `PillBtn`, `IconBtn`, `Breadcrumb`, `SearchField`, `SearchDock`, `BottomNav`,
   `IconTile`, `TileLg`, `Chip`, `Overline`, `Progress`, `SectionHead`, `ListRow`,
   `StatSummary`, `ListGroup`, `HeroCard`, `InfoRow`, `PickerRow`, `ShortcutRow`,
   `DueSummary`, `Insight`, `GoalRing`, `EmptyState`, `Banner`, `FormField`,
   `TextArea`, `Modal`, `Sheet`, `BusyOverlay`, `StudyTopBar`, `StudyShell`,
   `StudyOption`, `RateBtn`, `AnswerReveal`, `Avatar`, `Toggle`, `Slider`,
   `RadioRow`, `Segmented`, `BarChart`, `MasteryBar`, `Fab`, `Sk`.

## Screen files

Each screen is a self-contained IIFE in `screens/NN-name.jsx`:

```jsx
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;  // bundle guard — required
  const { Icon, S, PillBtn, /* … */ } = window.MX;

  window.MEMOX_KIT.register({
    num: "02", title: "Dashboard",
    states: [
      { label: "Loaded",  render: () => <div className="app">…</div> },
      { label: "Loading", render: () => <div className="app">…</div> },
    ],
  });
})();
```

- The **bundle guard** first line is required (the screen no-ops in the compiled
  bundle — no `__errors`).
- `render()` returns only content **inside** `.phone`. Never hand-build
  `.row` / `.stepper` / `.phone` — the gallery engine does that, renders **two**
  frames per state (light + `.memox-dark`), and runs `lucide.createIcons()` after.

## Visual mocks & specs

- **`shots/`** — 280 PNGs, the canonical visual truth (`NN-screen--state--light|dark.png`;
  index `shots/INDEX.md`). Use these for visual parity.
- **`specs/`** — auto-generated DOM specs (element tree, bboxes, resolved token
  values, a11y labels, and `data-mx-node` ids — see below). One `.md` per screen +
  `INDEX.md`. Regenerate after kit changes: `npm --prefix tool/ui_kit_shots run export:all`.
- The gallery (`index.html`) is for quick browse / copy text / control order only.

## Parity identity — `data-mx-node`

Tag the kit nodes that represent a **required UI element** with a stable identity, so
the Flutter app can be checked against the design by IDENTITY (not pixels, not
geometry). Source end of the parity-contract pipeline; full runbook
`docs/design/design-sync-process.md`.

- **Attribute:** `data-mx-node="<screen-id>/<node>"` — e.g.
  `data-mx-node="03-library/folder-row"`. In JSX it's a normal prop:
  `<div className="list-row" data-mx-node="03-library/folder-row">`.
- **Pipeline:** kit `data-mx-node` → `tool/ui_kit_shots/export_specs.mjs` emits the
  spec's `id:` field → `tool/parity/gen_contract.mjs` builds the per-screen contract
  → the Flutter widget carries `key: ValueKey('mx-node:<id>')` and a parity test
  asserts `find.byKey(...)`. A node tagged here but not built in Flutter ⇒ the test
  goes red (catches "FE chưa implement đủ").
- **Common layer first:** when the element is a `window.MX` primitive, give it an
  optional `node` prop that renders `data-mx-node={node}` and pass the id at the call
  site — don't hand-attach on a re-implemented copy. Use a raw `data-mx-node` only
  for genuinely screen-specific nodes.
- **Naming is a contract — keep it stable:** `<screen-id>` matches the spec file
  (`03-library`); `<node>` is a short kebab semantic name (`folder-row`, `fab`,
  `due-badge`). A rename breaks the Flutter key mapping → treat it like a schema
  change (update the FE key + test together). Tag only **meaningful required** nodes,
  not every `div`.
- **Lives in the kit → survives sync:** author it on Claude Design or edit locally
  and push to the v3 project; a pull carries it back, not overwritten. Adding the
  attribute is style-neutral (`check-ui-kit` stays clean); re-run `export:specs` so
  the `id:` lands in the spec.

## Design rules (calm, restrained)

### Tokens only

- Colors / sizes / spacing / radii: **only `var(--memox-*)`** (use `S(n)` for
  spacing). No hex/rgb, no raw `px` for type/spacing/radii. Hairline dividers use `.hr`.
- Build from the **shared primitives + contract classes** — never re-implement a
  primitive inline.

### Palette & restraint

- One indigo accent; meaningful note/status tints only; lots of calm cool-white
  space. **No gradients** behind content. **No emoji** as UI.
- Icons: Lucide via `<i data-lucide="name"></i>`; dark mode is handled by the
  `.memox-dark` token remap — never hand-set per-theme colors.

### Elevation & shadows

- **No colored or glowing shadows. Ever** — no accent/orange/violet glow under
  buttons, cards, FABs, anything. Shadows are neutral only.
- Use only the three neutral tokens: `--memox-shadow-sm` (cards), `--memox-shadow-md`
  (floating controls — FAB, popover), `--memox-shadow-lg` (sheets/dialogs). Don't
  invent new shadows or hardcode `box-shadow`.
- **Primary buttons are flat** — accent fill, no shadow. Prefer a **border**
  (`--memox-border-ghost` / `--memox-outline-variant`) over a shadow when either
  would do. Dark mode leans on borders with minimal shadow (cards:
  `--memox-shadow-soft: none`).
- `--memox-shadow-accent` is **deprecated** (now a neutral alias of `-md`); never
  reintroduce a colored glow.

### Layout

- **Side-by-side cards must use the `.card-row` wrapper** (flex +
  `align-items:stretch`, children `flex:1`) so heights always match — never hand-roll
  per-card `flex` for a row, and never nest a card in an extra wrapper div (it breaks
  the equal-height stretch).

## Before you finish — checklist

1. Change started at the **shared layer** (token → contract class → primitive), not a
   local screen patch.
2. **Tokens only** — no hardcoded color/px; dividers via `.hr`; spacing via `S(n)`.
3. Required nodes carry **`data-mx-node`** (common layer first); `export:specs`
   re-run so `id:` is in the spec.
4. `node tools/check-ui-kit.js` → **0 errors**.
5. Both **light and `.memox-dark`** read well.
