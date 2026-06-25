#!/usr/bin/env node
// tool/parity/fe_node_usage.mjs — FE-side coverage check for data-mx-node
// (deterministic, no AI, no Flutter). The static counterpart to
// mxnode_coverage.mjs: that one asks "did the KIT tag enough nodes?"; this one
// asks "did the FLUTTER code CONSUME them?" by cross-checking the resolved kit
// contract against the actual `ValueKey('mx-node:<id>')` strings in lib/**.
//
// Three layers, no Flutter runtime:
//   - contractIds  : distinct ids from tool/parity/contracts/contracts.json
//                    (the resolved required set; gen_contract.mjs --check keeps it
//                    fresh in CI). Each id carries its owning screen(s).
//   - feIds        : distinct ids from a JS-regex scan of lib/**/*.dart for
//                    `mx-node:<id>` (read in Node — git grep -oE has no \w in
//                    POSIX ERE and silently truncates).
//   - jsxLiteralIds: literal `data-mx-node="<id>"` strings in the kit screens
//                    (supplementary; rescues an FE id from "orphan" when the kit
//                    DOES tag it but export_specs dropped the id: — a spec-lag, not
//                    an FE bug). `data-mx-node={node}` props are unresolved and
//                    ignored — contractIds already resolves those.
//
// Identity is SET-LEVEL (distinct id): shared ids (study-session/*,
// flashcard-editor/*) live under several screen contracts but are one identity
// rendered by a shared widget, so an id counts as consumed if it appears ANYWHERE
// in lib/**. Per-screen "right key on the right screen/state" stays with the
// runtime parity-contract widget tests (test/.../*_parity_test.dart) — this tool
// is the cheap always-on gate; those are the semantic layer.
//
// Classification:
//   MISSING  contract id with no FE key            → blocks --check
//   ORPHAN   FE key, no contract id, not in kit JSX → blocks --check
//   SPEC-LAG FE key, no contract id, but in kit JSX → warn only (re-export specs)
// Documented FE↔mock divergences are read from intent-ledger.json `exceptions`
// (the SAME ledger the parity tests honour — no parallel list): a MISSING/ORPHAN
// whose node-segment + screen matches an exception drops to `exempt` (kept
// visible) instead of blocking.
//
// Usage:
//   node tool/parity/fe_node_usage.mjs            # missing / orphan / spec-lag / exempt
//   node tool/parity/fe_node_usage.mjs --screen 17-study-result
//   node tool/parity/fe_node_usage.mjs --check    # exit 1 on any blocking missing/orphan
//   node tool/parity/fe_node_usage.mjs --json
//
// Exit: 0 ok, 1 gate fail (--check), 2 IO error.

import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const MAP = JSON.parse(readFileSync(join(HERE, 'parity-map.json'), 'utf8'));
const KIT = resolve(REPO, MAP.shotsDir, '..'); // .../ui_kits/mobile
const SCREENS = join(KIT, 'screens'); // kit JSX
const CONTRACTS = join(HERE, 'contracts', 'contracts.json');
const LIB = join(REPO, 'lib');

const args = process.argv.slice(2);
const opt = (n, d) => { const i = args.indexOf(n); return i >= 0 && args[i + 1] ? args[i + 1] : d; };
const onlyScreen = opt('--screen', null);
const check = args.includes('--check');
const asJson = args.includes('--json');

if (!existsSync(CONTRACTS)) {
  console.error(`fe_node_usage: missing ${CONTRACTS} — run \`node tool/parity/gen_contract.mjs\` first.`);
  process.exit(2);
}

// --- Layer 1: the resolved contract (id -> owning screens) -------------------
const CONTRACT = JSON.parse(readFileSync(CONTRACTS, 'utf8')).contracts || {};
const idScreens = new Map(); // id -> Set(screen)
for (const [screen, arr] of Object.entries(CONTRACT)) {
  for (const e of arr) {
    const id = e.key.replace(/^mx-node:/, '');
    (idScreens.get(id) ?? idScreens.set(id, new Set()).get(id)).add(screen);
  }
}
const contractIds = new Set(idScreens.keys());

// --- Layer 2: FE consumption (id -> source files) ----------------------------
const FE_RE = /mx-node:([A-Za-z0-9][\w/-]*)/g;
function walk(dir) {
  let out = [];
  for (const d of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, d.name);
    if (d.isDirectory()) out = out.concat(walk(p));
    else if (d.name.endsWith('.dart')) out.push(p);
  }
  return out;
}
const feLoc = new Map(); // id -> Set(relPath)
if (existsSync(LIB)) {
  for (const f of walk(LIB)) {
    const rel = f.slice(REPO.length + 1).split('\\').join('/');
    const text = readFileSync(f, 'utf8');
    let m;
    while ((m = FE_RE.exec(text))) {
      (feLoc.get(m[1]) ?? feLoc.set(m[1], new Set()).get(m[1])).add(rel);
    }
  }
}
const feIds = new Set(feLoc.keys());

// --- Layer 3: literal kit-JSX data-mx-node ids (spec-lag rescue) --------------
const JSX_RE = /data-mx-node=["']([^"'{}]+)["']/g;
const jsxLiteral = new Set();
if (existsSync(SCREENS)) {
  for (const f of readdirSync(SCREENS).filter((x) => x.endsWith('.jsx'))) {
    const text = readFileSync(join(SCREENS, f), 'utf8');
    let m;
    while ((m = JSX_RE.exec(text))) jsxLiteral.add(m[1]);
  }
}

// --- Documented FE↔mock exceptions (reuse the parity ledger) -----------------
// Match an id to an `exceptions` entry by node-segment (the id's last path
// segment, which is what the ledger's `node` field names) + screen. For a MISSING
// id every owning screen must be excepted (so a still-required screen keeps it
// blocking); an ORPHAN has no contract screen, so a node-segment documented as an
// intentional FE addition on ANY screen exempts it.
const LEDGER = (() => {
  try { return JSON.parse(readFileSync(join(HERE, 'intent-ledger.json'), 'utf8')); }
  catch { return {}; }
})();
const EXC = Array.isArray(LEDGER.exceptions) ? LEDGER.exceptions : [];
const seg = (id) => id.slice(id.lastIndexOf('/') + 1);
const excMatch = (screen, id) => EXC.filter(
  (e) => (!screen || e.screen === screen) && seg(id).startsWith(e.node),
);
function missingExemption(id) {
  const screens = [...(idScreens.get(id) ?? [])];
  if (!screens.length) return null;
  const hits = screens.map((s) => excMatch(s, id)[0]).filter(Boolean);
  return hits.length === screens.length ? hits[0] : null; // every owning screen excepted
}
function orphanExemption(id) {
  return excMatch(null, id)[0] ?? null;
}

// --- Classify ----------------------------------------------------------------
const missing = []; // {id, screens, exempt?}
for (const id of [...contractIds].sort()) {
  if (feIds.has(id)) continue;
  if (onlyScreen && !(idScreens.get(id) ?? new Set()).has(onlyScreen)) continue;
  const ex = missingExemption(id);
  missing.push({ id, screens: [...(idScreens.get(id) ?? [])].sort(), exempt: ex });
}
const orphan = []; // {id, files, exempt?, specLag}
for (const id of [...feIds].sort()) {
  if (contractIds.has(id)) continue;
  const specLag = jsxLiteral.has(id);
  const ex = specLag ? null : orphanExemption(id);
  orphan.push({ id, files: [...(feLoc.get(id) ?? [])].sort(), specLag, exempt: ex });
}

const missingBlock = missing.filter((r) => !r.exempt);
const missingExempt = missing.filter((r) => r.exempt);
const orphanBlock = orphan.filter((r) => !r.specLag && !r.exempt);
const orphanExempt = orphan.filter((r) => !r.specLag && r.exempt);
const specLag = orphan.filter((r) => r.specLag); // never shown when --screen (global)
const blocking = missingBlock.length + orphanBlock.length;

if (asJson) {
  console.log(JSON.stringify({
    totals: {
      contractIds: contractIds.size,
      feIds: feIds.size,
      missingBlock: missingBlock.length,
      orphanBlock: orphanBlock.length,
      specLag: specLag.length,
      exempt: missingExempt.length + orphanExempt.length,
    },
    missing, orphan,
  }, null, 2));
  process.exit(check && blocking ? 1 : 0);
}

// --- Report ------------------------------------------------------------------
console.log('# data-mx-node FE usage (Flutter side, deterministic — no AI)\n');
const list = (rows, render) => rows.length
  ? rows.map((r) => `  - ${render(r)}`).join('\n')
  : '  (none)';

console.log(`## MISSING — required by kit contract, no ValueKey in lib/** (${missingBlock.length})`);
console.log(list(missingBlock, (r) => `${r.id}  [${r.screens.join(', ')}]`));
console.log('');
if (!onlyScreen) {
  console.log(`## ORPHAN — ValueKey in lib/** with no kit contract id (${orphanBlock.length})`);
  console.log(list(orphanBlock, (r) => `${r.id}  @ ${r.files.join(', ')}`));
  console.log('');
  console.log(`## SPEC-LAG — FE key IS tagged in kit JSX but missing from the spec export (${specLag.length})`);
  console.log('   → re-export specs so the contract carries it (not an FE bug).');
  console.log(list(specLag, (r) => `${r.id}  @ ${r.files.join(', ')}`));
  console.log('');
}
console.log(`## EXEMPT — documented FE↔mock divergence in intent-ledger.json (${missingExempt.length + orphanExempt.length})`);
console.log(list([...missingExempt, ...orphanExempt], (r) =>
  `${r.id}  (${r.exempt.exceptionKind}) — ${r.exempt.source}`));
console.log('');

console.log(`Summary: ${contractIds.size} contract id(s) · ${feIds.size} keyed in FE · `
  + `${missingBlock.length} missing · ${orphanBlock.length} orphan · ${specLag.length} spec-lag · `
  + `${missingExempt.length + orphanExempt.length} exempt.`);
console.log('Identity is set-level (an id counts as consumed if keyed anywhere in lib/**); the per-screen');
console.log('"right key, right state" check stays with test/**/*_parity_test.dart. Exemptions: intent-ledger.json `exceptions`.');

if (check && blocking) {
  console.error(`\nfe_node_usage: FAIL — ${blocking} blocking item(s) (${missingBlock.length} missing, ${orphanBlock.length} orphan). `
    + 'Key the widget in lib/**, or add a documented exception to tool/parity/intent-ledger.json.');
  process.exit(1);
}
process.exit(0);
