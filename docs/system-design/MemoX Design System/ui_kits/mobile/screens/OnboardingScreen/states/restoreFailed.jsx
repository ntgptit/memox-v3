/* Onboarding · state: restoreFailed — restore error (center dialog, two paths). */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.Onboarding = R.Onboarding || {});

D.restoreFailed = function (ctx) {
  const { Ic } = ctx;
  const overlay = (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px 18px', zIndex: 51 }}>
      <div style={{ width: '100%', maxWidth: 320, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderRadius: 18, overflow: 'hidden', boxShadow: 'var(--memox-shadow-card)', animation: 'memoxDialogIn 200ms cubic-bezier(0.2,0,0,1)' }}>
        <div style={{ padding: '22px 22px 4px', textAlign: 'center' }}>
          <div style={{ width: 52, height: 52, borderRadius: 14, background: 'color-mix(in srgb, var(--memox-danger) 10%, transparent)', color: 'var(--memox-error)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 12 }}>
            <Ic name="cloud-off" size={22} color="var(--memox-error)" />
          </div>
          <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 6 }}>Restore didn’t finish</div>
          <div style={{ fontSize: 14, color: 'var(--memox-on-surface-variant)', lineHeight: 1.55, padding: '0 6px' }}>
            Nothing was added to your device. You can try again, or start with a fresh deck.
          </div>
        </div>
        <div style={{ padding: '14px 14px 14px', display: 'flex', gap: 8, flexDirection: 'column' }}>
          <button className="pill-btn primary" style={{ height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, gap: 6 }}>
            <Ic name="refresh-cw" size={14} color="var(--memox-on-primary)" />
            Try restore again
          </button>
          <button className="pill-btn outline" style={{ height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Continue without restoring</button>
        </div>
      </div>
    </div>);
  return { overlay };
};
})();
