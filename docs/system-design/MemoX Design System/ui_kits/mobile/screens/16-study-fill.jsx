/* MemoX screen — 16 Study · Fill (2 states). Type-the-answer: input shows an
   empty field + Check; wrong shows the field in error (red border, the typed
   answer) with the correct answer revealed below. Study chrome from StudyShell;
   field uses the .field.invalid contract state + shared AnswerReveal. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, StudyShell, FormField, AnswerReveal } = window.MX;

  const Prompt = () => (
    <div className="card" style={{ padding: S(5) }}>
      <div className="ov" style={{ color: 'var(--memox-text-3)', marginBottom: S(2) }}>Type the reading</div>
      <div style={{ fontSize: 'calc(var(--memox-size-display) * 1.1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)', lineHeight: 1.1 }}>山</div>
      <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', marginTop: S(1) }}>English: mountain</div>
    </div>
  );

  function Screen({ wrong }) {
    const footer = wrong ? (
      <div style={{ display: 'flex', gap: S(2) }}>
        <button className="pill-btn outline"><Icon name="rotate-ccw" />Retry</button>
        <button className="pill-btn primary" style={{ flex: 1 }}>Next<Icon name="arrow-right" /></button>
      </div>
    ) : (
      <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="check" />Check answer</button>
    );

    return (
      <StudyShell index={wrong ? 14 : 13} total={20} footer={footer}>
        <Prompt />
        <div style={{ marginTop: S(5) }}>
          <FormField label="Your answer" error={wrong ? 'Not quite — see the answer below.' : undefined}>
            {wrong ? (
              <input className="field invalid" defaultValue="yamma" readOnly />
            ) : (
              <input className="field" placeholder="Romaji reading…" autoFocus />
            )}
          </FormField>
        </div>
        {wrong && (
          <div style={{ marginTop: S(4) }}>
            <AnswerReveal label="Correct answer">yama</AnswerReveal>
          </div>
        )}
      </StudyShell>
    );
  }

  window.MEMOX_KIT.register({
    num: '16',
    title: 'Study · Fill',
    states: [
      { label: 'Input', render: () => <Screen wrong={false} /> },
      { label: 'Wrong', render: () => <Screen wrong={true} /> },
    ],
  });
})();
