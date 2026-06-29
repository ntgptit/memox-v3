/* MemoX screen — 19 Progress (9 states). The analysis + gentle-nudge HOME: this
   is where goal, streak, trend, accuracy, due load, weak decks and "what to study
   next" live — the things the Dashboard deliberately keeps light. Layout:
   Today status (goal ring + streak) · ranged activity chart (Week | Month) · KPI
   strip (accuracy / time / cards) · Insights (analytic nudges). States: week ·
   month · goal met · streak lost · loading · empty · insufficient · partial ·
   error. Token-driven; composes the shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, Segmented, BarChart, StatSummary, GoalRing, Insight, SectionHead, Banner, EmptyState, HeroCard, Sk, ScreenBody, SubAppBar } = window.MX;

  const WEEK = [
    { label: 'M', value: 18 }, { label: 'T', value: 24 }, { label: 'W', value: 12 },
    { label: 'T', value: 31 }, { label: 'F', value: 22 }, { label: 'S', value: 9 }, { label: 'S', value: 16 },
  ];
  const MONTH = [
    { label: 'Wk1', value: 96 }, { label: 'Wk2', value: 132 }, { label: 'Wk3', value: 88 }, { label: 'Wk4', value: 121 },
  ];
  const PARTIAL = [
    { label: 'M', value: 18 }, { label: 'T', value: null }, { label: 'W', value: 12 },
    { label: 'T', value: null }, { label: 'F', value: 22 }, { label: 'S', value: 9 }, { label: 'S', value: 14 },
  ];
  // KPI strip — accuracy / time / cards (streak shown in the Today card above).
  const KPI_WEEK = [['86%', 'Accuracy'], ['3.3h', 'Time'], ['132', 'Cards']];
  const KPI_MONTH = [['84%', 'Accuracy'], ['14h', 'Time'], ['437', 'Cards']];
  const SK_BARS = [1.4, 2.2, 1, 2.7, 1.8, 0.8, 2];

  // ---- Insight library (analytic nudges live HERE, not on the Dashboard) ----
  const INS = {
    closeToGoal: { tone: 'good', icon: 'target', title: "You're close to today's goal", desc: '8 more cards to reach 20.', action: 'Review 8 cards' },
    goalMet: { tone: 'good', icon: 'check-check', title: 'Daily goal reached', desc: '20/20 cards today — keep the streak going.' },
    streakReset: { tone: 'warn', icon: 'flame', title: 'Your 11-day streak reset', desc: 'Study today to start a new one.', action: 'Review 12 cards' },
    mostDue: { tone: 'warn', icon: 'layers', title: 'Japanese · N5 has the most due', desc: '23 of your 33 due cards are in this deck.', action: 'Open deck' },
    accuracyUp: { tone: 'good', icon: 'trending-up', title: 'Accuracy is up this week', desc: '86% correct, up 4% from last week.' },
    accuracyDown: { tone: 'down', icon: 'trending-down', title: 'Accuracy dropped this week', desc: '80% correct, down 6% from last week.', action: 'Review missed cards' },
    weakDeck: { tone: 'warn', icon: 'flask-conical', title: 'Organic chemistry is your weakest deck', desc: '38% mastered — the lowest of your decks.', action: 'Study it' },
    needData: { tone: 'info', icon: 'info', title: 'A few more sessions needed', desc: 'Study a couple more days to unlock trends and insights.' },
  };

  const Bar = ({ range }) => (
    <SubAppBar title="Progress" noGap
      trail={<Segmented options={['Week', 'Month']} value={range === 'month' ? 'Month' : 'Week'} />} />
  );

  const Body = ({ children }) => <ScreenBody minH>{children}</ScreenBody>;

  // Today status — goal ring + streak. The goal/streak that USED to pressure the
  // Dashboard now reports here as status.
  const TodayCard = ({ goalValue = 12, goalTotal = 20, goalMet, streak = 11, streakLost }) => (
    <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(4) }}>
      <GoalRing value={goalMet ? goalTotal : goalValue} total={goalTotal} met={goalMet} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className="title" style={{ fontSize: 'var(--memox-fs-label-large)' }}>Today's goal</div>
        <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>
          {goalMet ? 'Goal reached — nice work' : `${goalTotal - goalValue} cards to go`}
        </div>
        <div style={{ marginTop: S(2), display: 'flex' }}>
          <span className={`chip${streakLost ? '' : ' learning'}`}>
            <Icon name="flame" />{streakLost ? 'Streak reset' : `${streak}-day streak`}
          </span>
        </div>
      </div>
    </div>
  );

  const ChartCard = ({ heading, total, data, dim }) => (
    <div className="card">
      <div className="section-head" style={{ marginBottom: S(4) }}>
        <div className="ov"><Icon name="bar-chart-3" />{heading}</div>
        <span className="title" style={{ fontSize: 'var(--memox-fs-label-large)', fontVariantNumeric: 'tabular-nums' }}>{total}</span>
      </div>
      <BarChart data={data} dim={dim} />
    </div>
  );

  const Insights = ({ items }) => (
    <div>
      <SectionHead title="Insights" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: S(3), marginTop: S(2) }}>
        {items.map((k, i) => <Insight key={i} {...INS[k]} />)}
      </div>
    </div>
  );

  function ProgressScreen({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Bar range="week" />
          <Body>
            <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(4) }}>
              <Sk h="72px" w="72px" r="var(--memox-radius-full)" />
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="14px" w="45%" /><Sk h="11px" w="60%" /></div>
            </div>
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

    // ---- Data states ----
    const range = variant === 'month' ? 'month' : 'week';
    const data = variant === 'partial' ? PARTIAL : (range === 'month' ? MONTH : WEEK);
    const heading = range === 'month' ? 'This month' : 'This week';
    const total = range === 'month' ? '437 cards' : '132 cards';
    const dim = variant === 'insufficient';

    const goalMet = variant === 'goal-met';
    const streakLost = variant === 'streak-lost';

    const insights =
      variant === 'goal-met' ? ['goalMet', 'weakDeck', 'accuracyUp']
        : variant === 'streak-lost' ? ['streakReset', 'mostDue', 'accuracyDown']
          : variant === 'insufficient' ? ['needData']
            : variant === 'partial' ? ['mostDue', 'accuracyDown']
              : variant === 'month' ? ['accuracyUp', 'weakDeck', 'mostDue']
                : ['closeToGoal', 'mostDue', 'accuracyUp']; // week

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
          <TodayCard goalMet={goalMet} streakLost={streakLost} />
          <ChartCard heading={heading} total={dim ? '\u2014' : total} data={data} dim={dim} />
          <StatSummary stats={range === 'month' ? KPI_MONTH : KPI_WEEK} />
          <Insights items={insights} />
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
      { label: 'Goal met', render: () => <ProgressScreen variant="goal-met" /> },
      { label: 'Streak lost', render: () => <ProgressScreen variant="streak-lost" /> },
      { label: 'Loading', render: () => <ProgressScreen variant="loading" /> },
      { label: 'Empty', render: () => <ProgressScreen variant="empty" /> },
      { label: 'Insufficient', render: () => <ProgressScreen variant="insufficient" /> },
      { label: 'Partial', render: () => <ProgressScreen variant="partial" /> },
      { label: 'Error', render: () => <ProgressScreen variant="error" /> },
    ],
  });
})();
