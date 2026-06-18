/* LibraryOverview · state: deleteFolder
   Sheet "Delete folder" → destructive confirm with type-to-confirm + reassurance
   that cards move to "Unsorted". */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.LibraryOverview = R.LibraryOverview || {});

D.deleteFolder = function (ctx) {
  const { Ic, Dialog, FoldersList } = ctx;
  const overlay = (
    <Dialog>
      <div style={{ padding: '18px 18px 4px', textAlign: 'center' }}>
        <div style={{ width: 48, height: 48, borderRadius: 14, background: 'color-mix(in srgb, var(--memox-danger) 12%, transparent)', color: 'var(--memox-error)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 12 }}>
          <Ic name="folder-x" size={22} color="var(--memox-error)" />
        </div>
        <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 6 }}>Delete this folder?</div>
        <div style={{ fontSize: 14, color: 'var(--memox-on-surface-variant)', lineHeight: 1.55, padding: '0 6px' }}>
          <strong style={{ color: 'var(--memox-on-surface)', fontWeight: 700 }}>Korean</strong> and its 8 decks will be removed from your library.
        </div>
      </div>

      <div style={{ padding: '14px 18px 4px' }}>
        <div style={{ padding: '10px 12px', background: 'color-mix(in srgb, var(--memox-mastery) 8%, transparent)', border: '1px solid color-mix(in srgb, var(--memox-mastery) 20%, transparent)', borderRadius: 'var(--memox-radius-md)', display: 'flex', gap: 8, alignItems: 'center' }}>
          <Ic name="shield-check" size={15} color="var(--memox-mastery)" />
          <div style={{ flex: 1, fontSize: 12, color: 'var(--memox-on-surface)', lineHeight: 1.5 }}>
            Cards in those decks <strong style={{ fontWeight: 700 }}>move to "Unsorted"</strong> — nothing is permanently lost.
          </div>
        </div>
      </div>

      <div style={{ padding: '14px 18px 4px' }}>
        <div className="ov" style={{ marginBottom: 6 }}>Type to confirm</div>
        <div style={{ height: 42, padding: '0 12px', background: 'var(--memox-surface-container-lowest)', border: '1px solid var(--memox-error)', borderRadius: 'var(--memox-radius-md)', display: 'flex', alignItems: 'center', gap: 8, fontSize: 14, fontWeight: 600, color: 'var(--memox-on-surface)' }}>
          <span>Korean</span>
          <span style={{ display: 'inline-block', width: 2, height: 18, background: 'var(--memox-error)', animation: 'memoxBlink 1s infinite' }} />
        </div>
      </div>

      <div style={{ padding: '14px 14px 14px', display: 'flex', gap: 8 }}>
        <button className="pill-btn outline" style={{ flex: 1, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Cancel</button>
        <button className="pill-btn" style={{ flex: 1.2, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, background: 'var(--memox-error-fill)', color: 'var(--memox-on-error-fill)', border: 'none', fontWeight: 600, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
          <Ic name="trash-2" size={14} color="var(--memox-on-error-fill)" />
          Delete folder
        </button>
      </div>
    </Dialog>);
  return { body: FoldersList(), overlay };
};
})();
