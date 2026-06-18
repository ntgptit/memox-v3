/* Onboarding · state: createForImp — inline form: create a destination deck for an import. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.Onboarding = R.Onboarding || {});

D.createForImp = function (ctx) {
  const { Ic } = ctx;
  const overlay = (
    <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 51, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderTopLeftRadius: 20, borderTopRightRadius: 20, boxShadow: 'var(--memox-shadow-chrome)', animation: 'memoxSheetIn 260ms cubic-bezier(0.2,0,0,1)', padding: '0 0 14px' }}>
      <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 4px' }}>
        <span style={{ width: 36, height: 4, borderRadius: 999, background: 'var(--memox-outline-variant)' }} />
      </div>
      <div style={{ padding: '4px 18px 12px' }}>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '4px 10px', borderRadius: 999, background: 'color-mix(in srgb, var(--memox-mastery) 10%, transparent)', color: 'var(--memox-mastery)', fontSize: 12, fontWeight: 700, letterSpacing: 0.3, textTransform: 'uppercase', marginBottom: 10 }}>
          <Ic name="upload" size={11} color="var(--memox-mastery)" />
          Step 1 of 2
        </div>
        <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 4 }}>Where should the imported cards go?</div>
        <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5 }}>We need a destination deck first. We won’t create it until you pick the file.</div>
      </div>
      <div style={{ padding: '0 18px 14px' }}>
        <div className="ov" style={{ marginBottom: 6 }}>Deck name</div>
        <div style={{ height: 44, padding: '0 14px', background: 'var(--memox-surface-container-lowest)', border: '1px solid var(--memox-primary)', borderRadius: 'var(--memox-radius-md)', display: 'flex', alignItems: 'center', gap: 8, fontSize: 14, fontWeight: 600 }}>
          <span>Imported vocabulary</span>
          <span style={{ display: 'inline-block', width: 2, height: 18, background: 'var(--memox-primary)', animation: 'memoxBlink 1s infinite' }} />
        </div>
        <div style={{ padding: '10px 12px', background: 'color-mix(in srgb, var(--memox-streak) 5%, transparent)', border: '1px solid color-mix(in srgb, var(--memox-streak) 16%, transparent)', borderRadius: 'var(--memox-radius-md)', fontSize: 12, color: 'var(--memox-on-surface)', lineHeight: 1.5, display: 'flex', gap: 8, alignItems: 'flex-start', marginTop: 12 }}>
          <Ic name="info" size={13} color="var(--memox-streak)" />
          <span>If you cancel after this step, the empty deck is discarded — nothing left behind.</span>
        </div>
      </div>
      <div style={{ padding: '4px 14px 0', display: 'flex', gap: 8 }}>
        <button className="pill-btn outline" style={{ flex: 1, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Cancel</button>
        <button className="pill-btn primary" style={{ flex: 1.4, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, gap: 6 }}>
          Continue to import
          <Ic name="arrow-right" size={14} color="var(--memox-on-primary)" />
        </button>
      </div>
    </div>);
  return { overlay };
};
})();
