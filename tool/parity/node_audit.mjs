#!/usr/bin/env node
// tool/parity/node_audit.mjs — run the per-node divergence log (golden_diff
// --spec) for EVERY `current` screen/state in parity-map.json and aggregate the
// MISSING? / COLOR? / SHIFT? classification across the whole app (deterministic).
//
// This is the app-wide view of `diff.py --spec`: where each screen's nodes are
// missing-in-render (solid blocks only — see diff.py for the honest limit), wrong
// colour, or shifted. The visual JUDGEMENT still belongs to ui-parity-checker.
//
// Usage:
//   node tool/parity/node_audit.mjs                # markdown summary, both themes
//   node tool/parity/node_audit.mjs --theme dark   # one theme
//   node tool/parity/node_audit.mjs --screen 02-dashboard
//   node tool/parity/node_audit.mjs --missing      # only list MISSING? nodes
//   node tool/parity/node_audit.mjs --tolerance 24 # forwarded to diff.py
//   node tool/parity/node_audit.mjs --json
//
// Exit: 0 ok, 2 config/IO error. (Reporting tool — no gate; use report.mjs --check.)

import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const MAP_PATH = join(HERE, 'parity-map.json');
const DIFF_PY = join(REPO, 'tool', 'golden_diff', 'diff.py');
const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';

const args = process.argv.slice(2);
const opt = (n, d) => {
  const i = args.indexOf(n);
  return i >= 0 && args[i + 1] ? args[i + 1] : d;
};
const asJson = args.includes('--json');
const onlyMissing = args.includes('--missing');
const onlyScreen = opt('--screen', null);
const tolerance = opt('--tolerance', '24');
const themes = opt('--theme', null) ? [opt('--theme', null)] : ['light', 'dark'];

const die = (m) => { console.error(`parity/node_audit: ${m}`); process.exit(2); };
if (!existsSync(MAP_PATH)) die(`missing ${MAP_PATH}`);
if (!existsSync(DIFF_PY)) die(`missing ${DIFF_PY}`);

const map = JSON.parse(readFileSync(MAP_PATH, 'utf8'));
const shotsDir = join(REPO, map.shotsDir);
const specsDir = resolve(shotsDir, '..', 'specs');

const STATUS = /^\s*(MISSING\?|COLOR\?|SHIFT\?)\s+(\S+)\s+\[(\d+),(\d+)\s+(\d+)x(\d+)\]/;

/** Run diff.py --spec once; return {missing:[], color:n, shift:n} or null. */
function auditOne(goldenAbs, shotAbs, specAbs) {
  if (!existsSync(goldenAbs) || !existsSync(shotAbs) || !existsSync(specAbs)) return null;
  let out;
  try {
    out = execFileSync(
      pythonCmd,
      [DIFF_PY, goldenAbs, shotAbs, '--threshold', '100', '--tolerance', tolerance,
        '--spec', specAbs, '--top', '999'],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] },
    );
  } catch {
    return null;
  }
  const res = { missing: [], color: 0, shift: 0 };
  for (const line of out.split('\n')) {
    const m = STATUS.exec(line);
    if (!m) continue;
    if (m[1] === 'MISSING?') res.missing.push(`${m[2]}[${m[3]},${m[4]} ${m[5]}x${m[6]}]`);
    else if (m[1] === 'COLOR?') res.color++;
    else res.shift++;
  }
  return res;
}

const rows = [];
const totals = { missing: 0, color: 0, shift: 0, states: 0, skipped: 0 };

for (const screen of map.screens) {
  if (onlyScreen && screen.id !== onlyScreen) continue;
  const specAbs = join(specsDir, `${screen.id}.md`);
  for (const st of screen.states ?? []) {
    if ((st.scope ?? 'current') !== 'current') continue;
    for (const theme of themes) {
      const goldenAbs = join(REPO, `${st.golden}__${theme}.png`);
      const shotAbs = join(shotsDir, `${screen.id}--${st.kit}--${theme}.png`);
      const r = auditOne(goldenAbs, shotAbs, specAbs);
      if (!r) { totals.skipped++; continue; }
      totals.states++;
      totals.missing += r.missing.length;
      totals.color += r.color;
      totals.shift += r.shift;
      rows.push({ screen: screen.id, state: st.kit, theme, ...r });
    }
  }
}

if (asJson) {
  console.log(JSON.stringify({ rows, totals }, null, 2));
  process.exit(0);
}

console.log('# App-wide per-node audit (deterministic — no AI)\n');
if (onlyMissing) {
  console.log('Only nodes flagged MISSING? (solid block in mock, blank in render):\n');
  for (const r of rows) {
    if (!r.missing.length) continue;
    console.log(`- **${r.screen} · ${r.state} · ${r.theme}** → ${r.missing.join(', ')}`);
  }
} else {
  console.log('| Screen | State | Theme | MISSING? | COLOR? | SHIFT? | MISSING nodes |');
  console.log('| --- | --- | --- | --- | --- | --- | --- |');
  for (const r of rows) {
    console.log(
      `| ${r.screen} | ${r.state} | ${r.theme} | ${r.missing.length} | ${r.color} | ${r.shift} | ${r.missing.join(', ') || ''} |`,
    );
  }
}
console.log(
  `\nTotals across ${totals.states} state×theme runs: ${totals.missing} MISSING? · ` +
    `${totals.color} COLOR? · ${totals.shift} SHIFT?` +
    `${totals.skipped ? ` · ${totals.skipped} skipped (no golden/shot/spec)` : ''}.`,
);
console.log(
  '\nMISSING? is high-precision for SOLID blocks only; sparse text/icons are NOT flagged ' +
    '(see tool/golden_diff/diff.py). Visual verdict: ui-parity-checker.',
);
process.exit(0);
