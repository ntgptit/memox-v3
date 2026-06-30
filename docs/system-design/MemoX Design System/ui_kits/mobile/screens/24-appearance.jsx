/* MemoX screen — 24 Appearance (3 states). Theme picker: Light · Dark · System,
   as a radio list with a live mini-preview swatch per option. The swatches force
   their palette via the .memox-light / .memox-dark token scopes, so each renders
   in its own theme regardless of the current one. Token-driven. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, RadioRow, ScreenBody, SubAppBar, ListCard } = window.MX;

  // Mini screen preview, forced into `theme` palette.
  const Swatch = ({ theme }) => (
    <div className={theme} style={{ width: 'var(--memox-size-fab)', height: 'var(--memox-size-fab)', flex: 'none', borderRadius: 'var(--memox-radius-md)', overflow: 'hidden', border: '1px solid var(--memox-border)', background: 'var(--memox-bg)', padding: 'var(--memox-space-2)', display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-1)' }}>
      <div style={{ height: 'var(--memox-space-2)', width: '55%', borderRadius: 'var(--memox-radius-xs)', background: 'var(--memox-accent)' }}></div>
      <div style={{ height: 'var(--memox-space-2)', borderRadius: 'var(--memox-radius-xs)', background: 'var(--memox-surface)' }}></div>
      <div style={{ height: 'var(--memox-space-2)', width: '80%', borderRadius: 'var(--memox-radius-xs)', background: 'var(--memox-surface)' }}></div>
    </div>
  );

  const SystemSwatch = () => (
    <div style={{ width: 'var(--memox-size-fab)', height: 'var(--memox-size-fab)', flex: 'none', borderRadius: 'var(--memox-radius-md)', overflow: 'hidden', border: '1px solid var(--memox-border)', display: 'flex' }}>
      <div className="memox-light" style={{ flex: 1, background: 'var(--memox-bg)', display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-1)', padding: 'var(--memox-space-1)' }}>
        <div style={{ height: 'var(--memox-space-2)', borderRadius: 'var(--memox-radius-xs)', background: 'var(--memox-accent)' }}></div>
        <div style={{ height: 'var(--memox-space-2)', borderRadius: 'var(--memox-radius-xs)', background: 'var(--memox-surface)' }}></div>
      </div>
      <div className="memox-dark" style={{ flex: 1, background: 'var(--memox-bg)', display: 'flex', flexDirection: 'column', gap: 'var(--memox-space-1)', padding: 'var(--memox-space-1)' }}>
        <div style={{ height: 'var(--memox-space-2)', borderRadius: 'var(--memox-radius-xs)', background: 'var(--memox-accent)' }}></div>
        <div style={{ height: 'var(--memox-space-2)', borderRadius: 'var(--memox-radius-xs)', background: 'var(--memox-surface)' }}></div>
      </div>
    </div>
  );

  const OPTIONS = [
    { key: 'light', title: 'Light', desc: 'Always light', swatch: <Swatch theme="memox-light" /> },
    { key: 'dark', title: 'Dark', desc: 'Always dark', swatch: <Swatch theme="memox-dark" /> },
    { key: 'system', title: 'System', desc: 'Match device setting', swatch: <SystemSwatch /> },
  ];

  function Screen({ selected }) {
    return (
      <div className="app">
        <SubAppBar title="Appearance" />
        <ScreenBody gap={2} minH>
          <div className="ov" style={{ paddingLeft: S(1) }}>Theme</div>
          <ListCard node="24-appearance/theme-list" inset={false} items={OPTIONS} row={(o) => (
            <RadioRow lead={o.swatch} title={o.title} desc={o.desc} selected={o.key === selected} />
          )} />
          <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', padding: `${S(2)} ${S(1)} 0`, display: 'flex', alignItems: 'center', gap: S(2) }}>
            <Icon name="info" style={{ width: 'var(--memox-icon-sm)', height: 'var(--memox-icon-sm)' }} />System follows your device's light/dark schedule.
          </div>
        </ScreenBody>
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '24',
    title: 'Appearance',
    states: [
      { label: 'System', render: () => <Screen selected="system" /> },
      { label: 'Light', render: () => <Screen selected="light" /> },
      { label: 'Dark', render: () => <Screen selected="dark" /> },
    ],
  });
})();
