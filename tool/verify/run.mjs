// verify — THE single verification entry for MemoX. Individual verification
// commands (flutter analyze/test, dart fix/format, build_runner, guards) must
// NOT be run directly; every step goes through this tool — including the inner
// dev loop (`--quick`). Enforcement: a successful docs/code run writes a
// pass-marker bound to the exact content state of the working tree, and the
// pre-commit hook rejects commits whose state has no matching marker. Piecemeal
// runs produce no marker, so they cannot be committed.
//
// Usage:
//   node tool/verify/run.mjs                  # auto-detect scope from git status
//   node tool/verify/run.mjs --docs           # docs-only chain (doc_guard, guard, diff --check)
//   node tool/verify/run.mjs --code           # full code chain, no tests
//   node tool/verify/run.mjs --test <paths..> # code chain + targeted flutter tests
//   node tool/verify/run.mjs --full           # code chain + ALL flutter tests (slow)
//   node tool/verify/run.mjs --quick [--test <paths..>]
//                                             # inner loop: analyze (+ targeted tests) only.
//                                             # Fast feedback while developing; writes NO marker.
//   node tool/verify/run.mjs --check-marker   # used by .githooks/pre-commit: exit 0 when the
//                                             # current tree state has a valid pass-marker.
//
// Exit code: 0 = every executed step passed, 1 = at least one step failed.

import { createHash } from 'node:crypto';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync, spawnSync } from 'node:child_process';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const markerPath = join(repoRoot, 'tool', 'verify', '.last-pass.json');
const args = process.argv.slice(2);
const has = (f) => args.includes(f);
const testTargets = (() => {
  const i = args.indexOf('--test');
  return i >= 0 ? args.slice(i + 1).filter((a) => !a.startsWith('--')) : [];
})();
// Golden workflow stays inside the single entry: forwarded to `flutter test`.
const goldenFlag = has('--update-goldens') ? ' --update-goldens' : '';

// ── content-state hash ───────────────────────────────────────────────────────
// Identifies the exact uncommitted content of the tree, independent of whether
// files are staged. `git add` does not change it; any edit does. The marker
// file itself is excluded.
function stateHash() {
  // -uall lists untracked files individually; the default collapses a new
  // directory into one `dir/` entry, which is unreadable as a file.
  const out = execSync('git status --porcelain -uall', { cwd: repoRoot }).toString();
  const entries = [];
  for (const line of out.split('\n').filter(Boolean)) {
    let path = line.slice(3).trim().replace(/^"|"$/g, '');
    if (path.includes(' -> ')) path = path.split(' -> ')[1].replace(/^"|"$/g, '');
    if (path === 'tool/verify/.last-pass.json' || path.endsWith('/')) continue;
    const abs = join(repoRoot, path);
    const content = existsSync(abs) ? readFileSync(abs) : Buffer.from('DELETED');
    entries.push(`${path}:${createHash('sha1').update(content).digest('hex')}`);
  }
  entries.sort();
  const head = execSync('git rev-parse HEAD', { cwd: repoRoot }).toString().trim();
  return createHash('sha1').update(head + '\n' + entries.join('\n')).digest('hex');
}

// ── --check-marker (called by .githooks/pre-commit) ──────────────────────────
if (has('--check-marker')) {
  if (!existsSync(markerPath)) {
    console.error('pre-commit: no verify pass-marker. Run `node tool/verify/run.mjs` (or --docs / --test <paths>) before committing.');
    process.exit(1);
  }
  let marker;
  try {
    marker = JSON.parse(readFileSync(markerPath, 'utf8'));
  } catch {
    console.error('pre-commit: unreadable pass-marker. Re-run `node tool/verify/run.mjs`.');
    process.exit(1);
  }
  if (marker.stateHash !== stateHash()) {
    console.error('pre-commit: tree changed since the last verify PASS (or verify was never run on this state).');
    console.error('Run `node tool/verify/run.mjs` again — piecemeal verification commands do not count.');
    process.exit(1);
  }
  const staged = execSync('git diff --cached --name-only', { cwd: repoRoot })
    .toString()
    .split('\n')
    .filter(Boolean);
  const codeStaged = staged.some(
    (f) => (f.startsWith('lib/') || f.startsWith('test/') || f === 'pubspec.yaml') && !f.endsWith('.md'),
  );
  if (codeStaged && marker.mode !== 'code') {
    console.error(`pre-commit: staged changes include code but the pass-marker is from the "${marker.mode}" chain.`);
    console.error('Run the code chain: `node tool/verify/run.mjs --test <targeted tests>`.');
    process.exit(1);
  }
  if (codeStaged && !marker.testsRan) {
    console.error('pre-commit: WARNING — code is staged but no tests ran in the verifying chain (no --test/--full).');
    console.error('Allowed, but the final report must justify the skip.');
  }
  process.exit(0);
}

// ── scope detection ──────────────────────────────────────────────────────────
function changedFiles() {
  const out = execSync('git status --porcelain -uall', { cwd: repoRoot }).toString();
  return out
    .split('\n')
    .filter(Boolean)
    .map((l) => l.slice(3).trim().replace(/^"|"$/g, ''));
}

let mode;
if (has('--quick')) mode = 'quick';
else if (has('--docs')) mode = 'docs';
else if (has('--code') || has('--full') || testTargets.length) mode = 'code';
else {
  const files = changedFiles();
  const codeTouched = files.some(
    (f) => (f.startsWith('lib/') || f.startsWith('test/') || f === 'pubspec.yaml') && !f.endsWith('.md'),
  );
  mode = codeTouched ? 'code' : 'docs';
  console.log(
    files.length
      ? `auto-detected scope: ${mode} (${files.length} changed file(s))`
      : `working tree clean — defaulting to: ${mode} chain`,
  );
}
const arbTouched = changedFiles().some((f) => f.startsWith('lib/l10n/') && f.endsWith('.arb'));

// ── step runner ──────────────────────────────────────────────────────────────
const results = [];
function step(name, cmd, { skip, optional } = {}) {
  if (skip) {
    results.push({ name, status: 'skipped', note: skip });
    return;
  }
  const t0 = Date.now();
  process.stdout.write(`\n── ${name}: ${cmd}\n`);
  const r = spawnSync(cmd, { cwd: repoRoot, shell: true, stdio: 'inherit', timeout: 600000 });
  const secs = ((Date.now() - t0) / 1000).toFixed(1);
  const ok = r.status === 0;
  results.push({
    name,
    status: ok ? 'pass' : optional ? 'warn' : 'FAIL',
    note: ok ? `${secs}s` : `exit ${r.status} (${secs}s)`,
  });
}

// ── chains ───────────────────────────────────────────────────────────────────
const guardPresent = existsSync(join(repoRoot, 'code-verification-guard', 'guard', 'run.py'));

if (mode === 'quick') {
  // Inner dev loop: fast feedback through the same entry. No marker — quick
  // runs are not commit-worthy verification.
  step('flutter analyze', 'flutter analyze');
  if (testTargets.length) step('flutter test (targeted)', `flutter test${goldenFlag} ${testTargets.join(' ')}`);
  else results.push({ name: 'flutter test', status: 'skipped', note: 'pass --test <paths> for tests in quick mode' });
} else if (mode === 'docs') {
  step('doc_guard', 'node tool/doc_guard/run.mjs check');
  step('token parity', 'node tool/parity/gen_tokens.mjs --check');
  step('symbol parity', 'node tool/parity/symbol_lint.mjs --check');
  step('binding contract', 'node tool/parity/gen_bindings.mjs --check');
  step('component fonts fresh', 'node tool/parity/gen_component_contract.mjs --check');
  // Completeness (thiếu/thừa): kit fully tagged + every tag keyed in FE + no foreign FE key.
  step('contract fresh', 'node tool/parity/gen_contract.mjs --check');
  step('kit coverage', 'node tool/parity/mxnode_coverage.mjs --check --min 100');
  step('fe coverage', 'node tool/parity/fe_node_usage.mjs --check');
  step('guard', 'python code-verification-guard/guard/run.py check --project . --ruleset memox', {
    skip: guardPresent ? undefined : 'tool not present',
  });
  step('ui-kit specs fresh', 'node tool/ui_kit_shots/check_specs_fresh.mjs');
  step('git diff --check', 'git diff --check');
} else {
  step('gen-l10n', 'flutter gen-l10n', { skip: arbTouched ? undefined : 'no ARB change' });
  step('build_runner', 'dart run build_runner build --delete-conflicting-outputs');
  step('guard', 'python code-verification-guard/guard/run.py check --project . --ruleset memox', {
    skip: guardPresent ? undefined : 'tool not present',
  });
  step('doc_guard', 'node tool/doc_guard/run.mjs check');
  step('token parity', 'node tool/parity/gen_tokens.mjs --check');
  step('symbol parity', 'node tool/parity/symbol_lint.mjs --check');
  step('binding contract', 'node tool/parity/gen_bindings.mjs --check');
  step('component fonts fresh', 'node tool/parity/gen_component_contract.mjs --check');
  // Completeness (thiếu/thừa): kit fully tagged + every tag keyed in FE + no foreign FE key.
  step('contract fresh', 'node tool/parity/gen_contract.mjs --check');
  step('kit coverage', 'node tool/parity/mxnode_coverage.mjs --check --min 100');
  step('fe coverage', 'node tool/parity/fe_node_usage.mjs --check');
  step('dart fix', 'dart fix --apply');
  step('dart format', 'dart format .');
  step('flutter analyze', 'flutter analyze');
  if (has('--full')) step('flutter test (ALL)', `flutter test${goldenFlag}`);
  else if (testTargets.length) step('flutter test (targeted)', `flutter test${goldenFlag} ${testTargets.join(' ')}`);
  else results.push({ name: 'flutter test', status: 'skipped', note: 'no targets — pass --test <paths> or --full' });
  step('ui-kit specs fresh', 'node tool/ui_kit_shots/check_specs_fresh.mjs');
  step('git diff --check', 'git diff --check');
}

// ── summary ──────────────────────────────────────────────────────────────────
console.log(`\n${'═'.repeat(60)}\nverify summary (${mode} chain):\n`);
for (const r of results) {
  const icon = r.status === 'pass' ? '✔' : r.status === 'skipped' ? '○' : r.status === 'warn' ? '⚠' : '✖';
  console.log(`  ${icon} ${r.name.padEnd(24)} ${r.status.padEnd(8)} ${r.note}`);
}
const failed = results.filter((r) => r.status === 'FAIL');
if (failed.length) {
  console.log(`\nverify: FAILED (${failed.map((f) => f.name).join(', ')})`);
  process.exit(1);
}

if (mode === 'quick') {
  console.log('\nverify: PASS (quick — inner loop only, no commit marker written)');
} else {
  const testsRan = has('--full') || testTargets.length > 0;
  writeFileSync(
    markerPath,
    JSON.stringify({ mode, stateHash: stateHash(), testsRan, at: new Date().toISOString() }, null, 2),
  );
  console.log(`\nverify: PASS (${mode} chain — commit marker written; edits after this point require a re-run)`);
  console.log('after dart fix/format: inspect the diff and keep only changes belonging to the task.');
}
process.exit(0);
