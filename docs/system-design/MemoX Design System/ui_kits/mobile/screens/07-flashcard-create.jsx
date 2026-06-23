/* MemoX screen — 07 Flashcard create (6 states). Create a new card: Front / Back
   faces plus an optional, collapsible Details area (deck, tags, note). App bar
   (title "New card" + back + Save). Token-driven; composes contract classes +
   shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, PillBtn, FormField, TextArea, Chip, Banner, PickerRow, Breadcrumb } = window.MX;

  // ---- App bar (back + title + Save) ---------------------------------------
  const Bar = ({ canSave, saving }) => (
    <>
      <div className="appbar">
        <button className="icon-btn" aria-label="Back"><Icon name="x" /></button>
        <span className="appbar-title" style={{ flex: 1, minWidth: 0, marginLeft: S(2) }}>New card</span>
        <button className="pill-btn primary sm" disabled={!canSave || saving} style={{ minWidth: '76px' }}>
          {saving ? <span className="spinner" style={{ width: 'var(--memox-icon-sm)', height: 'var(--memox-icon-sm)', borderWidth: '2px' }}></span> : <><Icon name="check" />Save</>}
        </button>
      </div>
      <Breadcrumb items={[{ label: 'Library', icon: 'library' }, { label: 'Languages' }, { label: 'Japanese \u00B7 N5' }, { label: 'New card', current: true }]} />
    </>
  );

  const Body = ({ children }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-12)`, display: 'flex', flexDirection: 'column', gap: 'var(--memox-gap-section)' }}>
      {children}
    </div>
  );

  // Collapsible "Details" disclosure header
  const DetailsHeader = ({ open }) => (
    <button style={{
      display: 'flex', alignItems: 'center', gap: S(2), width: '100%',
      background: 'none', border: 'none', cursor: 'pointer', padding: `0 ${S(1)}`,
      fontFamily: 'var(--memox-font-sans)', color: 'var(--memox-text-secondary)',
    }}>
      <Icon name={open ? 'chevron-down' : 'chevron-right'} style={{ width: 'var(--memox-icon-md)', height: 'var(--memox-icon-md)' }} />
      <span className="section-head-title" style={{ fontSize: 'var(--memox-fs-title-small)' }}>Details</span>
      <span style={{ flex: 1 }}></span>
      <span className="muted" style={{ fontSize: 'var(--memox-fs-body-small)', fontWeight: 'var(--memox-weight-semibold)' }}>{open ? 'tags · note' : 'Optional'}</span>
    </button>
  );

  const DetailsBody = () => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: S(4), paddingTop: S(2) }}>
      <FormField label="Deck">
        <PickerRow icon="languages" tint="var(--memox-status-new)" title="Japanese · N5" />
      </FormField>
      <FormField label="Tags">
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: S(2) }}>
          <Chip icon="hash">kanji</Chip>
          <Chip icon="hash">n5</Chip>
          <span className="chip" style={{ borderRadius: 'var(--memox-radius-full)', border: '1px dashed var(--memox-outline-variant)', background: 'transparent', cursor: 'pointer' }}><Icon name="plus" />Add tag</span>
        </div>
      </FormField>
      <FormField label="Note" right="Optional">
        <TextArea placeholder="Add a hint, mnemonic or example sentence…" defaultValue="" style={{ minHeight: '72px' }} />
      </FormField>
    </div>
  );

  function Screen({ variant }) {
    const filled = variant !== 'empty' && variant !== 'validation';
    const open = variant === 'details';
    const front = variant === 'validation' ? '' : (filled ? '日本' : '');
    const back = filled ? 'Japan / にほん' : '';

    return (
      <div className="app">
        <Bar canSave={filled} saving={variant === 'saving'} />

        {variant === 'save-failed' && (
          <div style={{ padding: `0 var(--memox-space-screen) ${S(3)}` }}>
            <Banner tone="danger" icon="alert-triangle" action="Retry">Couldn't save — your card is kept here.</Banner>
          </div>
        )}

        <Body>
          <FormField label="Front" error={variant === 'validation' ? 'The front of the card is required.' : undefined}>
            <TextArea invalid={variant === 'validation'} placeholder="Term, question or prompt" defaultValue={front} data-mx-node="flashcard-editor/front-field" />
          </FormField>

          <FormField label="Back">
            <TextArea placeholder="Answer or definition" defaultValue={back} data-mx-node="flashcard-editor/back-field" />
          </FormField>

          <div className="hr"></div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: open ? S(4) : 0 }}>
            <DetailsHeader open={open} />
            {open && <DetailsBody />}
          </div>
        </Body>
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '07',
    title: 'Flashcard create',
    states: [
      { label: 'Empty', render: () => <Screen variant="empty" /> },
      { label: 'Valid', render: () => <Screen variant="valid" /> },
      { label: 'Details open', render: () => <Screen variant="details" /> },
      { label: 'Validation', render: () => <Screen variant="validation" /> },
      { label: 'Saving', render: () => <Screen variant="saving" /> },
      { label: 'Save failed', render: () => <Screen variant="save-failed" /> },
    ],
  });
})();
