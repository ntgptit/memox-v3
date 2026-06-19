// Exports a text DOM-spec for every screen x state of the MemoX mobile UI kit, so
// AI agents WITHOUT strong vision (e.g. small Codex models) can consume the mock
// as exact, measured facts instead of reading pixels or 10k lines of JSX.
//
// Per screen it writes specs/NN-<screen>.md containing:
//   - a FULL element tree for the base (first) state: name, FULL text, bounding box
//     (relative to the phone frame), LAYOUT INTENT (flex/grid direction, gap,
//     justify, align, wrap), repeated-item annotation, and key computed styles
//     resolved back to `--memox-*` token names (theme-neutral — dark remaps the
//     same tokens), with semi-transparent colors emitted as `token@<pct>`;
//   - an ORDERED diff section per remaining state: + added / - removed lines in
//     document order with one line of context, so a state-specific banner/overlay
//     keeps its position relative to the surrounding elements.
//
// Design intent (hierarchy, layout direction, repetition) is what an agent needs
// to write correct Flutter — the renderer already knows it, so we stop discarding
// it (T1/T2). A sha256 of index.html is written to specs/.source-hash so the
// freshness check (tool/ui_kit_shots/check_specs_fresh.mjs, run by verify) fails
// when the mock changes but the specs were not re-exported (T5).
//
// The render and measurement are done by Chrome; this script only orchestrates
// the same row/stepper navigation as export_shots.mjs and serializes the result.
//
// Usage:  cd tool/ui_kit_shots && npm install && npm run export:specs
// Requires: Google Chrome + network (kit loads React/Babel/Lucide from unpkg).

import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, writeFileSync, readFileSync, readdirSync, unlinkSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import puppeteer from 'puppeteer-core';
import { startKitServer } from './serve_kit.mjs';

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

const specFileTemplate = readFileSync(join(here, 'spec-file.template.md'), 'utf8');
const specNodeTemplate = readFileSync(join(here, 'spec-node.template.md'), 'utf8');

function renderTemplate(template, values) {
  return template
    .replace(/{{#(\w+)}}([\s\S]*?){{\/\1}}/g, (match, key, body) => {
      const value = values[key];
      return value ? renderTemplate(body, values) : '';
    })
    .replace(/{{(\w+)}}/g, (match, key) => {
      const value = values[key];
      return value === undefined || value === null ? '' : String(value);
    });
}

function normalizeFinalNewline(text) {
  return text.replace(/\r?\n+$/, '\n');
}

// Runs INSIDE the page. Builds the light-theme token map (computed color -> token
// name) once, then extracts a structured element tree for a given .phone element:
// containment hierarchy, layout intent, repeated-item runs, full text, and
// token-resolved styles.
const pageHelpers = `
window.__mx = (() => {
  let colorToToken = null;
  const specNodeTemplate = ${JSON.stringify(specNodeTemplate)};

  function renderTemplate(template, values) {
    return template
      .replace(/{{#(\\w+)}}([\\s\\S]*?){{\\/\\1}}/g, (match, key, body) => {
        const value = values[key];
        return value ? renderTemplate(body, values) : '';
      })
      .replace(/{{(\\w+)}}/g, (match, key) => {
        const value = values[key];
        return value === undefined || value === null ? '' : String(value);
      });
  }

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

  // Human/agent-readable color string. Semi-transparent colors become
  // #rrggbb@<pct> (base + opacity) instead of an #rrggbbaa 8-digit hex that
  // hides the alpha — consistent with the token@<pct> form below.
  function toHex(rgb) {
    const m = rgb.match(/rgba?\\(([^)]+)\\)/);
    if (!m) return rgb;
    const p = m[1].split(',').map((x) => parseFloat(x));
    if (p.length > 3 && p[3] === 0) return 'transparent'; // a placeholder border that only reserves space
    const h = (n) => Math.round(n).toString(16).padStart(2, '0');
    const base = '#' + h(p[0]) + h(p[1]) + h(p[2]);
    if (p.length > 3 && p[3] < 1) return base + '@' + Math.round(p[3] * 100);
    return base;
  }

  // Resolve a computed color to a token. Semi-transparent colors (overlays/tints)
  // resolve to the OPAQUE base token + an @<pct> suffix instead of a hex, so an
  // agent maps them to "token at N% opacity" rather than hardcoding a color.
  function tokenOr(rgb) {
    const map = buildTokenMap();
    if (map[rgb]) return map[rgb];
    const m = rgb.match(/rgba?\\(([^)]+)\\)/);
    if (m) {
      const p = m[1].split(',').map((x) => parseFloat(x));
      if (p.length > 3 && p[3] < 1) {
        const opaque = 'rgb(' + Math.round(p[0]) + ', ' + Math.round(p[1]) + ', ' + Math.round(p[2]) + ')';
        if (map[opaque]) return map[opaque] + '@' + Math.round(p[3] * 100);
      }
    }
    return toHex(rgb);
  }

  function nodeName(el) {
    const cls = (el.getAttribute('class') || '').split(/\\s+/).filter((c) => c && !c.startsWith('memox'))[0];
    if (el.dataset && el.dataset.lucide) return 'icon:' + el.dataset.lucide;
    const i = el.querySelector(':scope > i[data-lucide]');
    if (el.tagName === 'BUTTON' && i && el.childElementCount === 1) return 'icon-button:' + i.dataset.lucide;
    if (cls) return cls;
    return el.tagName.toLowerCase();
  }

  // Suggested MemoX shared component for an element, grounded in the injected
  // component map (docs/design/component-visual-contract.md). The pill-btn family
  // is disambiguated by the kit's own primary/secondary/outline modifier class.
  // Returns '' when no confident mapping exists (the raw class name + the header
  // note then signal "component mapping unresolved" — never a silent guess).
  function mxHint(el) {
    const classes = (el.getAttribute('class') || '').split(/\\s+/).filter(Boolean);
    if (classes.includes('pill-btn')) {
      if (classes.includes('primary')) return 'MxPrimaryButton';
      if (classes.includes('secondary') || classes.includes('outline')) return 'MxSecondaryButton';
      return 'MxActionButton';
    }
    const map = window.__MX_COMPONENT_MAP || {};
    for (const c of classes) {
      if (map[c]) return map[c];
    }
    return '';
  }

  // Signature used for repeated-item detection: the first non-memox class, else tag.
  function sigOf(el) {
    const cls = (el.getAttribute('class') || '').split(/\\s+/).filter((c) => c && !c.startsWith('memox'))[0];
    return cls || el.tagName.toLowerCase();
  }

  // FULL own text (no truncation) — truncating made copy unrecoverable.
  function ownText(el) {
    let t = '';
    for (const n of el.childNodes) if (n.nodeType === 3) t += n.textContent;
    return t.replace(/\\s+/g, ' ').trim();
  }

  function isLayout(cs) {
    return cs.display === 'flex' || cs.display === 'grid' || cs.display === 'inline-flex' || cs.display === 'inline-grid';
  }

  // A node is worth a line when it carries text/interaction/visible styling (a
  // leaf), OR when it is a layout/grouping container (so the hierarchy survives).
  function meaningfulLeaf(el, cs) {
    if (ownText(el)) return true;
    if (['BUTTON', 'INPUT', 'TEXTAREA', 'SELECT', 'A'].includes(el.tagName)) return true;
    if (el.tagName === 'svg' || (el.dataset && el.dataset.lucide)) return true;
    if (cs.backgroundColor !== TRANSPARENT) return true;
    if (cs.borderTopWidth !== '0px' && cs.borderTopStyle !== 'none') return true;
    if (parseFloat(cs.opacity) < 1) return true;
    return false;
  }
  function emitWorthy(el, cs) {
    return meaningfulLeaf(el, cs) || isLayout(cs) || el.childElementCount >= 2;
  }

  // Layout intent: direction, gap, and main/cross alignment — what turns absolute
  // boxes into a Row/Column/Wrap/Grid in Flutter.
  function layoutBits(cs) {
    if (!isLayout(cs)) return '';
    const b = [];
    if (cs.display.includes('grid')) {
      b.push('grid');
      const t = cs.gridTemplateColumns;
      if (t && t !== 'none') b.push('cols:' + t.split(/\\s+/).filter(Boolean).length);
    } else {
      b.push('flex:' + (cs.flexDirection.startsWith('column') ? 'col' : 'row'));
      if (cs.flexWrap === 'wrap') b.push('wrap');
    }
    const gap = parseFloat(cs.gap) || parseFloat(cs.columnGap) || parseFloat(cs.rowGap) || 0;
    if (gap > 0) b.push('gap:' + Math.round(gap));
    const j = cs.justifyContent;
    if (j && j !== 'normal' && j !== 'flex-start') b.push('justify:' + j.replace('flex-', '').replace('space-', ''));
    const a = cs.alignItems;
    if (a && a !== 'normal' && a !== 'stretch') b.push('align:' + a.replace('flex-', ''));
    return b.join(' ');
  }

  // Full 4-edge box model, collapsed compactly: N (all equal) | V/H (t==b, l==r) | t/r/b/l.
  function edges(t, r, b, l) {
    if (t === r && r === b && b === l) return '' + t;
    if (t === b && l === r) return t + '/' + l;
    return t + '/' + r + '/' + b + '/' + l;
  }
  function boxBits(cs) {
    const out = [];
    const pt = Math.round(parseFloat(cs.paddingTop) || 0), pr = Math.round(parseFloat(cs.paddingRight) || 0),
      pb = Math.round(parseFloat(cs.paddingBottom) || 0), pl = Math.round(parseFloat(cs.paddingLeft) || 0);
    if (pt || pr || pb || pl) out.push('pad:' + edges(pt, pr, pb, pl));
    const mt = Math.round(parseFloat(cs.marginTop) || 0), mr = Math.round(parseFloat(cs.marginRight) || 0),
      mb = Math.round(parseFloat(cs.marginBottom) || 0), ml = Math.round(parseFloat(cs.marginLeft) || 0);
    if (mt || mr || mb || ml) out.push('margin:' + edges(mt, mr, mb, ml));
    return out.join(' ');
  }

  // Constraint intent for a flex item, mapped toward Flutter Expanded/Flexible.
  // Only emitted when the DOM parent is actually a flex container.
  function flexChildBits(el, cs) {
    const p = el.parentElement;
    if (!p) return '';
    const pcs = getComputedStyle(p);
    if (!isLayout(pcs) || pcs.display.includes('grid')) return '';
    const out = [];
    const grow = parseFloat(cs.flexGrow) || 0;
    const shrink = parseFloat(cs.flexShrink);
    const basis = cs.flexBasis;
    if (grow > 0) out.push('grow:' + grow);
    if (!Number.isNaN(shrink) && shrink !== 1) out.push('shrink:' + shrink);
    if (basis && basis !== 'auto') out.push('basis:' + Math.round(parseFloat(basis) || 0));
    const self = cs.alignSelf;
    if (self && self !== 'auto' && self !== 'normal' && self !== 'stretch') out.push('self:' + self.replace('flex-', ''));
    if (grow > 0) out.push('layout_hint:expanded');
    else if (!Number.isNaN(shrink) && shrink > 0 && basis !== 'auto') out.push('layout_hint:flexible');
    return out.join(' ');
  }

  // Explicit min/max sizing — computed width/height are always resolved to px and
  // cannot signal fixed-vs-flexible intent, but min/max constraints do.
  function sizeBits(cs) {
    const out = [];
    const minw = parseFloat(cs.minWidth) || 0, minh = parseFloat(cs.minHeight) || 0;
    if (minw > 0) out.push('minw:' + Math.round(minw));
    if (minh > 0) out.push('minh:' + Math.round(minh));
    if (cs.maxWidth && cs.maxWidth !== 'none') out.push('maxw:' + Math.round(parseFloat(cs.maxWidth) || 0));
    if (cs.maxHeight && cs.maxHeight !== 'none') out.push('maxh:' + Math.round(parseFloat(cs.maxHeight) || 0));
    return out.join(' ');
  }

  // Positioning / scrolling / stacking — needed for pinned bottom bars, overlays,
  // sheets, FABs, and clipped scroll lists.
  function positionBits(cs) {
    const out = [];
    if (cs.position && cs.position !== 'static') out.push('pos:' + cs.position);
    const scrolls = (v) => v === 'auto' || v === 'scroll';
    if (scrolls(cs.overflowX) || scrolls(cs.overflowY)) out.push('layout_hint:scroll');
    if (cs.position === 'sticky' || cs.position === 'fixed') out.push('layout_hint:pinned');
    if (cs.overflowX === 'hidden' || cs.overflowY === 'hidden') out.push('clip');
    if (cs.zIndex && cs.zIndex !== 'auto') out.push('z:' + cs.zIndex);
    return out.join(' ');
  }

  // Decode a non-identity transform into a readable hint (translate/scale/rotate).
  // Handles both matrix() and matrix3d(); sub-pixel/3d GPU hints (translateZ(0),
  // translate3d(0,0,0)) resolve to identity and are skipped (not layout-relevant).
  function transformBit(cs) {
    const t = cs.transform;
    if (!t || t === 'none') return '';
    const nums = (t.match(/-?\\d+(?:\\.\\d+)?(?:e-?\\d+)?/g) || []).map((x) => parseFloat(x));
    let a, b, c, d, e, f;
    if (t.startsWith('matrix3d') && nums.length >= 16) {
      a = nums[0]; b = nums[1]; c = nums[4]; d = nums[5]; e = nums[12]; f = nums[13];
    } else if (nums.length >= 6) {
      [a, b, c, d, e, f] = nums;
    } else {
      return 'transform';
    }
    if (a === 1 && b === 0 && c === 0 && d === 1 && Math.round(e) === 0 && Math.round(f) === 0) return '';
    if (b === 0 && c === 0) {
      if (a === 1 && d === 1) return 'transform:translate(' + Math.round(e) + ',' + Math.round(f) + ')';
      return 'transform:scale(' + (Math.round(a * 100) / 100) + ',' + (Math.round(d * 100) / 100) + ')';
    }
    return 'transform:rotate(' + Math.round((Math.atan2(b, a) * 180) / Math.PI) + ')';
  }

  function styleBits(el, cs) {
    const bits = [];
    if (cs.backgroundColor !== TRANSPARENT) bits.push('bg:' + tokenOr(cs.backgroundColor));
    if (ownText(el)) {
      // font:<size>/<weight>[/<line-height>] — line-height only when it differs
      // meaningfully from the font size (i.e. not the default ~1.0 box).
      const fs = parseFloat(cs.fontSize);
      const lh = parseFloat(cs.lineHeight);
      let font = 'font:' + fs + '/' + cs.fontWeight;
      if (!Number.isNaN(lh) && Math.abs(lh - fs) > 1) font += '/' + Math.round(lh);
      bits.push(font);
      bits.push('color:' + tokenOr(cs.color));
      const ta = cs.textAlign;
      if (ta === 'center' || ta === 'right' || ta === 'end' || ta === 'justify') bits.push('text:' + ta);
      const ls = parseFloat(cs.letterSpacing);
      if (!Number.isNaN(ls) && Math.abs(ls) >= 0.1) bits.push('tracking:' + (Math.round(ls * 10) / 10));
    }
    const r = parseFloat(cs.borderTopLeftRadius);
    if (r > 0) bits.push('r:' + Math.round(r));
    // Borders per side: a uniform 4-side border collapses to border:, but a
    // single-side hairline (a bottom/top divider) keeps its side — otherwise
    // border-bottom dividers were silently dropped.
    const sides = [['t', 'Top'], ['r', 'Right'], ['b', 'Bottom'], ['l', 'Left']];
    const present = sides
      .map(([k, S]) => (cs['border' + S + 'Style'] !== 'none' && parseFloat(cs['border' + S + 'Width']) > 0
        ? { k, w: Math.round(parseFloat(cs['border' + S + 'Width'])), c: tokenOr(cs['border' + S + 'Color']) }
        : null))
      .filter(Boolean);
    if (present.length === 4 && present.every((p) => p.w === present[0].w && p.c === present[0].c)) {
      bits.push('border:' + present[0].w + 'px ' + present[0].c);
    } else {
      for (const p of present) bits.push('border-' + p.k + ':' + p.w + 'px ' + p.c);
    }
    // Elevation: emit the first box-shadow as offsetY/blur (the kit uses shadows
    // on raised surfaces; without this an agent cannot tell a card's elevation).
    // Strip the color first so a bare "0" offset (no px unit) still parses.
    if (cs.boxShadow && cs.boxShadow !== 'none') {
      const lengths = cs.boxShadow.replace(/rgba?\\([^)]*\\)/g, '').replace(/#[0-9a-fA-F]+/g, '');
      const nums = lengths.match(/-?\\d+(?:\\.\\d+)?/g);
      if (nums && nums.length >= 3) bits.push('shadow:' + Math.round(parseFloat(nums[1])) + '/' + Math.round(parseFloat(nums[2])));
      else bits.push('shadow');
    }
    if (parseFloat(cs.opacity) < 1) bits.push('op:' + cs.opacity);
    return bits.join(' ');
  }

  function formatNodeBlock(meta) {
    const indent = '  '.repeat(meta.depth);
    const fieldIndent = indent + '  ';
    const rendered = renderTemplate(specNodeTemplate, {
      indent,
      fieldIndent,
      name: meta.name,
      itemLabel: meta.itemLabel || '',
      text: meta.text || '',
      mx: meta.mx || '',
      box: Boolean(meta.abs || meta.rel),
      abs: meta.abs || '',
      rel: meta.rel || '',
      layout: meta.layout || '',
      flex: meta.flex || '',
      repeat: meta.repeat || '',
      spacing: meta.spacing || '',
      size: meta.size || '',
      position: meta.position || '',
      scroll: meta.scroll || '',
      transform: meta.transform || '',
      style: meta.style || '',
    });
    const lines = rendered.split('\\n').filter((line) => line.length > 0);
    const signature = [
      meta.depth,
      meta.itemLabel || '',
      meta.name,
      meta.text || '',
      meta.mx || '',
      meta.layout || '',
      meta.flex || '',
      meta.repeat || '',
      meta.spacing || '',
      meta.size || '',
      meta.position || '',
      meta.scroll || '',
      meta.transform || '',
      meta.style || '',
    ].join('\u001f');
    return { lines, signature };
  }

  // True when the first <period> children carry real content (text or an icon),
  // so we never label a run of empty skeleton/spacer placeholders as a list.
  function unitHasContent(children, period) {
    for (let k = 0; k < period && k < children.length; k++) {
      const el = children[k];
      if (el.textContent && el.textContent.trim()) return true;
      if (el.querySelector && el.querySelector('[data-lucide], svg')) return true;
    }
    return false;
  }

  // Coarse "kind" of an element: text-bearing / icon-only / other. Used to reject
  // a period-1 run whose children alternate kinds (e.g. a breadcrumb of
  // label,chevron,label,chevron) which is NOT a uniform N-item list.
  function kindOf(el) {
    if (el.textContent && el.textContent.trim()) return 't';
    if (el.dataset && el.dataset.lucide) return 'i';
    if (el.querySelector && el.querySelector('[data-lucide], svg')) return 'i';
    return 'o';
  }

  // Detect a repeating unit among a parent's children: smallest period p (1..6)
  // whose signature pattern repeats >=2 full times. Trailing partial units (e.g. a
  // last row with a chevron instead of a badge) are allowed. Returns the run that
  // covers the most children, or null. Used only to ANNOTATE (never to drop lines).
  function detectUnits(children) {
    const sigs = [...children].map(sigOf);
    const kinds = [...children].map(kindOf);
    const uniformKind = kinds.every((k) => k === kinds[0]);
    let best = null;
    for (let p = 1; p <= 6; p++) {
      // A single-element period only counts as a list when every child is the
      // same kind — otherwise an alternating run (breadcrumb) gets mislabeled.
      if (p === 1 && !uniformKind) continue;
      if (sigs.length < p * 2) break;
      let reps = 1;
      while ((reps + 1) * p <= sigs.length) {
        let ok = true;
        for (let k = 0; k < p; k++) {
          if (sigs[reps * p + k] !== sigs[k]) { ok = false; break; }
        }
        if (!ok) break;
        reps++;
      }
      if (reps >= 2 && p * reps >= 4) {
        const covered = p * reps;
        if (!best || covered > best.covered) best = { period: p, reps, covered };
      }
    }
    if (best && !unitHasContent(children, best.period)) return null;
    return best;
  }

  function extract(phone) {
    const origin = phone.getBoundingClientRect();
    const blocks = [];      // full blocks (with bbox) for the base-state spec
    const signatures = []; // bbox-free structural lines for ordered state diffing

    function walk(el, depth, itemLabel, parentRect) {
      if (depth > 16) return;
      const cs = getComputedStyle(el);
      if (cs.display === 'none' || cs.visibility === 'hidden') return;
      const rect = el.getBoundingClientRect();
      if (rect.width < 1 || rect.height < 1) return;

      const isIcon = el.tagName === 'svg' || (el.dataset && el.dataset.lucide);
      const units = !isIcon && el.childElementCount >= 4 ? detectUnits(el.children) : null;
      let childParentRect = parentRect; // nearest EMITTED ancestor for child rel-geometry

      if (emitWorthy(el, cs)) {
        const name = nodeName(el);
        const text = ownText(el);
        const w = Math.round(rect.width), h = Math.round(rect.height);
        // abs = frame-relative (visual cross-check); rel = offset within the parent
        // box (so an agent reads spacing from the parent, not the whole screen).
        const abs = 'abs:[' + Math.round(rect.x - origin.x) + ',' + Math.round(rect.y - origin.y) + ' ' + w + 'x' + h + ']';
        const rel = 'rel:[' + Math.round(rect.x - parentRect.x) + ',' + Math.round(rect.y - parentRect.y) + ' ' + w + 'x' + h + ']';
        const lay = layoutBits(cs);
        const flex = flexChildBits(el, cs);
        const rep = units ? 'repeat:x' + (units.reps + (units.covered < el.childElementCount ? '+' : '')) + '(unit=' + units.period + ')' : '';
        const box = boxBits(cs);
        const size = sizeBits(cs);
        const posn = positionBits(cs);
        // content height of a scroll viewport (so viewport h vs scrollable content
        // height are distinguishable, not conflated with the element's own bbox).
        const scrolls = cs.overflowX === 'auto' || cs.overflowX === 'scroll' || cs.overflowY === 'auto' || cs.overflowY === 'scroll';
        const scrollh = scrolls && el.scrollHeight > el.clientHeight + 1 ? 'scrollh:' + el.scrollHeight : '';
        const tform = transformBit(cs);
        const sty = styleBits(el, cs);
        // Suggested Mx component (or mx:? when an interactive control has no mapping).
        const hint = mxHint(el);
        const mx = hint ? 'mx:' + hint : (el.tagName === 'BUTTON' || el.tagName === 'A' ? 'mx:?' : '');
        const block = formatNodeBlock({
          depth,
          itemLabel,
          name,
          text,
          mx: mx ? mx.replace(/^mx:/, '') : '',
          abs: abs.replace(/^abs:/, ''),
          rel: rel.replace(/^rel:/, ''),
          layout: lay,
          flex,
          repeat: rep ? rep.replace(/^repeat:/, '') : '',
          spacing: box,
          size,
          position: posn,
          scroll: scrollh,
          transform: tform,
          style: sty,
        });
        blocks.push(block.lines);
        signatures.push(block.signature);
        depth += 1;
        childParentRect = rect;
      }
      if (isIcon) return;

      // Tag the first child of each detected unit so the list structure is explicit.
      let unitMap = null;
      if (units) {
        unitMap = {};
        for (let u = 0; u < units.reps; u++) unitMap[u * units.period] = 'item[' + (u + 1) + ']';
      }
      let idx = 0;
      for (const child of el.children) {
        walk(child, depth, unitMap ? unitMap[idx] : undefined, childParentRect);
        idx += 1;
      }
    }

    for (const child of phone.children) walk(child, 0, undefined, origin);
    return { blocks, signatures };
  }

  return { extract };
})();
`;

// Ordered diff: LCS is computed over the bbox-free SIGNATURE lists (so 1px jitter
// is not a change), but the emitted op carries the geometry-bearing LINE (abs+rel
// bbox), so every added/removed/context line keeps enough geometry to be placed.
// Returns a compact unified view: changes plus one context line at each hunk edge;
// long unchanged runs collapse to a single ellipsis.
function diffSeq(baseSig, curSig, baseBlocks, curBlocks) {
  const n = baseSig.length, m = curSig.length;
  const dp = Array.from({ length: n + 1 }, () => new Int32Array(m + 1));
  for (let i = n - 1; i >= 0; i--) {
    for (let j = m - 1; j >= 0; j--) {
      dp[i][j] = baseSig[i] === curSig[j] ? dp[i + 1][j + 1] + 1 : Math.max(dp[i + 1][j], dp[i][j + 1]);
    }
  }
  const ops = [];
  let i = 0, j = 0;
  while (i < n && j < m) {
    if (baseSig[i] === curSig[j]) { ops.push({ op: ' ', block: curBlocks[j] }); i++; j++; }
    else if (dp[i + 1][j] >= dp[i][j + 1]) { ops.push({ op: '-', block: baseBlocks[i] }); i++; }
    else { ops.push({ op: '+', block: curBlocks[j] }); j++; }
  }
  while (i < n) ops.push({ op: '-', block: baseBlocks[i++] });
  while (j < m) ops.push({ op: '+', block: curBlocks[j++] });
  return ops;
}

function formatDiff(ops) {
  const out = [];
  for (let k = 0; k < ops.length; k++) {
    const o = ops[k];
    if (o.op !== ' ') {
      for (const line of o.block) out.push(o.op + ' ' + line.trimStart());
      continue;
    }
    const nearChange = (k > 0 && ops[k - 1].op !== ' ') || (k < ops.length - 1 && ops[k + 1].op !== ' ');
    if (nearChange) {
      for (const line of o.block) out.push('  ' + line.trimStart());
    }
    else if (out.length && out[out.length - 1] !== '  ...') out.push('  ...');
  }
  return out.length ? out.join('\n') : '(identical)';
}

async function main() {
  if (!existsSync(kitHtml)) throw new Error(`Kit not found: ${kitHtml}`);
  mkdirSync(outDir, { recursive: true });
  for (const f of readdirSync(outDir)) {
    if (f.endsWith('.md')) unlinkSync(join(outDir, f));
  }

  const sourceHash = createHash('sha256').update(readFileSync(kitHtml)).digest('hex');

  // classname -> Mx component map (grounded in component-visual-contract.md).
  const compMapPath = join(here, 'component-map.json');
  const compMap = existsSync(compMapPath) ? (JSON.parse(readFileSync(compMapPath, 'utf8')).map || {}) : {};

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
  // Serve from the design-system root so `../../colors_and_type.css` resolves.
  const kitServer = await startKitServer(resolve(kitDir, '..', '..'));
  await page.goto(`${kitServer.origin}/ui_kits/mobile/index.html`, { waitUntil: 'networkidle2', timeout: 120000 });
  await page.waitForSelector('.row .row-num', { timeout: 120000 });
  await page.addStyleTag({ content: '*,*::before,*::after{animation:none!important;transition:none!important}' });
  await page.evaluate((m) => { window.__MX_COMPONENT_MAP = m; }, compMap);
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
    let baseBlocks = [];
    const sections = [];

    for (let s = 0; s < total; s++) {
      const stateLabel = head.single
        ? 'Default'
        : (await row.evaluate((el) => el.querySelector('.st-label').textContent.trim())).replace(/\s*·\s*\d+\/\d+$/, '');
      await sleep(450);

      // Always measure the LIGHT frame (first frame in "both" view): values are
      // emitted as token names, which the dark theme remaps identically.
      const phone = (await row.$$('.frame-wrap:not(.memox-dark) .phone'))[0];
      const { blocks, signatures } = await phone.evaluate((el) => window.__mx.extract(el));

      if (s === 0) {
        baseLabel = stateLabel;
        baseSignatures = signatures;
        baseBlocks = blocks;
        sections.push(`## Base state: ${stateLabel}\n\n\`\`\`text\n${blocks.map((b) => b.join('\n')).join('\n')}\n\`\`\``);
      } else {
        const ops = diffSeq(baseSignatures, signatures, baseBlocks, blocks);
        const changed = ops.filter((o) => o.op !== ' ').length;
        if (changed > (baseSignatures.length + signatures.length) * 0.6) {
          // Mostly different screen — a diff would be noise; emit it in full.
          sections.push(`## State: ${stateLabel} (full — differs too much from base)\n\n\`\`\`text\n${blocks.map((b) => b.join('\n')).join('\n')}\n\`\`\``);
        } else {
          sections.push(
            `## State: ${stateLabel} (ordered diff vs ${baseLabel})\n\n` +
            `\`\`\`diff\n${formatDiff(ops)}\n\`\`\``,
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
    const fileContent = renderTemplate(specFileTemplate, {
      screen_num: head.num,
      screen_title: head.title,
      sections: sections.join('\n\n'),
    });
    writeFileSync(join(outDir, file), normalizeFinalNewline(fileContent));
    manifest.push({ num: head.num, title: head.title, file, states: total });
  }

  const idx = [
    '# UI Kit DOM Specs — Manifest',
    '',
    'Auto-generated by `tool/ui_kit_shots/export_specs.mjs`. Text extraction of the rendered',
    'UI kit for agents without strong image input: element trees with containment hierarchy,',
    'layout intent, repeated-item runs, bounding boxes, and `--memox-*` token-resolved styles.',
    'Pair with `../shots/*.png` when vision is available.',
    '',
    `Source \`index.html\` sha256: \`${sourceHash}\` (mirror of \`specs/.source-hash\`; the`,
    'freshness check in `tool/verify/run.mjs` fails if `index.html` changed without re-export).',
    '',
    '| # | Screen | Spec file | States |',
    '| --- | --- | --- | --- |',
    ...manifest.map((m) => `| ${m.num} | ${m.title} | \`${m.file}\` | ${m.states} |`),
    '',
    `Total: ${manifest.length} screens · ${manifest.reduce((n, m) => n + m.states, 0)} states.`,
    '',
  ];
  writeFileSync(join(outDir, 'INDEX.md'), normalizeFinalNewline(idx.join('\n')));
  writeFileSync(join(outDir, '.source-hash'), sourceHash + '\n');
  console.log(`done: ${manifest.length} spec files -> ${outDir}`);
  console.log(`source hash: ${sourceHash}`);
  await browser.close();
  await kitServer.close();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
