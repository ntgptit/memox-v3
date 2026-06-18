/* LibrarySearch · state: loading
   Debounced search running — two skeleton result groups. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.LibrarySearch = R.LibrarySearch || {});

D.loading = function (ctx) {
  const { query, Skel } = ctx;
  return (
    <>
      <div style={{ padding: '4px 4px 8px' }}>
        <span className="ov">Searching for "{query}"…</span>
      </div>
      {[0, 1].map((g) =>
        <div key={g} style={{ marginBottom: 14 }}>
          <div style={{ padding: '2px 4px 8px', display: 'flex', gap: 6 }}>
            <Skel w={70} h={9} op={0.4} />
          </div>
          <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
            {[0, 1, 2].map((i) =>
              <div key={i} style={{
                display: 'grid', gridTemplateColumns: '30px 1fr 20px', gap: 12, alignItems: 'center', padding: '12px 14px',
                borderBottom: i < 2 ? 'var(--memox-border-ghost)' : 'none'
              }}>
                <span style={{ width: 26, height: 26, borderRadius: 8, background: 'var(--memox-surface-container-high)', opacity: 0.5, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
                <div>
                  <Skel w={90 + i * 30} h={11} />
                  <div style={{ height: 6 }} />
                  <Skel w={60 + i * 20} h={9} op={0.4} />
                </div>
                <span />
              </div>
            )}
          </div>
        </div>
      )}
    </>);
};
})();
