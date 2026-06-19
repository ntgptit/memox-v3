/* ============================================================================
 * MemoX — UI-kit adherence checker
 * ----------------------------------------------------------------------------
 * Zero-dependency. Verifies that ui_kits screens stick to the shared system so
 * you don't have to eyeball-review (or pay an agent to):
 *   • no hardcoded colors  (#hex / rgb / rgba)            -> ERROR
 *   • no undefined --memox-* token references              -> ERROR
 *   • each screen has the bundle guard (no __errors)       -> ERROR
 *   • no raw px for spacing/size/radius/font               -> WARN
 *   • screens consume the shared primitives (window.MX)    -> WARN
 *   • screens don't re-declare a shared primitive locally  -> WARN
 *
 * Usage:   node tools/check-ui-kit.js
 * Exit:    0 = clean (no errors), 1 = at least one ERROR.
 *
 * NOTE: the whole body is wrapped in a Node-only guard so that when the design
 * system compiler bundles this file for the browser it simply no-ops (no
 * require/process there) — keeping _ds_bundle.js clean.
 * ========================================================================== */
'use strict';

(function () {
  if (typeof process === 'undefined' || !process.versions || !process.versions.node) return; // browser/bundle: no-op

  const fs = require('fs');
  const path = require('path');
  const ROOT = path.resolve(__dirname, '..');

  const read = (p) => fs.readFileSync(p, 'utf8');
  const exists = (p) => fs.existsSync(p);
  function walk(dir, out = []) {
    if (!exists(dir)) return out;
    for (const name of fs.readdirSync(dir)) {
      const fp = path.join(dir, name);
      if (fs.statSync(fp).isDirectory()) walk(fp, out);
      else out.push(fp);
    }
    return out;
  }
  const stripComments = (s) =>
    s.replace(/\/\*[\s\S]*?\*\//g, '').replace(/(^|[^:])\/\/.*$/gm, '$1');
  const rel = (p) => path.relative(ROOT, p).split(path.sep).join('/');

  // 1. defined --memox-* tokens (every root CSS file, skipping _generated)
  const cssFiles = walk(ROOT).filter((f) => f.endsWith('.css') && !f.includes(path.sep + '_'));
  const definedTokens = new Set();
  for (const f of cssFiles) {
    for (const m of read(f).matchAll(/(--memox-[\w-]+)\s*:/g)) definedTokens.add(m[1]);
  }

  // shared primitives exposed on window.MX
  const sharedPath = path.join(ROOT, 'ui_kits/mobile/screens/_shared.jsx');
  const sharedNames = new Set();
  if (exists(sharedPath)) {
    const m = read(sharedPath).match(/window\.MX\s*=\s*\{([^}]*)\}/);
    if (m) m[1].split(',').map((s) => s.trim()).filter(Boolean).forEach((n) => sharedNames.add(n));
  }

  // 2. screen files
  const screens = walk(ROOT)
    .filter((f) => /ui_kits\/.+\/screens\/.+\.jsx$/.test(f.split(path.sep).join('/')))
    .filter((f) => !/_shared\.jsx$/.test(f));

  // 3. checks
  let errors = 0, warns = 0;
  const report = (level, file, msg) => {
    if (level === 'ERROR') errors++; else warns++;
    console.log(`  [${level === 'ERROR' ? 'ERROR' : 'warn '}] ${rel(file)}: ${msg}`);
  };

  if (!sharedNames.size) console.log('! could not read window.MX from _shared.jsx — shared-usage checks skipped\n');

  for (const file of screens) {
    const src = stripComments(read(file));

    // 3a. hardcoded colors
    const colorHits = new Set();
    for (const m of src.matchAll(/#[0-9a-fA-F]{3,8}\b/g)) colorHits.add(m[0]);
    for (const m of src.matchAll(/\brgba?\([^)]*\)/g)) colorHits.add(m[0]);
    colorHits.forEach((c) => report('ERROR', file, `hardcoded color "${c}" — use a var(--memox-*) token`));

    // 3b. undefined token references
    const badTokens = new Set();
    for (const m of src.matchAll(/var\((--memox-[\w-]+)/g)) if (!definedTokens.has(m[1])) badTokens.add(m[1]);
    badTokens.forEach((t) => report('ERROR', file, `references undefined token ${t}`));

    // 3c. bundle guard present
    if (!/if\s*\(\s*!window\.MX[\s\S]{0,80}?return/.test(src)) {
      report('ERROR', file, 'missing bundle guard `if (!window.MX || !window.MEMOX_KIT...) return;` at IIFE top');
    }

    // 3d. consumes shared primitives
    if (sharedNames.size && !/window\.MX/.test(src)) {
      report('warn', file, 'does not read from window.MX — is it using the shared primitives?');
    }

    // 3e. re-declares a shared primitive locally
    for (const name of sharedNames) {
      if (new RegExp(`\\b(?:const|let|function)\\s+${name}\\b\\s*[=(]`).test(src)) {
        report('warn', file, `re-declares shared primitive "${name}" locally — import it from window.MX instead`);
      }
    }

    // 3f. raw px / bare size literals (skeleton px is acceptable)
    const pxHits = [];
    for (const m of src.matchAll(/\b(\d+)px\b/g)) if (m[1] !== '0' && m[1] !== '1') pxHits.push(m[0]);
    for (const m of src.matchAll(/\b(gap|padding[A-Za-z]*|margin[A-Za-z]*|fontSize|borderRadius)\s*:\s*(\d+)\b/g)) {
      if (m[2] !== '0') pxHits.push(`${m[1]}: ${m[2]}`);
    }
    if (pxHits.length) {
      const uniq = [...new Set(pxHits)].slice(0, 8).join(', ');
      report('warn', file, `raw px/size literal(s): ${uniq}${pxHits.length > 8 ? ' …' : ''} — prefer S(n)/--memox-* (skeleton px is ok)`);
    }
  }

  // 4. summary
  console.log('');
  console.log(`Checked ${screens.length} screen file(s) · ${definedTokens.size} tokens · ${sharedNames.size} shared primitives`);
  console.log(`Result: ${errors} error(s), ${warns} warning(s)`);
  if (errors === 0) console.log('\u2713 UI kit adheres to the shared theme / tokens / components.');
  process.exit(errors ? 1 : 0);
})();
