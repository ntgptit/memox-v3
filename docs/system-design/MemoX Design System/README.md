# MemoX — Design System

MemoX is a **mobile note-taking app** with a warm, paper-like character: capture
a thought fast, organize it into color-coded *Spaces*, and write longer notes on
a calm serif surface. This project is the design system + Mobile UI Kit that all
MemoX screens are built from.

> **Sources / provenance.** This system was bootstrapped from a written brief (the
> "MemoX — Mobile UI Kit" spec) — no Figma file or codebase was attached. The brief
> defined the gallery engine contract and file layout; the token *values*, screens,
> and components here are an original, coherent interpretation. **If you have the
> canonical `:root{}` / `.memox-dark{}` token block, paste it into
> `colors_and_type.css` (values only) — every component reads `var(--memox-*)`, so
> the whole system re-themes from that one edit.**
>
> **Color sources.** The current palette is drawn (colors only — not layout,
> type, or other theme content) from the **Tokyo Free** admin templates by
> bloomui: light from `tokyo-free-white-react-admin-dashboard`
> (`PureLightTheme.ts` — primary `#5569FF`, ink `#223354`, bg `#F2F5F9`), dark
> from `tokyo-free-black-react-admin-dashboard` (`NebulaFighterTheme.ts` —
> primary `#8C7CF0`, bg `#070C27`, surface `#111633`). Note/status tints and the
> component contract remain MemoX's own.

---

## Running locally

This is **not** a bundled React app — there is no `package.json`, build step, or
`node_modules`. The Mobile UI Kit is a static HTML gallery
(`ui_kits/mobile/index.html`) that loads React 18 (UMD) + Babel standalone + Lucide
from CDN and compiles `screens/*.jsx` in the browser at runtime.

**Requirements:** any static HTTP server (Python or Node) **and an internet
connection** (for the CDN scripts). You must serve over HTTP — opening
`index.html` via `file://` fails because Babel fetches the `.jsx` files over XHR
(CORS). Serve from **this folder** (the `index.html` links `../../colors_and_type.css`).

**One-click (Windows):** double-click `run.cmd` in this folder. It starts a local
server, opens the browser at the right URL, prefers Python and falls back to Node.
Stop it with `Ctrl+C`.

**Manual:**

```bash
cd "docs/system-design/MemoX Design System"

python -m http.server 8753          # Python
# or
npx http-server -p 8753 .           # Node
```

Then open: `http://127.0.0.1:8753/ui_kits/mobile/index.html`

> The gallery is for a quick browse / control order / copy text. The **canonical
> visual mock** for each screen is the PNG set under `ui_kits/mobile/shots/`
> (look up via `shots/INDEX.md`); exact measurements live in `ui_kits/mobile/specs/`.

---

## Index (root manifest)

| Path | What |
|---|---|
| `styles.css` | Global entry — `@import`s only. Consumers link this. |
| `colors_and_type.css` | All tokens: colors (light + `.memox-dark`), type, spacing, radii, shadows, fonts, **plus the contract semantic layer** (Material-style roles). |
| `memox-components.css` | **Component contract** — class-based, 100% token-driven primitives (`.appbar`, `.card`, `.pill-btn`, `.chip`, `.fab`, …). |
| `ui_kits/mobile/` | **Mobile UI Kit** — gallery engine (`index.html`) + `screens/*.jsx` (incl. `00 Components` showcase). |
| `components/core/` | Button, IconButton, Badge, Chip, Avatar, Switch, SegmentedControl, Card. |
| `components/mobile/` | NoteCard (the signature memo tile). |
| `guidelines/` | Foundation specimen cards (Colors / Type / Spacing / Brand). |
| `SKILL.md` | Agent-Skills front-matter for use in Claude Code. |
| `run.cmd` | **Local launcher** (Windows) — starts a static server and opens the gallery. See *Running locally* above. |
| `tools/check-ui-kit.js` | **Adherence linter** — `node tools/check-ui-kit.js` checks the UI kit for hardcoded colors, undefined tokens, missing bundle guards, raw px, and shared-primitive usage. Exit 0 = clean. |

### Components
`Button` · `IconButton` · `Badge` · `Chip` · `Avatar` · `Switch` ·
`SegmentedControl` · `Card` (core) · `NoteCard` (mobile). Each has a `.d.ts`
contract and `.prompt.md` usage note. Reach them at runtime via
`window.DesignSystem_48ad9c.<Name>` after loading `_ds_bundle.js`.

### UI kit — the gallery engine
`ui_kits/mobile/index.html` exposes a global:

```js
window.MEMOX_KIT.register({
  num: "02", title: "Note Editor",
  states: [
    { label: "Saving", render: () => <JSX inside .phone /> },
    { label: "Saved",  render: () => <JSX /> },
  ],
});
```

For every registered screen the engine builds a `.row` with `.row-num` / `.row-title`,
a `.stepper` (‹ label · n/m ›, omitted when there's a single state), and **two**
`.frame-wrap` device frames — one light, one `.memox-dark`. Next/Prev re-render
*both* phones to the new state and `lucide.createIcons()` runs after each render.
Add a screen by dropping `screens/NN-name.jsx` and a matching `<script type="text/babel">`
tag. Screens are plain IIFEs so top-level names never collide across Babel files.

---

## CONTENT FUNDAMENTALS

**Voice — calm, second-person, encouraging.** MemoX talks *to* the user ("you")
and never about itself in the first person. Copy is short, warm, and low-drama —
it reassures rather than hypes.

- **Casing:** Sentence case everywhere — titles, buttons, menu items
  ("New note", "Sync & backup", not "New Note" / "SYNC"). Eyebrows/section
  labels are the one exception: UPPERCASE with wide tracking ("RECENT", "WORK").
- **Person:** "you / your" for the reader. Greetings are personal —
  "Good morning, An". Never "we" except in product marketing.
- **Buttons** are verb-first and concrete: "New note", "Continue", "Export
  notes", "Delete". Avoid "Submit", "OK", "Click here".
- **Empty states** are gently motivating: "No memos yet" → "Capture your first
  thought." A streak nudge reads "You've captured something every day. Keep it
  going." — celebratory, never guilt-trippy.
- **Numbers & metadata** are terse and tabular: "12/148", "9:24", "3 results ·
  notes & tags".
- **Tone words:** calm, clear, paper-like, fast, low-drama. Avoid jargon,
  exclamation-mark spam, and growth-hack language.
- **Emoji:** not used in the product UI. Color-coded *note tints* and Lucide
  icons carry visual meaning instead.
- **Locale:** bilingual-friendly — Vietnamese content (e.g. "phở gà", "Đà Lạt",
  "An Nguyễn") sits naturally alongside English. Don't strip diacritics.

---

## VISUAL FOUNDATIONS

**Overall vibe:** clean, focused, and quiet. A cool near-white background
(`--memox-bg #F2F5F9`), a confident **blue accent** (`--memox-accent #5569FF`,
from the Tokyo Free White palette), and color only where it carries meaning.
Roomy, calm, unhurried — the opposite of a dense productivity dashboard.

- **Color.** One accent for primary actions, selection, and focus — **blue
  `#5569FF` in light, soft violet `#8C7CF0` in dark** (Tokyo Free White /
  Tokyo Free Black). Surfaces are cool off-whites; text is a navy-ink ramp
  (`text` → `text-2` → `text-3`). Eight **note tints** (amber, green, teal, blue,
  violet, pink, clay, yellow) color-code Spaces and tags — they are
  decorative-but-meaningful, never random. Semantic colors (success/warn/danger/
  info) each come as a solid + a soft tint. Avoid bluish-purple gradients and
  any color not in the token set.
- **Dark mode** is a token remap under `.memox-dark` — warm near-black surfaces
  (`#121210` / `#1B1B18`), a slightly lighter accent (`#FF7E55`). Applying the
  class to any container re-themes its whole subtree; descendants change nothing.
- **Type.** Two families. **Plus Jakarta Sans** for all UI (geometric, friendly,
  weights 400–800; display/titles at 800 with `-0.02em` tracking). **Lora**
  (serif) for the *note body* only — it makes writing feel page-like. **JetBrains
  Mono** for times, counts, tags, and code-ish metadata. The CSS sans stack ends in
  `system-ui … sans-serif`, so CJK (Korean/kanji) content falls back to the platform
  CJK font in the browser. The Flutter app mirrors this with a
  `fontFamilyFallback: ['Noto Sans KR']` on the theme (`MxTypography`), since Flutter
  does not auto-fall-back like a browser; the family is unbundled (device uses its CJK
  font) and golden tests register a Noto Sans KR subset under it.
- **Spacing.** 4px base scale (`--memox-space-1..12`). Screen gutters ~20px,
  card padding 16–18px, 12px between stacked cards.
- **Radii.** Generous and soft: cards `lg` (20px), inputs/sheets `md` (14px),
  chips & buttons **pill**, the phone frame 36–44px. Nothing sharp.
- **Backgrounds.** Flat cool off-white — *no* gradients, photos, or textures behind
  content. Depth comes from elevation, not imagery. The one "filled" surface is
  the accent streak-card and the FAB. Dark mode is a deep navy
  (`--memox-bg #070C27`, surfaces `#111633`), from the Tokyo Free Black palette.
- **Cards.** White (`--memox-card`) on paper, 1px `--memox-border`, `shadow-sm`,
  20px radius. The signature **NoteCard** adds a 5px colored left tint-bar — the
  single most recognizable MemoX motif. (This is the *intended* use of a colored
  left bar; don't confuse it with the generic-AI "rounded card + left accent" trope —
  here it's a deliberate, tint-coded system.)
- **Elevation — calm & neutral.** This is a *learning app*: keep elevation quiet
  so the eyes don't tire. Three soft, low-opacity, **neutral** shadows only:
  `sm` (cards), `md` (floating controls — FAB, popover), `lg` (sheets/dialogs).
  **No colored or glowing shadows anywhere** — primary buttons are **flat**
  (fill only, no glow). Prefer a border (`border-ghost` / `outline-variant`)
  over a shadow when either would do. Dark mode leans on borders with minimal
  shadow (cards drop shadow entirely → `--memox-shadow-soft: none`).
- **Buttons / press states.** Pill-shaped, **flat** — primary is an accent fill
  with no shadow. Press shrinks slightly (`transform: scale` ~.92 on steppers/
  icon buttons) and darkens toward `--memox-accent-press`. Hovers lift border to
  accent or warm the surface — subtle, fast (120–180ms ease).
- **Focus.** A 3px soft accent ring (`--memox-focus-ring`) — used on the active
  search field, etc.
- **Selection.** Filled accent for selected chips/segments; accent-soft tint for
  toggled icon buttons (e.g. Bold in the editor toolbar).
- **Animation.** Restrained. Short eases (120–200ms), gentle fades and toggle
  slides. No bounce, no parallax, no infinite decorative loops.
- **Transparency / blur.** Sticky bars (status header, tab bar, editor toolbar)
  use a `color-mix` translucent surface + `backdrop-filter: blur` so content
  scrolls softly beneath them.
- **Imagery vibe.** Minimal — MemoX is text-first. When imagery appears it should
  be warm and soft to match the paper palette. Avatars are solid-tint initials.

---

## COMPONENT CONTRACT (`memox-components.css`)

A second, **class-based** component layer (alongside the inline-styled React
primitives) implements a Material-3-flavored contract. Every rule is
**100% token-driven** — no literal colors, and sizes/radii/spacing read tokens.
It themes automatically: the same markup under `.memox-dark` flips via the
semantic alias tokens in `colors_and_type.css`.

> **Why two token namings?** The base palette (`--memox-accent`, `--memox-text`,
> …) is the source of truth. The contract layer adds **semantic role aliases**
> (`--memox-primary`, `--memox-on-primary`, `--memox-surface-raised`,
> `--memox-text-primary/secondary`, `--memox-outline(-variant)`,
> `--memox-status-*`, `--memox-op-*`, `--memox-fs-*`, `--memox-size-*`,
> `--memox-radius-card/button/fab/full`) that map onto the base. Aliases are
> declared in **both** `:root` and `.memox-dark` so their `var()` resolves in
> the active theme.

**Classes** (load `memox-components.css` after `colors_and_type.css`):
`.app` · `.appbar` / `.appbar-lg` (`.appbar-title`, `.appbar-subtitle`) ·
`.breadcrumb` / `.crumb` (`.current`) / `.crumb-sep` (nested-screen trail) ·
`.bottom-nav` / `.bottom-nav-item.active` (pill indicator; items `flex:1 1 0`
so the five destinations split evenly) · `.search-dock` (bottom-anchored,
thumb-reachable search bar, `--memox-size-search-dock`) · `.card` /
`.card.accent` · `.icon-btn` (40px, ≥48 hit) · `.icon-tile` / `.icon-tile.solid`
(tint via `--tile`) · `.pill-btn.primary|secondary|outline` (+`.sm`, `:disabled`)
· `.section-head` · `.ov` (overline, optional `.status-dot` via `--dot`) ·
`.chip.new|learning|reviewing|mastered|due` (+`.solid`) · `.progress` /
`.progress-fill` · `.list-row` · `.sheet` + `.scrim` · `.dialog` · `.fab`.

New `window.MX` primitives in `screens/_shared.jsx` (redesign): `Breadcrumb`,
`SearchField`/`SearchDock` (search docks at the FOOT, not the app bar),
`ShortcutRow`, `DueSummary` (quiet Dashboard due card), `Insight` + `GoalRing`
(Progress). The bottom nav now ships **five** destinations — Home · Library ·
Search · Stats · Settings. New tokens: `--memox-size-search-dock`,
`--memox-safe-top`.

State fills use `color-mix(... calc(var(--memox-op-*) * 100%), transparent)` so
hover / selected / disabled / scrim opacities are tokenized too. Icon sizes are
driven from `--memox-icon-sm|md|lg` via parent selectors (`.pill-btn svg`, etc.).

The **`00 Components`** screen in the Mobile UI Kit is the live showcase, rendered
in both light and dark frames. Status names (new / learning / reviewing /
mastered, "N due", progress) reflect MemoX's **spaced-repetition / flashcard**
study model.

---

## ICONOGRAPHY

- **Lucide** is the icon system (loaded from CDN: `lucide@0.460.0`). Stroke-style,
  ~1.75–2px weight, rounded — it matches the friendly, soft aesthetic. Render with
  `<i data-lucide="name"></i>` then call `lucide.createIcons()` after each React
  commit (the gallery engine does this automatically).
- Common glyphs in use: `notebook` `search` `layout-grid` `user` (tab bar),
  `plus` (FAB), `pin` `star` `folder` `clock` `bell` `lock` `cloud` `download`
  `chevron-right` `check` / `check-check` `flame` (streak), and editor tools
  `bold` `italic` `list` `list-checks` `link` `image` `mic`.
- Sizes: 17px in tab bar / status bar, 18–21px in toolbars & rows, 24–26px for
  the FAB. Color follows text tokens; active/selected use the accent.
- **No emoji** as icons; **no hand-rolled SVG paths** for UI glyphs — always use a
  Lucide name. The only non-Lucide vector is the app *mark* (the "M" in a rounded
  accent square), drawn with a styled element, not an icon.
- *Substitution flag:* Lucide is a deliberate, CDN-linked choice here (no bundled
  icon font was provided). If MemoX has its own icon set, drop the SVGs into
  `assets/` and document the swap here.

---

## CAVEATS

- **Token values are interpretive.** No canonical token block or design file was
  supplied; replace values in `colors_and_type.css` if you have the originals.
- **Fonts are Google Fonts** (Plus Jakarta Sans, Lora, JetBrains Mono) loaded via
  CDN `@import` — no font binaries are bundled. Swap to self-hosted `@font-face`
  if you need offline/production use.
- **Icons are CDN Lucide**, not a bundled MemoX icon set.
