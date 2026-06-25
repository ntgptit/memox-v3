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
//                                          # pick a bar after reading the report)
//   node tool/parity/report.mjs --screen 03-library-overview
//                                          # restrict to one screen id
//   node tool/parity/report.mjs --ssim     # add per-state SSIM columns (perceptual
//                                          # similarity, 1.0 = identical; needs scikit-image)
//   node tool/parity/report.mjs --check --min-ssim 0.6
//                                          # also exit 1 if a current state's SSIM
//                                          # drops below 0.6 (implies --ssim)
//
// NOTE on the threshold: goldens now render the REAL app font (Plus Jakarta Sans,
// loaded in test/flutter_test_config.dart), so diff% vs the kit shot is a strong
// signal — no longer dominated by the old Ahem test-font noise. Residual % is
// genuine renderer/anti-alias/variable-font-weight difference; treat % as a strong
// but not absolute signal, and let `ui-parity-checker` (reading the actual images)
// make the final call when % is borderline. `--check` (no --max) only gates STATE
// COVERAGE, which is fully deterministic and the highest-value no-AI guard.
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
const minSsimArg = opt('--min-ssim', null) != null ? Number(opt('--min-ssim', null)) : null;
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

// SSIM honesty floor. pixel-diff% is BLIND to missing near-background surfaces
// (a white card on a #F2F5F9 page differs <16/channel → counted "same"), so a
// screen missing 70% of its content can still read ~8% diff. SSIM is the headline
// verdict instead: a `current` state whose golden↔shot SSIM (either theme) falls
// below this floor is DIVERGED, not "OK". Configurable in parity-map.json
// (`minSsim`); `--min-ssim <v>` overrides. NOTE: SSIM is still whole-frame (diluted
// by large shared backgrounds) so it is a COARSE fidelity gate — element-level
// "missing/extra" is owned by the data-mx-node identity gate (mxnode_coverage +
// fe_node_usage), which is renderer/position/background-immune.
const DEFAULT_MIN_SSIM = 0.8;
const ssimFloor = minSsimArg != null ? minSsimArg : (typeof map.minSsim === 'number' ? map.minSsim : DEFAULT_MIN_SSIM);
const wantSsim = flag('--ssim') || ssimFloor != null;
const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';

/**
 * Run diff.py for one golden↔shot pair; returns { pct, ssim } (ssim only when
 * --ssim is requested), or null on error/missing file.
 */
function diffPair(goldenAbs, shotAbs) {
  if (!existsSync(goldenAbs) || !existsSync(shotAbs)) return null;
  const argv = [DIFF_PY, goldenAbs, shotAbs, '--threshold', '100'];
  if (wantSsim) argv.push('--ssim');
  try {
    const out = execFileSync(pythonCmd, argv, {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    });
    const pm = out.match(/mismatch:\s*([\d.]+)%/i);
    const sm = out.match(/ssim:\s*(-?[\d.]+)/i);
    return { pct: pm ? Number(pm[1]) : null, ssim: sm ? Number(sm[1]) : null };
  } catch {
    return null;
  }
}

const rows = [];
let missing = 0;
let overMax = 0;
let belowMin = 0;

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
    const ssimTheme = {};
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
      const res = diffPair(goldenAbs, shotAbs);
      perTheme[theme] = res == null ? 'diff-err' : res.pct;
      ssimTheme[theme] = res?.ssim ?? null;
      if (maxPct != null && typeof res?.pct === 'number' && res.pct > maxPct) overMax++;
    }
    if (stateMissing) missing++;
    // DIVERGED = golden exists but SSIM (either theme) is below the floor → the FE
    // does NOT visually match the design. This replaces the old "golden exists ⇒ OK".
    const diverged =
      !stateMissing &&
      ssimFloor != null &&
      [ssimTheme.light, ssimTheme.dark].some((s) => typeof s === 'number' && s < ssimFloor);
    if (diverged) belowMin++;
    rows.push({
      screen: screen.id,
      state: st.kit,
      scope: 'current',
      status: stateMissing ? 'MISSING' : diverged ? 'DIVERGED' : 'OK',
      light: perTheme.light,
      dark: perTheme.dark,
      lightSsim: ssimTheme.light,
      darkSsim: ssimTheme.dark,
      note: st.note ?? '',
    });
  }
}

const noFe = (map.noFe ?? []).map((id) => ({ screen: id, status: 'NO-FE-YET' }));

if (asJson) {
  console.log(JSON.stringify({ rows, noFe, missing, overMax }, null, 2));
} else {
  const fmt = (v) => (typeof v === 'number' ? `${v.toFixed(2)}%` : (v ?? ''));
  const fmtS = (v) => (typeof v === 'number' ? v.toFixed(3) : '');
  console.log('# Visual-parity report (deterministic — no AI)\n');
  const head = wantSsim
    ? '| Screen | State | Scope | Status | light% | dark% | light SSIM | dark SSIM | Note |'
    : '| Screen | State | Scope | Status | light | dark | Note |';
  console.log(head);
  console.log(head.replace(/[^|]+/g, ' --- '));
  for (const r of rows) {
    const base = `| ${r.screen} | ${r.state} | ${r.scope} | ${r.status} | ${fmt(r.light)} | ${fmt(r.dark)} |`;
    console.log(
      wantSsim
        ? `${base} ${fmtS(r.lightSsim)} | ${fmtS(r.darkSsim)} | ${r.note} |`
        : `${base} ${r.note} |`,
    );
  }
  if (noFe.length) {
    console.log('\n**No-FE-yet (out of scope):** ' + noFe.map((n) => n.screen).join(', '));
  }
  const current = rows.filter((r) => r.scope === 'current');
  const ok = current.filter((r) => r.status === 'OK').length;
  console.log(
    `\nSummary: ${ok}/${current.length} current states MATCH (SSIM ≥ ${ssimFloor})` +
      `${missing ? ` · ${missing} MISSING golden` : ''}` +
      `${ssimFloor != null ? ` · ${belowMin} DIVERGED (SSIM < ${ssimFloor})` : ''}` +
      `${maxPct != null ? ` · ${overMax} over ${maxPct}%` : ''}` +
      ` · ${rows.length - current.length} deferred/behavior/shared · ${noFe.length} no-FE-yet.`,
  );
  console.log(
    '\nVerdict = SSIM floor (whole-frame, COARSE — diluted by shared background). pixel-diff% is a' +
      ' secondary signal and is BLIND to missing near-bg surfaces. Element-level missing/extra is the' +
      ' data-mx-node identity gate (mxnode_coverage + fe_node_usage); borderline visual call → ui-parity-checker.',
  );
}

if (
  check &&
  (missing > 0 ||
    (maxPct != null && overMax > 0) ||
    (ssimFloor != null && belowMin > 0))
) {
  console.error(
    `\nparity/report: FAIL — ${missing} missing golden(s)` +
      `${ssimFloor != null ? `, ${belowMin} DIVERGED state(s) (SSIM < ${ssimFloor})` : ''}` +
      `${maxPct != null ? `, ${overMax} state(s) over ${maxPct}%` : ''}.`,
  );
  process.exit(1);
}
process.exit(0);
