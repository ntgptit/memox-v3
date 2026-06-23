#!/usr/bin/env node
// tool/parity/structural_inventory.mjs — STRUCTURAL parity inventory (no pixels,
// no AI): for each content-bearing node the spec declares, is anything actually
// rendered in its box? Compares a widget-tree dump (test/_parity_dump/<name>.json,
// produced by test/support/structural_dump.dart on the 390×780 frame) against the
// node bboxes in specs/NN-*.md by GEOMETRY.
//
// Why geometry: it catches a MISSING node even on a dark theme where the pixel
// colour ≈ background (golden_diff's blind spot) and for text/icons, not just
// solid fills.
//
// Usage:
//   node tool/parity/structural_inventory.mjs --dump <dump.json> --spec <spec.md>
//        [--cover 0.3]    # min fraction of a node's box covered to count as present
//        [--viewport 780] # frame height; nodes below the fold (y+h > this) and
//                         # shell nodes (--exclude) are NOT checked, only reported
//        [--exclude bottom-nav,nav-ind]  # node-name prefixes owned by the app
//                         # shell, not the screen pumped in isolation
//        [--json]
//
// Exit: 0 ok, 2 IO/usage error. (Reporting tool — no gate by default.)

import { existsSync, readFileSync } from 'node:fs';
import { basename, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import process from 'node:process';

const HERE = dirname(fileURLToPath(import.meta.url));

const args = process.argv.slice(2);
const opt = (n, d) => {
  const i = args.indexOf(n);
  return i >= 0 && args[i + 1] ? args[i + 1] : d;
};
const dumpPath = opt('--dump', null);
const specPath = opt('--spec', null);
const cover = Number(opt('--cover', '0.3'));
const viewport = Number(opt('--viewport', '780'));
const exclude = opt('--exclude', 'bottom-nav,nav-ind').split(',').filter(Boolean);
const asJson = args.includes('--json');

const die = (m) => { console.error(`parity/structural_inventory: ${m}`); process.exit(2); };
if (!dumpPath || !specPath) die('need --dump <json> and --spec <md>');
if (!existsSync(dumpPath)) die(`missing dump ${dumpPath}`);
if (!existsSync(specPath)) die(`missing spec ${specPath}`);

const ABS = /abs:\s*\[(\d+),(\d+)\s+(\d+)x(\d+)\]/;
const NODE = /node:\s*(\S+)/;

/** Parse spec md into per-node {name, x,y,w,h, style, text}, deduped. */
function parseSpec(md) {
  const out = [];
  let cur = null;
  for (const raw of md.split('\n')) {
    const s = raw.trim().replace(/^[-+]\s*/, '');
    const n = NODE.exec(s);
    if (n) { if (cur) out.push(cur); cur = { name: n[1], abs: null, style: '', text: null }; continue; }
    if (!cur) continue;
    if (!cur.abs) {
      const a = ABS.exec(s);
      if (a) cur.abs = a.slice(1, 5).map(Number);
    }
    if (cur.text == null && s.startsWith('text:')) cur.text = s.slice(5).trim();
    if (!cur.style && s.startsWith('style:')) cur.style = s.slice(6).trim();
  }
  if (cur) out.push(cur);
  const seen = new Set();
  return out.filter((nd) => {
    if (!nd.abs) return false;
    const k = `${nd.name}|${nd.abs.join(',')}`;
    if (seen.has(k)) return false;
    seen.add(k);
    return true;
  });
}

/** A node the user should SEE something in: text / icon / typographic / filled. */
function isContentNode(nd) {
  if (nd.text) return true;
  if (/^icon[:\-]/.test(nd.name)) return true;
  if (/\bfont:/.test(nd.style)) return true;
  if (/\bbg:/.test(nd.style)) return true;
  return false;
}

function coverage(nd, r) {
  const [x, y, w, h] = nd.abs;
  const ix = Math.max(0, Math.min(x + w, r.x + r.w) - Math.max(x, r.x));
  const iy = Math.max(0, Math.min(y + h, r.y + r.h) - Math.max(y, r.y));
  return (ix * iy) / (w * h);
}

function rendered(nd, rects) {
  const [x, y, w, h] = nd.abs;
  const cx = x + w / 2;
  const cy = y + h / 2;
  for (const r of rects) {
    if (cx >= r.x && cx <= r.x + r.w && cy >= r.y && cy <= r.y + r.h) return true;
    if (coverage(nd, r) >= cover) return true;
  }
  return false;
}

const isShell = (nd) => exclude.some((p) => nd.name.startsWith(p));
const inViewport = (nd) => nd.abs[1] + nd.abs[3] <= viewport;

// Source of truth = the mock's shots/specs; a divergence is a FIX by default.
// The intent ledger holds ONLY documented exceptions (behavior/future/rejected/
// needs-schema) — a node matching one is an exception, everything else is FIX.
const screenId = basename(specPath).replace(/\.md$/, '');
let ledger = [];
try {
  const lp = join(HERE, 'intent-ledger.json');
  if (existsSync(lp)) ledger = JSON.parse(readFileSync(lp, 'utf8')).exceptions ?? [];
} catch { ledger = []; }
function classify(name, kind) {
  const hit = ledger.find(
    (e) => e.screen === screenId
      && (e.node === '*' || name.startsWith(e.node))
      && (e.kind === '*' || e.kind === kind),
  );
  return hit
    ? { verdict: 'exception', source: `${hit.exceptionKind}: ${hit.source}` }
    : { verdict: 'FIX', source: null };
}

let rects;
try { rects = JSON.parse(readFileSync(dumpPath, 'utf8')); } catch (e) { die(`bad dump JSON: ${e.message}`); }
const nodes = parseSpec(readFileSync(specPath, 'utf8'));
const content = nodes.filter(isContentNode);

// Only nodes that should actually be in the dump are checkable: within the
// pumped viewport AND not owned by the app shell (the screen is pumped alone).
const checkable = content.filter((nd) => inViewport(nd) && !isShell(nd));
const belowFold = content.filter((nd) => !inViewport(nd) && !isShell(nd)).length;
const shell = content.filter(isShell).length;

const missing = [];
for (const nd of checkable) {
  if (!rendered(nd, rects)) {
    const [x, y, w, h] = nd.abs;
    const cls = classify(nd.name, 'missing');
    missing.push({
      name: nd.name, bbox: `[${x},${y} ${w}x${h}]`,
      intended: nd.style || (nd.text ? `text:"${nd.text}"` : '—'),
      verdict: cls.verdict, source: cls.source,
    });
  }
}
const bugs = missing.filter((m) => m.verdict === 'FIX').length;
const screenLedger = ledger.filter((e) => e.screen === screenId);

if (asJson) {
  console.log(JSON.stringify({
    dump: dumpPath, spec: specPath, viewport, screen: screenId,
    checkable: checkable.length, rendered: checkable.length - missing.length,
    missing, bugs, skipped: { belowFold, shell }, ledger: screenLedger,
  }, null, 2));
  process.exit(0);
}

console.log('# Structural inventory (geometry — no pixels, no AI)\n');
console.log(`dump: ${dumpPath}`);
console.log(`spec: ${specPath}`);
console.log(
  `checkable content nodes: ${checkable.length} · rendered: ${checkable.length - missing.length} · ` +
  `MISSING: ${missing.length}  (skipped: ${belowFold} below-fold, ${shell} app-shell)\n`,
);
if (!missing.length) {
  console.log('No structurally-missing content nodes in the viewport — every checkable spec node has a rendered box.');
} else {
  console.log(`Spec nodes with NOTHING rendered in their box — ${bugs} to FIX, ${missing.length - bugs} documented exception:`);
  for (const m of missing) {
    const tag = m.verdict === 'exception' ? `exception (${m.source})` : 'FIX';
    console.log(`  [${tag}] ${m.name.padEnd(20)} ${m.bbox.padEnd(16)} intended: ${m.intended}`);
  }
  console.log('\nFIX = diverges from the mock (source of truth) → fix the FE. Only a documented');
  console.log('exception (behavior/future/rejected/needs-schema, with a doc) belongs in intent-ledger.json.');
}
if (screenLedger.length) {
  console.log(`\nDocumented exceptions (ledger) for ${screenId}:`);
  for (const e of screenLedger) console.log(`  - ${e.node}/${e.kind}: ${e.exceptionKind} — ${e.reason}`);
}
process.exit(0);
