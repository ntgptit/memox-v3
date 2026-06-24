/* MemoX screen — 17 Study result (6 states). End-of-session summary: an accuracy
   ring hero · a stat strip (correct / wrong / next due) · a goal + streak update
   · Done / Keep studying. States: loaded · loading (saving) · goal off · save
   failed (banner + retry) · defensive (missing data fallback) · tough empty
   (no cards studied). Composes contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, IconTile, StatSummary, HeroCard, Banner } = window.MX;

  const Bar = ({ title }) => (
    <div className="appbar">
      <span className="appbar-title" style={{ flex: 1 }}>{title}</span>
      <button className="icon-btn" aria-label="Close" data-mx-node="17-study-result/close-btn"><Icon name="x" /></button>
    </div>
  );

  const Body = ({ children }) => (
    <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  const Footer = ({ children }) => (
    <div style={{ flex: 'none', padding: `${S(3)} var(--memox-space-screen) ${S(5)}`, display: 'flex', flexDirection: 'column', gap: S(2), borderTop: '1px solid var(--memox-border-ghost)' }}>
      {children}
    </div>
  );

  // Accuracy ring hero. `pct` null → unknown ("—"), draws an empty track.
  const ResultHero = ({ pct, title, sub }) => {
    const deg = pct == null ? 0 : Math.round((pct / 100) * 360);
    const ring = pct == null
      ? 'var(--memox-progress-track)'
      : `conic-gradient(var(--memox-rating-correct) ${deg}deg, var(--memox-progress-track) 0)`;
    return (
      <div className="card" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', padding: S(6), gap: S(4) }}>
        <div className="goal-ring" style={{ width: 'calc(var(--memox-size-ring) * 1.6)', height: 'calc(var(--memox-size-ring) * 1.6)', background: ring }}>
          <div className="goal-ring-inner" style={{ width: 'calc(var(--memox-size-ring) * 1.6 - var(--memox-space-4))', height: 'calc(var(--memox-size-ring) * 1.6 - var(--memox-space-4))' }}>
            <div>
              <div style={{ fontSize: 'var(--memox-size-display)', fontWeight: 'var(--memox-weight-extrabold)', lineHeight: 1, color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>
                {pct == null ? '—' : pct + '%'}
              </div>
              <div className="muted" style={{ fontSize: 'var(--memox-fs-label-medium)', fontWeight: 'var(--memox-weight-bold)', marginTop: S(1) }}>accuracy</div>
            </div>
          </div>
        </div>
        <div>
          <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>{title}</div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', marginTop: S(1) }}>{sub}</div>
        </div>
      </div>
    );
  };

  // Goal + streak update card (omitted when goal is off).
  const GoalUpdate = () => (
    <div className="card accent">
      <div className="ov" style={{ color: 'var(--memox-primary)', marginBottom: S(3) }}><Icon name="target" />Goal &amp; streak</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: S(3), marginBottom: S(3) }}>
        <IconTile icon="check" color="var(--memox-primary)" solid />
        <div style={{ flex: 1 }}>
          <div className="title">Daily goal reached</div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>20 / 20 cards today</div>
        </div>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
        <IconTile icon="flame" color="var(--memox-status-learning)" />
        <div style={{ flex: 1 }}>
          <div className="title">12-day streak</div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>+1 from today · keep it going</div>
        </div>
        <span className="chip got"><Icon name="arrow-up" />+1</span>
      </div>
    </div>
  );

  function Screen({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Bar title="Session complete" />
          <div style={{ flex: 1, display: 'grid', placeItems: 'center', padding: S(6) }}>
            <div style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: S(4) }}>
              <div className="spinner" style={{ width: 'var(--memox-size-fab)', height: 'var(--memox-size-fab)' }}></div>
              <div>
                <div className="title" style={{ fontSize: 'var(--memox-size-h2)' }}>Saving your session…</div>
                <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', marginTop: S(1) }}>Updating spaced-repetition schedule</div>
              </div>
            </div>
          </div>
        </div>
      );
    }

    if (variant === 'tough-empty') {
      return (
        <div className="app">
          <Bar title="Session ended" />
          <Body>
            <div style={{ flex: 1, display: 'grid', placeItems: 'center', padding: `${S(6)} 0` }}>
              <HeroCard icon="inbox" tint="var(--memox-text-secondary)" title="No cards studied"
                desc="This session ended before any cards were reviewed, so nothing was scored.">
              </HeroCard>
            </div>
          </Body>
          <Footer>
            <button className="pill-btn primary" style={{ width: '100%' }}>Back to deck</button>
          </Footer>
        </div>
      );
    }

    const goalOff = variant === 'goal-off';
    const failed = variant === 'save-failed';
    const defensive = variant === 'defensive';

    return (
      <div className="app">
        <Bar title="Session complete" />
        <Body>
          {failed && (
            <Banner tone="danger" icon="cloud-off">Couldn't save your results. Your progress is kept locally.</Banner>
          )}
          {defensive && (
            <Banner tone="warn" icon="alert-triangle">Some stats couldn't be calculated for this session.</Banner>
          )}
          {defensive ? (
            <ResultHero pct={null} title="Session saved" sub="Reviewed cards were recorded." />
          ) : (
            <ResultHero pct={85} title="Nice work!" sub="20 cards · Recall · Japanese · N5" />
          )}
          <StatSummary stats={defensive
            ? [['—', 'Correct'], ['—', 'Wrong'], ['9', 'Due next', true]]
            : [['17', 'Correct'], ['3', 'Wrong'], ['9', 'Due next', true]]} />
          {!goalOff && !defensive && <GoalUpdate />}
        </Body>
        <Footer>
          {failed ? (
            <div style={{ display: 'flex', gap: S(2) }}>
              <button className="pill-btn outline"><Icon name="rotate-ccw" />Retry save</button>
              <button className="pill-btn primary" style={{ flex: 1 }} data-mx-node="17-study-result/done-button">Done</button>
            </div>
          ) : (
            <div style={{ display: 'flex', gap: S(2) }}>
              <button className="pill-btn outline"><Icon name="play" />Keep studying</button>
              <button className="pill-btn primary" style={{ flex: 1 }} data-mx-node="17-study-result/done-button"><Icon name="check" />Done</button>
            </div>
          )}
        </Footer>
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '17',
    title: 'Study result',
    states: [
      { label: 'Loaded', render: () => <Screen variant="loaded" /> },
      { label: 'Loading', render: () => <Screen variant="loading" /> },
      { label: 'Goal off', render: () => <Screen variant="goal-off" /> },
      { label: 'Save failed', render: () => <Screen variant="save-failed" /> },
      { label: 'Defensive', render: () => <Screen variant="defensive" /> },
      { label: 'Tough empty', render: () => <Screen variant="tough-empty" /> },
    ],
  });
})();
