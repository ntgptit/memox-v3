/* FlashcardList · state: empty — deck has zero cards; dual add/import CTA. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.FlashcardList = R.FlashcardList || {});

D.empty = function (ctx) {
  const { Ic } = ctx;
  const body = (
    <div style={{ marginTop: 8 }}>
      <div className="card" style={{ padding: '32px 22px', textAlign: 'center', marginBottom: 14 }}>
        <div style={{ width: 64, height: 64, borderRadius: 18, background: 'color-mix(in srgb, var(--memox-primary) 10%, transparent)', color: 'var(--memox-primary)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}>
          <Ic name="layers" size={28} color="var(--memox-primary)" />
        </div>
        <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 6 }}>No cards in this deck yet</div>
        <div style={{ fontSize: 14, color: 'var(--memox-on-surface-variant)', lineHeight: 1.55, padding: '0 6px' }}>
          Add your first flashcard to start studying. You can also paste a list of terms or import a file.
        </div>
      </div>
      <button className="pill-btn primary" style={{ width: '100%', height: 44, borderRadius: 13, fontSize: 14, marginBottom: 8 }}>
        <Ic name="plus" size={17} color="var(--memox-on-primary)" />
        Add first flashcard
      </button>
      <button className="pill-btn" style={{ width: '100%', height: 'var(--memox-size-button)', borderRadius: 12, fontSize: 14, background: 'color-mix(in srgb, var(--memox-primary) 8%, transparent)', color: 'var(--memox-primary)', border: 'none', gap: 7 }}>
        <Ic name="upload" size={15} color="var(--memox-primary)" />
        Import cards (CSV, TSV, Anki)
      </button>
      <div style={{ marginTop: 14, padding: '10px 12px', background: 'var(--memox-surface-container-lowest)', borderRadius: 'var(--memox-radius-md)', border: 'var(--memox-border-ghost)', fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5, display: 'flex', gap: 8, alignItems: 'flex-start' }}>
        <Ic name="info" size={13} color="var(--memox-on-surface-variant)" />
        <span>Start study is available once you have at least one card.</span>
      </div>
    </div>);
  return { body };
};
})();
