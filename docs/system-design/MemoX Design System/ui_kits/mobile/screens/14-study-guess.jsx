/* MemoX screen — 14 Study · Guess (1 state). A prompt plus five A–E options
   (pick one). Shown here AFTER answering: the chosen option was wrong (red), the
   correct one is revealed (green), the rest dim. Study chrome from StudyShell;
   options are the shared StudyOption (.choice). Token-driven. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, StudyShell, StudyOption } = window.MX;

  // answered snapshot: picked C (wrong), B is correct.
  const OPTIONS = [
    { k: 'A', t: 'Sunday', state: null, dim: true },
    { k: 'B', t: 'Tuesday', state: 'correct', mark: 'check' },
    { k: 'C', t: 'Thursday', state: 'wrong', mark: 'x' },
    { k: 'D', t: 'Saturday', state: null, dim: true },
    { k: 'E', t: 'Monday', state: null, dim: true },
  ];

  function Screen() {
    return (
      <StudyShell index={5} total={20}
        footer={
          <button className="pill-btn primary" style={{ width: '100%' }}>Next<Icon name="arrow-right" /></button>
        }>
        <div className="card" style={{ marginBottom: S(5), padding: S(5) }}>
          <div className="ov" style={{ color: 'var(--memox-text-3)', marginBottom: S(2) }}>What does this mean?</div>
          <div style={{ fontSize: 'calc(var(--memox-size-display) * 1.1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)', lineHeight: 1.1 }}>火曜日</div>
          <div className="muted" style={{ fontSize: 'var(--memox-size-h2)', fontWeight: 'var(--memox-weight-medium)', fontFamily: 'var(--memox-font-serif)', marginTop: S(1) }}>かようび · kayoubi</div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
          {OPTIONS.map((o) => (
            <StudyOption key={o.k} k={o.k} state={o.state} mark={o.mark} dim={o.dim}>{o.t}</StudyOption>
          ))}
        </div>
      </StudyShell>
    );
  }

  window.MEMOX_KIT.register({
    num: '14',
    title: 'Study · Guess',
    states: [
      { label: 'Answered', render: () => <Screen /> },
    ],
  });
})();
