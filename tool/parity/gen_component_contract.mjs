// gen_component_contract.mjs — Phase-1 of the visual-parity plan
// (docs/design/visual-parity-plan.md §4, Phase 1).
//
// Generates tool/parity/contracts/component-contracts.json: the ONE source for the
// kit spec NUMBERS that the per-component spec-gate tests assert against (instead of
// each test hardcoding its own constant). Today it extracts the TEXT typography
// (fontSize / fontWeight) of each `mx:<Component>` node; geometry (height/radius/
// padding) follows once Phase-0 box-model calibration lands.
//
// HOW it finds the font: from the node's OWN `style:` line ONLY — the lines from the
// `mx:` line up to its FIRST descendant `- node:` (it does NOT descend into children).
// Buttons carry their font on the node itself
// (`mx:MxSecondaryButton … style:… font:14/700`). A component whose own style has no
// font — e.g. the app bar, whose `mx:MxAppBar` node is `style: bg:bg` and whose title
// font lives on a DESCENDANT — is reported `no-font`. Descendant/title-font extraction
// is NOT implemented: it is a deliberate follow-up (plan §3.1, the spec-number-
// derivation gotcha — it needs per-node title/label disambiguation).
//
// VARIANT-SPLIT (plan §1/§3): we collect the DISTINCT (size,weight) pairs a component
// shows across all its spec nodes. One distinct pair → a clean contract. More than
// one → `status: "needs-variant"` with every observed pair listed — we NEVER average.
// A component whose nodes carry no font → `status: "no-font"` (not fabricated).
//
// Usage:
//   node tool/parity/gen_component_contract.mjs           # report (no write)
//   node tool/parity/gen_component_contract.mjs --write   # (re)generate the JSON
//   node tool/parity/gen_component_contract.mjs --check    # freshness gate (CI/verify)

import { existsSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const SPECS_DIR = join(repoRoot, 'docs/system-design/MemoX Design System/ui_kits/mobile/specs');
const OUT = join(repoRoot, 'tool/parity/contracts/component-contracts.json');

const indentOf = (line) => line.length - line.trimStart().length;
const fontRe = /\bfont:(\d+(?:\.\d+)?)\/(\d+)/; // font:SIZE/WEIGHT

function specFiles() {
  return readdirSync(SPECS_DIR)
    .filter((n) => /^\d.*\.md$/.test(n))
    .sort()
    .map((n) => join(SPECS_DIR, n));
}

/** The `font:N/W` on the node's OWN style — the lines from the `mx:` line (index `i`,
 *  indent `mxIndent`) up to its FIRST descendant `- node:` (or the block end). We do
 *  NOT descend into children: a child's font (an app-bar title, a list-row label)
 *  belongs to that child, not to this component, and mixing them produced spurious
 *  `needs-variant` for every component. Components whose own style carries no font
 *  (e.g. MxAppBar's `style:bg:bg`, where the title font lives on a descendant) return
 *  null → `no-font`; their descendant-font extraction is a documented follow-up
 *  (plan §3.1, the spec-number-derivation gotcha). */
function ownFont(lines, i, mxIndent) {
  for (let j = i; j < lines.length; j++) {
    const line = lines[j];
    const t = line.trim();
    if (j > i && t.startsWith('- node:')) break; // first descendant → own props end
    if (j > i && t && indentOf(line) < mxIndent) break; // block ended
    const m = line.match(fontRe);
    if (m) return { fontSize: Number(m[1]), fontWeight: Number(m[2]) };
  }
  return null;
}

/** component -> { pairs: Map<"size/weight", {fontSize,fontWeight,count}>, sources:Set } */
function collect() {
  const comps = new Map();
  const mxRe = /\bmx:\s*(Mx[A-Za-z0-9]+)\b/;
  for (const f of specFiles()) {
    const base = f.split(/[\\/]/).pop();
    const lines = readFileSync(f, 'utf8').split('\n');
    for (let i = 0; i < lines.length; i++) {
      const m = lines[i].match(mxRe);
      if (!m) continue;
      const comp = m[1];
      const font = ownFont(lines, i, indentOf(lines[i]));
      if (!comps.has(comp)) comps.set(comp, { pairs: new Map(), sources: new Set() });
      const rec = comps.get(comp);
      rec.sources.add(base);
      if (font) {
        const key = `${font.fontSize}/${font.fontWeight}`;
        const p = rec.pairs.get(key) || { ...font, count: 0 };
        p.count++;
        rec.pairs.set(key, p);
      }
    }
  }
  return comps;
}

function build() {
  const comps = collect();
  const out = {
    $generated:
      'by tool/parity/gen_component_contract.mjs --write — DO NOT hand-edit. One source for the kit spec NUMBERS the spec-gate tests assert (see docs/design/visual-parity-plan.md §4). Today: text typography only.',
    components: {},
  };
  for (const [comp, rec] of [...comps].sort()) {
    const pairs = [...rec.pairs.values()].sort((a, b) => b.count - a.count);
    const sources = [...rec.sources].sort();
    if (pairs.length === 0) {
      out.components[comp] = { status: 'no-font', sources };
    } else if (pairs.length === 1) {
      out.components[comp] = {
        status: 'ok',
        text: { fontSize: pairs[0].fontSize, fontWeight: pairs[0].fontWeight },
        sources,
      };
    } else {
      out.components[comp] = {
        status: 'needs-variant',
        observed: pairs.map((p) => ({ fontSize: p.fontSize, fontWeight: p.fontWeight, count: p.count })),
        sources,
      };
    }
  }
  return out;
}

const mode = process.argv.includes('--check')
  ? 'check'
  : process.argv.includes('--write')
    ? 'write'
    : 'report';
const data = build();
const json = JSON.stringify(data, null, 2) + '\n';

if (mode === 'write') {
  writeFileSync(OUT, json);
  console.log(`gen_component_contract: wrote ${OUT.replace(repoRoot, '').replace(/^[\\/]/, '')}`);
} else if (mode === 'check') {
  if (!existsSync(OUT) || readFileSync(OUT, 'utf8') !== json) {
    console.error('gen_component_contract: STALE — run `node tool/parity/gen_component_contract.mjs --write`.');
    process.exit(1);
  }
  console.log('gen_component_contract: fresh.');
} else {
  for (const [c, v] of Object.entries(data.components)) {
    const t = v.text ? `${v.text.fontSize}/${v.text.fontWeight}` : v.status;
    console.log(`  ${c.padEnd(24)} ${t}`);
  }
}
