#!/usr/bin/env node
// gen_bindings — Bridge 3 of the "kit-as-compiled-contract" parity pipeline.
//
// gen_contract.mjs crystallises each kit spec's `data-mx-node` ids into a PRESENCE
// contract (which keyed nodes must exist). This goes one layer deeper: for every
// keyed node it also captures what the kit says it must LOOK like — the suggested
// `mx:` component and the token bindings (bg / text color / font / radius / border)
// from the node's `style:` — and resolves colors + radius to the real Flutter
// symbols. The output `tool/parity/contracts/bindings.json` is the deterministic,
// machine-readable "what each keyed node must bind" that agents build against,
// reviewers/ui-parity-checker diff the FE against, and binding tests assert.
//
// Like gen_contract, the GATE here is freshness: `--check` fails when bindings.json
// drifts from the specs (wired into tool/verify/run.mjs). FE-conformance to a
// binding (and documented behaviour exceptions) stays in the test / ui-parity /
// intent-ledger layer — this tool owns the spec→contract edge, not the FE edge.
//
// Usage:
//   node tool/parity/gen_bindings.mjs           # write contracts/bindings.json
//   node tool/parity/gen_bindings.mjs --check    # exit 1 if bindings.json is stale
//   node tool/parity/gen_bindings.mjs --json

import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const MAP = JSON.parse(readFileSync(join(HERE, 'parity-map.json'), 'utf8'));
const SPECS = resolve(join(REPO, MAP.shotsDir), '..', 'specs');
const OUT = join(HERE, 'contracts');
const COLORS_DART = join(REPO, 'lib/core/theme/mx_colors.dart');

const args = process.argv.slice(2);
const check = args.includes('--check');
const asJson = args.includes('--json');

// radius px → MxRadius token (mirrors mx_radius.dart).
const RADIUS = { 6: 'xs', 10: 'sm', 14: 'md', 20: 'lg', 28: 'xl', 999: 'pill', 18: 'fab' };
const COLOR_RENAME = { 'text-2': 'textSecondary', 'text-3': 'textTertiary', 'surface-2': 'surfaceMuted' };
const KEYWORDS = new Set(['transparent', 'currentcolor', 'inherit', 'none', 'color', 'white', 'black']);
const camel = (s) => s.split('-').map((p, i) => (i === 0 ? p : p[0].toUpperCase() + p.slice(1))).join('');

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
const members = mxColorMembers();

/** kit color token (may carry `@NN` opacity) → `mxColors.<member>` or null. */
function colorSymbol(token) {
  if (!token) return null;
  const suffix = token.replace(/@\d+$/, '');
  if (KEYWORDS.has(suffix) || suffix.includes('(') || suffix.startsWith('#')) return null;
  const cand = COLOR_RENAME[suffix] || camel(suffix);
  return members.has(cand) ? `mxColors.${cand}` : null;
}

/** Split a `style:` value into the bindings we track. */
function parseStyle(style) {
  const tokens = {};
  const flutter = {};
  let m;
  if ((m = /(?:^|\s)bg:([^\s]+)/.exec(style))) { tokens.bg = m[1]; const s = colorSymbol(m[1]); if (s) flutter.bg = s; }
  if ((m = /(?:^|\s)color:([^\s]+)/.exec(style))) { tokens.color = m[1]; const s = colorSymbol(m[1]); if (s) flutter.color = s; }
  if ((m = /(?:^|\s)font:([0-9]+(?:\/[0-9.]+){1,2})/.exec(style))) {
    const [size, weight] = m[1].split('/');
    tokens.font = m[1];
    flutter.font = { size: Number(size), weight: weight ? Number(weight) : null };
  }
  if ((m = /(?:^|\s)r:([0-9]+)/.exec(style))) { tokens.radius = Number(m[1]); if (RADIUS[m[1]]) flutter.radius = `MxRadius.${RADIUS[m[1]]}`; }
  if ((m = /(?:^|\s)border(?:-[trbl])?:\d+px\s+([a-z][a-z0-9-]*)/.exec(style))) {
    tokens.border = m[1]; const s = colorSymbol(m[1]); if (s) flutter.border = s;
  }
  return { tokens, flutter };
}

/** Parse a spec into per-node records (own direct fields only). */
function nodesInSpec(md) {
  const lines = md.split('\n');
  const starts = [];
  for (let i = 0; i < lines.length; i++) {
    if (/^\s*-?\s*node:\s*\S/.test(lines[i])) starts.push(i);
  }
  const out = [];
  for (let k = 0; k < starts.length; k++) {
    const from = starts[k];
    const to = k + 1 < starts.length ? starts[k + 1] : lines.length;
    const window = lines.slice(from, to).map((l) => l.trim());
    const name = /node:\s*(\S+)/.exec(window[0])?.[1] ?? '?';
    const id = window.map((s) => /\bid:\s*([A-Za-z0-9][\w/-]*)/.exec(s)?.[1]).find(Boolean);
    if (!id) continue;
    const mx = window.map((s) => /\bmx:\s*([A-Za-z?]\w*|\?)/.exec(s)?.[1]).find(Boolean) ?? null;
    const styleLine = window.find((s) => /^style:/.test(s));
    const { tokens, flutter } = styleLine ? parseStyle(styleLine.replace(/^style:\s*/, '')) : { tokens: {}, flutter: {} };
    out.push({ key: `mx-node:${id}`, node: name, component: mx, tokens, flutter });
  }
  // dedupe by key (first wins)
  const seen = new Set();
  return out.filter((e) => (seen.has(e.key) ? false : seen.add(e.key)));
}

const files = readdirSync(SPECS).filter((f) => f.endsWith('.md') && f !== 'INDEX.md');
const bindings = {};
let total = 0;
for (const f of files) {
  const screen = f.replace(/\.md$/, '');
  const nodes = nodesInSpec(readFileSync(join(SPECS, f), 'utf8'));
  if (nodes.length) { bindings[screen] = nodes; total += nodes.length; }
}

if (asJson) { console.log(JSON.stringify({ bindings, total }, null, 2)); process.exit(0); }

const outFile = join(OUT, 'bindings.json');
const next = `${JSON.stringify({
  $generated: 'tool/parity/gen_bindings.mjs — DO NOT hand-edit; regenerate from the kit specs.',
  $doc: 'Per keyed-node (data-mx-node) binding contract: the kit component (mx:) + token bindings, with colors/radius resolved to Flutter symbols. The FE must realize these (behaviour exceptions live in intent-ledger.json). --check gates freshness vs the specs.',
  bindings,
}, null, 2)}\n`;
const prev = existsSync(outFile) ? readFileSync(outFile, 'utf8') : '';

if (check) {
  if (prev !== next) {
    console.error('gen_bindings: bindings.json is STALE — run `node tool/parity/gen_bindings.mjs`.');
    process.exit(1);
  }
  console.log(`gen_bindings: up to date (${total} bound node(s) across ${Object.keys(bindings).length} screen(s)).`);
  process.exit(0);
}

mkdirSync(OUT, { recursive: true });
writeFileSync(outFile, next);
console.log(`gen_bindings: wrote ${outFile} — ${total} bound node(s) across ${Object.keys(bindings).length} screen(s).`);
process.exit(0);
