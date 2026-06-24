/* MemoX screen — 11 Tag management (11 states). Manage tags: rename, merge,
   delete. App bar (title "Tags" + search) · list of tag rows (tag + cards-used
   count + overflow). Token-driven; composes contract classes + shared
   primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, TileLg, EmptyState, Banner, SearchDock, Sk, Modal, Sheet, BusyOverlay } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const TAGS = [
    { name: 'kanji', count: 142 },
    { name: 'vocab', count: 210 },
    { name: 'verbs', count: 88 },
    { name: 'n5', count: 64 },
    { name: 'grammar', count: 52 },
    { name: 'particles', count: 31 },
  ];
  const MERGE_TARGETS = [
    { name: 'vocab', count: 210, sel: true },
    { name: 'verbs', count: 88, sel: false },
    { name: 'n5', count: 64, sel: false },
    { name: 'grammar', count: 52, sel: false },
  ];

  // ---- App bars ------------------------------------------------------------
  const Bar = () => (
    <div className="appbar">
      <button className="icon-btn" aria-label="Back"><Icon name="arrow-left" /></button>
      <span className="appbar-title" style={{ flex: 1, minWidth: 0, marginLeft: S(2) }}>Tags</span>
    </div>
  );

  const SearchBar = ({ query }) => (
    <SearchDock query={query} placeholder="Search tags" node="11-tag-management/search-dock" />
  );

  // ---- Tag row -------------------------------------------------------------
  const TagRow = ({ t }) => (
    <div className="list-row">
      <span className="icon-tile" style={{ '--tile': 'var(--memox-text-secondary)' }}><Icon name="hash" /></span>
      <div className="list-row-main">
        <div className="list-row-title">{t.name}</div>
        <div className="list-row-meta">{t.count} cards</div>
      </div>
      <span className="list-row-trail"><button className="icon-btn" aria-label="Tag options"><Icon name="more-vertical" /></button></span>
    </div>
  );

  const Body = ({ children }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${S(3)} var(--memox-space-screen) var(--memox-space-12)`, display: 'flex', flexDirection: 'column', gap: S(3) }}>
      {children}
    </div>
  );

  const TagList = ({ tags }) => (
    <>
      <div className="ov" style={{ paddingLeft: S(1) }}>{tags.length} tags</div>
      <div className="list-card" data-mx-node="11-tag-management/tag-list">
        {tags.map((t, i) => (
          <div key={t.name}>
            {i > 0 && <div className="hr inset"></div>}
            <TagRow t={t} />
          </div>
        ))}
      </div>
    </>
  );

  // ---- Overlays ------------------------------------------------------------
  const ActionSheet = () => (
    <Sheet title="kanji · 142 cards">
      <div style={{ display: 'flex', flexDirection: 'column' }}>
        {[
          { icon: 'pencil', label: 'Rename' },
          { icon: 'git-merge', label: 'Merge into…' },
          { icon: 'trash-2', label: 'Delete', danger: true },
        ].map((a, i) => (
          <div key={a.label}>
            {i > 0 && <div className="hr"></div>}
            <div className="list-row" style={a.danger ? { color: 'var(--memox-danger)' } : undefined}>
              <span className="icon-tile" style={{ '--tile': a.danger ? 'var(--memox-danger)' : 'var(--memox-text-secondary)' }}><Icon name={a.icon} /></span>
              <div className="list-row-main"><div className="list-row-title" style={a.danger ? { color: 'var(--memox-danger)' } : undefined}>{a.label}</div></div>
            </div>
          </div>
        ))}
      </div>
    </Sheet>
  );

  const RenameDialog = ({ conflict }) => (
    <Modal>
      <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>Rename tag</div>
      <div style={{ marginTop: S(4) }}>
        <input className="field" defaultValue={conflict ? 'vocab' : 'kanji'} autoFocus
          style={conflict ? { borderColor: 'var(--memox-danger)' } : undefined} />
      </div>
      {conflict ? (
        <>
          <Banner tone="warn" icon="git-merge" style={{ marginTop: S(3) }}>A tag “vocab” already exists. Merge them?</Banner>
          <div style={{ display: 'flex', gap: S(2), marginTop: S(5) }}>
            <button className="pill-btn outline" style={{ flex: 1 }}>Cancel</button>
            <button className="pill-btn primary" style={{ flex: 1 }}><Icon name="git-merge" />Merge tags</button>
          </div>
        </>
      ) : (
        <div style={{ display: 'flex', gap: S(2), marginTop: S(5) }}>
          <button className="pill-btn outline" style={{ flex: 1 }}>Cancel</button>
          <button className="pill-btn primary" style={{ flex: 1 }}><Icon name="check" />Save</button>
        </div>
      )}
    </Modal>
  );

  const MergeSheet = () => (
    <Sheet title="Merge “kanji” into">
      <div style={{ display: 'flex', flexDirection: 'column' }}>
        {MERGE_TARGETS.map((t, i) => (
          <div key={t.name}>
            {i > 0 && <div className="hr"></div>}
            <div className="list-row">
              <span className="icon-tile" style={{ '--tile': 'var(--memox-text-secondary)' }}><Icon name="hash" /></span>
              <div className="list-row-main">
                <div className="list-row-title">{t.name}</div>
                <div className="list-row-meta">{t.count} cards</div>
              </div>
              <span className="list-row-trail" style={t.sel ? { color: 'var(--memox-primary)' } : { color: 'var(--memox-outline-variant)' }}>
                <Icon name={t.sel ? 'check-circle-2' : 'circle'} />
              </span>
            </div>
          </div>
        ))}
      </div>
      <button className="pill-btn primary" style={{ width: '100%', marginTop: S(5) }}><Icon name="git-merge" />Merge into “vocab”</button>
    </Sheet>
  );

  const DeleteDialog = () => (
    <Modal>
      <TileLg icon="trash-2" tint="var(--memox-danger)" style={{ margin: `0 0 ${S(4)}` }} />
      <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>Delete tag “kanji”?</div>
      <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', lineHeight: 1.5, marginTop: S(2) }}>
        The tag is removed from <b style={{ color: 'var(--memox-text-primary)' }}>142 cards</b>. The cards themselves stay. This can't be undone.
      </div>
      <div style={{ display: 'flex', gap: S(2), marginTop: S(5) }}>
        <button className="pill-btn outline" style={{ flex: 1 }}>Cancel</button>
        <button className="pill-btn danger" style={{ flex: 1 }}><Icon name="trash-2" />Delete</button>
      </div>
    </Modal>
  );

  const ErrorDialog = () => (
    <Modal>
      <TileLg icon="alert-triangle" tint="var(--memox-danger)" style={{ margin: `0 0 ${S(4)}` }} />
      <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>Couldn't rename tag</div>
      <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', lineHeight: 1.5, marginTop: S(2) }}>Something went wrong updating this tag. Your tags are unchanged.</div>
      <div style={{ display: 'flex', gap: S(2), marginTop: S(5) }}>
        <button className="pill-btn outline" style={{ flex: 1 }}>Dismiss</button>
        <button className="pill-btn primary" style={{ flex: 1 }}><Icon name="rotate-ccw" />Try again</button>
      </div>
    </Modal>
  );

  function Screen({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <Sk h="12px" w="22%" />
            <div className="card" style={{ padding: `${S(2)} var(--memox-space-card)`, display: 'flex', flexDirection: 'column', gap: S(4) }}>
              {[0, 1, 2, 3, 4].map((i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
                  <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}>
                    <Sk h="14px" w="40%" /><Sk h="11px" w="26%" />
                  </div>
                </div>
              ))}
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
            <EmptyState icon="hash" pad={8} title="No tags yet"
              desc="Add tags to your cards and they'll appear here to manage." />
          </Body>
        </div>
      );
    }

    if (variant === 'search-empty') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <EmptyState icon="search-x" pad={10} title="No tags match"
              desc={'Nothing here matches “xyz”.'} />
          </Body>
          <SearchBar query="xyz" />
        </div>
      );
    }

    const overlay = {
      'action-sheet': <ActionSheet />,
      rename: <RenameDialog />,
      'rename-merge': <RenameDialog conflict />,
      'merge-sheet': <MergeSheet />,
      delete: <DeleteDialog />,
      busy: <BusyOverlay label="Merging tags…" />,
      'op-error': <ErrorDialog />,
    }[variant];

    return (
      <div className="app" style={{ position: 'relative' }}>
        <Bar />
        <Body>
          <TagList tags={TAGS} />
        </Body>
        <SearchBar query="" />
        {overlay}
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '11',
    title: 'Tag management',
    states: [
      { label: 'Loaded', render: () => <Screen variant="loaded" /> },
      { label: 'Loading', render: () => <Screen variant="loading" /> },
      { label: 'Empty', render: () => <Screen variant="empty" /> },
      { label: 'Search empty', render: () => <Screen variant="search-empty" /> },
      { label: 'Action sheet', render: () => <Screen variant="action-sheet" /> },
      { label: 'Rename', render: () => <Screen variant="rename" /> },
      { label: 'Rename → merge', render: () => <Screen variant="rename-merge" /> },
      { label: 'Merge sheet', render: () => <Screen variant="merge-sheet" /> },
      { label: 'Delete', render: () => <Screen variant="delete" /> },
      { label: 'Busy', render: () => <Screen variant="busy" /> },
      { label: 'Op error', render: () => <Screen variant="op-error" /> },
    ],
  });
})();
