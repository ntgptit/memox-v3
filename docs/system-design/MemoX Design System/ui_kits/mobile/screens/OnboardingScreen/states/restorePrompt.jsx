/* Onboarding · state: restorePrompt — after sign-in, ask before restoring (bottom sheet). */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.Onboarding = R.Onboarding || {});

D.restorePrompt = function (ctx) {
  const { Ic } = ctx;
  const overlay = (
    <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 51, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderTopLeftRadius: 20, borderTopRightRadius: 20, boxShadow: 'var(--memox-shadow-chrome)', animation: 'memoxSheetIn 260ms cubic-bezier(0.2,0,0,1)', padding: '0 0 14px' }}>
      <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 4px' }}>
        <span style={{ width: 36, height: 4, borderRadius: 999, background: 'var(--memox-outline-variant)' }} />
      </div>
      <div style={{ padding: '4px 18px 14px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
          <div style={{ width: 36, height: 36, borderRadius: 'var(--memox-radius-md)', background: 'color-mix(in srgb, var(--memox-streak) 12%, transparent)', color: 'var(--memox-streak)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <Ic name="cloud-download" size={16} color="var(--memox-streak)" />
          </div>
          <div style={{ minWidth: 0 }}>
            <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px' }}>We found a backup</div>
            <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', marginTop: 1, fontVariantNumeric: 'tabular-nums' }}>alex@memox.app · 326 cards · saved 4 days ago</div>
          </div>
        </div>
        <div style={{ fontSize: 14, lineHeight: 1.55, color: 'var(--memox-on-surface)' }}>
          Restoring will pull all decks, cards, and history from Drive onto this device.
        </div>
      </div>
      <div style={{ padding: '0 14px', display: 'flex', gap: 8 }}>
        <button className="pill-btn outline" style={{ flex: 1, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Not now</button>
        <button className="pill-btn primary" style={{ flex: 1.4, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, gap: 6 }}>
          <Ic name="cloud-download" size={14} color="var(--memox-on-primary)" />
          Restore now
        </button>
      </div>
      <div style={{ textAlign: 'center', marginTop: 10, fontSize: 12, color: 'var(--memox-on-surface-variant)' }}>You can do this later from Settings.</div>
    </div>);
  return { overlay };
};
})();
