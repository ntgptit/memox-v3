# MemoX — project rules

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
