/* MemoX Mobile — AppearanceScreen · MAIN
   ────────────────────────────────────────────────────────────────────────
   Folder layout:
     AppearanceScreen/
       AppearanceScreen.jsx  ← shared layout, rendered from the active theme mode
       states/               ← one file per state in window.MemoXStates.Appearance

   The three states only change which theme card is selected, so each state file
   returns its mode:
     window.MemoXStates.Appearance.<name> = () => ({ mode: 'system'|'light'|'dark' })
   and MAIN renders the shared theme/accent/display layout from it. */
(function () {
const { StatusBar, masteryColor, Ic, Breadcrumb, BottomNav, OfflineBanner, StudyTopBar } = window;

const selectedSeed = 'indigo';
const themes = [
  { id: 'system', label: 'System', desc: 'Match phone' },
  { id: 'light', label: 'Light', desc: 'Tokyo Pure' },
  { id: 'dark', label: 'Dark', desc: 'Tokyo Nebula' }
];
const seeds = [
  { id: 'indigo', label: 'Indigo', hex: '#5265F5' },
  { id: 'violet', label: 'Violet', hex: '#A78BFA' },
  { id: 'teal', label: 'Teal', hex: '#4DB6AC' },
  { id: 'rose', label: 'Rose', hex: '#E57373' },
  { id: 'amber', label: 'Amber', hex: '#FFB74D' },
  { id: 'sage', label: 'Sage', hex: '#81C784' }
];

const Toggle = ({ on }) =>
  <span role="switch" aria-checked={on} style={{ display: 'inline-block', position: 'relative', width: 44, height: 26, borderRadius: 999, flexShrink: 0, background: on ? 'var(--memox-primary)' : 'var(--memox-surface-container-high)' }}>
    <span style={{ position: 'absolute', top: 3, left: on ? 21 : 3, width: 20, height: 20, borderRadius: 999, background: 'var(--memox-surface-bright)', boxShadow: 'var(--memox-shadow-soft)' }} />
  </span>;

const Preview = ({ kind }) => {
  const dark = kind === 'dark';
  const split = kind === 'system';
  const line = dark ? '#2C356E' : '#DAE0EF';
  return (
    <div style={{ height: 62, borderRadius: 10, overflow: 'hidden', position: 'relative', background: dark ? '#0A0E27' : '#F7F9FE', border: '1px solid rgba(124,133,171,0.18)' }}>
      {split && <div style={{ position: 'absolute', top: 0, right: 0, bottom: 0, width: '50%', background: '#0A0E27' }} />}
      <div style={{ position: 'absolute', left: 8, top: 9, width: 20, height: 20, borderRadius: 6, background: '#5265F5' }} />
      <div style={{ position: 'absolute', left: 8, top: 35, width: 28, height: 5, borderRadius: 999, background: line }} />
      <div style={{ position: 'absolute', left: 8, top: 45, width: 18, height: 5, borderRadius: 999, background: line }} />
    </div>);
};

/* ════════════ SCREEN ════════════ */
function AppearanceScreen({ go, state = 'system' }) {
  const States = (window.MemoXStates && window.MemoXStates.Appearance) || {};
  const mod = States[state] || States.system;
  const cfg = (mod ? mod() : {}) || {};
  const mode = cfg.mode || 'system';

  return (
    <div className="app">
      <StatusBar />
      <div className="appbar">
        <button className="icon-btn" onClick={() => go('settings')}>
          <Ic name="arrow-left" size={20} />
        </button>
        <div className="title" style={{ fontSize: 16, fontWeight: 700 }}>Appearance</div>
        <div style={{ width: 40 }} />
      </div>

      <div className="scroll">
        <div className="ov" style={{ padding: '0 4px 8px' }}>Theme</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, marginBottom: 18 }}>
          {themes.map((t) => {
            const sel = mode === t.id;
            return (
              <div key={t.id} role="button" tabIndex={0} aria-pressed={sel} style={{ borderRadius: 16, padding: 8, cursor: 'pointer', background: 'var(--memox-surface-bright)', border: sel ? '2px solid var(--memox-primary)' : '1px solid var(--memox-outline-variant)', boxShadow: sel ? '0 1px 2px rgba(15,22,56,0.05)' : 'none' }}>
                <Preview kind={t.id} />
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 4, marginTop: 8 }}>
                  <span style={{ fontSize: 13, fontWeight: 600 }}>{t.label}</span>
                  {sel && <Ic name="check" size={14} color="var(--memox-primary)" />}
                </div>
                <div style={{ fontSize: 11, color: 'var(--memox-on-surface-variant)', marginTop: 1 }}>{t.desc}</div>
              </div>);
          })}
        </div>

        <div className="ov" style={{ padding: '0 4px 8px' }}>Accent color</div>
        <div className="card" style={{ marginBottom: 18 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', gap: 6 }}>
            {seeds.map((s) => {
              const sel = selectedSeed === s.id;
              return (
                <div key={s.id} role="button" tabIndex={0} aria-pressed={sel} title={s.label} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7, cursor: 'pointer' }}>
                  <span style={{ width: 38, height: 38, borderRadius: 999, background: s.hex, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', boxShadow: sel ? '0 0 0 2px var(--memox-surface-bright), 0 0 0 4px ' + s.hex : 'none' }}>
                    {sel && <Ic name="check" size={16} color="#fff" />}
                  </span>
                  <span style={{ fontSize: 10.5, color: sel ? 'var(--memox-on-surface)' : 'var(--memox-on-surface-variant)', fontWeight: sel ? 600 : 500 }}>{s.label}</span>
                </div>);
            })}
          </div>
        </div>

        <div className="ov" style={{ padding: '0 4px 8px' }}>Display</div>
        <div className="card" style={{ padding: 0, overflow: 'hidden', marginBottom: 8 }}>
          {[
            { ic: 'contrast', label: 'High contrast', sub: 'Stronger borders and text', on: false },
            { ic: 'zap-off', label: 'Reduce motion', sub: 'Minimize animations and transitions', on: false, last: true }
          ].map((r) =>
            <div key={r.label} style={{ display: 'grid', gridTemplateColumns: '34px 1fr auto', gap: 12, alignItems: 'center', padding: '13px 14px', borderBottom: r.last ? 'none' : 'var(--memox-border-ghost)' }}>
              <div style={{ width: 30, height: 30, borderRadius: 9, background: 'color-mix(in srgb, var(--memox-primary) 8%, transparent)', color: 'var(--memox-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Ic name={r.ic} size={15} color="var(--memox-primary)" />
              </div>
              <div style={{ minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: '-0.1px' }}>{r.label}</div>
                <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', marginTop: 2, lineHeight: 1.45 }}>{r.sub}</div>
              </div>
              <Toggle on={r.on} />
            </div>
          )}
        </div>

        <div style={{ textAlign: 'center', fontSize: 12, color: 'var(--memox-on-surface-variant)', padding: '4px 0 16px', lineHeight: 1.5 }}>
          Changes apply instantly.
        </div>
      </div>
    </div>);
}

Object.assign(window, { AppearanceScreen });
})();
