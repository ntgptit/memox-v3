/* MemoX screen — 05 Library search (5 states). Global search across folders,
   decks and flashcards; results grouped by type. Token-driven; composes
   contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, PillBtn, ListRow, SectionHead, HeroCard, EmptyState, SearchDock, BottomNav, Sk } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const FOLDER_HITS = [
    { icon: 'languages', tint: 'var(--memox-status-new)', name: 'Languages', meta: '4 decks · 412 cards' },
  ];
  const DECK_HITS = [
    { icon: 'languages', tint: 'var(--memox-status-new)', name: 'Japanese · N5', meta: 'Languages · 142 cards', due: 23 },
    { icon: 'languages', tint: 'var(--memox-status-reviewing)', name: 'Japanese · N4', meta: 'Languages · 88 cards', due: 5 },
  ];
  const CARD_HITS = [
    { icon: 'square-stack', tint: 'var(--memox-status-learning)', front: '日本 — Japan', meta: 'Japanese · N5' },
    { icon: 'square-stack', tint: 'var(--memox-status-learning)', front: '日曜日 — Sunday', meta: 'Japanese · N5' },
    { icon: 'square-stack', tint: 'var(--memox-status-reviewing)', front: '本 — book', meta: 'Japanese · N4' },
  ];
  const RECENT = ['Japanese', 'verbs', 'capitals', 'N5 kanji'];
  const POPULAR = [
    { icon: 'flame', tint: 'var(--memox-status-learning)', name: 'Due today', meta: 'Across all decks' },
    { icon: 'sparkles', tint: 'var(--memox-status-new)', name: 'Recently added', meta: 'New cards this week' },
  ];

  // ---- Result group --------------------------------------------------------
  const Group = ({ title, count, children }) => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
      <SectionHead title={title} action={<span className="muted" style={{ fontSize: 'var(--memox-fs-label-medium)', fontWeight: 'var(--memox-weight-bold)' }}>{count}</span>} />
      <div className="list-card">{children}</div>
    </div>
  );

  const Rows = ({ items, render }) => (
    <>
      {items.map((it, i) => (
        <div key={i}>
          {i > 0 && <div className="hr inset"></div>}
          {render(it)}
        </div>
      ))}
    </>
  );

  // ---- Assembled screen ----------------------------------------------------
  const Body = ({ children }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-10)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  // Search is a primary bottom-nav destination, so every state renders the SAME
  // shell — search field + BottomNav with `Search` active — and only the body
  // content changes per variant. One source of truth keeps the tab's active
  // state in sync no matter which state is shown. `query` seeds the field.
  function Search({ variant }) {
    let query = 'japan';
    let content;

    if (variant === 'empty') {
      query = '';
      content = (
        <>
          <div style={{ display: 'flex', flexDirection: 'column', gap: S(3) }}>
            <div className="ov">Recent searches</div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: S(2) }}>
              {RECENT.map((r) => (
                <span key={r} className="chip" style={{ cursor: 'pointer' }}><Icon name="clock" />{r}</span>
              ))}
            </div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
            <div className="ov">Jump to</div>
            <div className="list-card">
              <Rows items={POPULAR} render={(p) => <ListRow icon={p.icon} color={p.tint} title={p.name} meta={p.meta} />} />
            </div>
          </div>
        </>
      );
    } else if (variant === 'loading') {
      content = (
        <>
          {[0, 1].map((g) => (
            <div key={g} style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
              <Sk h="13px" w="30%" />
              <div className="card" style={{ padding: `${S(2)} var(--memox-space-card)`, display: 'flex', flexDirection: 'column', gap: S(4) }}>
                {[0, 1].map((i) => (
                  <div key={i} style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
                    <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
                    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}>
                      <Sk h="14px" w="60%" /><Sk h="11px" w="42%" />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </>
      );
    } else if (variant === 'no-results') {
      query = 'zxqv';
      content = (
        <EmptyState icon="search-x" pad={12} title="No results"
          desc={'Nothing matches “zxqv”. Try a different word or check the spelling.'} />
      );
    } else if (variant === 'error') {
      content = (
        <div style={{ flex: 1, display: 'grid', placeItems: 'center' }}>
          <HeroCard icon="alert-triangle" tint="var(--memox-danger)" title="Search failed"
            desc="We couldn't run that search just now.">
            <PillBtn variant="primary" icon="rotate-ccw" full>Try again</PillBtn>
          </HeroCard>
        </div>
      );
    } else {
      // results
      content = (
        <>
          <Group title="Folders" count="1">
            <Rows items={FOLDER_HITS} render={(f) => <ListRow icon={f.icon} color={f.tint} title={f.name} meta={f.meta} />} />
          </Group>
          <Group title="Decks" count="2">
            <Rows items={DECK_HITS} render={(d) => (
              <ListRow icon={d.icon} color={d.tint} title={d.name} meta={d.meta} due={d.due} />
            )} />
          </Group>
          <Group title="Flashcards" count="3">
            <Rows items={CARD_HITS} render={(c) => <ListRow icon={c.icon} color={c.tint} title={c.front} meta={c.meta} />} />
          </Group>
        </>
      );
    }

    return (
      <div className="app">
        <div className="appbar"><span className="appbar-title">Search</span></div>
        <Body>{content}</Body>
        <SearchDock query={query} placeholder="Search everything" />
        <BottomNav active="Search" />
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '05',
    title: 'Library search',
    states: [
      { label: 'Results', render: () => <Search variant="results" /> },
      { label: 'Empty', render: () => <Search variant="empty" /> },
      { label: 'Loading', render: () => <Search variant="loading" /> },
      { label: 'No results', render: () => <Search variant="no-results" /> },
      { label: 'Error', render: () => <Search variant="error" /> },
    ],
  });
})();
