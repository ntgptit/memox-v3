/* MemoX screen — 18 Stats (1 state). The "Stats" tab: a weekly activity column
   chart + a per-deck mastery list (each deck's mastery bar tinted by the
   low/mid/high scale). Token-driven; composes the shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, IconTile, SectionHead, BarChart, MasteryBar, BottomNav } = window.MX;

  // Cards reviewed per day this week.
  const WEEK = [
    { label: 'M', value: 18 },
    { label: 'T', value: 24 },
    { label: 'W', value: 12 },
    { label: 'T', value: 31 },
    { label: 'F', value: 22 },
    { label: 'S', value: 9 },
    { label: 'S', value: 16 },
  ];

  // Per-deck mastery (% of cards at the "mastered" stage).
  const DECKS = [
    { icon: 'languages', tint: 'var(--memox-status-new)', name: 'Japanese · N5', value: 72 },
    { icon: 'flask-conical', tint: 'var(--memox-status-learning)', name: 'Organic chemistry', value: 38 },
    { icon: 'landmark', tint: 'var(--memox-status-reviewing)', name: 'World capitals', value: 91 },
    { icon: 'book-open', tint: 'var(--memox-status-mastered)', name: 'SAT vocabulary', value: 56 },
  ];

  const MasteryRow = ({ d }) => (
    <div className="list-row" style={{ cursor: 'default' }}>
      <IconTile icon={d.icon} color={d.tint} />
      <div className="list-row-main">
        <div className="list-row-title">{d.name}</div>
        <div style={{ marginTop: S(2) }}><MasteryBar value={d.value} /></div>
      </div>
      <span style={{
        flex: 'none', minWidth: 'calc(var(--memox-space-10) + var(--memox-space-1))', textAlign: 'right',
        fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-extrabold)',
        color: 'var(--memox-text-primary)', fontVariantNumeric: 'tabular-nums',
      }}>{d.value}%</span>
    </div>
  );

  function StatsScreen() {
    const total = WEEK.reduce((s, d) => s + (d.value || 0), 0);
    return (
      <div className="app">
        <div className="appbar"><span className="appbar-title" style={{ flex: 1 }}>Stats</span></div>
        <div style={{ flex: 1, overflowY: 'auto', padding: `${S(2)} var(--memox-space-screen) var(--memox-space-6)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
          <div className="card">
            <div className="section-head" style={{ marginBottom: S(4) }}>
              <div className="ov"><Icon name="calendar-days" />Cards this week</div>
              <span className="title" style={{ fontSize: 'var(--memox-fs-label-large)', fontVariantNumeric: 'tabular-nums' }}>{total}</span>
            </div>
            <BarChart data={WEEK} />
          </div>

          <div>
            <SectionHead title="Per-deck mastery" />
            <div className="list-card" style={{ marginTop: S(2) }}>
              {DECKS.map((d, i) => (
                <div key={d.name}>
                  {i > 0 && <div className="hr inset"></div>}
                  <MasteryRow d={d} />
                </div>
              ))}
            </div>
          </div>
        </div>
        <BottomNav active="Stats" />
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '18',
    title: 'Stats',
    states: [
      { label: 'Loaded', render: () => <StatsScreen /> },
    ],
  });
})();
