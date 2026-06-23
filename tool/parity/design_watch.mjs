#!/usr/bin/env node
// tool/parity/design_watch.mjs — design-drift gate (deterministic, no AI).
//
// SOURCE OF TRUTH = the shots + specs generated from the mock design. When the
// design changes (a screen's spec or shots change), the Flutter code, goldens and
// docs MUST be updated to follow. This tool hashes each screen's spec + shots and
// compares to a committed baseline (design-baseline.json); drift = "design changed
// since last acknowledged → update downstream, then re-baseline (--update)".
//
// Re-baselining is the explicit acknowledgement that the FE/golden/docs were
// updated for that screen — so a committed baseline that matches HEAD means every
// design change has been followed through.
//
// Usage:
//   node tool/parity/design_watch.mjs            # report drift vs baseline
//   node tool/parity/design_watch.mjs --check    # exit 1 if any screen drifted
//   node tool/parity/design_watch.mjs --update   # re-baseline (after following through)
//   node tool/parity/design_watch.mjs --json
//
// Exit: 0 ok / in sync, 1 drift (--check), 2 IO error.

import { createHash } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const MAP_PATH = join(HERE, 'parity-map.json');
const BASELINE = join(HERE, 'design-baseline.json');

const args = process.argv.slice(2);
const asJson = args.includes('--json');
const check = args.includes('--check');
const update = args.includes('--update');

const die = (m) => { console.error(`parity/design_watch: ${m}`); process.exit(2); };
if (!existsSync(MAP_PATH)) die(`missing ${MAP_PATH}`);

const map = JSON.parse(readFileSync(MAP_PATH, 'utf8'));
const shotsDir = join(REPO, map.shotsDir);
const specsDir = resolve(shotsDir, '..', 'specs');
if (!existsSync(specsDir)) die(`missing specs dir ${specsDir}`);
if (!existsSync(shotsDir)) die(`missing shots dir ${shotsDir}`);

/** Hash a screen's spec file + all its shot PNGs (sorted) into one digest. */
function hashScreen(screenId) {
  const h = createHash('sha256');
  const specFile = join(specsDir, `${screenId}.md`);
  h.update('spec\0');
  h.update(existsSync(specFile) ? readFileSync(specFile) : Buffer.from('<none>'));
  const shots = readdirSync(shotsDir)
    .filter((f) => f.startsWith(`${screenId}--`) && f.endsWith('.png'))
    .sort();
  for (const s of shots) {
    h.update(`\0shot:${s}\0`);
    h.update(readFileSync(join(shotsDir, s)));
  }
  return { hash: h.digest('hex'), shots: shots.length };
}

// Screens = every spec file (the design's screen list), incl. no-FE ones.
const screenIds = readdirSync(specsDir)
  .filter((f) => f.endsWith('.md') && f !== 'INDEX.md')
  .map((f) => f.replace(/\.md$/, ''))
  .sort();

const current = {};
for (const id of screenIds) current[id] = hashScreen(id);

if (update) {
  writeFileSync(
    BASELINE,
    `${JSON.stringify({ $comment: 'Design baseline for tool/parity/design_watch.mjs — per-screen hash of spec + shots. Re-run with --update ONLY after the FE/goldens/docs have been updated to follow a design change.', screens: current }, null, 2)}\n`,
  );
  console.log(`parity/design_watch: baseline written for ${screenIds.length} screens → ${BASELINE}`);
  process.exit(0);
}

const baseline = existsSync(BASELINE) ? JSON.parse(readFileSync(BASELINE, 'utf8')).screens ?? {} : null;
if (baseline === null) {
  console.error('parity/design_watch: no baseline yet — run `--update` once to seed it.');
  process.exit(check ? 1 : 0);
}

const changed = [];
const added = [];
for (const id of screenIds) {
  if (!(id in baseline)) added.push(id);
  else if (baseline[id].hash !== current[id].hash) changed.push(id);
}
const removed = Object.keys(baseline).filter((id) => !(id in current));

if (asJson) {
  console.log(JSON.stringify({ changed, added, removed, screens: screenIds.length }, null, 2));
  process.exit(check && (changed.length || added.length || removed.length) ? 1 : 0);
}

console.log('# Design-drift watch (deterministic — no AI)\n');
if (!changed.length && !added.length && !removed.length) {
  console.log(`In sync — all ${screenIds.length} screens match the baseline (design ⇄ code/docs acknowledged).`);
  process.exit(0);
}
if (changed.length) console.log(`DESIGN CHANGED (spec/shots differ from baseline): ${changed.join(', ')}`);
if (added.length) console.log(`NEW design screens (no baseline): ${added.join(', ')}`);
if (removed.length) console.log(`REMOVED from design (still in baseline): ${removed.join(', ')}`);

console.log('\nFor each CHANGED/NEW screen, update downstream IN THE SAME COMMIT, then re-baseline:');
console.log('  1. FE widget        lib/presentation/features/**/screens/*.dart (match the new mock)');
console.log('  2. goldens          node tool/verify/run.mjs --update-goldens --test <screen test paths>');
console.log('  3. structural dump  re-run the screen\'s *_structural_test.dart (if present)');
console.log('  4. visual contract  docs/design/screens/<screen>.visual-contract.md');
console.log('  5. wireframe        docs/wireframes/<NN-...>.md');
console.log('  6. decision table   docs/decision-tables/memox-core-decision-table.md (if behaviour changed)');
console.log('  7. parity-map.json  add/adjust states if a state was added/removed');
console.log('  8. re-baseline      node tool/parity/design_watch.mjs --update');
console.log('\n(Re-baselining is the acknowledgement that 1–7 were done for the changed screens.)');

process.exit(check ? 1 : 0);
