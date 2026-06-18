/* FolderDetail · state: loading — skeleton rows. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.FolderDetail = R.FolderDetail || {});

D.loading = function (ctx) {
  const body = [0, 1, 2, 3].map((i) =>
    <div key={i} className="card" style={{ marginBottom: 8, display: 'grid', gridTemplateColumns: '40px 1fr 18px', gap: 12, alignItems: 'center', padding: '12px 14px' }}>
      <span style={{ width: 36, height: 36, borderRadius: 'var(--memox-radius-md)', background: 'var(--memox-surface-container-high)', opacity: 0.55, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
      <div>
        <span style={{ display: 'inline-block', height: 11, width: 100 + i * 30, borderRadius: 6, background: 'var(--memox-surface-container-high)', opacity: 0.55, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
        <span style={{ display: 'block', height: 4, width: '100%', borderRadius: 999, background: 'var(--memox-surface-container-high)', opacity: 0.35, marginTop: 8, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
      </div>
      <span />
    </div>
  );
  return { body };
};
})();
