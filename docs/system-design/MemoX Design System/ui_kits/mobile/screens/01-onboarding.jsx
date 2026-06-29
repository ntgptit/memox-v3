/* MemoX screen — 01 Onboarding (9 states). Welcomes a new user and routes to
   creating/importing a first deck, plus the sign-in + restore branch.
   Token-driven; composes the contract component classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  // Shared primitives — single source of truth (screens/_shared.jsx).
  const { Icon, S, PillBtn, HeroCard, InfoRow, ScreenBody } = window.MX;

  const AppBar = ({ title, subtitle }) => (
    <div className="appbar-lg">
      {subtitle && <div className="appbar-subtitle">{subtitle}</div>}
      <span className="appbar-title">{title}</span>
    </div>
  );

  const REASSURE = [
    { icon: 'shield-check', tint: 'var(--memox-status-mastered)', title: 'Local-first', desc: 'Your cards live on your device.' },
    { icon: 'calendar-check', tint: 'var(--memox-status-new)', title: 'A gentle daily rhythm', desc: 'Small reviews, every day.' },
    { icon: 'feather', tint: 'var(--memox-status-reviewing)', title: 'No streak pressure', desc: 'Miss a day — nothing breaks.' },
  ];

  const Body = ({ children }) => <ScreenBody padTop={2} padBottom={8} gap={3}>{children}</ScreenBody>;

  function Onboarding({ variant }) {
    let bar = { title: 'Welcome', subtitle: 'MemoX' };
    let body;

    if (variant === 'welcome') {
      body = (
        <Body>
          <HeroCard solid icon="graduation-cap" tint="var(--memox-primary)" title="Welcome to MemoX"
            desc="Make a deck, study a little each day, and let spaced repetition do the rest.">
            <PillBtn variant="primary" icon="plus" full>Create first deck</PillBtn>
            <PillBtn variant="secondary" icon="download" full>Import a deck</PillBtn>
          </HeroCard>
          {REASSURE.map((r) => <InfoRow key={r.title} {...r} />)}
        </Body>
      );
    } else if (variant === 'zero') {
      bar = { title: 'MemoX', subtitle: 'No decks yet' };
      body = (
        <Body>
          <HeroCard solid icon="layers" tint="var(--memox-primary)" title="No decks yet"
            desc="Your library is empty. Create your first deck to start studying.">
            <PillBtn variant="primary" icon="plus" full>Create first deck</PillBtn>
            <PillBtn variant="outline" icon="download" full>Import a deck</PillBtn>
          </HeroCard>
        </Body>
      );
    } else if (variant === 'create') {
      bar = { title: 'New deck', subtitle: 'Step 1 of 2' };
      body = (
        <Body>
          <div className="card" style={{ padding: S(6) }}>
            <span className="tile-lg tonal" style={{ '--tile': 'var(--memox-primary)', margin: `0 auto ${S(4)}` }}><Icon name="folder-plus" /></span>
            <div style={{ textAlign: 'center', fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', marginBottom: S(5) }}>Name your deck</div>
            <div className="ov" style={{ marginBottom: S(2) }}>DECK NAME</div>
            <input className="field" defaultValue="Japanese · N5" placeholder="e.g. Spanish verbs" />
            <div style={{ marginTop: S(5), display: 'flex', flexDirection: 'column', gap: S(2) }}>
              <PillBtn variant="primary" icon="check" full>Create deck</PillBtn>
              <PillBtn variant="outline" full>Cancel</PillBtn>
            </div>
          </div>
        </Body>
      );
    } else if (variant === 'import') {
      bar = { title: 'Import a deck', subtitle: 'Choose a source' };
      body = (
        <Body>
          <HeroCard solid icon="download" tint="var(--memox-status-new)" title="Import a deck"
            desc="Bring cards in from a file or straight from your clipboard." />
          {[
            { icon: 'file-up', tint: 'var(--memox-status-new)', title: 'From a file', desc: 'CSV, TSV or .apkg' },
            { icon: 'clipboard-paste', tint: 'var(--memox-status-reviewing)', title: 'From clipboard', desc: 'Paste tab-separated rows' },
          ].map((o) => (
            <InfoRow key={o.title} {...o} trail={<span className="list-row-trail"><Icon name="chevron-right" /></span>} />
          ))}
        </Body>
      );
    } else if (variant === 'signing') {
      bar = { title: 'Sign in', subtitle: 'MemoX' };
      body = (
        <Body>
          <div className="card" style={{ padding: S(8), display: 'flex', flexDirection: 'column', alignItems: 'center', gap: S(4) }}>
            <div className="spinner"></div>
            <div className="title" style={{ fontSize: 'var(--memox-size-h2)' }}>Signing in…</div>
            <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', textAlign: 'center' }}>Connecting to your Google account</div>
          </div>
        </Body>
      );
    } else if (variant === 'restore-prompt') {
      bar = { title: 'Backup found', subtitle: 'Google Drive' };
      body = (
        <Body>
          <HeroCard icon="cloud-download" tint="var(--memox-status-new)" title="Restore your decks?"
            desc={<span>We found a backup from <b style={{ color: 'var(--memox-text-primary)' }}>2 days ago</b> · 4 decks · 405 cards.</span>}>
            <PillBtn variant="primary" icon="cloud-download" full>Restore backup</PillBtn>
            <PillBtn variant="outline" full>Start fresh</PillBtn>
          </HeroCard>
        </Body>
      );
    } else if (variant === 'restoring') {
      bar = { title: 'Restoring', subtitle: 'Google Drive' };
      body = (
        <Body>
          <div className="card" style={{ padding: S(6) }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: S(3), marginBottom: S(4) }}>
              <span className="tile-lg tonal" style={{ '--tile': 'var(--memox-status-new)' }}><Icon name="cloud-download" /></span>
              <div>
                <div className="title" style={{ fontSize: 'var(--memox-size-h2)' }}>Restoring backup</div>
                <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>142 / 405 cards</div>
              </div>
            </div>
            <div className="progress"><div className="progress-fill" style={{ width: '35%' }}></div></div>
            <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', marginTop: S(2), textAlign: 'right' }}>35%</div>
          </div>
        </Body>
      );
    } else if (variant === 'restore-failed') {
      bar = { title: 'Restore failed', subtitle: 'Google Drive' };
      body = (
        <Body>
          <HeroCard icon="cloud-off" tint="var(--memox-danger)" title="Couldn't restore"
            desc="The connection dropped at 35%. You can try again or skip for now.">
            <PillBtn variant="primary" icon="rotate-ccw" full>Try again</PillBtn>
            <PillBtn variant="outline" full>Skip</PillBtn>
          </HeroCard>
        </Body>
      );
    } else { // import-handoff
      bar = { title: 'Import a deck', subtitle: 'Handing off' };
      body = (
        <Body>
          <HeroCard solid icon="arrow-right-left" tint="var(--memox-status-reviewing)" title="Open the importer"
            desc="We'll take you to the import flow to map fields and pick a deck.">
            <PillBtn variant="primary" iconRight="arrow-right" full>Continue to import</PillBtn>
            <PillBtn variant="outline" full>Back</PillBtn>
          </HeroCard>
        </Body>
      );
    }

    return (
      <div className="app">
        <AppBar title={bar.title} subtitle={bar.subtitle} />
        {body}
      </div>
    );
  }

  if (!window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  window.MEMOX_KIT.register({
    num: '01',
    title: 'Onboarding',
    states: [
      { label: 'Welcome', render: () => <Onboarding variant="welcome" /> },
      { label: 'Zero state', render: () => <Onboarding variant="zero" /> },
      { label: 'Create deck', render: () => <Onboarding variant="create" /> },
      { label: 'Deck for import', render: () => <Onboarding variant="import" /> },
      { label: 'Signing in', render: () => <Onboarding variant="signing" /> },
      { label: 'Restore prompt', render: () => <Onboarding variant="restore-prompt" /> },
      { label: 'Restoring', render: () => <Onboarding variant="restoring" /> },
      { label: 'Restore failed', render: () => <Onboarding variant="restore-failed" /> },
      { label: 'Import handoff', render: () => <Onboarding variant="import-handoff" /> },
    ],
  });
})();
