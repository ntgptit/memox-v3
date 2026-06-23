/* MemoX screen — 06 Flashcard list (8 states). The cards inside one deck:
   create / edit / delete / reorder. App bar (deck name + back + search + deck
   overflow) · list of card rows (front + SRS box/status meta + chevron) · FAB
   add card. Bottom nav hidden (sub-screen). Token-driven; composes contract
   classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, PillBtn, Chip, IconTile, TileLg, ListRow, HeroCard, EmptyState, Breadcrumb, SearchDock, Fab, Sk, Modal, Sheet } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const STATUS_TINT = {
    new: 'var(--memox-status-new)',
    learning: 'var(--memox-status-learning)',
    reviewing: 'var(--memox-status-reviewing)',
    mastered: 'var(--memox-status-mastered)',
  };
  const CARDS = [
    { front: '日本 — Japan', meta: 'Box 4 · due in 3d', status: 'reviewing' },
    { front: '日曜日 — Sunday', meta: 'Box 2 · due today', status: 'learning' },
    { front: '本 — book', meta: 'New · not studied', status: 'new' },
    { front: '水 — water', meta: 'Box 6 · mastered', status: 'mastered' },
    { front: '火曜日 — Tuesday', meta: 'Box 3 · due in 1d', status: 'reviewing' },
    { front: '山 — mountain', meta: 'Box 1 · due today', status: 'learning' },
  ];
  const STATUS_LABEL = { new: 'New', learning: 'Learning', reviewing: 'Review', mastered: 'Mastered' };

  // ---- App bars ------------------------------------------------------------
  const Bar = ({ title }) => (
    <>
      <div className="appbar">
        <button className="icon-btn" aria-label="Back"><Icon name="arrow-left" /></button>
        <span className="appbar-title" style={{ flex: 1, minWidth: 0, marginLeft: S(2), overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</span>
        <button className="icon-btn" aria-label="Deck options"><Icon name="more-vertical" /></button>
      </div>
      <Breadcrumb items={[{ label: 'Library', icon: 'library' }, { label: 'Languages' }, { label: title, current: true }]} />
    </>
  );

  const ReorderBar = ({ title }) => (
    <div className="appbar">
      <button className="icon-btn" aria-label="Cancel"><Icon name="x" /></button>
      <span className="appbar-title" style={{ flex: 1, minWidth: 0, marginLeft: S(2), overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>Reorder · {title}</span>
      <button className="pill-btn primary sm"><Icon name="check" />Done</button>
    </div>
  );

  const SearchBar = ({ query }) => (
    <SearchDock query={query} placeholder="Search cards" node="06-flashcard-list/search-dock" />
  );

  // ---- Card row ------------------------------------------------------------
  const CardRow = ({ c }) => (
    <ListRow icon="square-stack" color={STATUS_TINT[c.status]} title={c.front} meta={c.meta}
      trail={<Chip status={c.status}>{STATUS_LABEL[c.status]}</Chip>} />
  );

  const Body = ({ children, pad }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${pad || S(3)} var(--memox-space-screen) var(--memox-space-12)`, display: 'flex', flexDirection: 'column', gap: S(3) }}>
      {children}
    </div>
  );

  const FabSlot = () => (
    <Fab icon="plus" label="Add card" data-mx-node="06-flashcard-list/add-card-fab"
      style={{ position: 'absolute', right: S(5), bottom: `calc(var(--memox-size-search-dock) + ${S(4)})`, zIndex: 5 }} />
  );

  // count summary strip above the list
  const CountStrip = ({ total, due }) => (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: `0 ${S(1)}` }}>
      <span className="ov">{total} cards</span>
      <span className="chip due solid">{due} due</span>
    </div>
  );

  function Screen({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Japanese · N5" />
          <Body>
            <div className="card" style={{ padding: `${S(2)} var(--memox-space-card)`, display: 'flex', flexDirection: 'column', gap: S(4) }}>
              {[0, 1, 2, 3, 4].map((i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
                  <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}>
                    <Sk h="14px" w="58%" /><Sk h="11px" w="38%" />
                  </div>
                  <Sk h="22px" w="56px" r="var(--memox-radius-full)" />
                </div>
              ))}
            </div>
          </Body>
        </div>
      );
    }

    if (variant === 'error') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Japanese · N5" />
          <Body>
            <div style={{ flex: 1, display: 'grid', placeItems: 'center' }}>
              <HeroCard icon="cloud-off" tint="var(--memox-danger)" title="Couldn't load cards"
                desc="Check your connection and try again.">
                <PillBtn variant="primary" icon="rotate-ccw" full>Retry</PillBtn>
              </HeroCard>
            </div>
          </Body>
        </div>
      );
    }

    if (variant === 'empty') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Japanese · N5" />
          <Body>
            <div style={{ flex: 1, display: 'grid', placeItems: 'center' }}>
              <HeroCard solid icon="square-stack" tint="var(--memox-primary)" title="No cards yet"
                desc="Add your first flashcard, or import a set from a file.">
                <PillBtn variant="primary" icon="plus" full>Add card</PillBtn>
                <PillBtn variant="outline" icon="upload" full>Import cards</PillBtn>
              </HeroCard>
            </div>
          </Body>
        </div>
      );
    }

    if (variant === 'search-empty') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <Bar title="Japanese · N5" />
          <Body>
            <EmptyState icon="search-x" pad={10} title="No cards match"
              desc={'Nothing here matches “kanji”.'} />
          </Body>
          <SearchBar query="kanji" />
        </div>
      );
    }

    if (variant === 'reorder') {
      return (
        <div className="app" style={{ position: 'relative' }}>
          <ReorderBar title="Japanese · N5" />
          <Body pad={S(3)}>
            <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', padding: `0 ${S(1)}` }}>Drag the handles to reorder cards.</div>
            <div className="list-card">
              {CARDS.slice(0, 5).map((c, i) => (
                <div key={i}>
                  {i > 0 && <div className="hr inset"></div>}
                  <div className="list-row" style={i === 1 ? { background: 'color-mix(in srgb, var(--memox-primary) calc(var(--memox-op-selected) * 100%), transparent)' } : undefined}>
                    <span className="icon-tile" style={{ '--tile': STATUS_TINT[c.status] }}><Icon name="square-stack" /></span>
                    <div className="list-row-main">
                      <div className="list-row-title">{c.front}</div>
                      <div className="list-row-meta">{c.meta}</div>
                    </div>
                    <span className="list-row-trail" style={{ color: 'var(--memox-text-3)', cursor: 'grab' }}><Icon name="grip-vertical" /></span>
                  </div>
                </div>
              ))}
            </div>
          </Body>
        </div>
      );
    }

    // loaded (+ delete-card / delete-deck overlays)
    const overlay =
      variant === 'delete-card' ? (
        <Modal>
          <TileLg icon="trash-2" tint="var(--memox-danger)" style={{ margin: `0 0 ${S(4)}` }} />
          <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>Delete this card?</div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', lineHeight: 1.5, marginTop: S(2) }}>
            <b style={{ color: 'var(--memox-text-primary)' }}>“日本 — Japan”</b> and its review history will be removed. This can't be undone.
          </div>
          <div style={{ display: 'flex', gap: S(2), marginTop: S(5) }}>
            <button className="pill-btn outline" style={{ flex: 1 }}>Cancel</button>
            <button className="pill-btn danger" style={{ flex: 1 }}><Icon name="trash-2" />Delete</button>
          </div>
        </Modal>
      ) : variant === 'delete-deck' ? (
        <Modal>
          <TileLg icon="layers" tint="var(--memox-danger)" style={{ margin: `0 0 ${S(4)}` }} />
          <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>Delete “Japanese · N5”?</div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', lineHeight: 1.5, marginTop: S(2) }}>
            This deletes the whole deck and all <b style={{ color: 'var(--memox-text-primary)' }}>142 cards</b> inside it. This can't be undone.
          </div>
          <div style={{ display: 'flex', gap: S(2), marginTop: S(5) }}>
            <button className="pill-btn outline" style={{ flex: 1 }}>Cancel</button>
            <button className="pill-btn danger" style={{ flex: 1 }}><Icon name="trash-2" />Delete deck</button>
          </div>
        </Modal>
      ) : null;

    return (
      <div className="app" style={{ position: 'relative' }}>
        <Bar title="Japanese · N5" />
        <Body>
          <CountStrip total="142" due="23" />
          <div className="list-card">
            {CARDS.map((c, i) => (
              <div key={i}>
                {i > 0 && <div className="hr inset"></div>}
                <CardRow c={c} />
              </div>
            ))}
          </div>
        </Body>
        {!overlay && <FabSlot />}
        <SearchBar query="" />
        {overlay}
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '06',
    title: 'Flashcard list',
    states: [
      { label: 'Loaded', render: () => <Screen variant="loaded" /> },
      { label: 'Empty', render: () => <Screen variant="empty" /> },
      { label: 'Search empty', render: () => <Screen variant="search-empty" /> },
      { label: 'Loading', render: () => <Screen variant="loading" /> },
      { label: 'Error', render: () => <Screen variant="error" /> },
      { label: 'Delete card', render: () => <Screen variant="delete-card" /> },
      { label: 'Delete deck', render: () => <Screen variant="delete-deck" /> },
      { label: 'Reorder', render: () => <Screen variant="reorder" /> },
    ],
  });
})();
