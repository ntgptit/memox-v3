/* Onboarding · state: importHandoff — transient bridge before opening the import screen. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.Onboarding = R.Onboarding || {});

D.importHandoff = function (ctx) {
  const { Ic, Spinner } = ctx;
  const overlay = (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px 18px', zIndex: 51 }}>
      <div style={{ width: '100%', maxWidth: 300, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderRadius: 18, padding: '22px 22px', boxShadow: 'var(--memox-shadow-card)', textAlign: 'center', animation: 'memoxDialogIn 200ms cubic-bezier(0.2,0,0,1)' }}>
        <div style={{ width: 44, height: 44, borderRadius: 12, background: 'color-mix(in srgb, var(--memox-mastery) 12%, transparent)', color: 'var(--memox-mastery)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 12 }}>
          <Ic name="check" size={20} color="var(--memox-mastery)" />
        </div>
        <div style={{ fontSize: 16, fontWeight: 700, marginBottom: 4 }}>Deck ready</div>
        <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5, marginBottom: 14 }}>"Imported vocabulary" was created. Opening the import screen…</div>
        <Spinner size={16} />
      </div>
    </div>);
  return { overlay };
};
})();
