/* MemoX screen — 20 Settings (5 states). The settings hub: an account header
   block (avatar + email + sync status) followed by grouped category rows that
   lead to sub-screens. States: populated · loading · signed out · signing in ·
   sync error. App bar + bottom-nav; token-driven, composes shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, Avatar, ListRow, Banner, BottomNav, Sk, ScreenBody } = window.MX;

  const Header = () => (
    <div className="appbar-lg">
      <div style={{ display: 'flex', alignItems: 'flex-end', width: '100%' }}>
        <span className="appbar-title">Settings</span>
      </div>
    </div>
  );

  const Body = ({ children }) => <ScreenBody padTop={2} minH>{children}</ScreenBody>;

  // Account header block — its body switches per variant.
  const AccountBlock = ({ variant }) => {
    if (variant === 'signing-in') {
      return (
        <div className="card" data-mx-node="20-settings/account-card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
          <div className="spinner"></div>
          <div>
            <div className="title">Signing in…</div>
            <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>Connecting to your Google account</div>
          </div>
        </div>
      );
    }
    if (variant === 'signed-out') {
      return (
        <div className="card" data-mx-node="20-settings/account-card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
          <Avatar lg icon="user" tint="var(--memox-text-secondary)" />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="title">Not signed in</div>
            <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>Sign in to back up your decks</div>
          </div>
          <button className="pill-btn primary sm"><Icon name="log-in" />Sign in</button>
        </div>
      );
    }
    const synced = variant !== 'sync-error';
    return (
      <div className="card" data-mx-node="20-settings/account-card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
        <Avatar lg initials="AN" />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div className="title">An Nguyen</div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>an.nguyen@gmail.com</div>
        </div>
        {synced ? (
          <span className="chip got"><Icon name="cloud" />Synced</span>
        ) : (
          <button className="pill-btn outline sm" style={{ color: 'var(--memox-danger)', borderColor: 'color-mix(in srgb, var(--memox-danger) calc(var(--memox-op-border-subtle) * 100%), transparent)' }}><Icon name="rotate-ccw" />Retry</button>
        )}
      </div>
    );
  };

  const GROUP_1 = [
    { icon: 'target', tint: 'var(--memox-status-new)', title: 'Learning', meta: 'Daily goal, reminders', value: '20/day' },
    { icon: 'volume-2', tint: 'var(--memox-status-reviewing)', title: 'Audio & speech', meta: 'Text-to-speech voices', value: 'English' },
    { icon: 'palette', tint: 'var(--memox-status-learning)', title: 'Appearance', meta: 'Theme', value: 'System' },
    { icon: 'languages', tint: 'var(--memox-status-mastered)', title: 'Language', meta: 'App language', value: 'English' },
  ];
  const GROUP_2 = [
    { icon: 'cloud', tint: 'var(--memox-status-new)', title: 'Account & sync', meta: 'Backup and restore' },
    { icon: 'info', tint: 'var(--memox-text-secondary)', title: 'About', meta: 'Version, licenses', value: 'v2.4.0' },
  ];

  const Group = ({ items, node }) => (
    <div className="list-card" data-mx-node={node}>
      {items.map((it, i) => (
        <div key={it.title}>
          {i > 0 && <div className="hr inset"></div>}
          <ListRow icon={it.icon} color={it.tint} title={it.title} meta={it.meta}
            trail={it.value != null ? <span className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-semibold)' }}>{it.value}</span> : undefined} />
        </div>
      ))}
    </div>
  );

  function Screen({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Header />
          <Body>
            <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
              <Sk h="56px" w="56px" r="var(--memox-radius-full)" />
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="16px" w="50%" /><Sk h="12px" w="70%" /></div>
            </div>
            {[0, 1].map((g) => (
              <div key={g} className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(4), padding: `${S(2)} var(--memox-space-card)` }}>
                {[0, 1, 2].map((i) => (
                  <div key={i} style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
                    <Sk h="40px" w="40px" r="var(--memox-radius-md)" />
                    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: S(2) }}><Sk h="14px" w="45%" /><Sk h="11px" w="62%" /></div>
                  </div>
                ))}
              </div>
            ))}
          </Body>
          <BottomNav active="Settings" />
        </div>
      );
    }

    return (
      <div className="app">
        <Header />
        <Body>
          {variant === 'sync-error' && <Banner tone="danger" icon="cloud-off">Last sync failed. Your latest changes aren't backed up.</Banner>}
          <AccountBlock variant={variant} />
          <Group items={GROUP_1} node="20-settings/settings-group" />
          <Group items={GROUP_2} />
        </Body>
        <BottomNav active="Settings" />
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '20',
    title: 'Settings',
    states: [
      { label: 'Populated', render: () => <Screen variant="populated" /> },
      { label: 'Signed out', render: () => <Screen variant="signed-out" /> },
      { label: 'Signing in', render: () => <Screen variant="signing-in" /> },
      { label: 'Sync error', render: () => <Screen variant="sync-error" /> },
      { label: 'Loading', render: () => <Screen variant="loading" /> },
    ],
  });
})();
