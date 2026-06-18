/* Onboarding · state: createDeck — bottom sheet to name the first deck. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.Onboarding = R.Onboarding || {});

D.createDeck = function (ctx) {
  const { Ic } = ctx;
  const overlay = (
    <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 51, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderTopLeftRadius: 20, borderTopRightRadius: 20, boxShadow: 'var(--memox-shadow-chrome)', animation: 'memoxSheetIn 260ms cubic-bezier(0.2,0,0,1)', padding: '0 0 14px' }}>
      <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 4px' }}>
        <span style={{ width: 36, height: 4, borderRadius: 999, background: 'var(--memox-outline-variant)' }} />
      </div>
      <div style={{ padding: '4px 18px 14px' }}>
        <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 4 }}>Name your first deck</div>
        <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5 }}>You can rename it or move it into folders anytime.</div>
      </div>
      <div style={{ padding: '0 18px 14px' }}>
        <div className="ov" style={{ marginBottom: 6 }}>Deck name</div>
        <div style={{ height: 44, padding: '0 14px', background: 'var(--memox-surface-container-lowest)', border: '1px solid var(--memox-primary)', borderRadius: 'var(--memox-radius-md)', display: 'flex', alignItems: 'center', gap: 8, fontSize: 14, fontWeight: 600, color: 'var(--memox-on-surface)' }}>
          <span>Korean — TOPIK starter</span>
          <span style={{ display: 'inline-block', width: 2, height: 18, background: 'var(--memox-primary)', animation: 'memoxBlink 1s infinite' }} />
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 14, marginBottom: 6 }}>
          <Ic name="sparkles" size={11} color="var(--memox-on-surface-variant)" />
          <span className="ov">Or try a starter</span>
        </div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
          {['Korean basics', 'Japanese kana', 'Vocabulary', 'GRE words'].map((t) =>
            <button key={t} style={{ height: 28, padding: '0 12px', borderRadius: 999, fontSize: 12, background: 'var(--memox-surface-container-lowest)', border: 'var(--memox-border-ghost)', color: 'var(--memox-on-surface)', fontWeight: 600, fontFamily: 'inherit', cursor: 'pointer' }}>{t}</button>
          )}
        </div>
      </div>
      <div style={{ padding: '4px 14px 0', display: 'flex', gap: 8 }}>
        <button className="pill-btn outline" style={{ flex: 1, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Cancel</button>
        <button className="pill-btn primary" style={{ flex: 1.3, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, gap: 6 }}>
          <Ic name="check" size={14} color="var(--memox-on-primary)" />
          Create deck
        </button>
      </div>
    </div>);
  return { overlay };
};
})();
