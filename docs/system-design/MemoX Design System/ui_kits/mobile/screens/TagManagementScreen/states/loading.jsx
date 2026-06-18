/* TagManagement · state: loading — skeleton list. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.TagManagement = R.TagManagement || {});

D.loading = function () {
  const body = (
    <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
      {[0, 1, 2, 3, 4].map((i) =>
        <div key={i} style={{ display: 'grid', gridTemplateColumns: '32px 1fr 30px', gap: 12, alignItems: 'center', padding: '13px 14px', borderBottom: i < 4 ? 'var(--memox-border-ghost)' : 'none' }}>
          <span style={{ width: 28, height: 28, borderRadius: 8, background: 'var(--memox-surface-container-high)', opacity: 0.5, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
          <div>
            <span style={{ display: 'inline-block', height: 11, width: 80 + i * 20, borderRadius: 6, background: 'var(--memox-surface-container-high)', opacity: 0.5, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
            <span style={{ display: 'block', height: 9, width: 50, borderRadius: 6, background: 'var(--memox-surface-container-high)', opacity: 0.35, marginTop: 6, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
          </div>
          <span />
        </div>
      )}
    </div>);
  return { body };
};
})();
