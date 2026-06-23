#!/usr/bin/env node
// tool/parity/after-sync.mjs — deterministic step that runs AFTER a design pull
// from Claude Design (DesignSync / the /design-sync skill) lands new kit files in
// `ui_kits/mobile/`. The pull itself is agent-only (claude.ai auth) and cannot be
// CLI/CI; everything here is plain node and ties that pull into the existing
// pipeline so the deterministic side knows a sync happened.
//
// It does NOT call Claude Design. It orchestrates the tools we already have:
//   1. check_specs_fresh — did the kit change without specs/shots being regenerated?
//   2. (optional --export) re-run ui_kit_shots export:all (needs Chrome + network)
//   3. design_watch — which screens' spec+shots drifted vs the committed baseline
//      → those need FE (+keys), goldens, docs, contract updated, then a re-baseline.
//
// Usage:
//   node tool/parity/after-sync.mjs            # check freshness + report drift
//   node tool/parity/after-sync.mjs --export   # also regenerate shots+specs first
//
// Exit: 0 ok, 1 design drifted (downstream work needed), 2 specs stale / error.

import { spawnSync } from 'node:child_process';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const KIT = join(REPO, 'tool', 'ui_kit_shots');
const wantExport = process.argv.includes('--export');

const run = (cmd, args, opts = {}) =>
  spawnSync(cmd, args, { stdio: 'inherit', cwd: REPO, encoding: 'utf8', ...opts });

console.log('# after-sync — wire a Claude Design pull into the deterministic pipeline\n');

// 1. Optionally regenerate shots+specs from the freshly-pulled kit.
if (wantExport) {
  console.log('── regenerating shots + specs (ui_kit_shots export:all) ...');
  const ex = run('npm', ['--prefix', KIT, 'run', 'export:all'], { shell: process.platform === 'win32' });
  if (ex.status !== 0) {
    console.error('after-sync: export:all failed (needs Chrome + network). Fix, then re-run.');
    process.exit(2);
  }
}

// 2. Are specs in sync with the kit's index.html? (no Chrome needed)
console.log('\n── check_specs_fresh ...');
const fresh = run('node', [join(KIT, 'check_specs_fresh.mjs')]);
if (fresh.status !== 0) {
  console.error(
    '\nafter-sync: specs/shots are STALE vs the pulled kit. Regenerate them:\n' +
    '  node tool/parity/after-sync.mjs --export   (or: npm --prefix tool/ui_kit_shots run export:all)\n' +
    'then re-run this. (Export needs Chrome + network.)',
  );
  process.exit(2);
}

// 3. Which screens changed vs the acknowledged design baseline?
console.log('\n── design_watch (drift vs baseline) ...');
const watch = run('node', [join(HERE, 'design_watch.mjs')]);

if (watch.status === 0) {
  console.log('\nafter-sync: in sync — the pulled design matches the baseline. Nothing to do.');
  process.exit(0);
}

console.log(
  '\nafter-sync: design drifted. For each CHANGED screen above, in the SAME commit:\n' +
  '  • FE widget + the mx-node KEYS (parity contract) → match the new mock\n' +
  '  • goldens: node tool/verify/run.mjs --update-goldens --test <screen tests>\n' +
  '  • docs: visual-contract / wireframe / decision table (per CLAUDE.md trigger-map)\n' +
  '  • parity-map.json if states changed; regenerate the parity contract\n' +
  '  • then re-baseline: node tool/parity/design_watch.mjs --update\n' +
  'Run `node tool/verify/run.mjs` to gate before commit.',
);
process.exit(1);
