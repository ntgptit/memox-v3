#!/usr/bin/env node
// tool/parity/structural_audit.mjs — APP-WIDE structural bug count (no pixels, no
// AI). For every `current` screen/state in parity-map.json that has a widget-tree
// dump (test/_parity_dump/<golden-basename>__<theme>.json, produced by the golden
// tests via test/support/structural_dump.dart), runs structural_inventory.mjs and
// totals the structurally-missing nodes classified FIX (bug) vs exception (ledger).
//
// This is the deterministic answer to "how many bugs must we fix?": a FIX is a
// spec node the mock declares that the FE renders NOTHING in — a real divergence
// from the source of truth (shots/specs).
//
// Usage:
//   node tool/parity/structural_audit.mjs            # markdown table + totals
//   node tool/parity/structural_audit.mjs --json
//   node tool/parity/structural_audit.mjs --bugs     # list every FIX node
//   node tool/parity/structural_audit.mjs --check    # exit 1 if any FIX bug
//
// Exit: 0 ok, 1 bugs found (--check), 2 IO error.

import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { basename, dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const MAP_PATH = join(HERE, 'parity-map.json');
const INV = join(HERE, 'structural_inventory.mjs');
const DUMP_DIR = join(REPO, 'test', '_parity_dump');

const args = process.argv.slice(2);
const asJson = args.includes('--json');
const listBugs = args.includes('--bugs');
const check = args.includes('--check');

const die = (m) => { console.error(`parity/structural_audit: ${m}`); process.exit(2); };
if (!existsSync(MAP_PATH)) die(`missing ${MAP_PATH}`);

const map = JSON.parse(readFileSync(MAP_PATH, 'utf8'));
const shotsDir = join(REPO, map.shotsDir);
const specsDir = resolve(shotsDir, '..', 'specs');
const themes = ['light', 'dark'];

const rows = [];
const allBugs = [];
const totals = { checkable: 0, fix: 0, exception: 0, runs: 0, noDump: 0 };

for (const screen of map.screens) {
  const specAbs = join(specsDir, `${screen.id}.md`);
  if (!existsSync(specAbs)) continue;
  for (const st of screen.states ?? []) {
    if ((st.scope ?? 'current') !== 'current' || !st.golden) continue;
    const base = basename(st.golden);
    for (const theme of themes) {
      const dump = join(DUMP_DIR, `${base}__${theme}.json`);
      if (!existsSync(dump)) { totals.noDump++; continue; }
      let out;
      try {
        out = execFileSync('node', [INV, '--dump', dump, '--spec', specAbs, '--json'],
          { encoding: 'utf8' });
      } catch { totals.noDump++; continue; }
      const r = JSON.parse(out);
      const fix = r.missing.filter((m) => m.verdict === 'FIX');
      const exc = r.missing.length - fix.length;
      totals.runs++;
      totals.checkable += r.checkable;
      totals.fix += fix.length;
      totals.exception += exc;
      for (const b of fix) allBugs.push({ screen: screen.id, state: st.kit, theme, ...b });
      rows.push({ screen: screen.id, state: st.kit, theme, checkable: r.checkable, fix: fix.length, exception: exc });
    }
  }
}

if (asJson) {
  console.log(JSON.stringify({ rows, bugs: allBugs, totals }, null, 2));
  process.exit(check && totals.fix ? 1 : 0);
}

console.log('# App-wide structural bug count (deterministic — no AI)\n');
if (listBugs) {
  if (!allBugs.length) console.log('No FIX bugs — every checkable spec node is rendered.');
  for (const b of allBugs) {
    console.log(`- ${b.screen} · ${b.state} · ${b.theme} → ${b.name} ${b.bbox}  intended: ${b.intended}`);
  }
} else {
  console.log('| Screen | State | Theme | checkable | FIX (bug) | exception |');
  console.log('| --- | --- | --- | --- | --- | --- |');
  for (const r of rows) {
    const mark = r.fix ? `**${r.fix}**` : '0';
    console.log(`| ${r.screen} | ${r.state} | ${r.theme} | ${r.checkable} | ${mark} | ${r.exception} |`);
  }
}
console.log(
  `\nTOTAL BUGS TO FIX: ${totals.fix} structurally-missing node(s) across ${totals.runs} state×theme runs ` +
    `(${totals.checkable} checkable nodes · ${totals.exception} documented exceptions · ${totals.noDump} runs skipped, no dump).`,
);
if (totals.fix) console.log('Run with --bugs to list them; each is a spec node the FE renders nothing in → fix the FE.');
console.log('Note: covers only states with a structural dump; add a dumpStructure hook per screen to widen coverage.');

process.exit(check && totals.fix ? 1 : 0);
