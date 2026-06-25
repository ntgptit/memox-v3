#!/usr/bin/env node
// tool/parity/fe_node_coverage.mjs — FE-side EXTRA-coverage probe (deterministic,
// no AI, no Flutter). Closes the blind spot in the completeness contract:
//
//   mxnode_coverage.mjs  → did the KIT tag every significant node?      (MISSING comprehensiveness)
//   fe_node_usage.mjs    → MISSING (kit id not keyed) + ORPHAN (FE key not in kit)
//   THIS                 → did the FE KEY every significant component?  (EXTRA comprehensiveness)
//
// The hole it exposes: `fe_node_usage` ORPHAN only sees an extra element that
// carries an `mx-node` ValueKey. A significant FE component rendered with NO key
// — a card/CTA the kit never designed, added by hand — is invisible to every gate.
// This lists those: an "identity" shared component (MxCard / MxActionButton /
// MxPrimaryButton / MxSecondaryButton / MxFab / MxSearchDock) instantiated in a
// feature WITHOUT a nearby `ValueKey('mx-node:…')`. Each is a candidate EXTRA — to
// be either keyed (so ORPHAN can vet it against the kit) or marked a legitimate
// non-identity use (list item / decorative / nested in a keyed parent).
//
// Report-first by design: the legit-unkeyed set (list items, sub-cards) is large,
// so the gate (`--check`) trips only on instances NOT covered by an allow-marker.
// Mark a legit non-identity use by putting `// mx-node:none` on the component's
// line (or the line above) — an explicit, greppable opt-out, the FE mirror of the
// kit's intent-ledger.coverageExempt.
//
// Usage:
//   node tool/parity/fe_node_coverage.mjs            # per-component keyed/unkeyed + unkeyed list
//   node tool/parity/fe_node_coverage.mjs --check    # exit 1 on unkeyed, unmarked identity components
//   node tool/parity/fe_node_coverage.mjs --json

import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const FEATURES = join(REPO, 'lib', 'presentation', 'features');

const args = process.argv.slice(2);
const check = args.includes('--check');
const asJson = args.includes('--json');

// "Identity" shared components: STRUCTURAL elements a user perceives as a distinct
// section/surface on a screen (the kit maps these to nodes). Deliberately narrow:
// buttons (MxPrimaryButton/MxSecondaryButton/MxActionButton) are excluded because
// they are dominated by dialog/form actions that the kit does NOT tag (dialogs are
// shared overlays) — including them floods the signal. Atoms (MxIconTile,
// MxIconButton, MxText) are excluded too — they nest inside these. A rogue CARD/
// SURFACE the kit never designed is the high-signal EXTRA case this catches.
const IDENTITY = ['MxCard', 'MxFab', 'MxSearchDock', 'MxBottomNav'];
const KEY_WINDOW = 160; // chars after `Component(` to look for an mx-node key
const ALLOW = /mx-node:none/; // explicit "legitimate non-identity use" marker

function walk(dir, out = []) {
  for (const d of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, d.name);
    if (d.isDirectory()) walk(p, out);
    else if (d.name.endsWith('.dart') && !d.name.endsWith('.g.dart') && !d.name.endsWith('.freezed.dart')) out.push(p);
  }
  return out;
}

const rel = (f) => f.slice(REPO.length + 1).split('\\').join('/');
const lineAt = (text, idx) => text.slice(0, idx).split('\n').length;

const perComp = Object.fromEntries(IDENTITY.map((c) => [c, { keyed: 0, unkeyed: 0, allowed: 0 }]));
const unkeyed = []; // {component, file, line}

for (const f of walk(FEATURES)) {
  const text = readFileSync(f, 'utf8');
  const lines = text.split('\n');
  for (const comp of IDENTITY) {
    const re = new RegExp(`\\b${comp}\\s*\\(`, 'g');
    let m;
    while ((m = re.exec(text)) !== null) {
      const win = text.slice(m.index, m.index + KEY_WINDOW);
      const ln = lineAt(text, m.index);
      const prev = lines[ln - 2] ?? ''; // line above (1-based ln)
      const cur = lines[ln - 1] ?? '';
      if (/mx-node:[a-z0-9/-]+/.test(win) && !/mx-node:none/.test(win)) {
        perComp[comp].keyed++;
      } else if (ALLOW.test(cur) || ALLOW.test(prev) || ALLOW.test(win)) {
        perComp[comp].allowed++;
      } else {
        perComp[comp].unkeyed++;
        unkeyed.push({ component: comp, file: rel(f), line: ln });
      }
    }
  }
}

const totUnkeyed = unkeyed.length;
const totKeyed = Object.values(perComp).reduce((a, c) => a + c.keyed, 0);
const totAllowed = Object.values(perComp).reduce((a, c) => a + c.allowed, 0);

if (asJson) {
  console.log(JSON.stringify({ perComp, unkeyed, totals: { keyed: totKeyed, allowed: totAllowed, unkeyed: totUnkeyed } }, null, 2));
  process.exit(check && totUnkeyed ? 1 : 0);
}

console.log('# FE EXTRA-coverage probe (identity shared-components without an mx-node key)\n');
console.log('| Component | keyed | unkeyed | allowed (`mx-node:none`) |');
console.log('| --- | --- | --- | --- |');
for (const c of IDENTITY) {
  const r = perComp[c];
  console.log(`| ${c} | ${r.keyed} | ${r.unkeyed} | ${r.allowed} |`);
}
console.log(`\nUnkeyed identity components (candidate EXTRA — key it so ORPHAN can vet it vs the kit, or mark \`// mx-node:none\` if a legit list-item/nested/decorative use): ${totUnkeyed}`);
for (const u of unkeyed.slice(0, 40)) console.log(`  - ${u.component}  @ ${u.file}:${u.line}`);
if (totUnkeyed > 40) console.log(`  …+${totUnkeyed - 40} more`);
console.log(`\nTotals: ${totKeyed} keyed · ${totAllowed} allowed · ${totUnkeyed} unkeyed. `
  + 'An unkeyed identity component is the one EXTRA case fe_node_usage ORPHAN cannot see.');

if (check && totUnkeyed) {
  console.error(`\nfe_node_coverage: FAIL — ${totUnkeyed} unkeyed identity component(s). `
    + 'Add ValueKey(\'mx-node:<screen>/<node>\') (then it is vetted by fe_node_usage), or mark `// mx-node:none`.');
  process.exit(1);
}
process.exit(0);
