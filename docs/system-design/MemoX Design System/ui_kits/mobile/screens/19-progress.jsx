/* MemoX screen — 19 Progress (7 states). A drill-in from Stats: a ranged
   activity chart (Week | Month segmented toggle) + a KPI strip (streak /
   accuracy / time). States: week · month · loading · empty · insufficient
   (dimmed chart + note) · partial (chart with data gaps + note) · error.
   Token-driven; composes the shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, Segmented, BarChart, StatSummary, Banner, EmptyState, HeroCard, Sk } = window.MX;

  const WEEK = [
    { label: 'M', value: 18 }, { label: 'T', value: 24 }, { label: 'W', value: 12 },
    { label: 'T', value: 31 }, { label: 'F', value: 22 }, { label: 'S', value: 9 }, { label: 'S', value: 16 },
  ];
  const MONTH = [
    { label: 'Wk1', value: 96 }, { label: 'Wk2', value: 132 }, { label: 'Wk3', value: 88 }, { label: 'Wk4', value: 121 },
  ];
  // Week with two missing days (a partial range).
  const PARTIAL = [
    { label: 'M', value: 18 }, { label: 'T', value: null }, { label: 'W', value: 12 },
    { label: 'T', value: null }, { label: 'F', value: 22 }, { label: 'S', value: 9 }, { label: 'S', value: 14 },
  ];
  const KPI_WEEK = [['11', 'Streak'], ['86%', 'Accuracy'], ['3.3h', 'Time']];
  const KPI_MONTH = [['11', 'Streak'], ['84%', 'Accuracy'], ['14h', 'Time']];
  const SK_BARS = [1.4, 2.2, 1, 2.7, 1.8, 0.8, 2];

  const Bar = ({ range }) => (
    <div className="appbar">
      <button className="icon-btn" aria-label="Back"><Icon name="arrow-left" /></button>
      <span className="appbar-title" style={{ flex: 1 }}>Progress</span>
      <Segmented options={['Week', 'Month']} value={range === 'month' ? 'Month' : 'Week'} />
    </div>
  );

  const Body = ({ children }) => (
    <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  const ChartCard = ({ heading, total, data, dim }) => (
    <div className="card">
      <div className="section-head" style={{ marginBottom: S(4) }}>
        <div className="ov"><Icon name="trending-up" />{heading}</div>
        <span className="title" style={{ fontSize: 'var(--memox-fs-label-large)', fontVariantNumeric: 'tabular-nums' }}>{total}</span>
      </div>
      <BarChart data={data} dim={dim} />
    </div>
  );

  function ProgressScreen({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Bar range="week" />
          <Body>
            <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(4) }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}><Sk h="14px" w="42%" /><Sk h="14px" w="18%" /></div>
              <div style={{ display: 'flex', alignItems: 'flex-end', gap: S(2), height: 'calc(var(--memox-space-12) * 3)' }}>
                {SK_BARS.map((m, i) => (
                  <div key={i} style={{ flex: 1, display: 'flex', alignItems: 'flex-end', justifyContent: 'center' }}>
                    <Sk h={`calc(var(--memox-space-12) * ${m})`} w="100%" r="var(--memox-radius-sm)" />
                  </div>
                ))}
              </div>
            </div>
            <div className="card" style={{ display: 'flex', gap: S(2) }}>
              {[0, 1, 2].map((i) => (
                <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: S(2), padding: S(2) }}>
                  <Sk h="22px" w="58%" /><Sk h="11px" w="46%" />
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
          <Bar range="week" />
          <Body>
            <EmptyState icon="bar-chart-3" title="Not enough data"
              desc="Not enough data to show progress yet. Study a few sessions to start seeing your trends.">
              <button className="pill-btn primary"><Icon name="play" />Start studying</button>
            </EmptyState>
          </Body>
        </div>
      );
    }

    if (variant === 'error') {
      return (
        <div className="app">
          <Bar range="week" />
          <Body>
            <div style={{ flex: 1, display: 'grid', placeItems: 'center' }}>
              <HeroCard icon="alert-triangle" tint="var(--memox-danger)" title="Couldn't load progress"
                desc="Something went wrong fetching your stats.">
                <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="rotate-ccw" />Retry</button>
              </HeroCard>
            </div>
          </Body>
        </div>
      );
    }

    // Data states: week / month / insufficient / partial
    const range = variant === 'month' ? 'month' : 'week';
    const data = variant === 'partial' ? PARTIAL : (range === 'month' ? MONTH : WEEK);
    const heading = range === 'month' ? 'This month' : 'This week';
    const total = range === 'month' ? '437 cards' : '132 cards';

    return (
      <div className="app">
        <Bar range={range} />
        <Body>
          {variant === 'insufficient' && (
            <Banner tone="info" icon="info">A few more days of study are needed to show a trend.</Banner>
          )}
          {variant === 'partial' && (
            <Banner tone="warn" icon="alert-triangle">Study data is missing for some days in this range.</Banner>
          )}
          <ChartCard heading={heading} total={variant === 'insufficient' ? '—' : total} data={data} dim={variant === 'insufficient'} />
          <StatSummary stats={range === 'month' ? KPI_MONTH : KPI_WEEK} />
        </Body>
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '19',
    title: 'Progress',
    states: [
      { label: 'Week', render: () => <ProgressScreen variant="week" /> },
      { label: 'Month', render: () => <ProgressScreen variant="month" /> },
      { label: 'Loading', render: () => <ProgressScreen variant="loading" /> },
      { label: 'Empty', render: () => <ProgressScreen variant="empty" /> },
      { label: 'Insufficient', render: () => <ProgressScreen variant="insufficient" /> },
      { label: 'Partial', render: () => <ProgressScreen variant="partial" /> },
      { label: 'Error', render: () => <ProgressScreen variant="error" /> },
    ],
  });
})();
