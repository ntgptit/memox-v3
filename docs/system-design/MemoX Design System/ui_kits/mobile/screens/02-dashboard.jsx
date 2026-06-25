/* MemoX screen — 02 Dashboard (8 states). The "today" OVERVIEW hub (engagement):
   a neutral stat strip (Due/Decks/Accuracy/Streak) + Continue-studying resume +
   a due snapshot + recent decks + a shortcut into Stats. Restored 2026-06-25 by
   owner ruling (engagement is canonical) — this reverses the 2026-06-21 quiet
   redesign that had moved the stat strip / recent decks off to Progress. Every
   meaningful node carries data-mx-node so the Flutter app is checked by identity.
   Token-driven; composes shared primitives (single source: screens/_shared.jsx). */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, TileLg, Progress, ListRow, StatSummary, DueSummary, ShortcutRow, HeroCard, Banner, BottomNav, Sk } = window.MX;

  // ---- Header --------------------------------------------------------------
  const Header = () => (
    <div className="appbar-lg">
      <div style={{ display: 'flex', alignItems: 'flex-end', width: '100%', gap: S(2) }}>
        <div className="appbar-titles">
          <div className="appbar-subtitle">Thursday, 19 June</div>
          <span className="appbar-title">Good evening, An</span>
        </div>
        <span className="spacer"></span>
        <button className="icon-btn" aria-label="Settings" data-mx-node="02-dashboard/settings"><Icon name="settings" /></button>
      </div>
    </div>
  );

  // ---- Continue studying (only when a session is paused) -------------------
  const ResumeCard = ({ multi }) => (
    <div>
      <div className="ov" style={{ marginBottom: S(2) }}>
        <span className="status-dot" style={{ '--dot': 'var(--memox-primary)' }}></span>CONTINUE STUDYING
      </div>
      <div className="card" data-mx-node="02-dashboard/continue-studying">
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

  // ---- Recent decks --------------------------------------------------------
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
      <div className="list-card" data-mx-node="02-dashboard/recent-decks">
        {DECKS.map((d, i) => (
          <div key={d.name}>
            {i > 0 && <div className="hr inset"></div>}
            <ListRow icon={d.icon} color={d.tint} title={d.name} meta={d.meta} due={d.due} />
          </div>
        ))}
      </div>
    </div>
  );

  // Quiet shortcut into the analysis hub.
  const ProgressShortcut = () => (
    <ShortcutRow data-mx-node="02-dashboard/shortcut-progress" icon="trending-up" label="See learning stats" sub="Goal, streak, trends & weak decks" />
  );

  // ---- Assembled screen ----------------------------------------------------
  const Body = ({ children }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${S(2)} var(--memox-space-screen) var(--memox-space-6)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  function Dashboard({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Header />
          <Body>
            <div className="card" style={{ display: 'flex', gap: S(2) }}>
              {[0, 1, 2, 3].map((i) => (
                <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: S(2), padding: S(2) }}>
                  <Sk h="22px" w="60%" /><Sk h="11px" w="70%" />
                </div>
              ))}
            </div>
            <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
              <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="14px" w="45%" /><Sk h="11px" w="65%" /></div>
            </div>
            <div className="card" style={{ padding: `${S(2)} var(--memox-space-card)`, display: 'flex', flexDirection: 'column', gap: S(4) }}>
              {[0, 1, 2].map((i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
                  <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="14px" w="55%" /><Sk h="11px" w="40%" /></div>
                </div>
              ))}
            </div>
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
            <HeroCard solid icon="graduation-cap" tint="var(--memox-primary)" title="Nothing here yet"
              desc="Create your first deck and your overview fills up here.">
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
              desc="Something went wrong fetching your overview.">
              <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="rotate-ccw" />Retry</button>
            </HeroCard>
          </Body>
          <BottomNav />
        </div>
      );
    }

    // Data states: loaded / no-session / caught-up / multi-resume / offline
    const caughtUp = variant === 'caught-up';
    const hasSession = variant === 'loaded' || variant === 'multi-resume' || variant === 'offline';
    const multi = variant === 'multi-resume';

    // Overview stat strip — neutral snapshot, not a goal/streak nag. "Due" is the
    // one accented metric so it reads as the notable number without pressure.
    const stats = caughtUp
      ? [['0', 'Due'], ['9', 'Decks'], ['86%', 'Accuracy'], ['11', 'Streak']]
      : [['23', 'Due', true], ['9', 'Decks'], ['86%', 'Accuracy'], ['11', 'Streak']];

    return (
      <div className="app">
        <Header />
        <Body>
          {variant === 'offline' && <Banner tone="info" icon="cloud-off">You're offline — showing cached cards.</Banner>}
          <StatSummary node="02-dashboard/stat-summary" stats={stats} />
          {hasSession && <ResumeCard multi={multi} />}
          <DueSummary node="02-dashboard/due-summary" count={23} decks={3} minutes={14} caughtUp={caughtUp} />
          <DeckList />
          <ProgressShortcut />
        </Body>
        <BottomNav />
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '02',
    title: 'Dashboard',
    states: [
      { label: 'Loaded', render: () => <Dashboard variant="loaded" /> },
      { label: 'No session', render: () => <Dashboard variant="no-session" /> },
      { label: 'Caught up', render: () => <Dashboard variant="caught-up" /> },
      { label: 'Multi resume', render: () => <Dashboard variant="multi-resume" /> },
      { label: 'Onboarding', render: () => <Dashboard variant="onboarding" /> },
      { label: 'Loading', render: () => <Dashboard variant="loading" /> },
      { label: 'Offline', render: () => <Dashboard variant="offline" /> },
      { label: 'Error', render: () => <Dashboard variant="error" /> },
    ],
  });
})();
