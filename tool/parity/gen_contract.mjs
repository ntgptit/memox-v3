#!/usr/bin/env node
// tool/parity/gen_contract.mjs — generate the per-screen parity contract from the
// specs (deterministic, no AI, no auth). Reads every `specs/NN-*.md`, collects the
// nodes that carry an `id:<mx-node>` (emitted by export_specs from the kit's
// `data-mx-node` attribute), and writes the required-key list per screen to
// `tool/parity/contracts/<screen>.json`. The parity-contract tests assert
// `find.byKey('mx-node:<id>')` for these — FE missing a node ⇒ key absent ⇒ red.
//
// This is stage 3 of the pipeline: data-mx-node (Claude Design) → export_specs
// (carry id) → THIS (contract) → FE keys + tests. Until `data-mx-node` ids exist
// in the kit/specs it reports zero and explains how to add them — it never invents.
//
// Usage:
//   node tool/parity/gen_contract.mjs            # write contracts/<screen>.json
//   node tool/parity/gen_contract.mjs --check    # exit 1 if contracts are stale
//   node tool/parity/gen_contract.mjs --json

import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const MAP = JSON.parse(readFileSync(join(HERE, 'parity-map.json'), 'utf8'));
const SPECS = resolve(join(REPO, MAP.shotsDir), '..', 'specs');
const OUT = join(HERE, 'contracts');

const args = process.argv.slice(2);
const check = args.includes('--check');
const asJson = args.includes('--json');

// id field emitted by export_specs, e.g. `id: 02-dashboard/due-summary`.
const ID = /\bid:\s*([A-Za-z0-9][\w/-]*)/;
const NODE = /node:\s*(\S+)/;

if (!existsSync(SPECS)) { console.error(`gen_contract: missing ${SPECS}`); process.exit(2); }

/** Collect {id, node} for every spec node carrying an id:. */
function idsInSpec(md) {
  const out = [];
  let node = '?';
  for (const raw of md.split('\n')) {
    const s = raw.trim().replace(/^[-+]\s*/, '');
    const n = NODE.exec(s);
    if (n) node = n[1];
    const m = ID.exec(s);
    if (m) out.push({ id: m[1], node });
  }
  // dedupe by id
  const seen = new Set();
  return out.filter((e) => (seen.has(e.id) ? false : seen.add(e.id)));
}

const files = readdirSync(SPECS).filter((f) => f.endsWith('.md') && f !== 'INDEX.md');
const contracts = {};
let total = 0;
for (const f of files) {
  const screen = f.replace(/\.md$/, '');
  const ids = idsInSpec(readFileSync(join(SPECS, f), 'utf8'));
  if (ids.length) {
    contracts[screen] = ids.map((e) => ({ key: `mx-node:${e.id}`, node: e.node }));
    total += ids.length;
  }
}

if (asJson) { console.log(JSON.stringify({ contracts, total }, null, 2)); process.exit(0); }

const outFile = join(OUT, 'contracts.json');
const next = `${JSON.stringify({ $generated: 'tool/parity/gen_contract.mjs', contracts }, null, 2)}\n`;
const prev = existsSync(outFile) ? readFileSync(outFile, 'utf8') : '';

if (check) {
  if (prev !== next) {
    console.error('gen_contract: contracts.json is STALE — run `node tool/parity/gen_contract.mjs`.');
    process.exit(1);
  }
  console.log(`gen_contract: up to date (${total} required nodes across ${Object.keys(contracts).length} screens).`);
  process.exit(0);
}

mkdirSync(OUT, { recursive: true });
writeFileSync(outFile, next);
console.log(`gen_contract: wrote ${outFile} — ${total} required node(s) across ${Object.keys(contracts).length} screen(s).`);
if (total === 0) {
  console.log(
    '\nNo `data-mx-node` ids in the specs yet. To populate the contract:\n' +
    '  1. add data-mx-node="<screen>/<node>" to the kit JSX (in Claude Design, so it survives sync)\n' +
    '  2. teach export_specs to emit `id:<value>` for nodes with that attribute\n' +
    '  3. re-export specs, then re-run this. Until then, hand-write contracts like\n' +
    '     test/presentation/features/dashboard/dashboard_parity_test.dart.',
  );
}
process.exit(0);
