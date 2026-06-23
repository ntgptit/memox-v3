/* MemoX screen — 12 Study · Review (1 state). The classic flip card: the front
   shows the term; tapping the card flips to the meaning; "Next" advances. Study
   chrome (progress x/N + exit) comes from the shared StudyShell. The front face
   is shown here with a tap-to-flip affordance. Token-driven; composes contract
   classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, StudyShell } = window.MX;

  // The big flip card. Front = term + reading; a quiet hint invites the flip.
  const FlipCard = () => (
    <div style={{ flex: 1, minHeight: 0, display: 'flex' }}>
      <div className="card" data-mx-node="study-session/content-card" style={{
        flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center',
        justifyContent: 'center', gap: S(4), padding: S(6), textAlign: 'center',
      }}>
        <div className="ov" style={{ color: 'var(--memox-text-3)' }}>Term</div>
        <div style={{ fontSize: 'calc(var(--memox-size-display) * 1.9)', fontWeight: 'var(--memox-weight-extrabold)', lineHeight: 1.05, color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>日本</div>
        <div className="muted" style={{ fontSize: 'var(--memox-size-h2)', fontWeight: 'var(--memox-weight-medium)', fontFamily: 'var(--memox-font-serif)' }}>にほん · nihon</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: S(2), marginTop: S(4), color: 'var(--memox-text-3)', fontSize: 'var(--memox-fs-label-medium)', fontWeight: 'var(--memox-weight-bold)', letterSpacing: 'var(--memox-ls-section)', textTransform: 'uppercase' }}>
          <Icon name="rotate-cw" style={{ width: 'var(--memox-icon-sm)', height: 'var(--memox-icon-sm)' }} />Tap to flip
        </div>
      </div>
    </div>
  );

  function Screen() {
    return (
      <StudyShell index={8} total={20}
        footer={
          <div style={{ display: 'flex', gap: S(2) }}>
            <button className="pill-btn outline"><Icon name="rotate-cw" />Flip</button>
            <button className="pill-btn primary" style={{ flex: 1 }}>Next<Icon name="arrow-right" /></button>
          </div>
        }>
        <div style={{ marginBottom: S(3), display: 'flex', justifyContent: 'center' }}>
          <span className="chip reviewing">Japanese · N5</span>
        </div>
        <FlipCard />
      </StudyShell>
    );
  }

  window.MEMOX_KIT.register({
    num: '12',
    title: 'Study · Review',
    states: [
      { label: 'Front', render: () => <Screen /> },
    ],
  });
})();
