/* MemoX Mobile — shared primitives & layout chrome
   Loaded FIRST (before every screen file). Wrapped in an IIFE; publishes the
   shared chrome to window so each screen file can read it via
   const { StatusBar, Ic, BottomNav, Breadcrumb, OfflineBanner, StudyTopBar, masteryColor } = window;
   Edit shared chrome (status bar, bottom nav, icon wrapper, study top bar, mastery ramp) here. */
(function () {
const { useState, useEffect } = React;

function StatusBar() {
  return (
    <div className="statusbar">
      <span>9:41</span>
      <span style={{ display: 'flex', gap: 4, alignItems: 'center' }}>
        <svg width="16" height="12" viewBox="0 0 16 12" fill="currentColor"><path d="M1 11h2V7H1v4zm4 0h2V4H5v7zm4 0h2V1H9v10zm4 0h2V8h-2v3z" /></svg>
        <svg width="14" height="12" viewBox="0 0 14 12" fill="currentColor"><path d="M7 10.3a1.2 1.2 0 1 0 0 2.4 1.2 1.2 0 0 0 0-2.4zm0-3a3 3 0 0 1 2.12.88l1.06-1.06a4.5 4.5 0 0 0-6.36 0l1.06 1.06A3 3 0 0 1 7 7.3zm0-3a6 6 0 0 1 4.24 1.76l1.07-1.07a7.5 7.5 0 0 0-10.62 0l1.07 1.07A6 6 0 0 1 7 4.3z" /></svg>
        <svg width="22" height="12" viewBox="0 0 22 12" fill="none"><rect x="1" y="1" width="18" height="10" rx="2" stroke="currentColor" strokeOpacity=".4" /><rect x="2.5" y="2.5" width="13" height="7" rx="1" fill="currentColor" /><rect x="20" y="4" width="1.5" height="4" rx=".5" fill="currentColor" /></svg>
      </span>
    </div>);

}

// Single-color mastery fill — replaces tri-stop gradient.
// Returns the appropriate status color token based on percentage thresholds.
function masteryColor(pct) {
  if (pct < 0.34) return 'var(--memox-status-learning)'; // amber — early
  if (pct < 0.67) return 'var(--memox-status-reviewing)'; // primary — mid
  return 'var(--memox-status-mastered)'; // green — high
}

function Ic({ name, size = 22, color, label }) {
  const ref = React.useRef();
  React.useEffect(() => {
    if (ref.current && window.lucide) {
      ref.current.innerHTML = '';
      const i = document.createElement('i');
      i.setAttribute('data-lucide', name);
      ref.current.appendChild(i);
      window.lucide.createIcons({ icons: window.lucide.icons });
      const svg = ref.current.querySelector('svg');
      if (svg) {
        svg.setAttribute('width', size);
        svg.setAttribute('height', size);
        if (color) svg.style.stroke = color;
      }
    }
  }, [name, size, color]);
  // Icons are decorative by default (the surrounding button/text carries meaning).
  // Pass `label` only when the icon is the sole carrier of meaning.
  const a11y = label ? { role: 'img', 'aria-label': label } : { 'aria-hidden': 'true' };
  return <span ref={ref} {...a11y} style={{ display: 'inline-flex', lineHeight: 0 }} />;
}

/* Breadcrumb — folder/deck/card hierarchy path. Last segment is the current location. */
function Breadcrumb({ segments }) {
  return (
    <div className="scroll-x" style={{
      display: 'flex', alignItems: 'center', gap: 4,
      padding: '2px 14px 8px',
      fontSize: 12
    }}>
      {segments.map((s, i) => {
        const last = i === segments.length - 1;
        return (
          <React.Fragment key={i}>
            <span style={{
              color: last ? 'var(--memox-on-surface)' : 'var(--memox-on-surface-variant)',
              fontWeight: last ? 700 : 500,
              whiteSpace: 'nowrap',
              cursor: last ? 'default' : 'pointer',
              letterSpacing: 0.1
            }}>{s.label}</span>
            {!last && <Ic name="chevron-right" size={12} color="var(--memox-outline)" />}
          </React.Fragment>);

      })}
    </div>);

}

function BottomNav({ active, onChange }) {
  const items = [
  { id: 'home', icon: 'home', label: 'Home' },
  { id: 'library', icon: 'layers', label: 'Library' },
  { id: 'stats', icon: 'bar-chart-3', label: 'Stats' },
  { id: 'settings', icon: 'settings', label: 'Settings' }];

  return (
    <div className="bottom-nav-wrap">
      <div className="bottom-nav" role="navigation" aria-label="Primary">
        {items.map((it) =>
        <button type="button" key={it.id}
          aria-current={active === it.id ? 'page' : undefined}
          aria-label={it.label}
          className={"bn-item " + (active === it.id ? 'active' : '')} onClick={() => onChange(it.id)}>
            <span className="bn-pill"><Ic name={it.icon} size={22} /></span>
            <span>{it.label}</span>
          </button>
        )}
      </div>
    </div>);

}

/* Offline banner — shared, reusable connectivity-lost notice.
   Local-first voice: reassure first, never alarm. role="status" so AT announces
   it politely. Reuse on any surface that attempts Drive sync (Dashboard, Library,
   Study result). Flutter mapping: a MaterialBanner / inline Container driven by a
   connectivity stream; copy via l10n keys. */
function OfflineBanner() {
  return (
    <div role="status" style={{
      display: 'flex', alignItems: 'flex-start', gap: 10,
      padding: '10px 14px', marginBottom: 14,
      background: 'var(--memox-surface-container)',
      border: 'var(--memox-border-ghost)', borderRadius: 12
    }}>
      <Ic name="cloud-off" size={16} color="var(--memox-on-surface-variant)" />
      <div style={{ flex: 1, fontSize: 12, lineHeight: 1.55 }}>
        <strong style={{ fontWeight: 700 }}>You’re offline.</strong>{' '}
        <span style={{ color: 'var(--memox-on-surface-variant)' }}>Your cards are saved on this device. Drive sync resumes when you reconnect.</span>
      </div>
    </div>);
}

/* ─────── Shared: SearchField — real mobile search input (not a desktop shortcut) ───────
   Replaces the old static-span + Cmd-K affordance. Renders as a tappable field with a
   leading search glyph, placeholder/value, and a trailing CLEAR (when filled) or VOICE
   (when empty) button — the two affordances a phone search actually offers. Height is the
   input token (52). Flutter: TextField(prefixIcon: search, suffixIcon: clear|mic). */
function SearchField({ placeholder = 'Search', value = '', active = false, onClick, style }) {
  const filled = !!(value && value.length);
  return (
    <div role="search" onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 10,
      height: 'var(--memox-size-input)', padding: '0 6px 0 14px',
      background: active ? 'var(--memox-surface-container-lowest)' : 'var(--memox-surface-container)',
      border: active ? '1px solid var(--memox-primary)' : 'var(--memox-border-ghost)',
      borderRadius: 'var(--memox-radius-input)', cursor: 'text',
      transition: 'background 160ms var(--memox-ease-standard), border-color 160ms var(--memox-ease-standard)',
      ...style
    }}>
      <Ic name="search" size={18} color={active ? 'var(--memox-primary)' : 'var(--memox-on-surface-variant)'} />
      <span style={{
        flex: 1, minWidth: 0, fontSize: 16, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
        color: filled ? 'var(--memox-on-surface)' : 'var(--memox-on-surface-variant)'
      }}>
        {filled ? value : placeholder}
        {active &&
          <span style={{ display: 'inline-block', width: 2, height: 18, verticalAlign: 'text-bottom', marginLeft: 1, background: 'var(--memox-primary)', animation: 'memoxBlink 1s infinite' }} />}
      </span>
      {filled ?
        <button className="icon-btn" aria-label="Clear search" style={{ width: 36, height: 36 }}>
          <Ic name="x" size={18} color="var(--memox-on-surface-variant)" />
        </button> :
        <button className="icon-btn" aria-label="Search by voice" style={{ width: 36, height: 36 }}>
          <Ic name="mic" size={18} color="var(--memox-on-surface-variant)" />
        </button>}
    </div>);

}

/* ─────── Shared: Badge — one count/status pill for every screen ───────
   Tonal by default (soft tint + colored label), or `solid` for a filled pill.
   Roomy padding + tabular nums fix the cramped ‘23due” rendering. Always feed it
   text WITH the unit (‘23 due”) so the space is part of the label.
   Flutter: a small Chip / Container(pill). */
function Badge({ children, tone = 'primary', solid = false, style }) {
  const map = {
    primary: 'var(--memox-primary)',
    streak:  'var(--memox-streak)',
    mastery: 'var(--memox-mastery)',
    danger:  'var(--memox-error)',
    neutral: 'var(--memox-on-surface-variant)'
  };
  const c = map[tone] || map.primary;
  return (
    <span style={{
      height: 22, padding: '0 9px', borderRadius: 999, flexShrink: 0,
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 4,
      fontSize: 12, fontWeight: 700, lineHeight: 1, whiteSpace: 'nowrap', fontVariantNumeric: 'tabular-nums',
      color: solid ? 'var(--memox-on-primary)' : c,
      background: solid ? c : `color-mix(in srgb, ${c} 12%, transparent)`,
      ...style
    }}>{children}</span>);

}

/* ─────── Shared: Study top bar (close + mode badge + progress + counter) ─────── */
function StudyTopBar({ mode, accent = 'var(--memox-primary)', accentBg = 'color-mix(in srgb, var(--memox-primary) 10%, transparent)', current, total, onClose }) {
  return (
    <div className="appbar" style={{ justifyContent: 'space-between' }}>
      <button className="icon-btn" onClick={onClose}><Ic name="x" size={20} /></button>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, flex: 1, margin: '0 6px' }}>
        <span style={{
          fontSize: 12, fontWeight: 700, letterSpacing: 1.2, textTransform: 'uppercase',
          color: accent, padding: '3px 8px', background: accentBg, borderRadius: 999
        }}>{mode}</span>
        <div style={{ flex: 1, height: 4, background: 'var(--memox-surface-container)', borderRadius: 999, overflow: 'hidden' }}>
          <div style={{ height: '100%', width: `${current / total * 100}%`, background: accent, transition: 'width 200ms cubic-bezier(0.2,0,0,1)' }} />
        </div>
      </div>
      <div style={{ fontSize: 12, fontWeight: 600, fontVariantNumeric: 'tabular-nums', color: 'var(--memox-on-surface-variant)' }}>{current} / {total}</div>
    </div>);

}

/* ════════════════════════════════════════════════════════════════════════
   SHARED MOBILE LAYOUT PRIMITIVES
   One layout vocabulary for every screen, kept deliberately close to the
   Flutter widget tree so this mock translates 1:1 later. Spacing & bottom
   clearance are token-derived (see .app vars in index.html + LAYOUT.md) —
   never hand-tuned per screen.

   Conceptual mapping
     MobileScaffold → Scaffold + SafeArea
     ScreenHeader   → AppBar
     ScreenScroll   → Expanded( SingleChildScrollView )   (a.k.a. the body)
     BottomBar      → Scaffold.bottomNavigationBar / persistentFooterButtons
     Fab            → Scaffold.floatingActionButton  (the ONLY pinned content)
   Pinned/absolute positioning is reserved for true chrome only: FAB, bottom
   nav, sheets, scrims, toasts, modal overlays — never normal content.
   ════════════════════════════════════════════════════════════════════════ */

/* MobileScaffold — the column shell every screen shares.
   Children render in flow: header → scroll body → bottom bar. Pinned chrome
   (fab, overlay) layers on top via absolute positioning and is passed
   separately so it never interferes with the in-flow column.
     <MobileScaffold
        header={<ScreenHeader …/>}
        bottomBar={<BottomNav …/>}            // or a sticky footer
        fab={<Fab …/>}                         // optional, pinned
        overlay={sheetOrDialogNode}>           // optional, pinned full-bleed
       …scroll children…
     </MobileScaffold>
   `clearance` ('base' | 'fab' | 'fab-nav') is forwarded to the inner
   ScreenScroll so its bottom padding matches the pinned chrome present. */
function MobileScaffold({ header, children, bottomBar, fab, overlay, clearance = 'base', scrollProps = {}, style }) {
  return (
    <div className="app" style={style}>
      <StatusBar />
      {header}
      <ScreenScroll clearance={clearance} {...scrollProps}>{children}</ScreenScroll>
      {fab || null}
      {bottomBar || null}
      {overlay || null}
    </div>);
}

/* ScreenScroll — the single scrollable body. Flutter: Expanded(SingleChildScrollView).
   Horizontal gutter + bottom clearance come from tokens; `clearance` picks the
   variant so the last item always clears any pinned chrome:
     'base'    → nav / sticky footer / plain screen   (comfort gap only)
     'fab'     → screen has a FAB, no bottom nav
     'fab-nav' → screen has a FAB floating above the nav
   Extra className/style still compose (e.g. grid bodies, custom top padding). */
function ScreenScroll({ clearance = 'base', className = '', style, children, ...rest }) {
  const variant = clearance === 'fab' ? ' scroll-fab' : clearance === 'fab-nav' ? ' scroll-fab-nav' : '';
  return (
    <div className={('scroll' + variant + (className ? ' ' + className : '')).trim()} style={style} {...rest}>
      {children}
    </div>);
}

/* ScreenHeader — standard app bar. Flutter: AppBar(leading, title, actions).
   `leading`/`actions` are nodes (icon buttons); `large` switches to the taller
   title treatment. Keeps every screen's top chrome structurally identical. */
function ScreenHeader({ leading, title, actions, large = false, center = false, style, children }) {
  if (children) return <div className={'appbar' + (large ? ' appbar-lg' : '')} style={style}>{children}</div>;
  return (
    <div className={'appbar' + (large ? ' appbar-lg' : '')} style={style}>
      {leading || null}
      <div className="title" style={{ flex: 1, textAlign: center ? 'center' : 'left', fontSize: large ? 22 : undefined, fontWeight: 700, letterSpacing: '-0.3px' }}>{title}</div>
      {actions ? <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>{actions}</div> : null}
    </div>);
}

/* BottomBar — in-flow bottom chrome wrapper for sticky footers / commit bars
   (Save, Done, Cancel/Confirm). Flutter: Scaffold.bottomNavigationBar.
   A sibling of the scroll — it never overlaps content, so the scroll only needs
   the 'base' comfort clearance. Carries the device safe-area inset. */
function BottomBar({ children, style }) {
  return (
    <div style={{
      flexShrink: 0, padding: '10px var(--screen-gutter) calc(16px + env(safe-area-inset-bottom, 0px))',
      borderTop: 'var(--memox-border-ghost)', background: 'var(--memox-surface)',
      display: 'flex', flexDirection: 'column', gap: 8, ...style
    }}>{children}</div>);
}

/* Fab — shared extended FloatingActionButton (pinned chrome). Flutter:
   FloatingActionButton.extended. Position/safe-area come from .fab tokens;
   pass `aboveNav` on screens that also show the bottom nav so it lifts clear. */
function Fab({ icon, label, onClick, aboveNav = false, style }) {
  return (
    <button type="button" className={'fab' + (aboveNav ? ' fab-above-nav' : '')} onClick={onClick} aria-label={label} style={style}>
      {icon ? <Ic name={icon} size={18} color="var(--memox-on-primary)" /> : null}
      {label ? <span>{label}</span> : null}
    </button>);
}

Object.assign(window, { StatusBar, masteryColor, Ic, Breadcrumb, BottomNav, OfflineBanner, SearchField, Badge, StudyTopBar, MobileScaffold, ScreenScroll, ScreenHeader, BottomBar, Fab });
})();
