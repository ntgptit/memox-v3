// symbol_lint — Bridge 2 of the "kit-as-compiled-contract" parity pipeline.
//
// PROBLEM it kills (RC2): the prose `docs/design/design-token-mapping.md` told
// agents to code against Dart symbols that DO NOT EXIST (SpacingTokens.*,
// RadiusTokens.*, SizeTokens.*, lib/core/theme/tokens/**, MxTextRole, …). Prose
// can't be compiled, so the drift went undetected and agents improvised → wrong
// screens. The fix is a map that RESOLVES NAMES AGAINST THE ACTUAL CODE/CSS,
// not a hand-maintained table that rots:
//
//   - every kit `mx:<Component>` suggestion in a spec must resolve to a real
//     `class <Component>` in lib/ (or a documented alias/gap in symbol-aliases.json);
//   - every `--memox-*` color token a spec references must be a real token
//     declared in the kit's colors_and_type.css.
//
// `--write` regenerates the machine-readable inventory tool/parity/symbol-map.json
// (the artifact agents read INSTEAD of the rotted prose). `--check` is the gate
// (wired into tool/verify/run.mjs); it fails on any unresolved component or
// unknown color token.
//
// Usage:
//   node tool/parity/symbol_lint.mjs --check   # gate: fail on phantom component / unknown token
//   node tool/parity/symbol_lint.mjs --write   # regenerate symbol-map.json
//   node tool/parity/symbol_lint.mjs           # report (no exit-fail, no write)

import { existsSync, readdirSync, readFileSync, writeFileSync, statSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const LIB_DIR = join(repoRoot, 'lib');
const SPECS_DIR = join(repoRoot, 'docs/system-design/MemoX Design System/ui_kits/mobile/specs');
const CSS_PATH = join(repoRoot, 'docs/system-design/MemoX Design System/colors_and_type.css');
const COLORS_DART = join(repoRoot, 'lib/core/theme/mx_colors.dart');
const ALIASES_PATH = join(repoRoot, 'tool/parity/symbol-aliases.json');
const MAP_OUT = join(repoRoot, 'tool/parity/symbol-map.json');

// Color-suffix → MxColors member; camelCase covers most, these are the renames.
const COLOR_RENAME = { 'text-2': 'textSecondary', 'text-3': 'textTertiary', 'surface-2': 'surfaceMuted' };

// CSS color keywords / function residue that are NOT `--memox-*` tokens (legit
// values, not phantoms): `transparent` → Colors.transparent; `color` is the tail
// of color()/color-mix() computed colors the spec emits for tints.
const CSS_COLOR_KEYWORDS = new Set(['transparent', 'currentcolor', 'inherit', 'none', 'color', 'white', 'black']);
const camel = (s) => s.split('-').map((p, i) => (i === 0 ? p : p[0].toUpperCase() + p.slice(1))).join('');

// ── filesystem ───────────────────────────────────────────────────────────────

function walkDart(dir, out = []) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    const st = statSync(p);
    if (st.isDirectory()) walkDart(p, out);
    else if (name.endsWith('.dart') && !name.endsWith('.g.dart') && !name.endsWith('.freezed.dart')) out.push(p);
  }
  return out;
}

/** Every `class <Name>` declared in lib/ (excluding generated files). */
function libClassNames() {
  const set = new Set();
  for (const f of walkDart(LIB_DIR)) {
    const src = readFileSync(f, 'utf8');
    const re = /\bclass\s+([A-Za-z_]\w*)/g;
    let m;
    while ((m = re.exec(src)) !== null) set.add(m[1]);
  }
  return set;
}

/** Map class → file for the components we resolve (first declaration wins). */
function libClassFiles(names) {
  const out = {};
  for (const f of walkDart(LIB_DIR)) {
    const src = readFileSync(f, 'utf8');
    for (const name of names) {
      if (out[name]) continue;
      if (new RegExp(`\\bclass\\s+${name}\\b`).test(src)) out[name] = f.replace(repoRoot + '\\', '').replace(repoRoot + '/', '').replace(/\\/g, '/');
    }
  }
  return out;
}

function specFiles() {
  return readdirSync(SPECS_DIR)
    .filter((n) => /^\d.*\.md$/.test(n))
    .map((n) => join(SPECS_DIR, n));
}

// ── spec scanning ────────────────────────────────────────────────────────────

/** mx:<Name> refs (excluding `?`) → { name: { count, specs:Set } }. */
function componentRefs(files) {
  const refs = new Map();
  let unmapped = 0;
  for (const f of files) {
    const base = f.split(/[\\/]/).pop();
    const src = readFileSync(f, 'utf8');
    const re = /\bmx:\s*([A-Za-z]\w*|\?)/g;
    let m;
    while ((m = re.exec(src)) !== null) {
      if (m[1] === '?') { unmapped++; continue; }
      if (!refs.has(m[1])) refs.set(m[1], { count: 0, specs: new Set() });
      const r = refs.get(m[1]);
      r.count++;
      r.specs.add(base);
    }
  }
  return { refs, unmapped };
}

/** Token-shaped color refs (bg:/color:/border:) → Map(suffix → count). Skips
 *  computed colors (color()/color-mix()/rgba()) and bare #hex by construction. */
function colorRefs(files) {
  const refs = new Map();
  const add = (s) => refs.set(s, (refs.get(s) || 0) + 1);
  for (const f of files) {
    const src = readFileSync(f, 'utf8');
    let m;
    const re1 = /(?:bg|color):([a-z][a-z0-9-]*)(?:@\d+)?(?=[\s)]|$)/gm;
    while ((m = re1.exec(src)) !== null) add(m[1]);
    const re2 = /border(?:-[trbl])?:\d+px\s+([a-z][a-z0-9-]*)(?:@\d+)?/g;
    while ((m = re2.exec(src)) !== null) add(m[1]);
  }
  return refs;
}

// ── source token sets ────────────────────────────────────────────────────────

/** Every `--memox-<suffix>` declared in the kit CSS. */
function cssDeclaredSuffixes() {
  const css = readFileSync(CSS_PATH, 'utf8');
  const set = new Set();
  const re = /--memox-([\w-]+)\s*:/g;
  let m;
  while ((m = re.exec(css)) !== null) set.add(m[1]);
  return set;
}

/** MxColors members (final fields + getters) from mx_colors.dart. */
function mxColorMembers() {
  const src = readFileSync(COLORS_DART, 'utf8');
  const set = new Set();
  let m;
  const reField = /final Color (\w+);/g;
  while ((m = reField.exec(src)) !== null) set.add(m[1]);
  const reGet = /Color get (\w+) =>/g;
  while ((m = reGet.exec(src)) !== null) set.add(m[1]);
  return set;
}

const resolveColorMember = (suffix, members) => {
  const cand = COLOR_RENAME[suffix] || camel(suffix);
  return members.has(cand) ? cand : null;
};

// ── analyze ──────────────────────────────────────────────────────────────────

function analyze() {
  const aliases = JSON.parse(readFileSync(ALIASES_PATH, 'utf8'));
  const componentAliases = aliases.componentAliases || {};
  const componentGaps = aliases.componentGaps || {};

  const classes = libClassNames();
  const files = specFiles();
  const { refs: compRefs, unmapped } = componentRefs(files);
  const colRefs = colorRefs(files);
  const declared = cssDeclaredSuffixes();
  const members = mxColorMembers();

  // resolve components
  const components = {};
  for (const [name, info] of [...compRefs].sort()) {
    const specs = [...info.specs].sort();
    if (classes.has(name)) components[name] = { status: 'ok', class: name, count: info.count, specs };
    else if (componentAliases[name] && classes.has(componentAliases[name]))
      components[name] = { status: 'alias', class: componentAliases[name], count: info.count, specs };
    else if (componentGaps[name])
      components[name] = { status: 'gap', reason: componentGaps[name], count: info.count, specs };
    else components[name] = { status: 'PHANTOM', count: info.count, specs };
  }

  // resolve color tokens
  const colorTokens = {};
  for (const [suffix, count] of [...colRefs].sort()) {
    if (CSS_COLOR_KEYWORDS.has(suffix)) colorTokens[suffix] = { status: 'keyword', count };
    else if (!declared.has(suffix)) colorTokens[suffix] = { status: 'UNKNOWN', count };
    else {
      const member = resolveColorMember(suffix, members);
      colorTokens[suffix] = member
        ? { status: 'ok', member, count }
        : { status: 'no-member', count };
    }
  }

  return { components, colorTokens, unmapped, classFiles: libClassFiles };
}

// ── commands ─────────────────────────────────────────────────────────────────

function report(a) {
  const phantom = Object.entries(a.components).filter(([, v]) => v.status === 'PHANTOM');
  const gaps = Object.entries(a.components).filter(([, v]) => v.status === 'gap');
  const aliasd = Object.entries(a.components).filter(([, v]) => v.status === 'alias');
  const unknown = Object.entries(a.colorTokens).filter(([, v]) => v.status === 'UNKNOWN');
  const noMember = Object.entries(a.colorTokens).filter(([, v]) => v.status === 'no-member');

  const okC = Object.values(a.components).filter((v) => v.status === 'ok').length;
  console.log(`symbol_lint: components — ${okC} ok, ${aliasd.length} alias, ${gaps.length} gap, ${phantom.length} PHANTOM (mx:? unmapped: ${a.unmapped})`);
  for (const [n, v] of aliasd) console.log(`  ↪ ${n} → ${v.class} (alias; retag kit) — ${v.specs.join(', ')}`);
  for (const [n, v] of gaps) console.log(`  ◌ ${n} GAP — ${v.specs.join(', ')}`);
  for (const [n, v] of phantom) console.log(`  ✖ ${n} PHANTOM (no class in lib/, no alias/gap) — ${v.specs.join(', ')}`);

  const okT = Object.values(a.colorTokens).filter((v) => v.status === 'ok').length;
  console.log(`symbol_lint: color tokens — ${okT} ok, ${noMember.length} no-member, ${unknown.length} UNKNOWN`);
  for (const [t, v] of noMember) console.log(`  ⚠ ${t}: declared in CSS but no MxColors member (×${v.count})`);
  for (const [t, v] of unknown) console.log(`  ✖ ${t}: not a --memox-* token in colors_and_type.css (×${v.count})`);

  return { phantom, unknown };
}

function write(a) {
  const classFiles = a.classFiles(
    new Set(Object.values(a.components).map((v) => v.class).filter(Boolean)),
  );
  for (const v of Object.values(a.components)) if (v.class && classFiles[v.class]) v.file = classFiles[v.class];
  const out = {
    $generated: 'by tool/parity/symbol_lint.mjs --write — DO NOT hand-edit. Curated aliases/gaps live in tool/parity/symbol-aliases.json. This is the authoritative kit-symbol → Flutter-symbol map; read it instead of the prose in docs/design/design-token-mapping.md.',
    components: a.components,
    colorTokens: a.colorTokens,
    unmappedMxCount: a.unmapped,
  };
  writeFileSync(MAP_OUT, JSON.stringify(out, null, 2) + '\n');
  console.log(`symbol_lint: wrote ${MAP_OUT.replace(repoRoot, '').replace(/^[\\/]/, '')}`);
}

const mode = process.argv.includes('--write') ? 'write' : process.argv.includes('--check') ? 'check' : 'report';
const a = analyze();
if (mode === 'write') {
  write(a);
} else {
  const { phantom, unknown } = report(a);
  if (mode === 'check' && (phantom.length || unknown.length)) {
    console.error(`\nsymbol_lint: FAIL — ${phantom.length} phantom component(s), ${unknown.length} unknown color token(s).`);
    console.error('Fix: build the component / correct the kit mx: tag, or (if a documented exception) add to tool/parity/symbol-aliases.json.');
    process.exit(1);
  }
}
