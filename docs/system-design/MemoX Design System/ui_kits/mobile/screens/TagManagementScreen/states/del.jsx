/* TagManagement · state: del — delete confirmation. Deletes the tag label only,
   never the cards under it. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.TagManagement = R.TagManagement || {});

D.del = function (ctx) {
  const { Ic, Scrim, Dialog, TagList, selectedTag } = ctx;
  const overlay = (
    <>
      <Scrim />
      <Dialog>
        <div style={{ padding: '18px 18px 4px', textAlign: 'center' }}>
          <div style={{ width: 48, height: 48, borderRadius: 14, background: 'color-mix(in srgb, var(--memox-danger) 10%, transparent)', color: 'var(--memox-error)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 12 }}>
            <Ic name="tag" size={22} color="var(--memox-error)" />
          </div>
          <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 6 }}>Delete this tag?</div>
          <div style={{ fontSize: 14, color: 'var(--memox-on-surface-variant)', lineHeight: 1.55, padding: '0 6px' }}>
            The tag <strong style={{ color: 'var(--memox-on-surface)', fontWeight: 700 }}>{selectedTag.name}</strong> will be removed from {selectedTag.count} cards.
          </div>
        </div>
        <div style={{ padding: '14px 18px 4px' }}>
          <div style={{ padding: '10px 12px', background: 'color-mix(in srgb, var(--memox-mastery) 8%, transparent)', border: '1px solid color-mix(in srgb, var(--memox-mastery) 20%, transparent)', borderRadius: 'var(--memox-radius-md)', display: 'flex', gap: 8, alignItems: 'center' }}>
            <Ic name="shield-check" size={15} color="var(--memox-mastery)" />
            <div style={{ flex: 1, fontSize: 12, color: 'var(--memox-on-surface)', lineHeight: 1.5 }}>
              Your <strong style={{ fontWeight: 700 }}>{selectedTag.count} cards are kept</strong>. Only the tag label is removed.
            </div>
          </div>
        </div>
        <div style={{ padding: '14px 14px 14px', display: 'flex', gap: 8 }}>
          <button className="pill-btn outline" style={{ flex: 1, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Cancel</button>
          <button className="pill-btn" style={{ flex: 1.2, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, background: 'var(--memox-error-fill)', color: 'var(--memox-on-error-fill)', border: 'none', fontWeight: 600, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
            <Ic name="trash-2" size={14} color="var(--memox-on-error-fill)" />
            Delete tag
          </button>
        </div>
      </Dialog>
    </>);
  return { body: TagList(false), overlay };
};
})();
