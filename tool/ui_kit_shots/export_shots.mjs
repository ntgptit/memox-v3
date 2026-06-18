// Exports every screen x state x theme frame of the MemoX mobile UI kit as PNGs.
//
// The kit (docs/system-design/MemoX Design System/ui_kits/mobile/index.html) renders
// one state at a time per screen behind a stepper, with lazy-rendered frames, so this
// script scrolls each row into view, steps through ALL states, and screenshots the
// light and dark phone frames separately. It also writes shots/INDEX.md as the
// agent-facing manifest.
//
// Usage:  cd tool/ui_kit_shots && npm install && npm run export
// Requires: Google Chrome installed (path auto-detected below) + network access
// (the kit loads React/Babel/Lucide from unpkg).

import { existsSync, mkdirSync, writeFileSync, readdirSync, unlinkSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import puppeteer from 'puppeteer-core';
import { startKitServer } from './serve_kit.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(here, '..', '..');
const kitDir = join(repoRoot, 'docs', 'system-design', 'MemoX Design System', 'ui_kits', 'mobile');
const kitHtml = join(kitDir, 'index.html');
const outDir = join(kitDir, 'shots');

const chromeCandidates = [
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  `${process.env.LOCALAPPDATA}/Google/Chrome/Application/chrome.exe`,
  '/usr/bin/google-chrome',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
];
const chromePath = chromeCandidates.find((p) => p && existsSync(p));
if (!chromePath) {
  console.error('Chrome not found. Set CHROME_PATH or install Google Chrome.');
  process.exit(1);
}

const slug = (s) =>
  String(s)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function main() {
  if (!existsSync(kitHtml)) throw new Error(`Kit not found: ${kitHtml}`);
  mkdirSync(outDir, { recursive: true });
  // Clean stale shots so renames/removed states do not leave orphans behind.
  for (const f of readdirSync(outDir)) {
    if (f.endsWith('.png') || f === 'INDEX.md') unlinkSync(join(outDir, f));
  }

  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: 'new',
    args: ['--allow-file-access-from-files', '--force-device-scale-factor=1'],
    defaultViewport: { width: 1400, height: 1000 },
  });
  const page = await browser.newPage();

  page.on('pageerror', (e) => console.warn('pageerror:', e.message));
  // Serve the kit over HTTP so external `text/babel src=screens/*.jsx` scripts load
  // (browsers block fetch of local files under file://).
  const kitServer = await startKitServer(kitDir);
  await page.goto(`${kitServer.origin}/index.html`, { waitUntil: 'networkidle2', timeout: 120000 });

  // Babel-in-browser compile can take a while; wait for the rows to exist.
  await page.waitForSelector('.row .row-num', { timeout: 120000 });

  // Freeze animations/transitions so screenshots are deterministic.
  await page.addStyleTag({
    content: '*,*::before,*::after{animation:none!important;transition:none!important;caret-color:transparent!important}',
  });

  const rowCount = await page.$$eval('.row', (rows) => rows.length);
  console.log(`rows: ${rowCount}`);

  const manifest = [];
  let shotCount = 0;

  for (let r = 0; r < rowCount; r++) {
    const row = (await page.$$('.row'))[r];
    await row.evaluate((el) => el.scrollIntoView({ block: 'center' }));
    // Lazy frames render once near the viewport.
    await page.waitForFunction(
      (idx) => document.querySelectorAll('.row')[idx].querySelectorAll('.phone').length >= 1,
      { timeout: 30000 },
      r,
    );
    await sleep(350); // settle fonts/lucide icons

    const head = await row.evaluate((el) => {
      const num = el.querySelector('.row-num')?.textContent.trim() ?? '';
      const title = el.querySelector('.row-title')?.textContent.trim() ?? '';
      const label = el.querySelector('.st-label')?.textContent.trim() ?? '';
      const single = !el.querySelector('.stepper');
      return { num, title, label, single };
    });
    const total = head.single ? 1 : Number(head.label.match(/(\d+)\s*$/)?.[1] ?? 1);
    const screenSlug = slug(head.title);
    const entry = { num: head.num, title: head.title, states: [] };
    console.log(`[${head.num}] ${head.title} — ${total} state(s)`);

    for (let s = 0; s < total; s++) {
      const stateLabel = head.single
        ? 'Default'
        : (await row.evaluate((el) => el.querySelector('.st-label').textContent.trim())).replace(/\s*·\s*\d+\/\d+$/, '');
      const stateSlug = slug(stateLabel) || `state-${s + 1}`;
      await sleep(450); // lucide icons re-create after each remount

      const frames = await row.$$('.frame-wrap');
      const files = {};
      for (const frame of frames) {
        const isDark = await frame.evaluate((el) => el.classList.contains('memox-dark'));
        const theme = isDark ? 'dark' : 'light';
        const phone = await frame.$('.phone');
        const file = `${head.num}-${screenSlug}--${stateSlug}--${theme}.png`;
        await phone.screenshot({ path: join(outDir, file) });
        files[theme] = file;
        shotCount++;
      }
      entry.states.push({ label: stateLabel, ...files });

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
    manifest.push(entry);
  }

  // Agent-facing manifest: which file is the mock for which screen/state.
  const lines = [
    '# UI Kit Screenshots — Manifest',
    '',
    'Auto-generated by `tool/ui_kit_shots/export_shots.mjs`. Do not edit by hand;',
    're-run the exporter after any change to `../index.html`.',
    '',
    'Every screen state ships as a light + dark PNG pair at 390px width. These PNGs',
    'are the canonical visual mock reference for UI tasks — read the PNG, not the',
    '10k-line `index.html` source.',
    '',
  ];
  for (const e of manifest) {
    lines.push(`## ${e.num} — ${e.title}`, '');
    lines.push('| State | Light | Dark |');
    lines.push('| --- | --- | --- |');
    for (const st of e.states) {
      lines.push(`| ${st.label} | \`${st.light ?? '—'}\` | \`${st.dark ?? '—'}\` |`);
    }
    lines.push('');
  }
  const totalStates = manifest.reduce((n, e) => n + e.states.length, 0);
  lines.push(`Total: ${manifest.length} screens · ${totalStates} states · ${shotCount} PNGs.`, '');
  writeFileSync(join(outDir, 'INDEX.md'), lines.join('\n'));

  console.log(`done: ${manifest.length} screens, ${totalStates} states, ${shotCount} shots -> ${outDir}`);
  await browser.close();
  await kitServer.close();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
