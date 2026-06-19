/* MemoX screen — 25 Language (3 states). App-language picker: System default ·
   English · Tiếng Việt, as a simple radio list. Token-driven; composes shared
   primitives + contract classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, RadioRow } = window.MX;

  const Bar = () => (
    <div className="appbar">
      <button className="icon-btn" aria-label="Back"><Icon name="arrow-left" /></button>
      <span className="appbar-title" style={{ flex: 1, marginLeft: S(2) }}>Language</span>
    </div>
  );

  const OPTIONS = [
    { key: 'system', icon: 'smartphone', tint: 'var(--memox-text-secondary)', title: 'System default', desc: 'English (United States)' },
    { key: 'en', icon: 'globe', tint: 'var(--memox-status-new)', title: 'English', desc: 'English' },
    { key: 'vi', icon: 'globe', tint: 'var(--memox-status-mastered)', title: 'Tiếng Việt', desc: 'Vietnamese' },
  ];

  function Screen({ selected }) {
    return (
      <div className="app">
        <Bar />
        <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`, display: 'flex', flexDirection: 'column', gap: S(2) }}>
          <div className="ov" style={{ paddingLeft: S(1) }}>App language</div>
          <div className="list-card">
            {OPTIONS.map((o, i) => (
              <div key={o.key}>
                {i > 0 && <div className="hr inset"></div>}
                <RadioRow icon={o.icon} tint={o.tint} title={o.title} desc={o.desc} selected={o.key === selected} />
              </div>
            ))}
          </div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', padding: `${S(2)} ${S(1)} 0`, display: 'flex', alignItems: 'center', gap: S(2) }}>
            <Icon name="info" style={{ width: 'var(--memox-icon-sm)', height: 'var(--memox-icon-sm)' }} />Changing the language restarts the app.
          </div>
        </div>
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '25',
    title: 'Language',
    states: [
      { label: 'System', render: () => <Screen selected="system" /> },
      { label: 'English', render: () => <Screen selected="en" /> },
      { label: 'Vietnamese', render: () => <Screen selected="vi" /> },
    ],
  });
})();
