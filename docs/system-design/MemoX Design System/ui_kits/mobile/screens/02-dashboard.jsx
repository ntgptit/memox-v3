/* MemoX screen — 02 Dashboard (redesign). A QUIET "refer to work" surface — it
   never pressures the user to study now. The redesign FE
   (lib/presentation/features/dashboard/widgets/dashboard_body.dart) is the source
   of truth: a due snapshot (MxDueSummary) + two shortcut rows (Progress, Library).
   Daily goal / streak / insights / trends live on Progress, NOT here; the old stat
   strip, continue-studying resume card, and recent-decks list were dropped in the
   redesign. Token-driven; composes shared primitives (single source of truth in
   screens/_shared.jsx). The three required nodes carry data-mx-node so the parity
   contract (tool/parity/gen_contract.mjs) can assert the FE keys. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, DueSummary, ShortcutRow, HeroCard, BottomNav, Sk } = window.MX;

  // ---- Header (greeting app bar) ------------------------------------------
  const Header = () => (
    <div className="appbar-lg">
      <div style={{ display: 'flex', alignItems: 'flex-end', width: '100%', gap: S(2) }}>
        <div className="appbar-titles">
          <div className="appbar-subtitle">Thursday, 19 June</div>
          <span className="appbar-title">Good evening, An</span>
        </div>
        <span className="spacer"></span>
        <button className="icon-btn" aria-label="Settings"><Icon name="settings" /></button>
      </div>
    </div>
  );

  const Body = ({ children }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${S(2)} var(--memox-space-screen) var(--memox-space-6)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  // The quiet content: due snapshot + a shortcut into Progress and one into the
  // Library. Mirrors DashboardBody._content (MxDueSummary + two MxShortcutRow).
  const Content = ({ caughtUp }) => (
    <Body>
      <DueSummary node="02-dashboard/due-summary" count={23} decks={3} minutes={14} caughtUp={caughtUp} />
      <ShortcutRow data-mx-node="02-dashboard/shortcut-progress" icon="bar-chart-3" label="Progress" sub="Goal, streak, trends & weak decks" />
      <ShortcutRow data-mx-node="02-dashboard/shortcut-library" icon="folder" label="Library" sub="Folders, decks & cards" />
    </Body>
  );

  function Dashboard({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Header />
          <Body>
            <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
              <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="14px" w="45%" /><Sk h="11px" w="65%" /></div>
            </div>
            {[0, 1].map((i) => (
              <div key={i} className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
                <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
                <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="14px" w="55%" /><Sk h="11px" w="40%" /></div>
              </div>
            ))}
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

    // Data states: loaded (cards due) / caught-up (all clear).
    return (
      <div className="app">
        <Header />
        <Content caughtUp={variant === 'caught-up'} />
        <BottomNav />
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '02',
    title: 'Dashboard',
    states: [
      { label: 'Loaded', render: () => <Dashboard variant="loaded" /> },
      { label: 'Caught up', render: () => <Dashboard variant="caught-up" /> },
      { label: 'Loading', render: () => <Dashboard variant="loading" /> },
      { label: 'Error', render: () => <Dashboard variant="error" /> },
    ],
  });
})();
