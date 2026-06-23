#!/usr/bin/env node
// tool/parity/report.mjs — deterministic visual-parity report (NO AI).
//
// Turns the manual "parity audit" loop (list kit states → find golden → run
// diff.py per state → flag missing) into one command driven by a machine-
// readable contract (`tool/parity/parity-map.json`). Run it every commit / in
// CI; it never calls a model.
//
// What it does, per screen/state in the map:
//   - scope "current": assert the golden exists (light+dark) and pixel-diff it
//     against the kit shot via tool/golden_diff/diff.py. Missing golden = FAIL.
//   - scope "deferred" | "behavior" | "needs-schema" | "needs-token" | "shared":
//     reported as-is, NOT diffed (the divergence is owned elsewhere — see
//     docs/project-management/parity-loop/parity-deferred.md).
//   - screens listed in `noFe`: reported as no-FE-yet (out of scope).
//
// Usage:
//   node tool/parity/report.mjs            # print the markdown report
//   node tool/parity/report.mjs --json     # machine-readable JSON
//   node tool/parity/report.mjs --check    # exit 1 if any "current" state is
//                                          # MISSING a golden (state-coverage gate)
//   node tool/parity/report.mjs --check --max 60
//                                          # also exit 1 if a current state's
//                                          # diff% exceeds 60 (off by default —
//                                          # goldens render text in Ahem, so %
//                                          # is noisy; raise the bar deliberately)
//   node tool/parity/report.mjs --screen 03-library-overview
//                                          # restrict to one screen id
//
// NOTE on the threshold: Flutter golden tests render text with a block font
// (Ahem), so diff% vs the real-text kit shot carries large font-rendering noise.
// Treat % as a RELATIVE per-state signal, not an absolute parity verdict; the
// authoritative visual judgment is the `ui-parity-checker` agent reading the
// actual images. `--check` (no --max) only gates STATE COVERAGE, which is fully
// deterministic and the highest-value no-AI guard.
//
// Exit codes: 0 = ok, 1 = a gate failed (--check), 2 = config/IO error.

import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');
const MAP_PATH = join(HERE, 'parity-map.json');
const DIFF_PY = join(REPO, 'tool', 'golden_diff', 'diff.py');

const args = process.argv.slice(2);
const flag = (name) => args.includes(name);
const opt = (name, def) => {
  const i = args.indexOf(name);
  return i >= 0 && args[i + 1] ? args[i + 1] : def;
};

const asJson = flag('--json');
const check = flag('--check');
const maxPct = opt('--max', null) ? Number(opt('--max', null)) : null;
const onlyScreen = opt('--screen', null);
const themes = ['light', 'dark'];

function die(msg) {
  console.error(`parity/report: ${msg}`);
  process.exit(2);
}

if (!existsSync(MAP_PATH)) die(`missing config ${MAP_PATH}`);
if (!existsSync(DIFF_PY)) die(`missing ${DIFF_PY}`);

let map;
try {
  map = JSON.parse(readFileSync(MAP_PATH, 'utf8'));
} catch (e) {
  die(`parity-map.json is not valid JSON: ${e.message}`);
}

const shotsDir = join(REPO, map.shotsDir);
const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';

/** Run diff.py for one golden↔shot pair; returns mismatch % or null on error. */
function diffPct(goldenAbs, shotAbs) {
  if (!existsSync(goldenAbs) || !existsSync(shotAbs)) return null;
  try {
    const out = execFileSync(
      pythonCmd,
      [DIFF_PY, goldenAbs, shotAbs, '--threshold', '100'],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] },
    );
    const m = out.match(/mismatch:\s*([\d.]+)%/i);
    return m ? Number(m[1]) : null;
  } catch {
    return null;
  }
}

const rows = [];
let missing = 0;
let overMax = 0;

for (const screen of map.screens) {
  if (onlyScreen && screen.id !== onlyScreen) continue;
  for (const st of screen.states ?? []) {
    const scope = st.scope ?? 'current';
    if (scope !== 'current') {
      rows.push({
        screen: screen.id,
        state: st.kit,
        scope,
        status: scope.toUpperCase(),
        note: st.reason ?? st.note ?? '',
      });
      continue;
    }
    // current: must have a golden, diff both themes.
    const perTheme = {};
    let stateMissing = false;
    for (const theme of themes) {
      const goldenAbs = join(REPO, `${st.golden}__${theme}.png`);
      const shotAbs = join(shotsDir, `${screen.id}--${st.kit}--${theme}.png`);
      if (!existsSync(goldenAbs)) {
        stateMissing = true;
        perTheme[theme] = 'no-golden';
        continue;
      }
      if (!existsSync(shotAbs)) {
        perTheme[theme] = 'no-shot';
        continue;
      }
      const pct = diffPct(goldenAbs, shotAbs);
      perTheme[theme] = pct == null ? 'diff-err' : pct;
      if (maxPct != null && typeof pct === 'number' && pct > maxPct) overMax++;
    }
    if (stateMissing) missing++;
    rows.push({
      screen: screen.id,
      state: st.kit,
      scope: 'current',
      status: stateMissing ? 'MISSING' : 'OK',
      light: perTheme.light,
      dark: perTheme.dark,
      note: st.note ?? '',
    });
  }
}

const noFe = (map.noFe ?? []).map((id) => ({ screen: id, status: 'NO-FE-YET' }));

if (asJson) {
  console.log(JSON.stringify({ rows, noFe, missing, overMax }, null, 2));
} else {
  const fmt = (v) => (typeof v === 'number' ? `${v.toFixed(2)}%` : (v ?? ''));
  console.log('# Visual-parity report (deterministic — no AI)\n');
  console.log('| Screen | State | Scope | Status | light | dark | Note |');
  console.log('| --- | --- | --- | --- | --- | --- | --- |');
  for (const r of rows) {
    console.log(
      `| ${r.screen} | ${r.state} | ${r.scope} | ${r.status} | ${fmt(r.light)} | ${fmt(r.dark)} | ${r.note} |`,
    );
  }
  if (noFe.length) {
    console.log('\n**No-FE-yet (out of scope):** ' + noFe.map((n) => n.screen).join(', '));
  }
  const current = rows.filter((r) => r.scope === 'current');
  const ok = current.filter((r) => r.status === 'OK').length;
  console.log(
    `\nSummary: ${ok}/${current.length} current states have goldens` +
      `${missing ? ` · ${missing} MISSING` : ''}` +
      `${maxPct != null ? ` · ${overMax} over ${maxPct}%` : ''}` +
      ` · ${rows.length - current.length} deferred/behavior/shared · ${noFe.length} no-FE-yet.`,
  );
  console.log(
    '\nReminder: diff% includes Ahem test-font noise — % is a relative signal, not a verdict.',
  );
}

if (check && (missing > 0 || (maxPct != null && overMax > 0))) {
  console.error(
    `\nparity/report: FAIL — ${missing} missing golden(s)` +
      `${maxPct != null ? `, ${overMax} state(s) over ${maxPct}%` : ''}.`,
  );
  process.exit(1);
}
process.exit(0);
