/* MemoX screen — 02 Dashboard (9 states). The "today" hub: resume studying,
   streak/goal, cards due, recent decks. Token-driven; composes contract classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  // Shared primitives — single source of truth (screens/_shared.jsx).
  const { Icon, S, IconTile, TileLg, Progress, ListRow, HeroCard, Banner, BottomNav, Sk } = window.MX;

  // ---- Header --------------------------------------------------------------
  const Header = () => (
    <div className="appbar-lg">
      <div style={{ display: 'flex', alignItems: 'flex-end', width: '100%', gap: S(2) }}>
        <div className="appbar-titles">
          <div className="appbar-subtitle">Thursday, 19 June</div>
          <span className="appbar-title">Good evening, An</span>
        </div>
        <span className="spacer"></span>
        <button className="icon-btn" aria-label="Search"><Icon name="search" /></button>
        <button className="icon-btn" aria-label="Settings"><Icon name="settings" /></button>
      </div>
    </div>
  );

  // ---- Resume card ---------------------------------------------------------
  const ResumeCard = ({ multi }) => (
    <div>
      <div className="ov" style={{ marginBottom: S(2) }}>
        <span className="status-dot" style={{ '--dot': 'var(--memox-primary)' }}></span>CONTINUE STUDYING
      </div>
      <div className="card">
        <div style={{ display: 'flex', alignItems: 'center', gap: S(3), marginBottom: S(3) }}>
          <TileLg icon="pause" tint="var(--memox-primary)" solid />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="title" style={{ fontSize: 'var(--memox-size-h2)' }}>Japanese · N5</div>
            <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>Recall · 7/20 cards · paused 32m ago</div>
          </div>
        </div>
        <div style={{ marginBottom: S(4) }}><Progress value={35} /></div>
        <div style={{ display: 'flex', gap: S(2) }}>
          <button className="pill-btn secondary" style={{ flex: 1 }}><Icon name="play" />Resume</button>
          <button className="pill-btn outline">Discard</button>
        </div>
        {multi && (
          <div style={{ display: 'flex', justifyContent: 'center', marginTop: S(3) }}>
            <span className="chip"><Icon name="pause" />+2 sessions paused</span>
          </div>
        )}
      </div>
    </div>
  );

  // ---- Stats row -----------------------------------------------------------
  const StreakCard = () => (
    <div className="card" style={{ flex: 1 }}>
      <IconTile icon="flame" color="var(--memox-status-learning)" style={{ marginBottom: S(3) }} />
      <div style={{ fontSize: 'var(--memox-size-title)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', lineHeight: 1 }}>11</div>
      <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', fontWeight: 'var(--memox-weight-semibold)' }}>day streak</div>
    </div>
  );

  const GoalCard = ({ disabled }) => {
    const ringBg = disabled
      ? 'var(--memox-progress-track)'
      : 'conic-gradient(var(--memox-primary) 216deg, var(--memox-progress-track) 0)';
    return (
      <div className="card" style={{ flex: 1, opacity: disabled ? 'var(--memox-op-disabled)' : 1, display: 'flex', alignItems: 'center', gap: S(3) }}>
        <div className="goal-ring" style={{ background: ringBg }}>
          <div className="goal-ring-inner">
            <div>
              <span style={{ fontSize: 'var(--memox-fs-title-small)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)' }}>{disabled ? '0' : '12'}</span>
              <span className="muted" style={{ fontSize: 'var(--memox-fs-label-small)', fontWeight: 'var(--memox-weight-bold)' }}>/20</span>
            </div>
          </div>
        </div>
        <div>
          <div className="title" style={{ fontSize: 'var(--memox-fs-label-large)' }}>Today's goal</div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>{disabled ? 'Goal paused' : '8 to go'}</div>
        </div>
      </div>
    );
  };

  const StatsRow = ({ showStreak, goalDisabled }) => (
    <div className="card-row">
      {showStreak && <StreakCard />}
      <GoalCard disabled={goalDisabled} />
    </div>
  );

  // ---- Today's review ------------------------------------------------------
  const ReviewCard = ({ caughtUp }) => {
    if (caughtUp) {
      return (
        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
          <IconTile icon="check" color="var(--memox-status-mastered)" />
          <div style={{ flex: 1 }}>
            <div className="title">All caught up</div>
            <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>You've reviewed everything due today.</div>
          </div>
        </div>
      );
    }
    return (
      <div className="card accent">
        <div className="ov" style={{ color: 'var(--memox-primary)', marginBottom: S(2) }}>
          <Icon name="zap" />TODAY'S REVIEW
        </div>
        <div style={{ fontSize: 'var(--memox-size-title)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>23 cards due</div>
        <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', marginBottom: S(4) }}>Across 3 decks · about 14 minutes</div>
        <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="play" />Start today's review</button>
      </div>
    );
  };

  // ---- New learning + decks ------------------------------------------------
  const NewLearning = () => (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: S(2), padding: `${S(1)} 0`, color: 'var(--memox-text-secondary)' }}>
      <Icon name="sparkles" style={{ width: 'var(--memox-icon-sm)', height: 'var(--memox-icon-sm)' }} />
      <span style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-bold)' }}>Start new learning</span>
      <span className="chip new">6 new</span>
    </div>
  );

  const DECKS = [
    { icon: 'languages', tint: 'var(--memox-status-new)', name: 'Japanese · N5', meta: '142 cards · last 2h ago', due: 23 },
    { icon: 'flask-conical', tint: 'var(--memox-status-learning)', name: 'Organic chemistry', meta: '120 cards · last 1d ago', due: 8 },
    { icon: 'landmark', tint: 'var(--memox-status-reviewing)', name: 'World capitals', meta: '195 cards · last 3d ago', due: 2 },
  ];

  const DeckList = () => (
    <div>
      <div className="section-head" style={{ marginBottom: S(2) }}>
        <div className="ov">RECENT DECKS</div>
        <button className="pill-btn ghost sm">Library<Icon name="chevron-right" /></button>
      </div>
      <div className="list-card">
        {DECKS.map((d, i) => (
          <div key={d.name}>
            {i > 0 && <div className="hr inset"></div>}
            <ListRow icon={d.icon} color={d.tint} title={d.name} meta={d.meta} due={d.due} />
          </div>
        ))}
      </div>
    </div>
  );

  // ---- Assembled screen ----------------------------------------------------
  function Dashboard({ variant }) {
    const Body = ({ children }) => (
      <div style={{ flex: 1, overflowY: 'auto', padding: `${S(2)} var(--memox-space-screen) var(--memox-space-6)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
        {children}
      </div>
    );

    if (variant === 'loading') {
      return (
        <div className="app">
          <Header />
          <Body>
            <Sk h="20px" w="55%" r="var(--memox-radius-sm)" />
            <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(3) }}>
              <div style={{ display: 'flex', gap: S(3), alignItems: 'center' }}>
                <Sk h="56px" w="56px" r="var(--memox-radius-md)" />
                <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="14px" w="60%" /><Sk h="12px" w="80%" /></div>
              </div>
              <Sk h="4px" r="var(--memox-radius-full)" />
              <Sk h="44px" r="var(--memox-radius-full)" />
            </div>
            <div className="card-row">
              <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="34px" w="34px" r="var(--memox-radius-sm)" /><Sk h="22px" w="50%" /></div>
              <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="34px" w="34px" r="var(--memox-radius-sm)" /><Sk h="22px" w="50%" /></div>
            </div>
            <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(3) }}><Sk h="12px" w="40%" /><Sk h="26px" w="60%" /><Sk h="44px" r="var(--memox-radius-full)" /></div>
          </Body>
          <BottomNav />
        </div>
      );
    }

    if (variant === 'onboarding') {
      return (
        <div className="app">
          <Header />
          <Body>
            <HeroCard solid icon="graduation-cap" tint="var(--memox-primary)" title="Nothing due yet"
              desc="Create your first deck and your &quot;today&quot; hub fills up here.">
              <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="plus" />Create first deck</button>
              <button className="pill-btn outline" style={{ width: '100%' }}><Icon name="download" />Import a deck</button>
            </HeroCard>
          </Body>
          <BottomNav />
        </div>
      );
    }

    if (variant === 'error') {
      return (
        <div className="app">
          <Header />
          <Body>
            <HeroCard icon="alert-triangle" tint="var(--memox-danger)" title="Couldn't load today"
              desc="Something went wrong fetching your dashboard.">
              <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="rotate-ccw" />Retry</button>
            </HeroCard>
          </Body>
          <BottomNav />
        </div>
      );
    }

    // Data states: loaded / goal-off / resume-only / streak-broken / offline / multi-resume
    const goalOff = variant === 'goal-off';
    const caughtUp = variant === 'resume-only';
    const multi = variant === 'multi-resume';

    return (
      <div className="app">
        <Header />
        <Body>
          {variant === 'offline' && <Banner tone="info" icon="cloud-off">You're offline — showing cached cards.</Banner>}
          {variant === 'streak-broken' && <Banner tone="warn" icon="flame">Your 11-day streak ended. Start a new one today.</Banner>}
          <ResumeCard multi={multi} />
          <StatsRow showStreak={!goalOff} goalDisabled={goalOff} />
          <ReviewCard caughtUp={caughtUp} />
          <NewLearning />
          <DeckList />
        </Body>
        <BottomNav />
      </div>
    );
  }

  if (!window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  window.MEMOX_KIT.register({
    num: '02',
    title: 'Dashboard',
    states: [
      { label: 'Loaded', render: () => <Dashboard variant="loaded" /> },
      { label: 'Loading', render: () => <Dashboard variant="loading" /> },
      { label: 'Onboarding', render: () => <Dashboard variant="onboarding" /> },
      { label: 'Goal off', render: () => <Dashboard variant="goal-off" /> },
      { label: 'Resume only', render: () => <Dashboard variant="resume-only" /> },
      { label: 'Streak broken', render: () => <Dashboard variant="streak-broken" /> },
      { label: 'Error', render: () => <Dashboard variant="error" /> },
      { label: 'Offline', render: () => <Dashboard variant="offline" /> },
      { label: 'Multi resume', render: () => <Dashboard variant="multi-resume" /> },
    ],
  });
})();
