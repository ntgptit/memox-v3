/* MemoX screen — 10 Deck import (9 states). Import cards from a file: choose →
   parse → preview (valid / invalid rows) → import. App bar (title "Import" +
   back). Token-driven; composes contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, Progress, IconTile, TileLg, HeroCard, Banner } = window.MX;

  // ---- Data (parsed rows) --------------------------------------------------
  const ROWS = [
    { front: '日本 — Japan', ok: true },
    { front: '日曜日 — Sunday', ok: true },
    { front: '本 — book', ok: true },
    { front: '水 — water', ok: true },
    { front: '火曜日 — Tuesday', ok: true },
  ];
  const ROWS_MIXED = [
    { front: '日本 — Japan', ok: true },
    { front: '日曜日 — Sunday', ok: true },
    { front: '(empty front)', ok: false, why: 'Missing front' },
    { front: '水 — water', ok: true },
    { front: 'dup: 本 — book', ok: false, why: 'Duplicate card' },
  ];

  // ---- App bar -------------------------------------------------------------
  const Bar = ({ action }) => (
    <div className="appbar">
      <button className="icon-btn" aria-label="Back"><Icon name="arrow-left" /></button>
      <span className="appbar-title" style={{ flex: 1, minWidth: 0, marginLeft: S(2) }}>Import</span>
      {action}
    </div>
  );

  const Body = ({ children, center }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-12)`, display: 'flex', flexDirection: 'column', gap: S(4), ...(center ? { justifyContent: 'center' } : null) }}>
      {children}
    </div>
  );

  // file chip card
  const FileCard = ({ status }) => (
    <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3), padding: S(4) }}>
      <IconTile icon="file-text" color="var(--memox-status-new)" />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className="title" style={{ fontSize: 'var(--memox-fs-label-large)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>japanese-n5.csv</div>
        <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>{status || '24.6 KB · CSV'}</div>
      </div>
      <button className="icon-btn" aria-label="Remove file"><Icon name="x" /></button>
    </div>
  );

  // parsed-rows preview list
  const PreviewList = ({ rows }) => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
      <div className="ov" style={{ paddingLeft: S(1) }}>Preview<span style={{ marginLeft: S(1), color: 'var(--memox-text-3)' }}>{rows.length}</span></div>
      <div className="list-card">
        {rows.map((r, i) => (
          <div key={i}>
            {i > 0 && <div className="hr inset"></div>}
            <div className="list-row" style={{ cursor: 'default' }}>
              <IconTile icon={r.ok ? 'check' : 'alert-triangle'} color={r.ok ? 'var(--memox-status-mastered)' : 'var(--memox-danger)'} />
              <div className="list-row-main">
                <div className="list-row-title" style={r.ok ? undefined : { color: 'var(--memox-text-secondary)' }}>{r.front}</div>
                {!r.ok && <div className="list-row-meta" style={{ color: 'var(--memox-danger)' }}>{r.why}</div>}
              </div>
              {!r.ok && <span className="chip" style={{ '--chip': 'var(--memox-danger)' }}>Skip</span>}
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  // result hero (success / partial / failed)
  const ResultHero = ({ icon, tint, solid, title, desc, primary, secondary }) => (
    <HeroCard icon={icon} tint={tint} solid={solid} title={title} desc={desc}>
      {primary}{secondary}
    </HeroCard>
  );

  function Screen({ variant }) {
    // ----- empty: dropzone -----
    if (variant === 'empty') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <div style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: S(3),
              padding: `${S(10)} var(--memox-space-6)`, textAlign: 'center',
              border: '2px dashed var(--memox-outline-variant)', borderRadius: 'var(--memox-radius-card)',
              background: 'var(--memox-surface)',
            }}>
              <TileLg icon="upload-cloud" tint="var(--memox-primary)" />
              <div className="title" style={{ marginTop: S(1) }}>Drop a file to import</div>
              <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', maxWidth: '240px' }}>Drag a file here, or browse to choose one from your device.</div>
              <button className="pill-btn primary" style={{ marginTop: S(2) }}><Icon name="folder-open" />Browse files</button>
            </div>
            <Banner tone="info" icon="info">Supports CSV, TSV and Anki (.apkg) files.</Banner>
          </Body>
        </div>
      );
    }

    // ----- file selected: file card + parse action -----
    if (variant === 'selected') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <FileCard status="24.6 KB · CSV · ready to parse" />
            <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="scan-line" />Parse file</button>
            <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', textAlign: 'center' }}>We'll show a preview before anything is imported.</div>
          </Body>
        </div>
      );
    }

    // ----- parsing -----
    if (variant === 'parsing') {
      return (
        <div className="app">
          <Bar />
          <Body center>
            <div style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: S(4) }}>
              <div className="spinner"></div>
              <div>
                <div className="title">Parsing file…</div>
                <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', marginTop: S(1) }}>Reading japanese-n5.csv</div>
              </div>
            </div>
          </Body>
        </div>
      );
    }

    // ----- preview (all valid) -----
    if (variant === 'preview-all') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <FileCard status="142 cards found · all valid" />
            <Banner tint="var(--memox-status-mastered)" icon="check-circle-2">All 142 cards look good.</Banner>
            <PreviewList rows={ROWS} />
            <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="download" />Import 142 cards</button>
          </Body>
        </div>
      );
    }

    // ----- preview (mixed valid/invalid) -----
    if (variant === 'preview-mixed') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <FileCard status="142 found · 118 valid · 24 to skip" />
            <Banner tone="warn" icon="alert-triangle">24 cards have problems and will be skipped.</Banner>
            <PreviewList rows={ROWS_MIXED} />
            <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="download" />Import 118 valid cards</button>
          </Body>
        </div>
      );
    }

    // ----- importing -----
    if (variant === 'importing') {
      return (
        <div className="app">
          <Bar />
          <Body center>
            <div style={{ width: '100%', textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: S(4) }}>
              <span className="tile-lg solid" style={{ '--tile': 'var(--memox-primary)' }}><Icon name="download" /></span>
              <div>
                <div className="title">Importing cards…</div>
                <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', marginTop: S(1) }}>96 of 142 imported</div>
              </div>
              <div style={{ width: '100%' }}><Progress value={68} /></div>
            </div>
          </Body>
        </div>
      );
    }

    // ----- success -----
    if (variant === 'success') {
      return (
        <div className="app">
          <Bar />
          <Body center>
            <ResultHero icon="check" tint="var(--memox-status-mastered)"
              title="142 cards imported" desc="They're now in your “Japanese · N5” deck, ready to study."
              primary={<button className="pill-btn primary" style={{ width: '100%' }}><Icon name="layers" />Open deck</button>}
              secondary={<button className="pill-btn outline" style={{ width: '100%' }}>Done</button>} />
          </Body>
        </div>
      );
    }

    // ----- partial -----
    if (variant === 'partial') {
      return (
        <div className="app">
          <Bar />
          <Body center>
            <ResultHero icon="check-check" tint="var(--memox-status-learning)"
              title="118 imported · 24 skipped" desc="Some rows were invalid or duplicates and were left out."
              primary={<button className="pill-btn primary" style={{ width: '100%' }}><Icon name="download" />Review skipped</button>}
              secondary={<button className="pill-btn outline" style={{ width: '100%' }}>Done</button>} />
          </Body>
        </div>
      );
    }

    // ----- failed -----
    return (
      <div className="app">
        <Bar />
        <Body center>
          <ResultHero icon="x" tint="var(--memox-danger)"
            title="Import failed" desc="Nothing was imported. The file may be corrupt or in an unsupported format."
            primary={<button className="pill-btn primary" style={{ width: '100%' }}><Icon name="rotate-ccw" />Try again</button>}
            secondary={<button className="pill-btn outline" style={{ width: '100%' }}>Choose another file</button>} />
        </Body>
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '10',
    title: 'Deck import',
    states: [
      { label: 'Empty', render: () => <Screen variant="empty" /> },
      { label: 'File selected', render: () => <Screen variant="selected" /> },
      { label: 'Parsing', render: () => <Screen variant="parsing" /> },
      { label: 'Preview · all valid', render: () => <Screen variant="preview-all" /> },
      { label: 'Preview · mixed', render: () => <Screen variant="preview-mixed" /> },
      { label: 'Importing', render: () => <Screen variant="importing" /> },
      { label: 'Success', render: () => <Screen variant="success" /> },
      { label: 'Partial', render: () => <Screen variant="partial" /> },
      { label: 'Failed', render: () => <Screen variant="failed" /> },
    ],
  });
})();
