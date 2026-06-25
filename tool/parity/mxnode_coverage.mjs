#!/usr/bin/env node
// tool/parity/mxnode_coverage.mjs — coverage check for data-mx-node tagging on the
// kit (deterministic, no AI). Answers "which meaningful kit nodes still lack a
// data-mx-node id?" so the rollout doesn't stop at a few singletons per screen.
//
// Candidate = a spec node the exporter mapped to a MemoX component (`mx:<Mx>`) or
// flagged as an unmapped interactive control (`mx: ?`) — i.e. a real, identity-worthy
// UI element — EXCEPT the structural shells in EXCLUDE (scaffold/app-bar/content-shell
// carry no per-instance identity) AND nodes listed in intent-ledger.coverageExempt
// (intentionally untagged: kit pre-redesign / Future / child of a tagged container).
// A candidate is "tagged" when its node block also has an `id:` line (data-mx-node →
// spec). Coverage = tagged / candidates per screen; exempt nodes are shown separately,
// not counted as gaps or in the --check denominator.
//
// Scope: the FE screens listed in parity-map.json (no-FE screens are out of scope).
//
// Usage:
//   node tool/parity/mxnode_coverage.mjs            # per-screen table + untagged list
//   node tool/parity/mxnode_coverage.mjs --screen 06-flashcard-list
//   node tool/parity/mxnode_coverage.mjs --check --min 100  # gate: every candidate
//                                                            # tagged or ledger-exempt
//   node tool/parity/mxnode_coverage.mjs --json
//
// Exit: 0 ok, 1 below --min (with --check), 2 IO error.

import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const MAP = JSON.parse(readFileSync(join(HERE, 'parity-map.json'), 'utf8'));
const SPECS = resolve(join(REPO, MAP.shotsDir), '..', 'specs');

// Documented tag-exemptions (intent-ledger.coverageExempt): kit candidates that are
// intentionally NOT given a data-mx-node id (kit pre-redesign / Future / decorative
// child of a tagged container). They are dropped from the gap list AND the --check
// denominator, but surfaced in an `exempt` column so they stay visible.
const EXEMPT = (() => {
  try {
    const j = JSON.parse(readFileSync(join(HERE, 'intent-ledger.json'), 'utf8'));
    return Array.isArray(j.coverageExempt) ? j.coverageExempt : [];
  } catch { return []; }
})();
const isExempt = (screenId, nd) => EXEMPT.some(
  (e) => e.screen === screenId && nd.name.startsWith(e.node) && (!e.mx || e.mx === nd.mx),
);

const args = process.argv.slice(2);
const opt = (n, d) => { const i = args.indexOf(n); return i >= 0 && args[i + 1] ? args[i + 1] : d; };
const onlyScreen = opt('--screen', null);
const check = args.includes('--check');
const minPct = Number(opt('--min', '0'));
const asJson = args.includes('--json');

// Structural / global-chrome shells: present on every screen, no per-instance,
// screen-specific identity (handle the bottom nav once at the app-shell level).
const EXCLUDE = new Set([
  'MxScaffold',
  'MxAppBar',
  'MxContentShell',
  'MxBottomNav',
]);

/**
 * The spec is "## Base state: …" followed by per-state sections (some FULL
 * re-renders). Counting across all of them makes a per-state singleton (the FAB,
 * the dock — present in every state) look REPEATED. Scope the candidate inventory
 * to the base-state section so each node is counted once. Falls back to the whole
 * file when there is no base-state header.
 */
function baseSection(md) {
  const lines = md.split('\n');
  const start = lines.findIndex((l) => /^##\s+Base state/i.test(l));
  if (start < 0) return md;
  let end = lines.length;
  for (let i = start + 1; i < lines.length; i += 1) {
    if (/^##\s/.test(lines[i])) { end = i; break; }
  }
  return lines.slice(start, end).join('\n');
}

const NODE = /node:\s*(\S+)/;
const MX = /\bmx:\s*(\S.*?)\s*$/;
const IDLINE = /\bid:\s*([A-Za-z0-9][\w/-]*)/;
const ABS = /abs:\s*\[(\d+),(\d+)\s+(\d+)x(\d+)\]/;

/** Per-node {name, mx, id, abs} for a spec. */
function parseNodes(md) {
  const out = [];
  let cur = null;
  for (const raw of md.split('\n')) {
    const s = raw.trim().replace(/^[-+]\s*/, '');
    const n = NODE.exec(s);
    if (n) { if (cur) out.push(cur); cur = { name: n[1], mx: null, id: null, abs: null }; continue; }
    if (!cur) continue;
    if (cur.mx == null) { const m = MX.exec(s); if (m) cur.mx = m[1]; }
    if (cur.id == null) { const i = IDLINE.exec(s); if (i) cur.id = i[1]; }
    if (cur.abs == null) { const a = ABS.exec(s); if (a) cur.abs = a.slice(1, 5).map(Number); }
  }
  if (cur) out.push(cur);
  return out;
}

const isCandidate = (nd) => nd.mx != null && !EXCLUDE.has(nd.mx);

if (!existsSync(SPECS)) { console.error(`mxnode_coverage: missing ${SPECS}`); process.exit(2); }

const rows = [];
let totCand = 0;
let totTagged = 0;
let totExempt = 0;
for (const screen of MAP.screens) {
  if (onlyScreen && screen.id !== onlyScreen) continue;
  const spec = join(SPECS, `${screen.id}.md`);
  if (!existsSync(spec)) continue;
  const nodes = parseNodes(baseSection(readFileSync(spec, 'utf8')));
  // Dedupe candidates by (name, abs) — a node recurs across state sections.
  const seen = new Set();
  const cands = [];
  for (const nd of nodes) {
    if (!isCandidate(nd)) continue;
    const key = `${nd.name}|${(nd.abs || []).join(',')}`;
    if (seen.has(key)) continue;
    seen.add(key);
    cands.push(nd);
  }
  // Split singletons (the real tag targets) from REPEATED list items (a node name
  // occurring more than once = a list/grid item — tag its container, never each
  // item: duplicate keys crash Flutter). Coverage is measured on singletons.
  const byName = new Map();
  for (const c of cands) byName.set(c.name, (byName.get(c.name) ?? 0) + 1);
  const singles = cands.filter((c) => byName.get(c.name) === 1);
  const repeated = cands.length - singles.length;
  const tagged = singles.filter((c) => c.id);
  // Untagged splits into documented-exempt (intent-ledger) and real gaps. Coverage %
  // and the --check denominator are measured on real candidates only (tagged + gaps).
  const untaggedAll = singles.filter((c) => !c.id);
  const exempt = untaggedAll.filter((c) => isExempt(screen.id, c));
  const untagged = untaggedAll.filter((c) => !isExempt(screen.id, c));
  const denom = tagged.length + untagged.length;
  totCand += denom;
  totTagged += tagged.length;
  totExempt += exempt.length;
  rows.push({
    screen: screen.id,
    candidates: denom,
    tagged: tagged.length,
    repeated,
    exempt: exempt.length,
    pct: denom ? Math.round((100 * tagged.length) / denom) : 100,
    untagged: untagged.map((u) => ({ node: u.name, mx: u.mx, bbox: u.abs ? `[${u.abs.join(',').replace(/,(\d+),(\d+)$/, ' $1x$2')}]` : '' })),
    exemptList: exempt.map((u) => ({ node: u.name, mx: u.mx })),
  });
}

const below = rows.filter((r) => r.candidates > 0 && r.pct < minPct);

if (asJson) {
  console.log(JSON.stringify({ rows, totals: { candidates: totCand, tagged: totTagged, exempt: totExempt } }, null, 2));
  process.exit(check && below.length ? 1 : 0);
}

console.log('# data-mx-node coverage (kit, deterministic — no AI)\n');
console.log('| Screen | tagged / candidates | % | repeated | exempt | untagged singletons (node:mx) |');
console.log('| --- | --- | --- | --- | --- | --- |');
for (const r of rows) {
  const u = r.untagged.slice(0, 6).map((x) => `${x.node}:${x.mx}`).join(', ') + (r.untagged.length > 6 ? ` …+${r.untagged.length - 6}` : '');
  console.log(`| ${r.screen} | ${r.tagged}/${r.candidates} | ${r.pct}% | ${r.repeated} | ${r.exempt} | ${u} |`);
}
const overall = totCand ? Math.round((100 * totTagged) / totCand) : 100;
const exemptNote = totExempt ? ` · ${totExempt} exempt (documented in intent-ledger.coverageExempt)` : '';
console.log(`\nOverall: ${totTagged}/${totCand} SINGLETON candidate nodes tagged (${overall}%)${exemptNote}${minPct ? ` · ${below.length} screen(s) under ${minPct}%` : ''}.`);
console.log('Candidate = node mapped to a MemoX component (mx:) or unmapped interactive (mx: ?), excluding ' + [...EXCLUDE].join('/') + ' + documented exempt nodes.');
console.log('Singleton = node name unique on the screen (the real tag target); "repeated" = list/grid items (tag the container, not each).');
console.log('"exempt" = intentionally-untagged candidates (kit pre-redesign / Future / child of a tagged container) — see tool/parity/intent-ledger.json.');
console.log('Run with --screen <id> to see a screen\'s full untagged list, --json for machine output.');

if (check && below.length) {
  console.error(`\nmxnode_coverage: FAIL — ${below.length} screen(s) below ${minPct}%: ${below.map((b) => b.screen).join(', ')}.`);
  process.exit(1);
}
process.exit(0);
