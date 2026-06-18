/* Onboarding · state: restoring — restore in progress (center modal + progress). */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.Onboarding = R.Onboarding || {});

D.restoring = function (ctx) {
  const { Spinner } = ctx;
  const overlay = (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px 18px', zIndex: 51 }}>
      <div style={{ width: '100%', maxWidth: 320, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderRadius: 18, padding: '24px 22px', boxShadow: 'var(--memox-shadow-card)', textAlign: 'center', animation: 'memoxDialogIn 200ms cubic-bezier(0.2,0,0,1)' }}>
        <div style={{ width: 52, height: 52, borderRadius: 14, background: 'color-mix(in srgb, var(--memox-primary) 10%, transparent)', color: 'var(--memox-primary)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}>
          <Spinner size={26} />
        </div>
        <div style={{ fontSize: 16, fontWeight: 700, marginBottom: 4 }}>Restoring your library</div>
        <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5, marginBottom: 14 }}>Pulling 326 cards from Drive. Don’t close the app yet.</div>
        <div style={{ height: 5, background: 'var(--memox-surface-container)', borderRadius: 999, overflow: 'hidden' }}>
          <div style={{ height: '100%', width: '42%', background: 'var(--memox-primary)', borderRadius: 999, animation: 'memoxProgPulse 1.4s ease-in-out infinite' }} />
        </div>
        <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', marginTop: 8, fontVariantNumeric: 'tabular-nums' }}>136 of 326</div>
      </div>
    </div>);
  return { overlay };
};
})();
