/* MemoX screen — 13 Study · Match (3 states). Two columns — terms on the left,
   meanings on the right (shuffled). Tap a term, then its match: a correct pair
   locks green, a wrong attempt flashes red, the current pick shows primary.
   Cards are the shared StudyOption (.choice.clamp) inside the .match-grid:
     • Standard — meanings up to 2 lines (default).
     • Long meanings — the grid opts into .match-grid.long-text so every card
       gets the taller floor + 3-line clamp at once (stays uniform).
     • Read full meaning — a meaning longer than 3 lines clamps with a "tap to
       read" hint and opens the full text in the shared bottom Sheet, so a
       truncated meaning never leaves the user guessing.
   All height/padding/clamp logic lives in the match-card tokens + common
   component — the screen only picks the strategy. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, StudyShell, StudyOption, Sheet, PillBtn } = window.MX;

  // ---- Standard grid: short / medium meanings, 2-line cards. ----
  const STD_LEFT = [
    { t: '水', state: 'correct', mark: 'check' },
    { t: '火', state: 'wrong', mark: 'x' },
    { t: '日本', state: 'selected' },
    { t: '山' },
    { t: '本' },
  ];
  const STD_RIGHT = [
    { t: 'fire', state: 'wrong', mark: 'x' },
    { t: 'water', state: 'correct', mark: 'check' },
    { t: 'book' },
    { t: 'a tall landform rising above its surroundings' },
    { t: 'Japan' },
  ];

  // ---- Long-text grid: one 3-line definition + one meaning too long for the
  // card, which clamps with the "tap to read" hint (more). ----
  const LONG_FULL = 'a very long definition that requires three or more lines to read fully, with extra clauses and examples the learner needs before choosing the right pair';
  const LONG_LEFT = [
    { t: '山' },
    { t: '勉強' },
    { t: '図書館' },
  ];
  const LONG_RIGHT = [
    { t: 'a tall landform rising high above the surrounding land' },
    { t: 'the act of studying or learning something with focused effort over time' },
    { t: LONG_FULL, more: true },
  ];

  const StdGrid = () => (
    <div className="match-grid" data-mx-node="13-study-match/board">
      {STD_LEFT.map((l, i) => (
        <React.Fragment key={i}>
          <StudyOption clamp state={l.state} mark={l.mark} dim={l.state === 'correct'}>{l.t}</StudyOption>
          <StudyOption clamp state={STD_RIGHT[i].state} mark={STD_RIGHT[i].mark} dim={STD_RIGHT[i].state === 'correct'}>{STD_RIGHT[i].t}</StudyOption>
        </React.Fragment>
      ))}
    </div>
  );

  const LongGrid = () => (
    <div className="match-grid long-text" data-mx-node="13-study-match/board">
      {LONG_LEFT.map((l, i) => (
        <React.Fragment key={i}>
          <StudyOption clamp state={l.state} mark={l.mark}>{l.t}</StudyOption>
          <StudyOption clamp state={LONG_RIGHT[i].state} mark={LONG_RIGHT[i].mark} more={LONG_RIGHT[i].more}>{LONG_RIGHT[i].t}</StudyOption>
        </React.Fragment>
      ))}
    </div>
  );

  const Head = ({ sub }) => (
    <div style={{ textAlign: 'center', marginBottom: S(5) }}>
      <div className="title" style={{ fontSize: 'var(--memox-size-h1)' }}>Match the pairs</div>
      <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', marginTop: S(1) }}>{sub}</div>
    </div>
  );

  const Legend = ({ matched, left }) => (
    <div style={{ display: 'flex', justifyContent: 'center', gap: S(4), marginTop: S(5), color: 'var(--memox-text-secondary)', fontSize: 'var(--memox-fs-body-small)', fontWeight: 'var(--memox-weight-bold)' }}>
      <span style={{ display: 'inline-flex', alignItems: 'center', gap: S(1) }}><span className="status-dot" style={{ '--dot': 'var(--memox-rating-correct)' }}></span>{matched} matched</span>
      <span style={{ display: 'inline-flex', alignItems: 'center', gap: S(1) }}><span className="status-dot" style={{ '--dot': 'var(--memox-text-3)' }}></span>{left} left</span>
    </div>
  );

  const ShuffleFooter = (
    <button className="pill-btn outline" style={{ width: '100%' }}><Icon name="rotate-ccw" />Shuffle &amp; restart</button>
  );

  // State 1 — standard short/medium meanings.
  function Standard() {
    return (
      <StudyShell index={1} total={5} center footer={ShuffleFooter}>
        <Head sub="Tap a term, then its meaning." />
        <StdGrid />
        <Legend matched={1} left={4} />
      </StudyShell>
    );
  }

  // State 2 — a grid that holds a long definition: the whole grid uses the
  // long-text strategy (taller floor + 3 lines), still uniform.
  function LongMeanings() {
    return (
      <StudyShell index={2} total={5} center footer={ShuffleFooter}>
        <Head sub="Longer meanings show up to three lines." />
        <LongGrid />
        <Legend matched={0} left={3} />
      </StudyShell>
    );
  }

  // State 3 — a meaning too long for the card: tapping it opens the full text in
  // the shared bottom sheet so the learner can read it all before matching.
  function ReadFull() {
    return (
      <StudyShell index={2} total={5} center footer={ShuffleFooter}>
        <Head sub="Tap a clipped meaning to read it in full." />
        <LongGrid />
        <Legend matched={0} left={3} />
        <Sheet title="Full meaning">
          <div style={{ display: 'flex', alignItems: 'center', gap: S(2), color: 'var(--memox-text-secondary)', fontSize: 'var(--memox-fs-label-medium)', fontWeight: 'var(--memox-weight-bold)', textTransform: 'uppercase', letterSpacing: 'var(--memox-ls-section)', marginBottom: S(2) }}>
            <Icon name="book-open" style={{ width: 'var(--memox-icon-sm)', height: 'var(--memox-icon-sm)' }} />Meaning
          </div>
          <div style={{ fontSize: 'var(--memox-fs-title-small)', fontWeight: 'var(--memox-weight-semibold)', lineHeight: 'var(--memox-leading-normal)', color: 'var(--memox-text-primary)' }}>
            {LONG_FULL}
          </div>
          <div style={{ marginTop: S(5) }}>
            <PillBtn variant="primary" full>Got it</PillBtn>
          </div>
        </Sheet>
      </StudyShell>
    );
  }

  window.MEMOX_KIT.register({
    num: '13',
    title: 'Study · Match',
    states: [
      { label: 'Matching', render: () => <Standard /> },
      { label: 'Long meanings', render: () => <LongMeanings /> },
      { label: 'Read full meaning', render: () => <ReadFull /> },
    ],
  });
})();
