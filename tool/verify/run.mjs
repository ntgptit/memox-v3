// verify — single-entry verification chain for MemoX.
//
// Replaces running the CLAUDE.md verification commands one by one. Detects the
// change scope from `git status` (docs-only vs code) and runs the right steps
// in the canonical order with the pairing rules applied (dart fix -> dart
// format -> flutter analyze), then prints one summary table. Agents run ONE
// command and read ONE result block.
//
// Usage:
//   node tool/verify/run.mjs                  # auto-detect scope from git status
//   node tool/verify/run.mjs --docs           # docs-only chain (doc_guard, guard, diff --check)
//   node tool/verify/run.mjs --code           # full code chain, no tests
//   node tool/verify/run.mjs --test <paths..> # code chain + targeted flutter tests
//   node tool/verify/run.mjs --full           # code chain + ALL flutter tests (slow)
//
// Exit code: 0 = every executed step passed, 1 = at least one step failed.

import { existsSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync, spawnSync } from 'node:child_process';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const args = process.argv.slice(2);
const has = (f) => args.includes(f);
const testTargets = (() => {
  const i = args.indexOf('--test');
  return i >= 0 ? args.slice(i + 1).filter((a) => !a.startsWith('--')) : [];
})();

// ── scope detection ──────────────────────────────────────────────────────────
function changedFiles() {
  const out = execSync('git status --porcelain', { cwd: repoRoot }).toString();
  return out
    .split('\n')
    .filter(Boolean)
    .map((l) => l.slice(3).trim().replace(/^"|"$/g, ''));
}

let mode;
if (has('--docs')) mode = 'docs';
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

if (mode === 'docs') {
  step('doc_guard', 'node tool/doc_guard/run.mjs check');
  step('guard', 'python code-verification-guard/guard/run.py check --project . --ruleset memox', {
    skip: guardPresent ? undefined : 'tool not present',
  });
  step('git diff --check', 'git diff --check');
} else {
  step('gen-l10n', 'flutter gen-l10n', { skip: arbTouched ? undefined : 'no ARB change' });
  step('build_runner', 'dart run build_runner build --delete-conflicting-outputs');
  step('guard', 'python code-verification-guard/guard/run.py check --project . --ruleset memox', {
    skip: guardPresent ? undefined : 'tool not present',
  });
  step('doc_guard', 'node tool/doc_guard/run.mjs check');
  step('dart fix', 'dart fix --apply');
  step('dart format', 'dart format .');
  step('flutter analyze', 'flutter analyze');
  if (has('--full')) step('flutter test (ALL)', 'flutter test');
  else if (testTargets.length) step('flutter test (targeted)', `flutter test ${testTargets.join(' ')}`);
  else results.push({ name: 'flutter test', status: 'skipped', note: 'no targets — pass --test <paths> or --full' });
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
console.log('\nverify: PASS');
console.log('reminder: after dart fix/format, inspect the diff and keep only changes belonging to the task.');
process.exit(0);
