/* Onboarding · state: signingIn — Google sign-in in progress (center modal). */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.Onboarding = R.Onboarding || {});

D.signingIn = function (ctx) {
  const { Ic, Spinner } = ctx;
  const overlay = (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px 18px', zIndex: 51 }}>
      <div style={{ width: '100%', maxWidth: 300, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderRadius: 18, padding: '24px 22px', boxShadow: 'var(--memox-shadow-card)', textAlign: 'center', animation: 'memoxDialogIn 200ms cubic-bezier(0.2,0,0,1)' }}>
        <div style={{ width: 52, height: 52, borderRadius: 14, background: 'color-mix(in srgb, var(--memox-primary) 10%, transparent)', color: 'var(--memox-primary)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}>
          <Spinner size={26} />
        </div>
        <div style={{ fontSize: 16, fontWeight: 700, marginBottom: 6 }}>Signing in to Google</div>
        <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5, marginBottom: 14 }}>Continue in the Google sign-in window.</div>
        <button className="pill-btn outline" style={{ height: 36, padding: '0 14px', borderRadius: 'var(--memox-radius-md)', fontSize: 12 }}>Cancel</button>
      </div>
    </div>);
  return { overlay };
};
})();
