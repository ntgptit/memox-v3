/* MemoX screen — 15 Study · Recall (2 states). Active recall: hidden shows only
   the prompt + "Show answer"; revealed surfaces the answer and three self-rate
   buttons (Missed / Partial / Got it) coloured from the self-* tokens. Study
   chrome from StudyShell; reveal + rate buttons are shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, StudyShell, AnswerReveal, RateBtn } = window.MX;

  const Prompt = () => (
    <div className="card" style={{ padding: S(5) }}>
      <div className="ov" style={{ color: 'var(--memox-text-3)', marginBottom: S(2) }}>Recall the meaning</div>
      <div style={{ fontSize: 'calc(var(--memox-size-display) * 1.1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)', lineHeight: 1.1 }}>水曜日</div>
      <div className="muted" style={{ fontSize: 'var(--memox-size-h2)', fontWeight: 'var(--memox-weight-medium)', fontFamily: 'var(--memox-font-serif)', marginTop: S(1) }}>すいようび · suiyoubi</div>
    </div>
  );

  function Screen({ revealed }) {
    const footer = revealed ? (
      <div>
        <div className="ov" style={{ justifyContent: 'center', color: 'var(--memox-text-3)', marginBottom: S(2) }}>How well did you know it?</div>
        <div style={{ display: 'flex', gap: S(2) }}>
          <RateBtn tone="missed" icon="x">Missed</RateBtn>
          <RateBtn tone="partial" icon="minus">Partial</RateBtn>
          <RateBtn tone="got" icon="check">Got it</RateBtn>
        </div>
      </div>
    ) : (
      <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="eye" />Show answer</button>
    );

    return (
      <StudyShell index={revealed ? 12 : 11} total={20} footer={footer}>
        <Prompt />
        {revealed ? (
          <div style={{ marginTop: S(4) }}>
            <AnswerReveal label="Answer">Wednesday</AnswerReveal>
          </div>
        ) : (
          <div style={{ flex: 1, display: 'grid', placeItems: 'center', color: 'var(--memox-text-3)', gap: S(2) }}>
            <div style={{ textAlign: 'center' }}>
              <Icon name="brain" style={{ width: 'var(--memox-icon-lg)', height: 'var(--memox-icon-lg)' }} />
              <div style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-semibold)', marginTop: S(2) }}>Say it in your head, then reveal.</div>
            </div>
          </div>
        )}
      </StudyShell>
    );
  }

  window.MEMOX_KIT.register({
    num: '15',
    title: 'Study · Recall',
    states: [
      { label: 'Hidden', render: () => <Screen revealed={false} /> },
      { label: 'Revealed', render: () => <Screen revealed={true} /> },
    ],
  });
})();
