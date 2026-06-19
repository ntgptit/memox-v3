/* MemoX screen — 03 Library overview (6 states). Top-level browser: shows the
   high-level FOLDER list (never raw decks). Token-driven; composes contract
   classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, ListRow, HeroCard, BottomNav, Fab, Sk } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const FOLDERS = [
    { icon: 'languages', tint: 'var(--memox-status-new)', name: 'Languages', meta: '4 decks · 412 cards' },
    { icon: 'flask-conical', tint: 'var(--memox-status-learning)', name: 'Sciences', meta: '3 decks · 286 cards' },
    { icon: 'landmark', tint: 'var(--memox-status-reviewing)', name: 'History & Geography', meta: '2 decks · 195 cards' },
    { icon: 'briefcase', tint: 'var(--memox-status-mastered)', name: 'Work', meta: '5 decks · 320 cards' },
    { icon: 'book-open', tint: 'var(--memox-primary)', name: 'Literature', meta: '1 deck · 64 cards' },
  ];

  // ---- App bars ------------------------------------------------------------
  const TitleBar = () => (
    <div className="appbar">
      <span className="appbar-title">Library</span>
      <span className="spacer"></span>
      <button className="icon-btn" aria-label="Search"><Icon name="search" /></button>
      <button className="icon-btn" aria-label="Sort"><Icon name="arrow-up-down" /></button>
    </div>
  );

  const SearchBar = ({ query }) => (
    <div className="appbar" style={{ gap: S(2) }}>
      <div style={{ position: 'relative', flex: 1, display: 'flex', alignItems: 'center' }}>
        <span style={{ position: 'absolute', left: S(3), display: 'grid', placeItems: 'center', color: 'var(--memox-text-secondary)', pointerEvents: 'none' }}>
          <Icon name="search" style={{ width: 'var(--memox-icon-md)', height: 'var(--memox-icon-md)' }} />
        </span>
        <input className="field" style={{ paddingLeft: 'var(--memox-space-10)' }} defaultValue={query} placeholder="Search folders" />
      </div>
      <button className="pill-btn ghost sm" style={{ height: 'var(--memox-size-button)' }}>Cancel</button>
    </div>
  );

  // ---- List card -----------------------------------------------------------
  const FolderCard = ({ items }) => (
    <div className="list-card">
      {items.map((f, i) => (
        <div key={f.name}>
          {i > 0 && <div className="hr inset"></div>}
          <ListRow icon={f.icon} color={f.tint} title={f.name} meta={f.meta} />
        </div>
      ))}
    </div>
  );

  // ---- Bottom sheet (overflow actions for one folder) ----------------------
  const SheetRow = ({ icon, label, danger }) => (
    <button className="list-row" style={{ width: '100%', background: 'none', border: 'none', cursor: 'pointer', padding: `${S(3)} 0`, textAlign: 'left' }}>
      <span className="icon-tile" style={{ '--tile': danger ? 'var(--memox-danger)' : 'var(--memox-text-secondary)' }}><Icon name={icon} /></span>
      <span className="list-row-main">
        <span className="list-row-title" style={danger ? { color: 'var(--memox-danger)' } : undefined}>{label}</span>
      </span>
    </button>
  );

  const OverflowSheet = () => (
    <div style={{ position: 'absolute', inset: 0, zIndex: 20, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
      <div className="scrim"></div>
      <div className="sheet" style={{ position: 'relative' }}>
        <div className="sheet-grabber"></div>
        <div className="list-row" style={{ padding: `0 0 ${S(2)}` }}>
          <span className="icon-tile" style={{ '--tile': 'var(--memox-status-new)' }}><Icon name="languages" /></span>
          <div className="list-row-main">
            <div className="list-row-title">Languages</div>
            <div className="list-row-meta">4 decks · 412 cards</div>
          </div>
        </div>
        <div className="hr" style={{ margin: `${S(2)} 0` }}></div>
        <SheetRow icon="pencil" label="Rename" />
        <SheetRow icon="folder-input" label="Move to…" />
        <SheetRow icon="trash-2" label="Delete folder" danger />
      </div>
    </div>
  );

  // ---- Assembled screen ----------------------------------------------------
  const Body = ({ children }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${S(3)} var(--memox-space-screen) var(--memox-space-10)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  const FabSlot = () => (
    <Fab icon="folder-plus" label="New folder"
      style={{ position: 'absolute', right: S(5), bottom: `calc(var(--memox-size-bottom-nav) + ${S(4)})`, zIndex: 5 }} />
  );

  function Library({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <TitleBar />
          <Body>
            <div className="card" style={{ padding: `${S(2)} var(--memox-space-card)`, display: 'flex', flexDirection: 'column', gap: S(4) }}>
              {[0, 1, 2, 3].map((i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
                  <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}>
                    <Sk h="14px" w="55%" /><Sk h="11px" w="38%" />
                  </div>
                </div>
              ))}
            </div>
          </Body>
          <BottomNav active="Library" />
        </div>
      );
    }

    if (variant === 'empty') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <TitleBar />
          <Body>
            <HeroCard solid icon="folder-open" tint="var(--memox-primary)" title="No folders yet"
              desc="Folders keep your decks tidy by subject. Create your first to get started.">
              <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="folder-plus" />Create folder</button>
            </HeroCard>
          </Body>
          <BottomNav active="Library" />
        </div>
      );
    }

    if (variant === 'error') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <TitleBar />
          <Body>
            <HeroCard icon="alert-triangle" tint="var(--memox-danger)" title="Couldn't load library"
              desc="We couldn't reach your folders. Check your connection and try again.">
              <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="rotate-ccw" />Retry</button>
            </HeroCard>
          </Body>
          <BottomNav active="Library" />
        </div>
      );
    }

    if (variant === 'search') {
      const results = FOLDERS.filter((f) => /lang|sci/i.test(f.name));
      return (
        <div className="app" style={{ position: 'relative' }}>
          <SearchBar query="la" />
          <Body>
            <div className="ov">2 folders</div>
            <FolderCard items={results} />
          </Body>
          <BottomNav active="Library" />
        </div>
      );
    }

    if (variant === 'overflow') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <TitleBar />
          <Body>
            <FolderCard items={FOLDERS} />
          </Body>
          <FabSlot />
          <BottomNav active="Library" />
          <OverflowSheet />
        </div>
      );
    }

    // loaded
    return (
      <div className="app" style={{ position: 'relative' }}>
        <TitleBar />
        <Body>
          <FolderCard items={FOLDERS} />
        </Body>
        <FabSlot />
        <BottomNav active="Library" />
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '03',
    title: 'Library overview',
    states: [
      { label: 'Loaded', render: () => <Library variant="loaded" /> },
      { label: 'Loading', render: () => <Library variant="loading" /> },
      { label: 'Empty', render: () => <Library variant="empty" /> },
      { label: 'Search', render: () => <Library variant="search" /> },
      { label: 'Overflow sheet', render: () => <Library variant="overflow" /> },
      { label: 'Error', render: () => <Library variant="error" /> },
    ],
  });
})();
