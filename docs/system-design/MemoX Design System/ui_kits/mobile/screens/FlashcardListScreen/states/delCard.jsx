/* FlashcardList · state: delCard — delete one flashcard, shows the card. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.FlashcardList = R.FlashcardList || {});

D.delCard = function (ctx) {
  const { Ic, Scrim, CardList } = ctx;
  const overlay = (
    <>
      <Scrim />
      <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px 18px', zIndex: 51, pointerEvents: 'none' }}>
        <div style={{ width: '100%', maxWidth: 340, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderRadius: 18, boxShadow: 'var(--memox-shadow-card)', pointerEvents: 'auto', overflow: 'hidden', animation: 'memoxDialogIn 200ms cubic-bezier(0.2,0,0,1)' }}>
          <div style={{ padding: '18px 18px 4px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
              <div style={{ width: 34, height: 34, borderRadius: 'var(--memox-radius-md)', background: 'color-mix(in srgb, var(--memox-danger) 12%, transparent)', color: 'var(--memox-error)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <Ic name="trash-2" size={16} color="var(--memox-error)" />
              </div>
              <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px' }}>Delete this flashcard?</div>
            </div>
            <div style={{ padding: '12px 14px', background: 'var(--memox-surface-container-lowest)', borderRadius: 'var(--memox-radius-md)', border: 'var(--memox-border-ghost)', marginTop: 4 }}>
              <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 3 }}>도서관</div>
              <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)' }}>library, reading room</div>
            </div>
            <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5, marginTop: 12 }}>
              Review history for this card will be removed. Other cards in this deck are unaffected.
            </div>
          </div>
          <div style={{ padding: '14px 14px 14px', display: 'flex', gap: 8 }}>
            <button className="pill-btn outline" style={{ flex: 1, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Cancel</button>
            <button className="pill-btn" style={{ flex: 1.2, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, background: 'var(--memox-error-fill)', color: 'var(--memox-on-error-fill)', border: 'none', fontWeight: 600, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
              <Ic name="trash-2" size={14} color="var(--memox-on-error-fill)" />
              Delete card
            </button>
          </div>
        </div>
      </div>
    </>);
  return { body: CardList(false), overlay };
};
})();
