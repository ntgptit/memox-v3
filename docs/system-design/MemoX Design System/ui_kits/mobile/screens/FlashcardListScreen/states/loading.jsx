/* FlashcardList · state: loading — skeleton card rows. */
(function () {
const R = (window.MemoXStates = window.MemoXStates || {});
const D = (R.FlashcardList = R.FlashcardList || {});

D.loading = function () {
  const body = [0, 1, 2, 3, 4].map((i) =>
    <div key={i} style={{ marginBottom: 8, padding: '12px 14px', background: 'var(--memox-surface-container-lowest)', border: 'var(--memox-border-ghost)', borderRadius: 12, display: 'grid', gridTemplateColumns: '8px 1fr 36px', gap: 12, alignItems: 'flex-start' }}>
      <span style={{ width: 8, height: 8, borderRadius: 999, marginTop: 6, background: 'var(--memox-surface-container-high)', opacity: 0.5, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
      <div>
        <span style={{ display: 'inline-block', height: 13, width: 100 + i * 18, borderRadius: 6, background: 'var(--memox-surface-container-high)', opacity: 0.55, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
        <span style={{ display: 'block', height: 10, width: 160, borderRadius: 6, background: 'var(--memox-surface-container-high)', opacity: 0.4, marginTop: 6, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
        <span style={{ display: 'block', height: 8, width: 80, borderRadius: 6, background: 'var(--memox-surface-container-high)', opacity: 0.3, marginTop: 8, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
      </div>
      <span />
    </div>
  );
  return { body };
};
})();
