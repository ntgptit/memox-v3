/* MemoX screen — 23 Audio & speech (7 states). Text-to-speech: voice language,
   voice list (radio), a preview, and speed/pitch. States: Korean · English ·
   loading · no voices (empty) · engine error · playing (stop + waveform) ·
   saving. Token-driven; composes shared primitives + contract classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const { Icon, S, RadioRow, Slider, HeroCard, BusyOverlay, Sk, SkList, ScreenBody, SubAppBar, ListCard } = window.MX;

  const Bar = () => <SubAppBar title="Audio &amp; speech" />;
  const Body = ({ children }) => <ScreenBody minH>{children}</ScreenBody>;

  const SectionLabel = ({ children }) => <div className="ov" style={{ paddingLeft: S(1) }}>{children}</div>;

  const VOICES = {
    Korean: { sample: '안녕하세요, 오늘도 공부해요.', list: [
      { name: 'Yuna', desc: 'Female · Neural', sel: true },
      { name: 'Minho', desc: 'Male · Neural' },
      { name: 'Sora', desc: 'Female · Standard' },
    ] },
    English: { sample: 'The quick brown fox jumps over the lazy dog.', list: [
      { name: 'Ava', desc: 'Female · US · Neural', sel: true },
      { name: 'James', desc: 'Male · UK' },
      { name: 'Emma', desc: 'Female · UK' },
    ] },
  };

  const LangRow = ({ lang }) => (
    <div className="list-card" data-mx-node="23-audio-speech/language-row">
      <div className="list-row">
        <span className="icon-tile" style={{ '--tile': 'var(--memox-status-reviewing)' }}><Icon name="languages" /></span>
        <div className="list-row-main"><div className="list-row-title">Voice language</div></div>
        <span className="list-row-trail"><span style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-bold)', color: 'var(--memox-text-primary)' }}>{lang}</span><Icon name="chevron-right" /></span>
      </div>
    </div>
  );

  const PreviewCard = ({ sample, playing }) => (
    <div className="card" data-mx-node="23-audio-speech/preview-card" style={{ display: 'flex', flexDirection: 'column', gap: S(3) }}>
      <SectionLabel>Preview</SectionLabel>
      <div style={{ fontSize: 'var(--memox-size-h2)', fontWeight: 'var(--memox-weight-semibold)', color: 'var(--memox-text-primary)', fontFamily: 'var(--memox-font-serif)', lineHeight: 1.4 }}>{sample}</div>
      {playing ? (
        <div style={{ display: 'flex', alignItems: 'center', gap: S(3) }}>
          <button className="pill-btn primary" data-mx-node="23-audio-speech/preview-button" style={{ flex: 1 }}><Icon name="square" />Stop</button>
          <div className="waveform"><span></span><span></span><span></span><span></span><span></span></div>
        </div>
      ) : (
        <button className="pill-btn secondary" data-mx-node="23-audio-speech/preview-button" style={{ width: '100%' }}><Icon name="play" />Play sample</button>
      )}
    </div>
  );

  const Tuning = () => (
    <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: S(5) }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
        <div className="section-head"><span className="title">Speed</span><span className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-bold)' }}>1.0×</span></div>
        <Slider value={1} min={0.5} max={2} />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
        <div className="section-head"><span className="title">Pitch</span><span className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-bold)' }}>Normal</span></div>
        <Slider value={50} min={0} max={100} />
      </div>
    </div>
  );

  function Screen({ variant }) {
    if (variant === 'loading') {
      return (
        <div className="app">
          <Bar />
          <Body>
            <Sk h="64px" r="var(--memox-radius-card)" />
            <SkList rows={3} w1="40%" w2="55%" trail={<Sk h="22px" w="22px" r="var(--memox-radius-full)" />} />
          </Body>
        </div>
      );
    }

    if (variant === 'no-voices' || variant === 'engine-error') {
      const err = variant === 'engine-error';
      return (
        <div className="app">
          <Bar />
          <Body>
            <div style={{ flex: 1, display: 'grid', placeItems: 'center', padding: `${S(6)} 0` }}>
              <HeroCard icon={err ? 'alert-triangle' : 'volume-x'} tint={err ? 'var(--memox-danger)' : 'var(--memox-text-secondary)'}
                title={err ? 'Speech engine unavailable' : 'No voices installed'}
                desc={err ? "MemoX couldn't reach the device's text-to-speech engine." : 'Your device has no text-to-speech voices for this language yet.'}>
                <button className="pill-btn primary" style={{ width: '100%' }}><Icon name={err ? 'rotate-ccw' : 'settings'} />{err ? 'Try again' : 'Install voices'}</button>
              </HeroCard>
            </div>
          </Body>
        </div>
      );
    }

    const lang = variant === 'English' ? 'English' : 'Korean';
    const data = VOICES[lang];
    const playing = variant === 'playing';

    return (
      <div className="app" style={{ position: 'relative' }}>
        <Bar />
        <Body>
          <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
            <SectionLabel>Language</SectionLabel>
            <LangRow lang={lang} />
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
            <SectionLabel>Voice</SectionLabel>
            <ListCard node="23-audio-speech/voice-list" items={data.list} row={(v) => (
              <RadioRow icon="mic" tint="var(--memox-status-new)" title={v.name} desc={v.desc} selected={v.sel} />
            )} />
          </div>
          <PreviewCard sample={data.sample} playing={playing} />
          <Tuning />
        </Body>
        {variant === 'saving' && <BusyOverlay label="Saving…" />}
      </div>
    );
  }

  window.MEMOX_KIT.register({
    num: '23',
    title: 'Audio & speech',
    states: [
      { label: 'Korean', render: () => <Screen variant="Korean" /> },
      { label: 'English', render: () => <Screen variant="English" /> },
      { label: 'Playing', render: () => <Screen variant="playing" /> },
      { label: 'Loading', render: () => <Screen variant="loading" /> },
      { label: 'No voices', render: () => <Screen variant="no-voices" /> },
      { label: 'Engine error', render: () => <Screen variant="engine-error" /> },
      { label: 'Saving', render: () => <Screen variant="saving" /> },
    ],
  });
})();
