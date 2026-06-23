# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

MemoX Design System — a **zero-build, token-driven UI kit** for a calm mobile flashcard app. No `package.json`, no `node_modules`, no bundler. The Mobile UI Kit (`ui_kits/mobile/index.html`) loads React 18 (UMD) + Babel standalone + Lucide from CDN and compiles `screens/*.jsx` in the browser at runtime.

## Running locally

```bash
# From this folder (docs/system-design/MemoX Design System):
python -m http.server 8753          # or: npx http-server -p 8753 .
# Open: http://127.0.0.1:8753/ui_kits/mobile/index.html

# Windows one-click:
run.cmd
```

Requires HTTP server (not `file://`) + internet (CDN scripts). Serve from **this folder** — `index.html` links `../../colors_and_type.css` relatively.

## Verification

```bash
node tools/check-ui-kit.js    # 0 errors required before kit work is done
```

Checks all `screens/*.jsx` for: hardcoded colors, undefined tokens, missing bundle guard, raw px, re-declared shared primitives, unused `window.MX`. Exit 0 = clean.

## Architecture (three layers, strict cascade)

Changes flow top-down. **Always fix/extend the shared layer first**, never patch a single screen locally when the change belongs to the system.

1. **Tokens** (`colors_and_type.css`) — all `--memox-*` variables: colors (light + `.memox-dark` remap), spacing (`--memox-space-1..12`, 4px base), type (Plus Jakarta Sans / Lora / JetBrains Mono), radii, shadows, semantic role aliases, component sizes, opacities. Dark mode is a full remap under `.memox-dark` — descendants change nothing.

2. **Component contract** (`memox-components.css`, 860 lines) — class-based, 100% token-driven Material-3-flavored primitives: `.appbar`, `.bottom-nav`, `.search-dock`, `.card`, `.card-row`, `.pill-btn`, `.icon-btn`, `.icon-tile`, `.chip`, `.fab`, `.list-row`, `.sheet`, `.dialog`, `.choice` (study answers), `.match-grid`, `.rate-btn`, `.field`, `.segmented`, `.banner`, `.skeleton`, `.spinner`, `.hr`, `.avatar`, `.switch`, `.waveform`. State fills use `color-mix()` with tokenized opacities.

3. **Shared JSX primitives** (`screens/_shared.jsx` → `window.MX`) — 46 components that every screen destructures from. Key exports: `Icon`, `S(n)` (spacing helper → `var(--memox-space-${n})`), `PillBtn`, `IconBtn`, `Breadcrumb`, `SearchField`, `SearchDock`, `BottomNav`, `IconTile`, `TileLg`, `Chip`, `Overline`, `Progress`, `SectionHead`, `ListRow`, `StatSummary`, `ListGroup`, `HeroCard`, `InfoRow`, `PickerRow`, `ShortcutRow`, `DueSummary`, `Insight`, `GoalRing`, `EmptyState`, `Banner`, `FormField`, `TextArea`, `Modal`, `Sheet`, `BusyOverlay`, `StudyTopBar`, `StudyShell`, `StudyOption`, `RateBtn`, `AnswerReveal`, `Avatar`, `Toggle`, `Slider`, `RadioRow`, `Segmented`, `BarChart`, `MasteryBar`, `Fab`, `Sk`. If a new repeated pattern appears, add it to `_shared.jsx` once — don't leave a local copy.

## Screen file structure

Each screen is a self-contained IIFE in `ui_kits/mobile/screens/NN-name.jsx`:

```jsx
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;  // bundle guard — required
  const { Icon, S, PillBtn, /* ... */ } = window.MX;

  window.MEMOX_KIT.register({
    num: "02", title: "Dashboard",
    states: [
      { label: "Loaded", render: () => <div className="app">...</div> },
      { label: "Loading", render: () => <div className="app">...</div> },
    ],
  });
})();
```

- 26 screens (00–25) + `_shared.jsx` = 27 files, ~140 unique states total.
- `render()` returns only content **inside** `.phone`. Never hand-build `.row`/`.stepper`/`.phone` — the engine does that.
- The gallery engine renders **two** frames per screen (light + `.memox-dark`) and runs `lucide.createIcons()` after each render.

## Visual mocks and specs

- **`shots/`** — 280 PNGs, canonical visual truth. Naming: `NN-screen--state--light|dark.png`. Lookup via `shots/INDEX.md`.
- **`specs/`** — auto-generated DOM specs (element tree, bounding boxes, resolved token values, a11y labels). One `.md` per screen + `INDEX.md`.
- The gallery (`index.html`) is for quick browse / copy text / control order. For visual parity, use the PNGs.

## Hard design rules

MemoX is a **calm learning app**. Visual restraint is a hard requirement, not a preference.

## Elevation & shadows (always follow)
- **No colored or glowing shadows. Ever.** No accent/orange/violet glows under buttons, cards, FABs, or anything. Shadows are neutral only.
- Use only the three neutral tokens: `--memox-shadow-sm` (cards), `--memox-shadow-md` (floating controls — FAB, popover), `--memox-shadow-lg` (sheets/dialogs). Don't invent new shadows or hardcode `box-shadow`.
- **Primary buttons are flat** — accent fill, no shadow.
- Prefer a **border** (`--memox-border-ghost` / `--memox-outline-variant`) over a shadow when either would do.
- Dark mode leans on borders with minimal shadow (cards use `--memox-shadow-soft: none`).
- `--memox-shadow-accent` is **deprecated** (now a neutral alias of `-md`); never reintroduce a colored glow.

## General
- **Always adjust from the common layer first (mandatory).** Any design change must start at the shared layer — common **theme/tokens** (`colors_and_type.css`), then common **components** (`memox-components.css` contract classes + `screens/_shared.jsx` `window.MX` primitives) — BEFORE touching any individual screen. Fix/extend the shared source so every screen inherits it; never patch one screen locally when the change belongs to the system. If a new repeated pattern appears in a screen, promote it into `_shared.jsx` (and add a token/contract class if needed) rather than leaving a local copy.
- All styling is **token-driven** — only `var(--memox-*)`. No hardcoded colors or px for radii/spacing/sizes (see `colors_and_type.css` + `memox-components.css`).
- Keep the palette quiet: one indigo accent, meaningful note/status tints only, lots of calm cool-white space. No gradients behind content. No emoji as UI.
- Icons: Lucide via `<i data-lucide="name"></i>`; dark theme handled by `.memox-dark` token remap — never hand-set per-theme colors.
- UI kit screens register via `window.MEMOX_KIT.register({num,title,states})`; `render()` returns only the content **inside** `.phone`. Never hand-build `.row`/`.stepper`/`.phone` — the engine does that.
- **UI-kit screens must adhere strictly to the shared system** — this is the whole point of the kit:
  - Colors/sizes/spacing/radii: **only `var(--memox-*)` tokens** (use the `S(n)` helper for spacing). No hex/rgb, no raw `px` for type/spacing/radii. Hairline dividers use `.hr`.
  - Build from **shared primitives** in `screens/_shared.jsx` (`window.MX`: `Icon, S, PillBtn, IconBtn, IconTile, TileLg, Chip, Overline, Progress, SectionHead, ListRow, StatSummary, ListGroup, HeroCard, InfoRow`) and the **contract classes** in `memox-components.css` (`.card`, `.pill-btn`, `.chip`, `.list-row`, `.card-row`, …). Don't re-implement a primitive inline — if a new repeated pattern appears, add it to `_shared.jsx` once.
  - Each screen IIFE must start with `if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;` (so it no-ops in the compiled bundle — no `__errors`).
  - Verify with **`node tools/check-ui-kit.js`** (0 errors required) before considering kit work done.
- **Side-by-side cards must use the `.card-row` wrapper** (flex + `align-items:stretch`, children `flex:1`) so their heights always match — never hand-roll per-card `flex` for a row, and never nest a card in an extra wrapper div (it breaks the equal-height stretch).
