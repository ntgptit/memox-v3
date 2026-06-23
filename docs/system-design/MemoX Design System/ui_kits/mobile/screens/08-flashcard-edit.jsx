/* MemoX screen — 08 Flashcard edit (7 states). Edit an existing card: prefilled
   Front / Back / Details, plus loading + load-error states and a delete action.
   App bar (title "Edit card" + back + Save + delete). Token-driven; composes
   contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, PillBtn, FormField, TextArea, Chip, TileLg, HeroCard, Banner, Sk, Modal, PickerRow, Breadcrumb } = window.MX;

  // ---- App bar (back + title + delete + Save) ------------------------------
  const Bar = ({ saving, showActions = true }) => (
    <>
      <div className="appbar">
        <button className="icon-btn" aria-label="Back" data-mx-node="flashcard-editor/back-btn"><Icon name="arrow-left" /></button>
        <span className="appbar-title" style={{ flex: 1, minWidth: 0, marginLeft: S(2) }}>Edit card</span>
        {showActions && (
          <>
            <button className="icon-btn" aria-label="Delete card" style={{ color: 'var(--memox-danger)' }} data-mx-node="flashcard-editor/delete-btn"><Icon name="trash-2" /></button>
            <button className="pill-btn primary sm" disabled={saving} style={{ minWidth: '76px' }} data-mx-node="flashcard-editor/save-button">
              {saving ? <span className="spinner" style={{ width: 'var(--memox-icon-sm)', height: 'var(--memox-icon-sm)', borderWidth: '2px' }}></span> : <><Icon name="check" />Save</>}
            </button>
          </>
        )}
      </div>
      <Breadcrumb items={[{ label: 'Library', icon: 'library' }, { label: 'Languages' }, { label: 'Japanese \u00B7 N5' }, { label: 'Edit card', current: true }]} />
    </>
  );

  const Body = ({ children }) => (
    <div style={{ flex: 1, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen) var(--memox-space-12)`, display: 'flex', flexDirection: 'column', gap: S(5) }}>
      {children}
    </div>
  );

  const DetailsBlock = () => (
    <>
      <div className="hr"></div>
      <FormField label="Deck">
        <PickerRow icon="languages" tint="var(--memox-status-new)" title="Japanese · N5" />
      </FormField>
      <FormField label="Tags">
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: S(2) }}>
          <Chip icon="hash">kanji</Chip>
          <Chip icon="hash">n5</Chip>
          <Chip icon="hash">vocab</Chip>
          <span className="chip" style={{ border: '1px dashed var(--memox-outline-variant)', background: 'transparent', cursor: 'pointer' }}><Icon name="plus" />Add tag</span>
        </div>
      </FormField>
    </>
  );

  function Screen({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Bar showActions={false} />
          <Body>
            {[0, 1].map((i) => (
              <div key={i} style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
                <Sk h="12px" w="22%" />
                <Sk h="96px" r="var(--memox-radius-md)" />
              </div>
            ))}
            <Sk h="1px" />
            <div style={{ display: 'flex', gap: S(2) }}>
              <Sk h="24px" w="64px" r="var(--memox-radius-full)" />
              <Sk h="24px" w="52px" r="var(--memox-radius-full)" />
            </div>
          </Body>
        </div>
      );
    }

    if (variant === 'load-error') {
      return (
        <div className="app">
          <Bar showActions={false} />
          <Body>
            <div style={{ flex: 1, display: 'grid', placeItems: 'center' }}>
              <HeroCard icon="cloud-off" tint="var(--memox-danger)" title="Couldn't load card"
                desc="We couldn't fetch this card to edit.">
                <PillBtn variant="primary" icon="rotate-ccw" full>Retry</PillBtn>
              </HeroCard>
            </div>
          </Body>
        </div>
      );
    }

    const invalid = variant === 'validation';
    const overlay = variant === 'delete' ? (
      <Modal>
        <TileLg icon="trash-2" tint="var(--memox-danger)" style={{ margin: `0 0 ${S(4)}` }} />
        <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>Delete this card?</div>
        <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', lineHeight: 1.5, marginTop: S(2) }}>
          <b style={{ color: 'var(--memox-text-primary)' }}>“日本 — Japan”</b> and its review history will be removed. This can't be undone.
        </div>
        <div style={{ display: 'flex', gap: S(2), marginTop: S(5) }}>
          <button className="pill-btn outline" style={{ flex: 1 }}>Cancel</button>
          <button className="pill-btn danger" style={{ flex: 1 }}><Icon name="trash-2" />Delete</button>
        </div>
      </Modal>
    ) : null;

    return (
      <div className="app" style={{ position: 'relative' }}>
        <Bar saving={variant === 'saving'} />

        {variant === 'save-failed' && (
          <div style={{ padding: `0 var(--memox-space-screen) ${S(3)}` }}>
            <Banner tone="danger" icon="alert-triangle" action="Retry">Changes couldn't be saved.</Banner>
          </div>
        )}

        <Body>
          <FormField label="Front" error={invalid ? 'The front of the card is required.' : undefined}>
            <TextArea invalid={invalid} defaultValue={invalid ? '' : '日本'} placeholder="Term, question or prompt" data-mx-node="flashcard-editor/front-field" />
          </FormField>
          <FormField label="Back">
            <TextArea defaultValue="Japan / にほん" data-mx-node="flashcard-editor/back-field" />
          </FormField>
          <DetailsBlock />
        </Body>
        {overlay}
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '08',
    title: 'Flashcard edit',
    states: [
      { label: 'Loaded', render: () => <Screen variant="loaded" /> },
      { label: 'Loading', render: () => <Screen variant="loading" /> },
      { label: 'Load error', render: () => <Screen variant="load-error" /> },
      { label: 'Validation', render: () => <Screen variant="validation" /> },
      { label: 'Saving', render: () => <Screen variant="saving" /> },
      { label: 'Save failed', render: () => <Screen variant="save-failed" /> },
      { label: 'Delete', render: () => <Screen variant="delete" /> },
    ],
  });
})();
