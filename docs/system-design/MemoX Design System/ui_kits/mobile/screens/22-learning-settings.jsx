/* MemoX screen — 22 Learning settings (5 states). Daily goal + reminders.
   App bar · Daily goal card (toggle + slider/stepper of cards) · Reminder card
   (toggle + time). States: goal on · goal off · reminder on · perm denied
   (notification permission refused → banner) · saving. Token-driven; composes
   shared primitives + contract classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, IconTile, Toggle, Slider, Banner, BusyOverlay } = window.MX;

  const Bar = () => (
    <div className="appbar">
      <button className="icon-btn" aria-label="Back"><Icon name="arrow-left" /></button>
      <span className="appbar-title" style={{ flex: 1, marginLeft: S(2) }}>Learning</span>
    </div>
  );

  const Body = ({ children }) => (
    <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  const RowHead = ({ icon, tint, title, desc, on, disabled, toggleNode }) => (
    <div style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
      <IconTile icon={icon} color={tint} />
      <div style={{ flex: 1 }}>
        <div className="title">{title}</div>
        <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>{desc}</div>
      </div>
      <Toggle on={on} disabled={disabled} node={toggleNode} />
    </div>
  );

  const PRESETS = [10, 20, 30, 50];
  const GoalCard = ({ on }) => (
    <div className="card" data-mx-node="22-learning-settings/goal-card" style={{ display: 'flex', flexDirection: 'column', gap: S(4) }}>
      <RowHead icon="target" tint="var(--memox-status-new)" title="Daily goal" desc={on ? 'Cards to study each day' : 'Turned off — study freely'} on={on} toggleNode="22-learning-settings/goal-toggle" />
      {on && (
        <React.Fragment>
          <div className="hr"></div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: S(2) }}>
            <span style={{ fontSize: 'var(--memox-size-display)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)', lineHeight: 1 }}>20</span>
            <span className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-semibold)' }}>cards / day</span>
          </div>
          <Slider value={20} min={5} max={60} node="22-learning-settings/goal-slider" />
          <div data-mx-node="22-learning-settings/goal-presets" style={{ display: 'flex', gap: S(2) }}>
            {PRESETS.map((p) => (
              <span key={p} className={`chip${p === 20 ? ' due solid' : ''}`} style={{ flex: 1, justifyContent: 'center', cursor: 'pointer' }}>{p}</span>
            ))}
          </div>
        </React.Fragment>
      )}
    </div>
  );

  const ReminderCard = ({ on, disabled }) => (
    <div className="card" data-mx-node="22-learning-settings/reminder-card" style={{ display: 'flex', flexDirection: 'column', gap: S(4), opacity: disabled ? 'var(--memox-op-disabled)' : 1 }}>
      <RowHead icon="bell" tint="var(--memox-status-learning)" title="Daily reminder" desc={on ? 'A nudge to keep your streak' : 'No reminder set'} on={on} disabled={disabled} />
      {on && !disabled && (
        <React.Fragment>
          <div className="hr"></div>
          <div className="list-row" style={{ margin: 0, padding: `${S(2)} 0` }}>
            <IconTile icon="clock" color="var(--memox-text-secondary)" />
            <div className="list-row-main"><div className="list-row-title">Time</div></div>
            <span className="list-row-trail"><span style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-bold)', color: 'var(--memox-text-primary)' }}>8:00 PM</span><Icon name="chevron-right" /></span>
          </div>
          <div className="hr inset"></div>
          <div className="list-row" style={{ margin: 0, padding: `${S(2)} 0` }}>
            <IconTile icon="repeat" color="var(--memox-text-secondary)" />
            <div className="list-row-main"><div className="list-row-title">Repeat</div></div>
            <span className="list-row-trail"><span className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-semibold)' }}>Every day</span><Icon name="chevron-right" /></span>
          </div>
        </React.Fragment>
      )}
    </div>
  );

  function Screen({ variant }) {
    const goalOn = variant !== 'goal-off';
    const reminderOn = variant === 'reminder-on';
    const permDenied = variant === 'perm-denied';

    return (
      <div className="app" style={{ position: 'relative' }}>
        <Bar />
        <Body>
          {permDenied && (
            <Banner tone="warn" icon="bell-off">Notifications are blocked. Enable them in system settings to get reminders.</Banner>
          )}
          <GoalCard on={goalOn} />
          <ReminderCard on={permDenied ? true : reminderOn} disabled={permDenied} />
          {permDenied && (
            <button className="pill-btn outline" style={{ width: '100%' }}><Icon name="settings" />Open system settings</button>
          )}
        </Body>
        {variant === 'saving' && <BusyOverlay label="Saving…" />}
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '22',
    title: 'Learning settings',
    states: [
      { label: 'Goal on', render: () => <Screen variant="goal-on" /> },
      { label: 'Goal off', render: () => <Screen variant="goal-off" /> },
      { label: 'Reminder on', render: () => <Screen variant="reminder-on" /> },
      { label: 'Perm denied', render: () => <Screen variant="perm-denied" /> },
      { label: 'Saving', render: () => <Screen variant="saving" /> },
    ],
  });
})();
