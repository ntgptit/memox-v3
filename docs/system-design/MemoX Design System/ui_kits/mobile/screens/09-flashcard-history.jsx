/* MemoX screen — 09 Flashcard history (5 states). Activity timeline for one
   card: study events with result + timestamp + duration, under a card summary
   header. App bar (title "History" + back). Token-driven; composes contract
   classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, PillBtn, Chip, HeroCard, EmptyState, Banner, Sk } = window.MX;

  // ---- Data ----------------------------------------------------------------
  // grade -> { icon, tint } maps each review outcome to a calm status color.
  const GRADE = {
    Easy: { icon: 'check-check', tint: 'var(--memox-status-mastered)' },
    Good: { icon: 'check', tint: 'var(--memox-status-reviewing)' },
    Hard: { icon: 'alert-circle', tint: 'var(--memox-status-learning)' },
    Again: { icon: 'rotate-ccw', tint: 'var(--memox-danger)' },
    Created: { icon: 'plus', tint: 'var(--memox-status-new)' },
  };
  const EVENTS = [
    { grade: 'Good', when: 'Today · 9:41', dur: '4.2s' },
    { grade: 'Easy', when: 'Yesterday · 8:05', dur: '2.8s' },
    { grade: 'Again', when: '3 days ago · 21:10', dur: '11.0s' },
    { grade: 'Hard', when: '5 days ago · 7:58', dur: '8.4s' },
    { grade: 'Good', when: 'Mar 2 · 9:30', dur: '5.1s' },
    { grade: 'Created', when: 'Feb 24 · 14:02', dur: null },
  ];

  // ---- App bar -------------------------------------------------------------
  const Bar = () => (
    <div className="appbar">
      <button className="icon-btn" aria-label="Back"><Icon name="arrow-left" /></button>
      <span className="appbar-title" style={{ flex: 1, minWidth: 0, marginLeft: S(2) }}>History</span>
    </div>
  );

  // ---- Card summary header -------------------------------------------------
  const SummaryHead = () => (
    <div className="card" style={{ padding: 'var(--memox-space-5)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
        <span className="icon-tile" style={{ '--tile': 'var(--memox-status-reviewing)' }}><Icon name="square-stack" /></span>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div className="title" style={{ fontSize: 'var(--memox-size-h1)' }}>日本 — Japan</div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>Japanese · N5</div>
        </div>
        <Chip status="reviewing">Box 4</Chip>
      </div>
      <div style={{ display: 'flex', marginTop: S(4), gap: S(1) }}>
        {[['18', 'Reviews'], ['92%', 'Retention'], ['5.4s', 'Avg time']].map(([v, l]) => (
          <div key={l} style={{ flex: 1, textAlign: 'center' }}>
            <div style={{ fontSize: 'var(--memox-size-h2)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', fontVariantNumeric: 'tabular-nums' }}>{v}</div>
            <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', fontWeight: 'var(--memox-weight-semibold)' }}>{l}</div>
          </div>
        ))}
      </div>
    </div>
  );

  // ---- Event row -----------------------------------------------------------
  const EventRow = ({ e }) => {
    const g = GRADE[e.grade];
    return (
      <div className="list-row" style={{ cursor: 'default' }}>
        <span className="icon-tile" style={{ '--tile': g.tint }}><Icon name={g.icon} /></span>
        <div className="list-row-main">
          <div className="list-row-title" style={{ fontWeight: 'var(--memox-weight-bold)' }}>{e.grade === 'Created' ? 'Card created' : `Reviewed · ${e.grade}`}</div>
          <div className="list-row-meta">{e.when}</div>
        </div>
        {e.dur && <span className="list-row-trail" style={{ fontSize: 'var(--memox-fs-body-small)', fontWeight: 'var(--memox-weight-semibold)', color: 'var(--memox-text-secondary)', fontVariantNumeric: 'tabular-nums' }}>{e.dur}</span>}
      </div>
    );
  };

  const Body = ({ children }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-12)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  const Feed = ({ events }) => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
      <div className="ov" style={{ paddingLeft: S(1) }}>Activity</div>
      <div className="list-card">
        {events.map((e, i) => (
          <div key={i}>
            {i > 0 && <div className="hr inset"></div>}
            <EventRow e={e} />
          </div>
        ))}
      </div>
    </div>
  );

  function Screen({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <Sk h="148px" r="var(--memox-radius-card)" />
            <div className="card" style={{ padding: `${S(2)} var(--memox-space-card)`, display: 'flex', flexDirection: 'column', gap: S(4) }}>
              {[0, 1, 2, 3].map((i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
                  <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}>
                    <Sk h="14px" w="50%" /><Sk h="11px" w="34%" />
                  </div>
                  <Sk h="11px" w="32px" />
                </div>
              ))}
            </div>
          </Body>
        </div>
      );
    }

    if (variant === 'error') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <div style={{ flex: 1, display: 'grid', placeItems: 'center' }}>
              <HeroCard icon="cloud-off" tint="var(--memox-danger)" title="Couldn't load history"
                desc="We couldn't fetch this card's activity.">
                <PillBtn variant="primary" icon="rotate-ccw" full>Retry</PillBtn>
              </HeroCard>
            </div>
          </Body>
        </div>
      );
    }

    if (variant === 'empty') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <SummaryHead />
            <EmptyState icon="history" pad={6} title="No history yet"
              desc="Study this card and your reviews will show up here." />
          </Body>
        </div>
      );
    }

    if (variant === 'partial') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <SummaryHead />
            <Feed events={EVENTS.slice(0, 3)} />
            <Banner tone="info" icon="info" action="Retry">Older events couldn't be loaded.</Banner>
          </Body>
        </div>
      );
    }

    // loaded
    return (
      <div className="app">
        <Bar />
        <Body>
          <SummaryHead />
          <Feed events={EVENTS} />
        </Body>
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '09',
    title: 'Flashcard history',
    states: [
      { label: 'Loaded', render: () => <Screen variant="loaded" /> },
      { label: 'Empty', render: () => <Screen variant="empty" /> },
      { label: 'Loading', render: () => <Screen variant="loading" /> },
      { label: 'Error', render: () => <Screen variant="error" /> },
      { label: 'Partial', render: () => <Screen variant="partial" /> },
    ],
  });
})();
