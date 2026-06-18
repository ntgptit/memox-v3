/* FlashcardList · state: delDeck — delete the whole deck, type-to-confirm. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.FlashcardList = R.FlashcardList || {});

D.delDeck = function (ctx) {
  const { Ic, Scrim, CardList } = ctx;
  const overlay = (
    <>
      <Scrim />
      <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px 18px', zIndex: 51, pointerEvents: 'none' }}>
        <div style={{ width: '100%', maxWidth: 340, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderRadius: 18, boxShadow: 'var(--memox-shadow-card)', pointerEvents: 'auto', overflow: 'hidden', animation: 'memoxDialogIn 200ms cubic-bezier(0.2,0,0,1)' }}>
          <div style={{ padding: '18px 18px 4px', textAlign: 'center' }}>
            <div style={{ width: 48, height: 48, borderRadius: 14, background: 'color-mix(in srgb, var(--memox-danger) 12%, transparent)', color: 'var(--memox-error)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 12 }}>
              <Ic name="layers" size={22} color="var(--memox-error)" />
            </div>
            <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 6 }}>Delete this deck?</div>
            <div style={{ fontSize: 14, color: 'var(--memox-on-surface-variant)', lineHeight: 1.55, padding: '0 6px' }}>
              <strong style={{ color: 'var(--memox-on-surface)', fontWeight: 700 }}>TOPIK II — Vocab</strong> and its 142 cards will be removed from this folder.
            </div>
          </div>
          <div style={{ padding: '14px 18px 4px' }}>
            <div className="ov" style={{ marginBottom: 6 }}>Type the deck name to confirm</div>
            <div style={{ height: 42, padding: '0 12px', background: 'var(--memox-surface-container-lowest)', border: '1px solid var(--memox-error)', borderRadius: 'var(--memox-radius-md)', display: 'flex', alignItems: 'center', gap: 8, fontSize: 14, fontWeight: 600, color: 'var(--memox-on-surface)' }}>
              <span>TOPIK II — Vo</span>
              <span style={{ display: 'inline-block', width: 2, height: 18, background: 'var(--memox-error)', animation: 'memoxBlink 1s infinite' }} />
            </div>
          </div>
          <div style={{ padding: '14px 14px 14px', display: 'flex', gap: 8 }}>
            <button className="pill-btn outline" style={{ flex: 1, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Cancel</button>
            <button className="pill-btn" style={{ flex: 1.2, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, background: 'var(--memox-error-fill)', color: 'var(--memox-on-error-fill)', border: 'none', fontWeight: 600, opacity: 0.5, pointerEvents: 'none', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
              <Ic name="trash-2" size={14} color="var(--memox-on-error-fill)" />
              Delete deck
            </button>
          </div>
        </div>
      </div>
    </>);
  return { body: CardList(false), overlay };
};
})();
