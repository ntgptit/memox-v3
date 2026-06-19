/* MemoX screen — 00 Components. Storybook of the token-driven contract layer.
   Every element uses the .memox-components.css classes; the gallery renders it
   in light AND dark frames automatically. JSX helpers wrap each class. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  // Shared primitives — single source of truth (screens/_shared.jsx).
  const { Icon, PillBtn, IconBtn, IconTile, Chip, Overline, Progress, SectionHead, ListRow } = window.MX;

  const Group = ({ label, children, cols }) => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>
      <Overline>{label}</Overline>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 'var(--memox-space-2)', alignItems: 'center' }}>{children}</div>
    </div>
  );

  function Components() {
    return (
      <div className="app">
        <div className="appbar-lg">
          <div className="appbar-subtitle">MemoX UI Kit</div>
          <div style={{ display: 'flex', width: '100%', alignItems: 'flex-end' }}>
            <span className="appbar-title">Components</span>
            <span className="spacer"></span>
            <IconBtn icon="sliders-horizontal" label="Filter" />
          </div>
        </div>

        <div style={{ flex: 1, overflowY: 'auto', padding: 'var(--memox-space-1) var(--memox-space-screen) var(--memox-space-8)', display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-6)' }}>

          <Group label="Pill buttons">
            <PillBtn variant="primary" icon="play">Study</PillBtn>
            <PillBtn variant="secondary" icon="plus">Add</PillBtn>
            <PillBtn variant="outline">Skip</PillBtn>
            <PillBtn variant="primary" disabled>Done</PillBtn>
          </Group>

          <Group label="Icon buttons">
            <IconBtn icon="search" label="Search" />
            <IconBtn icon="star" label="Star" />
            <IconBtn icon="share-2" label="Share" />
            <IconBtn icon="more-vertical" label="More" />
          </Group>

          <Group label="Icon tiles — tonal & solid">
            <IconTile icon="sparkles" color="var(--memox-status-new)" />
            <IconTile icon="brain" color="var(--memox-status-learning)" />
            <IconTile icon="repeat" color="var(--memox-status-reviewing)" />
            <IconTile icon="check" color="var(--memox-status-mastered)" solid />
            <IconTile icon="folder" color="var(--memox-note-clay)" solid />
          </Group>

          <div className="card accent">
            <Overline dot="var(--memox-primary)">DUE TODAY</Overline>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 'var(--memox-space-2)', margin: 'var(--memox-space-1) 0 var(--memox-space-2)' }}>
              <span style={{ fontSize: 'var(--memox-fs-headline-medium)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)' }}>12 cards</span>
              <Chip status="due">in 3 decks</Chip>
            </div>
            <Progress value={64} />
          </div>

          <Group label="Status chips">
            <Chip status="new">New</Chip>
            <Chip status="learning">Learning</Chip>
            <Chip status="reviewing">Reviewing</Chip>
            <Chip status="mastered" icon="check">Mastered</Chip>
            <Chip status="due" solid>12 due</Chip>
          </Group>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-3)' }}>
            <SectionHead title="Your decks" action={<PillBtn variant="secondary" sm iconRight="chevron-right">All</PillBtn>} />
            <div className="card" style={{ padding: 'var(--memox-space-1) var(--memox-space-card)' }}>
              <ListRow icon="languages" color="var(--memox-status-new)" title="Japanese · N5" meta="48 cards · 6 due" />
              <div className="hr"></div>
              <ListRow icon="flask-conical" color="var(--memox-status-learning)" title="Organic chemistry" meta="120 cards · 4 due" />
              <div className="hr"></div>
              <ListRow icon="landmark" color="var(--memox-status-reviewing)" title="World capitals" meta="195 cards · 2 due" />
            </div>
          </div>

          <Group label="Bottom sheet">
            <div style={{ position: 'relative', width: '100%', borderRadius: 'var(--memox-radius-card)', overflow: 'hidden', border: '1px solid var(--memox-border-ghost)' }}>
              <div style={{ height: 60, background: 'var(--memox-bg)' }}></div>
              <div className="scrim" style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 'var(--memox-space-12)' }}></div>
              <div className="sheet" style={{ position: 'relative' }}>
                <div className="sheet-grabber"></div>
                <div className="section-head-title" style={{ marginBottom: 'var(--memox-space-1)' }}>Add to deck</div>
                <div className="list-row-meta" style={{ marginBottom: 'var(--memox-space-3)' }}>Pick a deck for this card.</div>
                <PillBtn variant="primary" icon="plus">New deck</PillBtn>
              </div>
            </div>
          </Group>
        </div>

        <div style={{ position: 'absolute', right: 'var(--memox-space-4)', bottom: 'calc(var(--memox-size-bottom-nav) + var(--memox-space-4))' }}>
          <button className="fab" aria-label="New card"><Icon name="plus" /></button>
        </div>

        <div className="bottom-nav">
          <div className="bottom-nav-item active"><span className="nav-ind"><Icon name="layers" /></span>Decks</div>
          <div className="bottom-nav-item"><span className="nav-ind"><Icon name="graduation-cap" /></span>Study</div>
          <div className="bottom-nav-item"><span className="nav-ind"><Icon name="bar-chart-3" /></span>Stats</div>
          <div className="bottom-nav-item"><span className="nav-ind"><Icon name="user" /></span>You</div>
        </div>
      </div>
    );
  }

  if (!window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  window.MEMOX_KIT.register({
    num: '00',
    title: 'Components',
    states: [
      { label: 'Showcase', render: () => <Components /> }
    ]
  });
})();
