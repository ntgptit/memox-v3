// Exports a text DOM-spec for every screen x state of the MemoX mobile UI kit, so
// AI agents WITHOUT strong vision (e.g. small Codex models) can consume the mock
// as exact, measured facts instead of reading pixels or 10k lines of JSX.
//
// Per screen it writes specs/NN-<screen>.md containing:
//   - a FULL element tree for the base (first) state: name, text, bounding box
//     (relative to the phone frame), and key computed styles resolved back to
//     `--memox-*` token names (theme-neutral — dark remaps the same tokens);
//   - a DELTA section per remaining state: structural lines added/removed vs base
//     (token-cheap: a state usually differs by a banner/overlay/empty body).
//
// The render and measurement are done by Chrome; this script only orchestrates
// the same row/stepper navigation as export_shots.mjs and serializes the result.
//
// Usage:  cd tool/ui_kit_shots && npm install && npm run export:specs
// Requires: Google Chrome + network (kit loads React/Babel/Lucide from unpkg).

import { existsSync, mkdirSync, writeFileSync, readdirSync, unlinkSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import puppeteer from 'puppeteer-core';

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(here, '..', '..');
const kitDir = join(repoRoot, 'docs', 'system-design', 'MemoX Design System', 'ui_kits', 'mobile');
const kitHtml = join(kitDir, 'index.html');
const outDir = join(kitDir, 'specs');

const chromeCandidates = [
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  `${process.env.LOCALAPPDATA}/Google/Chrome/Application/chrome.exe`,
  '/usr/bin/google-chrome',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
];
const chromePath = chromeCandidates.find((p) => p && existsSync(p));
if (!chromePath) {
  console.error('Chrome not found. Install Google Chrome.');
  process.exit(1);
}

const slug = (s) =>
  String(s)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Runs INSIDE the page. Builds the light-theme token map (computed color -> token
// name) once, then extracts a compact element tree for a given .phone element.
const pageHelpers = `
window.__mx = (() => {
  let colorToToken = null;

  function buildTokenMap() {
    if (colorToToken) return colorToToken;
    const raw = {};
    for (const sheet of document.styleSheets) {
      let rules;
      try { rules = sheet.cssRules; } catch { continue; }
      for (const rule of rules) {
        if (!rule.style || !rule.selectorText) continue;
        if (rule.selectorText.includes('memox-dark')) continue; // light values only
        for (let k = 0; k < rule.style.length; k++) {
          const prop = rule.style[k];
          if (prop.startsWith('--memox-')) raw[prop] = rule.style.getPropertyValue(prop).trim();
        }
      }
    }
    const probe = document.createElement('div');
    document.body.appendChild(probe);
    colorToToken = {};
    for (const [name, value] of Object.entries(raw)) {
      if (!value || value.includes('gradient') || value.includes('blur') || value.includes('solid')) continue;
      probe.style.color = '';
      probe.style.color = value;
      if (!probe.style.color) continue; // not a color
      const rgb = getComputedStyle(probe).color;
      if (!(rgb in colorToToken)) colorToToken[rgb] = name.replace('--memox-', '');
    }
    probe.remove();
    return colorToToken;
  }

  const TRANSPARENT = 'rgba(0, 0, 0, 0)';

  function toHex(rgb) {
    const m = rgb.match(/rgba?\\(([^)]+)\\)/);
    if (!m) return rgb;
    const p = m[1].split(',').map((x) => parseFloat(x));
    const h = (n) => Math.round(n).toString(16).padStart(2, '0');
    let out = '#' + h(p[0]) + h(p[1]) + h(p[2]);
    if (p.length > 3 && p[3] < 1) out += h(p[3] * 255);
    return out;
  }

  function tokenOr(rgb) {
    const map = buildTokenMap();
    return map[rgb] || toHex(rgb);
  }

  function nodeName(el) {
    const cls = (el.getAttribute('class') || '').split(/\\s+/).filter((c) => c && !c.startsWith('memox'))[0];
    if (el.dataset && el.dataset.lucide) return 'icon:' + el.dataset.lucide;
    const i = el.querySelector(':scope > i[data-lucide]');
    if (el.tagName === 'BUTTON' && i && el.childElementCount === 1) return 'icon-button:' + i.dataset.lucide;
    if (cls) return cls;
    return el.tagName.toLowerCase();
  }

  function ownText(el) {
    let t = '';
    for (const n of el.childNodes) if (n.nodeType === 3) t += n.textContent;
    t = t.replace(/\\s+/g, ' ').trim();
    if (t.length > 48) t = t.slice(0, 45) + '...';
    return t;
  }

  // A node is worth a line when it carries text, interaction, or visible styling.
  function meaningful(el, cs) {
    if (ownText(el)) return true;
    if (['BUTTON', 'INPUT', 'TEXTAREA', 'SELECT', 'A'].includes(el.tagName)) return true;
    if (el.tagName === 'svg' || (el.dataset && el.dataset.lucide)) return true;
    if (cs.backgroundColor !== TRANSPARENT) return true;
    if (cs.borderTopWidth !== '0px' && cs.borderTopStyle !== 'none') return true;
    if (parseFloat(cs.opacity) < 1) return true;
    return false;
  }

  function styleBits(el, cs) {
    const bits = [];
    if (cs.backgroundColor !== TRANSPARENT) bits.push('bg:' + tokenOr(cs.backgroundColor));
    if (ownText(el)) {
      bits.push('font:' + parseFloat(cs.fontSize) + '/' + cs.fontWeight);
      bits.push('color:' + tokenOr(cs.color));
    }
    const r = parseFloat(cs.borderTopLeftRadius);
    if (r > 0) bits.push('r:' + Math.round(r));
    const pt = parseFloat(cs.paddingTop), pl = parseFloat(cs.paddingLeft);
    if (pt > 0 || pl > 0) bits.push('pad:' + Math.round(pt) + '/' + Math.round(pl));
    if (cs.borderTopStyle !== 'none' && parseFloat(cs.borderTopWidth) > 0)
      bits.push('border:' + Math.round(parseFloat(cs.borderTopWidth)) + 'px ' + tokenOr(cs.borderTopColor));
    if (parseFloat(cs.opacity) < 1) bits.push('op:' + cs.opacity);
    return bits.join(' ');
  }

  function extract(phone) {
    const origin = phone.getBoundingClientRect();
    const lines = [];      // full lines (with bbox) for the base-state spec
    const signatures = []; // bbox-free structural lines for state diffing

    function walk(el, depth) {
      if (depth > 14) return;
      const cs = getComputedStyle(el);
      if (cs.display === 'none' || cs.visibility === 'hidden') return;
      const rect = el.getBoundingClientRect();
      if (rect.width < 1 || rect.height < 1) return;

      const isIcon = el.tagName === 'svg' || (el.dataset && el.dataset.lucide);
      if (meaningful(el, cs)) {
        const name = nodeName(el);
        const text = ownText(el);
        const ind = '  '.repeat(depth);
        const bbox = '[' + Math.round(rect.x - origin.x) + ',' + Math.round(rect.y - origin.y) +
          ' ' + Math.round(rect.width) + 'x' + Math.round(rect.height) + ']';
        const bits = styleBits(el, cs);
        const core = name + (text ? ' "' + text + '"' : '');
        lines.push(ind + '- ' + core + ' ' + bbox + (bits ? ' ' + bits : ''));
        signatures.push(ind + '- ' + core + (bits ? ' ' + bits : ''));
        depth += 1;
      }
      if (isIcon) return; // never descend into svg internals
      for (const child of el.children) walk(child, depth);
    }

    for (const child of phone.children) walk(child, 0);
    return { lines, signatures };
  }

  return { extract };
})();
`;

async function main() {
  if (!existsSync(kitHtml)) throw new Error(`Kit not found: ${kitHtml}`);
  mkdirSync(outDir, { recursive: true });
  for (const f of readdirSync(outDir)) {
    if (f.endsWith('.md')) unlinkSync(join(outDir, f));
  }

  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: 'new',
    args: ['--allow-file-access-from-files', '--force-device-scale-factor=1'],
    defaultViewport: { width: 1400, height: 1000 },
  });
  const page = await browser.newPage();
  page.on('pageerror', (e) => console.warn('pageerror:', e.message));
  await page.goto(pathToFileURL(kitHtml).href, { waitUntil: 'networkidle2', timeout: 120000 });
  await page.waitForSelector('.row .row-num', { timeout: 120000 });
  await page.addStyleTag({ content: '*,*::before,*::after{animation:none!important;transition:none!important}' });
  await page.evaluate(pageHelpers);

  const rowCount = await page.$$eval('.row', (rows) => rows.length);
  const manifest = [];

  for (let r = 0; r < rowCount; r++) {
    const row = (await page.$$('.row'))[r];
    await row.evaluate((el) => el.scrollIntoView({ block: 'center' }));
    await page.waitForFunction(
      (idx) => document.querySelectorAll('.row')[idx].querySelectorAll('.phone').length >= 1,
      { timeout: 30000 },
      r,
    );
    await sleep(350);

    const head = await row.evaluate((el) => ({
      num: el.querySelector('.row-num')?.textContent.trim() ?? '',
      title: el.querySelector('.row-title')?.textContent.trim() ?? '',
      label: el.querySelector('.st-label')?.textContent.trim() ?? '',
      single: !el.querySelector('.stepper'),
    }));
    const total = head.single ? 1 : Number(head.label.match(/(\d+)\s*$/)?.[1] ?? 1);
    console.log(`[${head.num}] ${head.title} — ${total} state(s)`);

    let baseLabel = '';
    let baseSignatures = [];
    const sections = [];

    for (let s = 0; s < total; s++) {
      const stateLabel = head.single
        ? 'Default'
        : (await row.evaluate((el) => el.querySelector('.st-label').textContent.trim())).replace(/\s*·\s*\d+\/\d+$/, '');
      await sleep(450);

      // Always measure the LIGHT frame (first frame in "both" view): values are
      // emitted as token names, which the dark theme remaps identically.
      const phone = (await row.$$('.frame-wrap:not(.memox-dark) .phone'))[0];
      const { lines, signatures } = await phone.evaluate((el) => window.__mx.extract(el));

      if (s === 0) {
        baseLabel = stateLabel;
        baseSignatures = signatures;
        sections.push(`## Base state: ${stateLabel}\n\n\`\`\`text\n${lines.join('\n')}\n\`\`\``);
      } else {
        const baseSet = new Set(baseSignatures);
        const curSet = new Set(signatures);
        const added = signatures.filter((l) => !baseSet.has(l));
        const removed = baseSignatures.filter((l) => !curSet.has(l));
        const churn = added.length + removed.length;
        if (churn > (baseSignatures.length + signatures.length) * 0.6) {
          // Mostly different screen — a delta would be noise; emit it in full.
          sections.push(`## State: ${stateLabel} (full — differs too much from base)\n\n\`\`\`text\n${lines.join('\n')}\n\`\`\``);
        } else {
          const fmt = (arr) => (arr.length ? arr.map((l) => l.trimStart()).join('\n') : '(none)');
          sections.push(
            `## State: ${stateLabel} (delta vs ${baseLabel})\n\n` +
            `Added:\n\`\`\`text\n${fmt(added)}\n\`\`\`\n\n` +
            `Removed:\n\`\`\`text\n${fmt(removed)}\n\`\`\``,
          );
        }
      }

      if (!head.single && s < total - 1) {
        const next = await row.$('.stepper button[aria-label="Next state"]');
        await next.evaluate((el) => el.click());
        await page.waitForFunction(
          (idx, expected) =>
            document.querySelectorAll('.row')[idx].querySelector('.st-label').textContent.includes(`${expected}/`),
          { timeout: 15000 },
          r,
          s + 2,
        );
      }
    }

    const screenSlug = slug(head.title);
    const file = `${head.num}-${screenSlug}.md`;
    const headerLines = [
      `# ${head.num} — ${head.title} — DOM spec`,
      '',
      'Auto-generated by `tool/ui_kit_shots/export_specs.mjs` from the rendered UI kit. Do not',
      'edit by hand; re-run the exporter after any `../index.html` change.',
      '',
      'Reading guide: each line is one visible element —',
      '`- name "own text" [x,y WxH] bg:<token> font:<size/weight> color:<token> r:<radius> pad:<top/left>`.',
      'Coordinates are px relative to the 390x780 phone frame (light theme measured; dark remaps',
      'the same `--memox-*` tokens). Token names map to Flutter symbols via',
      '`docs/design/design-token-mapping.md`; raw hex means no token matched — treat as a gap,',
      'not a license to hardcode. Mock copy/data must not be copied into the app',
      '(`docs/design/mock-design-index.md`). Visual reference PNGs: `../shots/` (see',
      '`../shots/INDEX.md`).',
      '',
    ];
    writeFileSync(join(outDir, file), headerLines.join('\n') + sections.join('\n\n') + '\n');
    manifest.push({ num: head.num, title: head.title, file, states: total });
  }

  const idx = [
    '# UI Kit DOM Specs — Manifest',
    '',
    'Auto-generated by `tool/ui_kit_shots/export_specs.mjs`. Text extraction of the rendered',
    'UI kit for agents without strong image input: exact element trees, bounding boxes, and',
    '`--memox-*` token-resolved styles. Pair with `../shots/*.png` when vision is available.',
    '',
    '| # | Screen | Spec file | States |',
    '| --- | --- | --- | --- |',
    ...manifest.map((m) => `| ${m.num} | ${m.title} | \`${m.file}\` | ${m.states} |`),
    '',
    `Total: ${manifest.length} screens · ${manifest.reduce((n, m) => n + m.states, 0)} states.`,
    '',
  ];
  writeFileSync(join(outDir, 'INDEX.md'), idx.join('\n'));
  console.log(`done: ${manifest.length} spec files -> ${outDir}`);
  await browser.close();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
