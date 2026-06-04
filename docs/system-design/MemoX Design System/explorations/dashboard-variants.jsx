/* MemoX — Dashboard "resume" placement explorations (Direction B family).
   All three keep Today's review as the single hero + the Streak/Goal pair,
   and differ only in HOW the paused-session "resume" is surfaced as a light
   secondary affordance (since resume is an occasional utility, not a co-hero).

   Shared primitives mirror ui_kits/mobile/index.html so the mockups read as
   the real app. Tokens come from ../colors_and_type.css (Tokyo Pure Light). */

const { useEffect } = React;

/* ── Status bar ─────────────────────────────────────────── */
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

/* ── Lucide icon ────────────────────────────────────────── */
function Ic({ name, size = 22, color, label }) {
  const ref = React.useRef();
  useEffect(() => {
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
  const a11y = label ? { role: 'img', 'aria-label': label } : { 'aria-hidden': 'true' };
  return <span ref={ref} {...a11y} style={{ display: 'inline-flex', lineHeight: 0 }} />;
}

/* ── Bottom nav ─────────────────────────────────────────── */
function BottomNav({ active = 'home' }) {
  const items = [
    { id: 'home', icon: 'home', label: 'Home' },
    { id: 'library', icon: 'layers', label: 'Library' },
    { id: 'stats', icon: 'bar-chart-3', label: 'Stats' },
    { id: 'settings', icon: 'settings', label: 'Settings' }];
  return (
    <div className="bottom-nav-wrap">
      <div className="bottom-nav">
        {items.map((it) =>
          <div key={it.id} className={"bn-item " + (active === it.id ? 'active' : '')}>
            <span className="bn-pill"><Ic name={it.icon} size={22} /></span>
            <span>{it.label}</span>
          </div>)}
      </div>
    </div>);
}

/* ── App bar (greeting) ─────────────────────────────────── */
function AppBar({ trailing }) {
  return (
    <div className="appbar appbar-lg" style={{
      flexDirection: 'column', alignItems: 'flex-start', gap: 2,
      paddingTop: 18, paddingBottom: 14, position: 'relative'
    }}>
      <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: '-0.5px' }}>Good evening, Alex</div>
      <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)' }}>Tuesday, May 27</div>
      <div style={{ position: 'absolute', right: 14, top: 18, display: 'flex', gap: 4, alignItems: 'center' }}>
        {trailing}
        <button className="icon-btn" title="Search"><Ic name="search" size={18} color="var(--memox-on-surface-variant)" /></button>
        <button className="icon-btn" title="Settings"><Ic name="settings" size={18} color="var(--memox-on-surface-variant)" /></button>
      </div>
    </div>);
}

/* ── Streak + Goal pair (kept as-is per the brief) ──────── */
function SummaryCards() {
  const completedToday = 12, dailyGoal = 20;
  const goalPct = Math.min(completedToday / dailyGoal, 1);
  return (
    <div style={{ display: 'flex', gap: 10, marginBottom: 14 }}>
      <div className="card" style={{ padding: '12px 14px', flex: 1, display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 38, height: 38, borderRadius: 11, background: 'rgba(249,115,22,0.12)', color: 'var(--memox-streak)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Ic name="flame" size={18} color="var(--memox-streak)" />
        </div>
        <div style={{ minWidth: 0 }}>
          <div className="ov">Streak</div>
          <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: '-0.3px', fontVariantNumeric: 'tabular-nums', marginTop: 1 }}>
            11 <span style={{ fontSize: 11, color: 'var(--memox-on-surface-variant)', fontWeight: 600 }}>days</span>
          </div>
        </div>
      </div>
      <div className="card" style={{ padding: '12px 14px', flex: 1, display: 'flex', alignItems: 'center', gap: 12 }}>
        <svg width="38" height="38" viewBox="0 0 40 40" style={{ flexShrink: 0 }}>
          <circle cx="20" cy="20" r="16" fill="none" stroke="var(--memox-surface-container)" strokeWidth="3.5" />
          <circle cx="20" cy="20" r="16" fill="none" stroke="var(--memox-primary)" strokeWidth="3.5" strokeLinecap="round" strokeDasharray="100.5" strokeDashoffset={(1 - goalPct) * 100.5} transform="rotate(-90 20 20)" />
        </svg>
        <div style={{ minWidth: 0 }}>
          <div className="ov">Today’s goal</div>
          <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: '-0.3px', fontVariantNumeric: 'tabular-nums', marginTop: 1 }}>
            12<span style={{ fontSize: 11, color: 'var(--memox-on-surface-variant)', fontWeight: 600 }}> / 20</span>
          </div>
        </div>
      </div>
    </div>);
}

/* ── Today's review — the single hero ───────────────────── */
function TodayHero({ footer }) {
  return (
    <div className="card" style={{
      padding: '16px', marginBottom: footer ? 0 : 10,
      background: 'linear-gradient(135deg, rgba(82,101,245,0.10) 0%, rgba(139,111,245,0.10) 100%)',
      border: '1px solid rgba(82,101,245,0.22)',
      borderBottomLeftRadius: footer ? 0 : 12, borderBottomRightRadius: footer ? 0 : 12
    }}>
      <div className="ov" style={{ display: 'inline-flex', alignItems: 'center', gap: 6, color: 'var(--memox-primary)', marginBottom: 10 }}>
        <Ic name="zap" size={11} color="var(--memox-primary)" />
        Today’s review
      </div>
      <div style={{ fontSize: 24, fontWeight: 700, letterSpacing: '-0.5px', lineHeight: 1.1, fontVariantNumeric: 'tabular-nums', marginBottom: 4 }}>
        23 cards due
      </div>
      <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5, marginBottom: 14 }}>
        Across 3 decks · about 14 minutes
      </div>
      <button className="pill-btn primary" style={{ width: '100%', height: 40, borderRadius: 12, fontSize: 14, gap: 8 }}>
        <Ic name="play" size={16} color="#fff" />
        Start today’s review
      </button>
    </div>);
}

/* ── Start new learning (secondary) ─────────────────────── */
function StartNew() {
  return (
    <button className="pill-btn" style={{
      width: '100%', height: 40, borderRadius: 11, fontSize: 13,
      background: 'rgba(82,101,245,0.08)', color: 'var(--memox-primary)',
      border: 'none', gap: 7, marginBottom: 18
    }}>
      <Ic name="sparkles" size={14} color="var(--memox-primary)" />
      Start new learning
      <span style={{ fontSize: 10, fontWeight: 700, padding: '1px 6px', borderRadius: 999, background: 'rgba(82,101,245,0.14)', color: 'var(--memox-primary)', fontVariantNumeric: 'tabular-nums' }}>6 new</span>
    </button>);
}

/* ── Recent decks ───────────────────────────────────────── */
function RecentDecks() {
  const decks = [
    { n: 'TOPIK II — Vocab', cards: 142, due: 23, last: '2h ago', col: '#5265F5' },
    { n: 'Idioms', cards: 34, due: 3, last: 'yesterday', col: '#8B6FF5' },
    { n: 'Verb conjugation', cards: 148, due: 0, last: 'a week ago', col: '#2BA88B' }];
  return (
    <>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 4px 8px' }}>
        <div className="ov">Recent decks</div>
        <div style={{ color: 'var(--memox-primary)', fontSize: 11, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 3 }}>
          Library <Ic name="chevron-right" size={11} color="var(--memox-primary)" />
        </div>
      </div>
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        {decks.map((d, i, a) =>
          <div key={d.n} style={{ display: 'grid', gridTemplateColumns: '34px 1fr auto', gap: 12, alignItems: 'center', padding: '12px 14px', borderBottom: i < a.length - 1 ? 'var(--memox-border-ghost)' : 'none' }}>
            <div style={{ width: 30, height: 30, borderRadius: 9, background: `${d.col}1F`, color: d.col, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Ic name="layers" size={14} color={d.col} />
            </div>
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 600, letterSpacing: '-0.1px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{d.n}</div>
              <div style={{ fontSize: 11, color: 'var(--memox-on-surface-variant)', marginTop: 1, fontVariantNumeric: 'tabular-nums' }}>{d.cards} cards · last {d.last}</div>
            </div>
            {d.due > 0 ?
              <span style={{ height: 20, padding: '0 7px', borderRadius: 999, background: 'rgba(82,101,245,0.10)', color: 'var(--memox-primary)', fontSize: 10, fontWeight: 700, fontVariantNumeric: 'tabular-nums', display: 'inline-flex', alignItems: 'center' }}>{d.due} due</span> :
              <Ic name="chevron-right" size={15} color="var(--memox-on-surface-variant)" />}
          </div>)}
      </div>
    </>);
}

/* ════════════════════════════════════════════════════════
   VARIANT B1 — Resume as a slim dismissible strip under the
   app bar. Lightest "you have something paused" notice, sits
   above the day's plan; one tap to resume, one to dismiss.
   ════════════════════════════════════════════════════════ */
function DashboardB1() {
  return (
    <div className="app">
      <StatusBar />
      <AppBar />
      <div className="scroll" style={{ padding: '0 14px 14px' }}>
        {/* resume strip */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14,
          padding: '9px 10px 9px 12px', borderRadius: 11,
          background: 'var(--memox-surface-container-low)', border: 'var(--memox-border-ghost)'
        }}>
          <span style={{ width: 7, height: 7, borderRadius: 999, background: 'var(--memox-streak)', flexShrink: 0, animation: 'memoxPulseDot 1.8s ease-in-out infinite' }} />
          <div style={{ flex: 1, minWidth: 0, fontSize: 12, lineHeight: 1.35 }}>
            <span style={{ fontWeight: 700 }}>Resume TOPIK II — Vocab</span>
            <span style={{ color: 'var(--memox-on-surface-variant)' }}> · 7/20 · paused 32m ago</span>
          </div>
          <button className="pill-btn primary" style={{ height: 30, padding: '0 13px', borderRadius: 9, fontSize: 12, gap: 5, flexShrink: 0 }}>
            <Ic name="play" size={12} color="#fff" /> Resume
          </button>
          <button className="icon-btn" style={{ width: 26, height: 26, flexShrink: 0 }} title="Dismiss">
            <Ic name="x" size={13} color="var(--memox-on-surface-variant)" />
          </button>
        </div>
        <SummaryCards />
        <TodayHero />
        <StartNew />
        <RecentDecks />
      </div>
      <BottomNav />
    </div>);
}

/* ════════════════════════════════════════════════════════
   VARIANT B2 — Resume tucked onto the hero's footer. Reads
   as "and you also left one half-done" directly under the
   day's plan, visually subordinate (a quiet attached row).
   ════════════════════════════════════════════════════════ */
function DashboardB2() {
  return (
    <div className="app">
      <StatusBar />
      <AppBar />
      <div className="scroll" style={{ padding: '0 14px 14px' }}>
        <SummaryCards />
        <div style={{ marginBottom: 18 }}>
          <TodayHero footer />
          {/* attached resume row */}
          <button style={{
            width: '100%', display: 'flex', alignItems: 'center', gap: 10,
            padding: '11px 14px', border: 'var(--memox-border-ghost)', borderTop: 'none',
            borderBottomLeftRadius: 12, borderBottomRightRadius: 12,
            background: 'var(--memox-surface-container-low)', textAlign: 'left'
          }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: 'rgba(249,115,22,0.12)', color: 'var(--memox-streak)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <Ic name="rotate-ccw" size={13} color="var(--memox-streak)" />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 12, fontWeight: 700, letterSpacing: '-0.1px' }}>Resume TOPIK II — Vocab</div>
              <div style={{ fontSize: 11, color: 'var(--memox-on-surface-variant)', marginTop: 1 }}>Recall · 7/20 · paused 32m ago</div>
            </div>
            <Ic name="chevron-right" size={15} color="var(--memox-on-surface-variant)" />
          </button>
        </div>
        <StartNew />
        <RecentDecks />
      </div>
      <BottomNav />
    </div>);
}

/* ════════════════════════════════════════════════════════
   VARIANT B3 — Resume nearly disappears: a compact icon
   chip in the app bar (badge dot = something paused). The
   dashboard body is purely the day's plan; resume is a
   "pick back up" affordance you reach for only when you want
   it. Most minimal — closest to "remove from Home" without
   losing the entry point entirely.
   ════════════════════════════════════════════════════════ */
function DashboardB3() {
  return (
    <div className="app">
      <StatusBar />
      <AppBar trailing={
        <button className="icon-btn" title="Resume paused session" style={{ position: 'relative' }}>
          <Ic name="rotate-ccw" size={18} color="var(--memox-on-surface-variant)" />
          <span style={{ position: 'absolute', top: 5, right: 5, width: 7, height: 7, borderRadius: 999, background: 'var(--memox-streak)', border: '1.5px solid var(--memox-surface)' }} />
        </button>
      } />
      <div className="scroll" style={{ padding: '0 14px 14px' }}>
        <SummaryCards />
        <TodayHero />
        <StartNew />
        <RecentDecks />
      </div>
      <BottomNav />
    </div>);
}

/* ── Current (for reference) — both as co-heroes ────────── */
function DashboardCurrent() {
  return (
    <div className="app">
      <StatusBar />
      <AppBar />
      <div className="scroll" style={{ padding: '0 14px 14px' }}>
        {/* CONTINUE STUDYING hero */}
        <div style={{ marginBottom: 14 }}>
          <div className="ov" style={{ padding: '0 4px 8px', display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 6, height: 6, borderRadius: 999, background: 'var(--memox-streak)', display: 'inline-block', animation: 'memoxPulseDot 1.8s ease-in-out infinite' }} />
            Continue studying
          </div>
          <div className="card" style={{ padding: '14px', background: 'linear-gradient(135deg, rgba(249,115,22,0.08) 0%, rgba(82,101,245,0.08) 100%)', border: '1px solid rgba(249,115,22,0.20)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
              <div style={{ width: 42, height: 42, borderRadius: 12, background: 'var(--memox-streak)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <Ic name="pause" size={18} color="#fff" />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 700, letterSpacing: '-0.1px' }}>TOPIK II — Vocab</div>
                <div style={{ fontSize: 11, color: 'var(--memox-on-surface-variant)', marginTop: 2 }}>Recall · 7 / 20 cards · paused 32m ago</div>
                <div style={{ marginTop: 8, height: 4, background: 'rgba(82,101,245,0.15)', borderRadius: 999, overflow: 'hidden' }}>
                  <div style={{ height: '100%', width: '35%', background: 'var(--memox-primary)' }} />
                </div>
              </div>
            </div>
            <div style={{ display: 'flex', gap: 8 }}>
              <button className="pill-btn primary" style={{ flex: 1, height: 40, borderRadius: 11, fontSize: 13, gap: 7 }}>
                <Ic name="play" size={14} color="#fff" /> Resume
              </button>
              <button className="pill-btn outline" style={{ height: 40, padding: '0 14px', borderRadius: 11, fontSize: 12, color: 'var(--memox-on-surface-variant)', borderColor: 'var(--memox-outline-variant)' }}>Discard</button>
            </div>
          </div>
        </div>
        <SummaryCards />
        <TodayHero />
        <StartNew />
        <RecentDecks />
      </div>
      <BottomNav />
    </div>);
}

/* ── Canvas composition ─────────────────────────────────── */
const PHONE_W = 380, PHONE_H = 800;
function PhoneFrame({ children }) {
  return (
    <div style={{ width: PHONE_W, height: PHONE_H, background: 'var(--memox-surface)', position: 'relative', overflow: 'hidden' }}>
      {children}
    </div>);
}

function App() {
  const { DesignCanvas, DCSection, DCArtboard } = window;
  return (
    <DesignCanvas>
      <DCSection id="ref" title="Hiện tại (tham chiếu)" subtitle="Hai hero cạnh tranh — vấn đề cần giải">
        <DCArtboard id="current" label="Now · Continue + Today (2 hero)" width={PHONE_W} height={PHONE_H}>
          <PhoneFrame><DashboardCurrent /></PhoneFrame>
        </DCArtboard>
      </DCSection>
      <DCSection id="b" title="Hướng B — Today's review là hero, resume thành thanh mảnh" subtitle="3 biến thể về độ nhẹ của resume">
        <DCArtboard id="b1" label="B1 · Thanh resume dưới app bar" width={PHONE_W} height={PHONE_H}>
          <PhoneFrame><DashboardB1 /></PhoneFrame>
        </DCArtboard>
        <DCArtboard id="b2" label="B2 · Resume gắn dưới hero" width={PHONE_W} height={PHONE_H}>
          <PhoneFrame><DashboardB2 /></PhoneFrame>
        </DCArtboard>
        <DCArtboard id="b3" label="B3 · Resume thu vào icon ở app bar" width={PHONE_W} height={PHONE_H}>
          <PhoneFrame><DashboardB3 /></PhoneFrame>
        </DCArtboard>
      </DCSection>
    </DesignCanvas>);
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
