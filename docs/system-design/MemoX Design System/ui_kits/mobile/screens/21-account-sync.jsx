/* MemoX screen — 21 Account sync (9 states). Google sign-in + Drive backup /
   restore. App bar · account block · backup block (status + Backup/Restore) ·
   recent-sync log. States: signed out · signing in · failed · no backup ·
   ready · uploading · restore warn (dialog) · restoring · token expired.
   Token-driven; composes shared primitives + contract classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, PillBtn, Avatar, IconTile, TileLg, HeroCard, Banner, Progress, Modal } = window.MX;

  const Bar = () => (
    <div className="appbar">
      <button className="icon-btn" aria-label="Back"><Icon name="arrow-left" /></button>
      <span className="appbar-title" style={{ flex: 1, marginLeft: S(2) }}>Account</span>
    </div>
  );

  const Body = ({ children }) => (
    <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  const SectionLabel = ({ children }) => <div className="ov" style={{ paddingLeft: S(1) }}>{children}</div>;

  // Account identity block.
  const AccountBlock = ({ variant }) => {
    if (variant === 'signing-in') {
      return (
        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
          <div className="spinner"></div>
          <div><div className="title">Signing in…</div><div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>Authorizing with Google</div></div>
        </div>
      );
    }
    if (variant === 'signed-out' || variant === 'failed') {
      return (
        <HeroCard icon="cloud" tint="var(--memox-primary)" title="Sign in to sync"
          desc="Back up your decks to Google Drive and restore them on any device.">
          <PillBtn variant="primary" icon="log-in" full>Continue with Google</PillBtn>
        </HeroCard>
      );
    }
    return (
      <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
        <Avatar lg initials="AN" />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div className="title">An Nguyen</div>
          <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>an.nguyen@gmail.com</div>
        </div>
        <button className="pill-btn outline sm">Sign out</button>
      </div>
    );
  };

  // Backup block per variant.
  const BackupBlock = ({ variant }) => {
    if (variant === 'uploading' || variant === 'restoring') {
      const up = variant === 'uploading';
      return (
        <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(3) }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
          <IconTile icon={up ? 'upload' : 'download'} color="var(--memox-primary)" />
            <div style={{ flex: 1 }}>
              <div className="title">{up ? 'Backing up…' : 'Restoring…'}</div>
              <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>{up ? '3 decks · 412 cards' : 'Replacing local data'}</div>
            </div>
            <span style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-primary)', fontVariantNumeric: 'tabular-nums' }}>{up ? '60%' : '40%'}</span>
          </div>
          <Progress value={up ? 60 : 40} />
        </div>
      );
    }
    if (variant === 'no-backup') {
      return (
        <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(4) }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
            <IconTile icon="cloud-off" color="var(--memox-status-learning)" />
            <div style={{ flex: 1 }}><div className="title">No backup yet</div><div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>Your decks aren't on Drive yet</div></div>
          </div>
          <button className="pill-btn primary" style={{ width: '100%' }}><Icon name="upload" />Back up now</button>
        </div>
      );
    }
    // ready / restore-warn underlying
    return (
      <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(4) }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
          <IconTile icon="check" color="var(--memox-status-mastered)" />
          <div style={{ flex: 1 }}><div className="title">Backup ready</div><div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>3 decks · 412 cards · 1.2 MB</div></div>
        </div>
        <div style={{ display: 'flex', gap: S(2) }}>
          <button className="pill-btn primary" style={{ flex: 1 }}><Icon name="upload" />Back up</button>
          <button className="pill-btn outline" style={{ flex: 1 }}><Icon name="download" />Restore</button>
        </div>
      </div>
    );
  };

  const LOG = [
    { icon: 'upload', tint: 'var(--memox-status-mastered)', t: 'Backed up', meta: '412 cards', when: '2h ago' },
    { icon: 'download', tint: 'var(--memox-status-new)', t: 'Restored', meta: '398 cards', when: 'Jun 14' },
    { icon: 'upload', tint: 'var(--memox-status-mastered)', t: 'Backed up', meta: '398 cards', when: 'Jun 12' },
  ];
  const SyncLog = () => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
      <SectionLabel>Recent sync</SectionLabel>
      <div className="list-card">
        {LOG.map((l, i) => (
          <div key={i}>
            {i > 0 && <div className="hr inset"></div>}
            <div className="list-row" style={{ cursor: 'default' }}>
              <IconTile icon={l.icon} color={l.tint} />
              <div className="list-row-main"><div className="list-row-title">{l.t}</div><div className="list-row-meta">{l.meta}</div></div>
              <span className="list-row-trail muted" style={{ fontSize: 'var(--memox-fs-body-small)', fontWeight: 'var(--memox-weight-semibold)' }}>{l.when}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  function Screen({ variant }) {
    const showBackup = ['no-backup', 'ready', 'uploading', 'restoring', 'restore-warn'].includes(variant);
    const showLog = ['ready', 'uploading', 'restoring', 'restore-warn'].includes(variant);

    const overlay = variant === 'restore-warn' ? (
      <Modal>
        <TileLg icon="alert-triangle" tint="var(--memox-status-learning)" style={{ margin: `0 0 ${S(4)}` }} />
        <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>Restore from backup?</div>
        <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', lineHeight: 1.5, marginTop: S(2) }}>
          This <b style={{ color: 'var(--memox-text-primary)' }}>replaces all local decks</b> with the backup from 2h ago. Anything not backed up will be lost.
        </div>
        <div style={{ display: 'flex', gap: S(2), marginTop: S(5) }}>
          <button className="pill-btn outline" style={{ flex: 1 }}>Cancel</button>
          <button className="pill-btn primary" style={{ flex: 1 }}><Icon name="download" />Restore</button>
        </div>
      </Modal>
    ) : null;

    return (
      <div className="app" style={{ position: 'relative' }}>
        <Bar />
        <Body>
          {variant === 'failed' && <Banner tone="danger" icon="alert-circle">Sign-in failed. Please try again.</Banner>}
          {variant === 'token-expired' && <Banner tone="warn" icon="clock">Your session expired. Sign in again to keep syncing.</Banner>}
          <AccountBlock variant={variant} />
          {showBackup && <BackupBlock variant={variant} />}
          {showLog && <SyncLog />}
        </Body>
        {overlay}
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '21',
    title: 'Account sync',
    states: [
      { label: 'Signed out', render: () => <Screen variant="signed-out" /> },
      { label: 'Signing in', render: () => <Screen variant="signing-in" /> },
      { label: 'Failed', render: () => <Screen variant="failed" /> },
      { label: 'No backup', render: () => <Screen variant="no-backup" /> },
      { label: 'Ready', render: () => <Screen variant="ready" /> },
      { label: 'Uploading', render: () => <Screen variant="uploading" /> },
      { label: 'Restore warn', render: () => <Screen variant="restore-warn" /> },
      { label: 'Restoring', render: () => <Screen variant="restoring" /> },
      { label: 'Token expired', render: () => <Screen variant="token-expired" /> },
    ],
  });
})();
