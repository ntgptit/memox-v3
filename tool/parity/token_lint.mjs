#!/usr/bin/env node
// tool/parity/token_lint.mjs — deterministic token-coverage lint of the UI-kit
// specs (NO AI).
//
// Per the spec reading guide, a `--memox-*` token name in a spec maps to a
// Flutter token, but a bare `#rrggbb` "means no token matched — treat as a gap,
// not a license to hardcode". This linter surfaces those gaps and inventories
// every color token the kit references, so coverage is checked by machine
// instead of by eye.
//
// What it reports:
//   - GAPS: bare `#rrggbb` in any spec (un-tokenized color the design system
//     hasn't named) → file:line.
//   - INVENTORY: every distinct `bg:` / `color:` token the specs use, with a
//     count — cross-check that each has a Flutter token (design-token-mapping.md).
//
// (Typography/size values like `font:22/800` and `r:14` are intentionally NOT
// linted here — they are scalar values, not named tokens; missing type/size
// SLOTS are tracked in parity-deferred.md under needs-token.)
//
// Usage:
//   node tool/parity/token_lint.mjs           # print gaps + inventory
//   node tool/parity/token_lint.mjs --check   # exit 1 if any bare-hex gap
//   node tool/parity/token_lint.mjs --json
//
// Exit: 0 = ok, 1 = gap found (--check), 2 = IO error.

import { readdirSync, readFileSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const SPECS = join(
  REPO,
  'docs/system-design/MemoX Design System/ui_kits/mobile/specs',
);

const args = process.argv.slice(2);
const check = args.includes('--check');
const asJson = args.includes('--json');

if (!existsSync(SPECS)) {
  console.error(`parity/token_lint: missing specs dir ${SPECS}`);
  process.exit(2);
}

// Specs where bare #rrggbb is legitimate content (e.g. a theme/appearance
// screen that DISPLAYS color swatches). Sourced from parity-map.json so the
// allowlist lives in one contract.
let allow = [];
try {
  const mapPath = join(HERE, 'parity-map.json');
  if (existsSync(mapPath)) allow = JSON.parse(readFileSync(mapPath, 'utf8')).tokenLintAllow ?? [];
} catch {
  allow = [];
}
const isAllowed = (file) => allow.some((id) => file === `${id}.md`);

const files = readdirSync(SPECS).filter(
  (f) => f.endsWith('.md') && f !== 'INDEX.md',
);

const BARE_HEX = /#[0-9a-fA-F]{6}\b/g;
const TOKEN_REF = /\b(?:bg|color|border-[trbl]?):([a-z][\w-]*)/g;

const gaps = [];
const tokens = new Map();

for (const file of files) {
  const text = readFileSync(join(SPECS, file), 'utf8');
  const lines = text.split('\n');
  const allowed = isAllowed(file);
  lines.forEach((line, i) => {
    let m;
    if (!allowed) {
      BARE_HEX.lastIndex = 0;
      while ((m = BARE_HEX.exec(line))) {
        gaps.push({ file, line: i + 1, hex: m[0] });
      }
    }
    TOKEN_REF.lastIndex = 0;
    while ((m = TOKEN_REF.exec(line))) {
      // Skip scalar-ish captures (e.g. border widths already excluded by the
      // [a-z] anchor); keep only real token names.
      if (m[1] === 'px') continue;
      tokens.set(m[1], (tokens.get(m[1]) ?? 0) + 1);
    }
  });
}

const inventory = [...tokens.entries()].sort((a, b) => b[1] - a[1]);

if (asJson) {
  console.log(JSON.stringify({ gaps, inventory }, null, 2));
} else {
  console.log('# UI-kit token lint (deterministic — no AI)\n');
  console.log(`## Bare-hex GAPS (un-tokenized colors): ${gaps.length}`);
  for (const g of gaps) console.log(`  ${g.file}:${g.line}  ${g.hex}`);
  if (!gaps.length) console.log('  (none — every color in specs is a named token or a token@opacity tint)');
  console.log(`\n## Color-token inventory (${inventory.length} distinct):`);
  for (const [name, n] of inventory) console.log(`  ${String(n).padStart(4)}  ${name}`);
  console.log(
    '\nCross-check each token against docs/design/design-token-mapping.md + the Dart theme layer.',
  );
}

if (check && gaps.length) {
  console.error(`\nparity/token_lint: FAIL — ${gaps.length} bare-hex gap(s) in specs.`);
  process.exit(1);
}
process.exit(0);
