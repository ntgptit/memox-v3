// gen_tokens — Bridge 1 of the "kit-as-compiled-contract" parity pipeline.
//
// SOURCE OF TRUTH for token VALUES is the design kit's
//   docs/system-design/MemoX Design System/colors_and_type.css
// (the same `--memox-*` block crafted on Claude Design). The Flutter theme is a
// DOWNSTREAM consumer: this tool generates / verifies the token literals in
//   lib/core/theme/*.dart
// directly from that CSS, so the two can never drift by hand again. Change a
// value in the kit → re-run `--write` → the Dart literals follow; the `--check`
// gate (wired into tool/verify/run.mjs) fails any commit where they disagree.
//
// Usage:
//   node tool/parity/gen_tokens.mjs --check   # gate: assert Dart == CSS (exit 1 on drift)
//   node tool/parity/gen_tokens.mjs --write   # regenerate the writable families from CSS
//   node tool/parity/gen_tokens.mjs           # same as --check
//
// FAMILIES (this slice):
//   - colors   (mx_colors.dart)      28 ARGB tokens × 2 themes — check + write (block regen)
//   - spacing  (mx_spacing.dart)     4px scale + roles            — check + write (literal regen)
//   - radius   (mx_radius.dart)      radius scale + roles         — check + write (literals; aliases checked, not rewritten)
//   - type     (mx_typography.dart)  weights + line-heights       — check only
//
// Type tracking (`--memox-tracking-*`, em) and font sizes are intentionally NOT
// checked: tracking is an em→px design conversion (not numerically equal) and
// sizes are composed into Material TextTheme slots (no 1:1 Dart symbol).

import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const CSS_PATH = join(
  repoRoot,
  'docs/system-design/MemoX Design System/colors_and_type.css',
);
const themeFile = (f) => join(repoRoot, 'lib/core/theme', f);

// ── colors family map ────────────────────────────────────────────────────────
// CSS `--memox-<suffix>` → Dart MxColors field, in field-declaration order (so a
// regenerated block is byte-identical when there is no drift). The three marked
// ↯ are renamed — exactly why a plain string transform is NOT enough.
const COLOR_MAP = [
  ['accent', 'accent'],
  ['accent-soft', 'accentSoft'],
  ['accent-contrast', 'accentContrast'],
  ['bg', 'bg'],
  ['surface', 'surface'],
  ['surface-2', 'surfaceMuted'], // ↯ renamed
  ['overlay', 'overlay'],
  ['text', 'text'],
  ['text-2', 'textSecondary'], // ↯ renamed
  ['text-3', 'textTertiary'], // ↯ renamed
  ['border', 'border'],
  ['border-strong', 'borderStrong'],
  ['divider', 'divider'],
  ['focus-ring', 'focusRing'],
  ['success', 'success'],
  ['success-soft', 'successSoft'],
  ['warn', 'warn'],
  ['danger', 'danger'],
  ['danger-soft', 'dangerSoft'],
  ['info', 'info'],
  ['note-yellow', 'noteYellow'],
  ['note-amber', 'noteAmber'],
  ['note-green', 'noteGreen'],
  ['note-teal', 'noteTeal'],
  ['note-blue', 'noteBlue'],
  ['note-violet', 'noteViolet'],
  ['note-pink', 'notePink'],
  ['note-clay', 'noteClay'],
];

// ── scalar families ──────────────────────────────────────────────────────────
// Each pair is [cssVarSuffix, dartSymbol]; both sides are resolved to a NUMBER
// (CSS `var()`/px and Dart symbol-aliases/`FontWeight.wNNN` are resolved) and
// compared. `writable` families have their numeric-literal symbols regenerated
// in place by --write; symbols whose Dart value is an alias/non-literal are
// still checked but left untouched.
const SCALAR_FAMILIES = [
  {
    name: 'spacing',
    file: 'mx_spacing.dart',
    writable: true,
    map: [
      ['space-1', 'space1'],
      ['space-2', 'space2'],
      ['space-3', 'space3'],
      ['space-4', 'space4'],
      ['space-5', 'space5'],
      ['space-6', 'space6'],
      ['space-8', 'space8'],
      ['space-10', 'space10'],
      ['space-12', 'space12'],
      ['space-screen', 'screen'],
      ['space-card', 'card'],
      ['gap-section', 'gapSection'],
      ['hit', 'minTouchTarget'],
    ],
  },
  {
    name: 'radius',
    file: 'mx_radius.dart',
    writable: true,
    map: [
      ['radius-xs', 'xs'],
      ['radius-sm', 'sm'],
      ['radius-md', 'md'],
      ['radius-lg', 'lg'],
      ['radius-xl', 'xl'],
      ['radius-pill', 'pill'],
      ['radius-card', 'card'], // Dart alias `= lg` → checked, not rewritten
      ['radius-button', 'button'], // Dart alias `= pill` → checked, not rewritten
      ['radius-fab', 'fab'],
    ],
  },
  {
    name: 'type',
    file: 'mx_typography.dart',
    writable: false,
    map: [
      ['weight-regular', 'regular'],
      ['weight-medium', 'medium'],
      ['weight-semibold', 'semibold'],
      ['weight-bold', 'bold'],
      ['weight-extrabold', 'extrabold'],
      ['leading-tight', 'leadingTight'],
      ['leading-snug', 'leadingSnug'],
      ['leading-normal', 'leadingNormal'],
    ],
  },
];

// ── CSS parsing ──────────────────────────────────────────────────────────────

/** Split a stylesheet into { selector, body } rule blocks (comments stripped). */
function ruleBlocks(css) {
  const noComments = css.replace(/\/\*[\s\S]*?\*\//g, '');
  const blocks = [];
  const re = /([^{}]+)\{([^{}]*)\}/g;
  let m;
  while ((m = re.exec(noComments)) !== null) {
    blocks.push({ selector: m[1].trim(), body: m[2] });
  }
  return blocks;
}

/** Concatenated body of every rule whose selector targets the given theme. */
function themeScope(blocks, matcher) {
  return blocks
    .filter((b) => matcher(b.selector))
    .map((b) => b.body)
    .join('\n');
}

const isLight = (s) => /(^|,)\s*(:root|\.memox-light)\b/.test(s);
const isDark = (s) => /\.memox-dark\b/.test(s);

/** All `--memox-<suffix>: value` declarations in a scope → Map(suffix → rawValue). */
function parseDecls(scope) {
  const out = new Map();
  const re = /--memox-([\w-]+)\s*:\s*([^;]+);/g;
  let m;
  while ((m = re.exec(scope)) !== null) out.set(m[1], m[2].trim());
  return out;
}

/** Resolve a CSS custom-property suffix to a number (follows `var()`, strips px). */
function resolveCss(suffix, decls, seen = new Set()) {
  if (seen.has(suffix)) return null;
  seen.add(suffix);
  const raw = decls.get(suffix);
  if (raw === undefined) return null;
  const v = raw.trim();
  const ref = /^var\(\s*--memox-([\w-]+)\s*\)$/.exec(v);
  if (ref) return resolveCss(ref[1], decls, seen);
  const num = /^(-?\d+(?:\.\d+)?)px$/.exec(v) || /^(-?\d+(?:\.\d+)?)$/.exec(v);
  if (num) return Number(num[1]);
  return null; // em / none / env(...) / non-numeric
}

// ── CSS color literal → Dart ARGB ────────────────────────────────────────────

const hex2 = (n) => Math.max(0, Math.min(255, n)).toString(16).toUpperCase().padStart(2, '0');

function literalColor(scope, suffix) {
  const re = new RegExp(`--memox-${suffix}\\s*:\\s*([^;]+);`, 'g');
  let m;
  while ((m = re.exec(scope)) !== null) {
    const v = m[1].trim();
    if (!v.startsWith('var(')) return v;
  }
  return null;
}

function toDartArgb(value) {
  const v = value.trim();
  let m = /^#([0-9a-fA-F]{6})$/.exec(v);
  if (m) return `0xFF${m[1].toUpperCase()}`;
  m = /^#([0-9a-fA-F]{3})$/.exec(v);
  if (m) {
    const [r, g, b] = m[1].split('');
    return `0xFF${(r + r + g + g + b + b).toUpperCase()}`;
  }
  m = /^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+)\s*)?\)$/.exec(v);
  if (m) {
    const a = m[4] === undefined ? 1 : Number(m[4]);
    // round(a*255): matches the committed literals (0.45 → 0x73, 0.4 → 0x66).
    return `0x${hex2(Math.round(a * 255))}${hex2(Number(m[1]))}${hex2(Number(m[2]))}${hex2(Number(m[3]))}`;
  }
  throw new Error(`unrecognized CSS color literal: "${value}"`);
}

function cssColorTheme(scope, label) {
  const out = {};
  for (const [suffix, field] of COLOR_MAP) {
    const raw = literalColor(scope, suffix);
    if (raw === null) throw new Error(`CSS token --memox-${suffix} not found in ${label} scope`);
    out[field] = toDartArgb(raw);
  }
  return out;
}

// ── Dart parsing ─────────────────────────────────────────────────────────────

function colorBlock(dart, themeName) {
  const re = new RegExp(` {2}static const MxColors ${themeName} = MxColors\\([\\s\\S]*?\\n {2}\\);`);
  const m = re.exec(dart);
  if (!m) throw new Error(`could not locate "static const MxColors ${themeName}" block in mx_colors.dart`);
  return m[0];
}

function dartColors(block) {
  const out = {};
  const re = /(\w+):\s*Color\((0x[0-9a-fA-F]{8})\)/g;
  let m;
  while ((m = re.exec(block)) !== null) out[m[1]] = `0x${m[2].slice(2).toUpperCase()}`;
  return out;
}

/** Map(symbol → raw expression) for every `static const <T> <symbol> = <expr>;`. */
function parseDartConsts(src) {
  const out = new Map();
  const re = /static const [\w<>]+ (\w+)\s*=\s*([^;]+);/g;
  let m;
  while ((m = re.exec(src)) !== null) out.set(m[1], m[2].trim());
  return out;
}

/** Resolve a Dart const symbol to a number (numeric literal, FontWeight, alias). */
function resolveDart(symbol, consts, seen = new Set()) {
  if (seen.has(symbol)) return null;
  seen.add(symbol);
  const expr = consts.get(symbol);
  if (expr === undefined) return null;
  if (/^-?\d+(?:\.\d+)?$/.test(expr)) return Number(expr);
  const w = /^FontWeight\.w(\d+)$/.exec(expr);
  if (w) return Number(w[1]);
  if (/^\w+$/.test(expr)) return resolveDart(expr, consts, seen);
  return null; // BorderRadius.all(...), TextTheme(...), lists, etc.
}

// ── render (colors --write) ──────────────────────────────────────────────────

function renderColorBlock(themeName, valuesByField) {
  const lines = COLOR_MAP.map(([, field]) => `    ${field}: Color(${valuesByField[field]}),`);
  return `  static const MxColors ${themeName} = MxColors(\n${lines.join('\n')}\n  );`;
}

// ── load ─────────────────────────────────────────────────────────────────────

function load() {
  if (!existsSync(CSS_PATH)) {
    console.error(`gen_tokens: CSS source not found: ${CSS_PATH}`);
    process.exit(1);
  }
  const css = readFileSync(CSS_PATH, 'utf8');
  const blocks = ruleBlocks(css);
  const lightScope = themeScope(blocks, isLight);
  const darkScope = themeScope(blocks, isDark);
  return {
    cssColorLight: cssColorTheme(lightScope, 'light'),
    cssColorDark: cssColorTheme(darkScope, 'dark'),
    // spacing/radius/type are theme-neutral → declared in the light/:root scope.
    decls: parseDecls(lightScope),
  };
}

// ── check ────────────────────────────────────────────────────────────────────

function check() {
  const { cssColorLight, cssColorDark, decls } = load();
  const drift = [];

  // colors
  const colorSrc = readFileSync(themeFile('mx_colors.dart'), 'utf8');
  const dartLight = dartColors(colorBlock(colorSrc, 'light'));
  const dartDark = dartColors(colorBlock(colorSrc, 'dark'));
  for (const [theme, cssVals, dartVals] of [['light', cssColorLight, dartLight], ['dark', cssColorDark, dartDark]]) {
    for (const [, field] of COLOR_MAP) {
      const want = cssVals[field];
      const got = dartVals[field];
      if (got === undefined) drift.push(`colors.${theme}.${field}: missing in mx_colors.dart (CSS=${want})`);
      else if (got !== want) drift.push(`colors.${theme}.${field}: CSS=${want} but Dart=${got}`);
    }
  }
  let checked = COLOR_MAP.length * 2;

  // scalar families
  for (const fam of SCALAR_FAMILIES) {
    const consts = parseDartConsts(readFileSync(themeFile(fam.file), 'utf8'));
    for (const [cssVar, sym] of fam.map) {
      const want = resolveCss(cssVar, decls);
      const got = resolveDart(sym, consts);
      checked++;
      if (want === null) drift.push(`${fam.name}.${sym}: CSS token --memox-${cssVar} unresolved`);
      else if (got === null) drift.push(`${fam.name}.${sym}: Dart symbol unresolved in ${fam.file} (CSS=${want})`);
      else if (Math.abs(want - got) > 1e-9) drift.push(`${fam.name}.${sym}: CSS(--memox-${cssVar})=${want} but Dart=${got}`);
    }
  }

  if (drift.length) {
    console.error('gen_tokens: token DRIFT — Flutter theme disagrees with colors_and_type.css (the kit is source):');
    for (const d of drift) console.error(`  ✖ ${d}`);
    console.error('\nFix: edit the CSS in the kit, then `node tool/parity/gen_tokens.mjs --write` (colors/spacing/radius are auto-regenerated; type + aliases are hand-edited per the message above).');
    process.exit(1);
  }
  console.log(`gen_tokens: ✔ ${checked} tokens match colors_and_type.css (colors×2 + spacing + radius + type)`);
}

// ── write ────────────────────────────────────────────────────────────────────

function writeScalarLiterals(fam, decls) {
  const path = themeFile(fam.file);
  let src = readFileSync(path, 'utf8');
  let changed = 0;
  for (const [cssVar, sym] of fam.map) {
    const want = resolveCss(cssVar, decls);
    if (want === null) continue;
    // Replace only when the Dart value is a numeric literal (skip aliases like `= lg`).
    const re = new RegExp(`(static const [\\w<>]+ ${sym}\\s*=\\s*)(-?\\d+(?:\\.\\d+)?)(\\s*;)`);
    const m = re.exec(src);
    if (!m) continue;
    const next = `${m[1]}${String(want)}${m[3]}`;
    if (next !== m[0]) changed++;
    src = src.replace(re, next);
  }
  writeFileSync(path, src);
  return changed;
}

function write() {
  const { cssColorLight, cssColorDark, decls } = load();
  // colors
  const colorPath = themeFile('mx_colors.dart');
  let colorSrc = readFileSync(colorPath, 'utf8');
  colorSrc = colorSrc.replace(colorBlock(colorSrc, 'light'), renderColorBlock('light', cssColorLight));
  colorSrc = colorSrc.replace(colorBlock(colorSrc, 'dark'), renderColorBlock('dark', cssColorDark));
  writeFileSync(colorPath, colorSrc);
  console.log(`gen_tokens: wrote colors (${COLOR_MAP.length} × 2 themes) into mx_colors.dart`);
  // scalar families
  for (const fam of SCALAR_FAMILIES) {
    if (!fam.writable) {
      console.log(`gen_tokens: ${fam.name} is check-only (no --write) — ${fam.file}`);
      continue;
    }
    const n = writeScalarLiterals(fam, decls);
    console.log(`gen_tokens: ${fam.name} — ${n} literal(s) updated in ${fam.file}`);
  }
  console.log('Run `node tool/verify/run.mjs` to format + verify.');
}

const mode = process.argv.includes('--write') ? 'write' : 'check';
if (mode === 'write') write();
else check();
