/* MemoX screen — 04 Folder detail (8 states). The children of one folder —
   EITHER subfolders OR decks (never mixed) — with a scope summary, create FAB
   and overflow. Token-driven; composes contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, TileLg, ListRow, StatSummary, ListGroup, HeroCard, EmptyState, SearchDock, BottomNav, Fab, Sk, ScreenBody, SubAppBar } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const DECKS = [
    { icon: 'languages', tint: 'var(--memox-status-new)', name: 'Japanese · N5', meta: '142 cards · last 2h ago', due: 23 },
    { icon: 'book-marked', tint: 'var(--memox-status-reviewing)', name: 'Spanish verbs', meta: '96 cards · last 1d ago', due: 8 },
    { icon: 'book-open-text', tint: 'var(--memox-status-learning)', name: 'French basics', meta: '74 cards · last 4d ago', due: 0 },
  ];
  const SUBFOLDERS = [
    { icon: 'folder', tint: 'var(--memox-status-new)', name: 'East Asian', meta: '2 decks · 238 cards' },
    { icon: 'folder', tint: 'var(--memox-status-reviewing)', name: 'Romance', meta: '3 decks · 174 cards' },
  ];
  const MOVE_TARGETS = [
    { icon: 'languages', name: 'Languages', sel: false },
    { icon: 'flask-conical', name: 'Sciences', sel: true },
    { icon: 'landmark', name: 'History & Geography', sel: false },
    { icon: 'briefcase', name: 'Work', sel: false },
  ];

  // ---- App bar -------------------------------------------------------------
  const Bar = ({ title }) => (
    <SubAppBar title={title} minW ellipsis
      trail={<button className="icon-btn" aria-label="More"><Icon name="more-vertical" /></button>}
      breadcrumb={[{ label: 'Library', icon: 'library' }, { label: title, current: true }]} />
  );

  const SearchBar = ({ query }) => (
    <SearchDock query={query} placeholder="Search this folder" node="04-folder-detail/search-dock" />
  );

  // ---- Delete confirm dialog ----------------------------------------------
  const DeleteDialog = () => (
    <div style={{ position: 'absolute', inset: 0, zIndex: 20, display: 'grid', placeItems: 'center', padding: 'var(--memox-space-6)' }}>
      <div className="scrim"></div>
      <div className="dialog" style={{ position: 'relative', width: '100%' }}>
        <TileLg icon="trash-2" tint="var(--memox-danger)" style={{ margin: `0 0 ${S(4)}` }} />
        <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>Delete “Languages”?</div>
        <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', lineHeight: 1.5, marginTop: S(2) }}>
          This removes the folder and its <b style={{ color: 'var(--memox-text-primary)' }}>4 decks · 412 cards</b>. This can't be undone.
        </div>
        <div style={{ display: 'flex', gap: S(2), marginTop: S(5) }}>
          <button className="pill-btn outline" style={{ flex: 1 }}>Cancel</button>
          <button className="pill-btn danger" style={{ flex: 1 }}><Icon name="trash-2" />Delete</button>
        </div>
      </div>
    </div>
  );

  // ---- Move bottom sheet ---------------------------------------------------
  const MoveSheet = () => (
    <div style={{ position: 'absolute', inset: 0, zIndex: 20, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
      <div className="scrim"></div>
      <div className="sheet" style={{ position: 'relative' }}>
        <div className="sheet-grabber"></div>
        <div className="section-head" style={{ marginBottom: S(3) }}>
          <span className="section-head-title">Move to folder</span>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column' }}>
          {MOVE_TARGETS.map((t, i) => (
            <div key={t.name}>
              {i > 0 && <div className="hr"></div>}
              <div className="list-row">
                <span className="icon-tile" style={{ '--tile': 'var(--memox-text-secondary)' }}><Icon name={t.icon} /></span>
                <div className="list-row-main"><div className="list-row-title">{t.name}</div></div>
                <span className="list-row-trail" style={t.sel ? { color: 'var(--memox-primary)' } : { color: 'var(--memox-outline-variant)' }}>
                  <Icon name={t.sel ? 'check-circle-2' : 'circle'} />
                </span>
              </div>
            </div>
          ))}
        </div>
        <button className="pill-btn primary" style={{ width: '100%', marginTop: S(5) }}><Icon name="folder-input" />Move here</button>
      </div>
    </div>
  );

  // ---- Assembled screen ----------------------------------------------------
  const Body = ({ children }) => <ScreenBody padTop={3} padBottom={10}>{children}</ScreenBody>;

  const FabSlot = ({ icon = 'plus', node }) => (
    <Fab icon={icon} label="Create" data-mx-node={node}
      style={{ position: 'absolute', right: S(5), bottom: `calc(var(--memox-size-bottom-nav) + ${S(4)})`, zIndex: 5 }} />
  );

  function Folder({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Languages" />
          <Body>
            <Sk h="64px" r="var(--memox-radius-card)" />
            <div className="card" style={{ padding: `${S(2)} var(--memox-space-card)`, display: 'flex', flexDirection: 'column', gap: S(4) }}>
              {[0, 1, 2].map((i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
                  <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}>
                    <Sk h="14px" w="55%" /><Sk h="11px" w="40%" />
                  </div>
                </div>
              ))}
            </div>
          </Body>
          <BottomNav active="Library" />
        </div>
      );
    }

    if (variant === 'error') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Folder" />
          <Body>
            <HeroCard icon="folder-x" tint="var(--memox-danger)" title="Folder not found"
              desc="This folder may have been moved or deleted.">
              <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="arrow-left" />Back to library</button>
            </HeroCard>
          </Body>
          <BottomNav active="Library" />
        </div>
      );
    }

    if (variant === 'unlocked') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Languages" />
          <Body>
            <HeroCard solid icon="folder-open" tint="var(--memox-primary)" title="Empty folder"
              desc="Add a deck of cards, or nest a subfolder to keep things organized.">
              <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="layers" />Create deck</button>
              <button className="pill-btn outline" style={{ width: '100%' }}><Icon name="folder-plus" />Create subfolder</button>
            </HeroCard>
          </Body>
          <BottomNav active="Library" />
        </div>
      );
    }

    if (variant === 'search-empty') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Languages" />
          <Body>
            <EmptyState icon="search-x" pad={10} title="No matches in this folder"
              desc={'Nothing here matches “kanji”.'} />
          </Body>
          <SearchBar query="kanji" />
          <BottomNav active="Library" />
        </div>
      );
    }

    if (variant === 'subfolders') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Languages" />
          <Body>
            <StatSummary stats={[['2', 'Subfolders'], ['5', 'Decks'], ['31', 'Due', true]]} node="04-folder-detail/stat-card" />
            <ListGroup heading="Folders" items={SUBFOLDERS} kind="folder" />
          </Body>
          <FabSlot icon="folder-plus" node="04-folder-detail/new-subfolder-fab" />
          <BottomNav active="Library" />
        </div>
      );
    }

    if (variant === 'delete' || variant === 'move') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Languages" />
          <Body>
            <StatSummary stats={[['3', 'Decks'], ['312', 'Cards'], ['31', 'Due', true]]} node="04-folder-detail/stat-card" />
            <ListGroup heading="Decks" items={DECKS} kind="deck" node="04-folder-detail/deck-list" />
          </Body>
          <FabSlot icon="layers" />
          <BottomNav active="Library" />
          {variant === 'delete' ? <DeleteDialog /> : <MoveSheet />}
        </div>
      );
    }

    // decks
    return (
      <div className="app" style={{ position: 'relative' }}>
        <Bar title="Languages" />
        <Body>
          <StatSummary stats={[['3', 'Decks'], ['312', 'Cards'], ['31', 'Due', true]]} node="04-folder-detail/stat-card" />
          <ListGroup heading="Decks" items={DECKS} kind="deck" node="04-folder-detail/deck-list" />
        </Body>
        <FabSlot icon="layers" node="04-folder-detail/create-deck-fab" />
        <BottomNav active="Library" />
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '04',
    title: 'Folder detail',
    states: [
      { label: 'Decks', render: () => <Folder variant="decks" /> },
      { label: 'Subfolders', render: () => <Folder variant="subfolders" /> },
      { label: 'Empty / unlocked', render: () => <Folder variant="unlocked" /> },
      { label: 'Search empty', render: () => <Folder variant="search-empty" /> },
      { label: 'Loading', render: () => <Folder variant="loading" /> },
      { label: 'Error', render: () => <Folder variant="error" /> },
      { label: 'Delete confirm', render: () => <Folder variant="delete" /> },
      { label: 'Move sheet', render: () => <Folder variant="move" /> },
    ],
  });
})();
