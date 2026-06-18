/* MemoX Mobile — FlashcardEditScreen · MAIN
   ────────────────────────────────────────────────────────────────────────
   Folder layout:
     FlashcardEditScreen/
       FlashcardEditScreen.jsx  ← shared edit form + helpers, rendered from a flag set
       states/                  ← one file per state in window.MemoXStates.FlashcardEdit

   Like Create, this is ONE form with flag-driven states, so each state file just
   declares its flags:
     window.MemoXStates.FlashcardEdit.<name> = () =>
       ({ loading, loadError, validationErr, saving, saveFailed, delConfirm })
   The MAIN file derives `valid` / `back` from those, renders the single form, swaps
   to the full-screen load-error layout when loadError, and adds the delete dialog
   when delConfirm. Editing one state's file never touches the others. */
(function () {
const { StatusBar, masteryColor, Ic, Breadcrumb, BottomNav, OfflineBanner, StudyTopBar } = window;

const FRONT = '연구자';
const example = '그는 유명한 언어학 연구자이다.';
const hint = '연구 = research · 자 = person';
const pron = 'yeon-gu-ja';
const tags = ['TOPIK II', 'noun', 'people'];

const Spinner = ({ color = '#fff', size = 14 }) =>
  <span style={{ display: 'inline-block', width: size, height: size, borderRadius: 999, border: `2px solid ${color}`, borderTopColor: 'transparent', animation: 'memoxSpin 0.8s linear infinite', verticalAlign: 'middle' }} />;

const Skel = ({ w = '100%', h = 12, op = 0.5 }) =>
  <span style={{ display: 'block', width: w, height: h, borderRadius: 6, background: 'var(--memox-surface-container-high)', opacity: op, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />;

const Scrim = () =>
  <div style={{ position: 'absolute', inset: 0, background: 'rgba(25,28,30,0.45)', zIndex: 50, animation: 'memoxScrimIn 220ms ease' }} />;

const FieldHeader = ({ label, required, count, max, loading }) =>
  <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '0 4px 6px' }}>
    <div style={{ display: 'inline-flex', alignItems: 'baseline', gap: 5 }}>
      <span className="ov">{label}</span>
      {required && <span style={{ fontSize: 12, fontWeight: 700, color: 'var(--memox-primary)', letterSpacing: 0.3 }}>Required</span>}
    </div>
    {count != null && !loading && <span style={{ fontSize: 12, fontWeight: 600, letterSpacing: 0.2, color: 'var(--memox-on-surface-variant)', fontVariantNumeric: 'tabular-nums' }}>{count} / {max}</span>}
  </div>;

const OptionalField = ({ label, icon, value, trailing }) =>
  <div>
    <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '0 4px 6px' }}>
      <Ic name={icon} size={11} color="var(--memox-on-surface-variant)" />
      <span style={{ fontSize: 12, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase', color: 'var(--memox-on-surface-variant)' }}>{label}</span>
      <span style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', opacity: 0.55, fontWeight: 500 }}>· optional</span>
    </div>
    <div style={{ background: 'var(--memox-surface-container-lowest)', border: 'var(--memox-border-ghost)', borderRadius: 'var(--memox-radius-md)', padding: '10px 12px', minHeight: 40, fontSize: 14, color: 'var(--memox-on-surface)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8, lineHeight: 1.45 }}>
      <span style={{ flex: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{value}</span>
      {trailing}
    </div>
  </div>;

/* ════════════ SCREEN ════════════ */
function FlashcardEditScreen({ go, state = 'loaded' }) {
  const States = (window.MemoXStates && window.MemoXStates.FlashcardEdit) || {};
  const mod = States[state] || States.loaded;
  const f = (mod ? mod() : {}) || {};
  const { loading = false, loadError = false, validationErr = false, saving = false, saveFailed = false, delConfirm = false } = f;
  const valid = !loading && !loadError && !validationErr;
  const back = validationErr ? '' : 'Researcher / Nhà nghiên cứu';

  /* Load error replaces the entire body. */
  if (loadError) {
    return (
      <div className="app">
        <StatusBar />
        <div className="appbar" style={{ justifyContent: 'space-between' }}>
          <button className="icon-btn" onClick={() => go('cards')}>
            <Ic name="x" size={20} />
          </button>
          <div className="title" style={{ fontSize: 16, fontWeight: 700, flex: 1, textAlign: 'left', marginLeft: 4 }}>Edit flashcard</div>
        </div>
        <div className="scroll" style={{ padding: '24px 22px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div className="card" style={{ padding: '36px 22px', textAlign: 'center', width: '100%' }}>
            <div style={{ width: 52, height: 52, borderRadius: 14, background: 'color-mix(in srgb, var(--memox-danger) 10%, transparent)', color: 'var(--memox-error)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}>
              <Ic name="cloud-off" size={22} color="var(--memox-error)" />
            </div>
            <div style={{ fontSize: 16, fontWeight: 700, marginBottom: 6 }}>Couldn't load this card</div>
            <div style={{ fontSize: 14, color: 'var(--memox-on-surface-variant)', lineHeight: 1.55, marginBottom: 16 }}>
              Your data is safe on this device. Try again in a moment.
            </div>
            <div style={{ display: 'flex', gap: 8, justifyContent: 'center' }}>
              <button className="pill-btn outline" style={{ height: 'var(--memox-size-button)', padding: '0 18px', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Back to deck</button>
              <button className="pill-btn primary" style={{ height: 'var(--memox-size-button)', padding: '0 18px', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>
                <Ic name="refresh-cw" size={14} color="var(--memox-on-primary)" />
                Retry
              </button>
            </div>
          </div>
        </div>
      </div>);
  }

  return (
    <div className="app" style={{ position: 'relative' }}>
      <StatusBar />

      <div className="appbar" style={{ justifyContent: 'space-between' }}>
        <button className="icon-btn" onClick={() => go('cards')}>
          <Ic name="arrow-left" size={20} />
        </button>
        <div className="title" style={{ fontSize: 16, fontWeight: 700, flex: 1, textAlign: 'left', marginLeft: 4, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>Edit flashcard</div>
        <button className="pill-btn primary" disabled={!valid || saving} style={{ height: 32, padding: '0 14px', borderRadius: 9, fontSize: 12, gap: 6, opacity: !valid || saving ? 0.45 : 1, pointerEvents: !valid || saving ? 'none' : 'auto' }}>
          {saving ? <><Spinner size={11} /> Saving…</> : 'Save'}
        </button>
      </div>

      <Breadcrumb segments={[{ label: 'Library' }, { label: 'Korean' }, { label: 'TOPIK II — Vocab' }, { label: 'Edit' }]} />

      <div className="scroll">

        {/* Card history strip */}
        {!loading &&
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '8px 12px', background: 'var(--memox-surface-container-lowest)', border: 'var(--memox-border-ghost)', borderRadius: 'var(--memox-radius-md)', marginBottom: 14, fontSize: 12 }}>
            <Ic name="clock" size={12} color="var(--memox-on-surface-variant)" />
            <span style={{ flex: 1, color: 'var(--memox-on-surface-variant)' }}>
              Last edited <span style={{ color: 'var(--memox-on-surface)', fontWeight: 600 }}>3 days ago</span> ·
              <span style={{ fontVariantNumeric: 'tabular-nums' }}> 14 reviews · 78% recall</span>
            </span>
            <button style={{ background: 'transparent', border: 'none', padding: 0, color: 'var(--memox-primary)', fontSize: 12, fontWeight: 600, fontFamily: 'inherit', cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 3 }}>
              History
              <Ic name="chevron-right" size={11} color="var(--memox-primary)" />
            </button>
          </div>}

        {/* Deck destination */}
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 8, padding: '6px 12px 6px 8px', background: 'var(--memox-surface-container-lowest)', border: 'var(--memox-border-ghost)', borderRadius: 999, fontSize: 12, fontWeight: 600, marginBottom: 16 }}>
          <span style={{ width: 22, height: 22, borderRadius: 7, background: 'color-mix(in srgb, var(--memox-primary) 10%, transparent)', color: 'var(--memox-primary)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
            <Ic name="layers" size={13} color="var(--memox-primary)" />
          </span>
          <span>TOPIK II — Vocab</span>
          <Ic name="chevron-down" size={13} color="var(--memox-on-surface-variant)" />
        </div>

        <div className="ov" style={{ padding: '0 4px 10px', display: 'inline-flex', alignItems: 'center', gap: 6 }}>
          <span style={{ width: 6, height: 6, borderRadius: 999, background: 'var(--memox-primary)' }} />
          Required
        </div>

        {/* Front */}
        <FieldHeader label="Front · Korean" required count={loading ? null : FRONT.length} max={60} loading={loading} />
        <div className="card" style={{ padding: '14px 14px', minHeight: 66, display: 'flex', alignItems: 'center', position: 'relative', background: 'var(--memox-surface-container-lowest)', marginBottom: 14, paddingRight: 42 }}>
          {loading ? <Skel w={120} h={22} /> :
            <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: '-0.4px', lineHeight: 1.2 }}>{FRONT}</div>}
          {!loading &&
            <button className="icon-btn" style={{ position: 'absolute', top: '50%', transform: 'translateY(-50%)', right: 6, width: 30, height: 30 }} title="Record pronunciation">
              <Ic name="mic" size={15} color="var(--memox-on-surface-variant)" />
            </button>}
        </div>

        {/* Back */}
        <FieldHeader label="Back · Meaning" required count={loading ? null : back.length} max={240} loading={loading} />
        <div className="card" style={{ padding: '12px 14px', minHeight: 76, background: 'var(--memox-surface-container-lowest)', borderColor: validationErr ? 'var(--memox-error)' : undefined, borderWidth: validationErr ? 1 : undefined, borderStyle: validationErr ? 'solid' : undefined, display: 'flex', alignItems: loading || !back ? 'center' : 'flex-start', marginBottom: validationErr ? 8 : 14 }}>
          {loading ?
            <div style={{ width: '100%' }}>
              <Skel w="80%" h={13} />
              <div style={{ height: 6 }} />
              <Skel w="55%" h={13} op={0.35} />
            </div> :
            back ?
              <div style={{ fontSize: 16, fontWeight: 500, lineHeight: 1.45 }}>{back}</div> :
              <div style={{ fontSize: 14, color: 'var(--memox-on-surface-variant)', opacity: 0.65, lineHeight: 1.5 }}>
                English, Vietnamese, or both — comma-separated reads cleanest.
              </div>}
        </div>
        {validationErr &&
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '0 4px', color: 'var(--memox-error)', fontSize: 12, fontWeight: 600, marginBottom: 14 }}>
            <Ic name="alert-circle" size={12} color="var(--memox-error)" />
            <span>Add a meaning so this card can be answered.</span>
          </div>}

        {/* Optional details */}
        <div className="ov" style={{ padding: '2px 4px 10px' }}>Optional details</div>
        {loading ?
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 18 }}>
            {[0, 1, 2].map((i) =>
              <div key={i} style={{ background: 'var(--memox-surface-container-lowest)', border: 'var(--memox-border-ghost)', borderRadius: 'var(--memox-radius-md)', padding: '12px 14px' }}>
                <Skel w={90} h={9} op={0.4} />
                <div style={{ height: 8 }} />
                <Skel w={i === 1 ? '70%' : '60%'} h={12} />
              </div>
            )}
          </div> :
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 18 }}>
            <OptionalField icon="message-square" label="Example sentence" value={example} />
            <OptionalField icon="lightbulb" label="Hint" value={hint} />
            <OptionalField icon="volume-2" label="Pronunciation · romanization" value={pron} trailing={<button className="icon-btn" style={{ width: 26, height: 26 }}><Ic name="volume-2" size={13} color="var(--memox-on-surface-variant)" /></button>} />
          </div>}

        {/* Tags */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '0 4px 8px' }}>
          <Ic name="tag" size={11} color="var(--memox-on-surface-variant)" />
          <span style={{ fontSize: 12, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase', color: 'var(--memox-on-surface-variant)' }}>Tags</span>
          <span style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', opacity: 0.55, fontWeight: 500 }}>· optional</span>
        </div>
        {loading ?
          <div style={{ display: 'flex', gap: 6, marginBottom: 24 }}>
            <Skel w={70} h={26} />
            <Skel w={56} h={26} />
            <Skel w={64} h={26} />
          </div> :
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: 24 }}>
            {tags.map((t) =>
              <span key={t} style={{ height: 28, padding: '0 8px 0 12px', background: 'color-mix(in srgb, var(--memox-primary) 10%, transparent)', color: 'var(--memox-primary)', borderRadius: 999, fontSize: 12, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                {t}
                <Ic name="x" size={11} color="var(--memox-primary)" />
              </span>
            )}
            <button style={{ height: 28, padding: '0 12px', background: 'transparent', color: 'var(--memox-on-surface-variant)', border: '1px dashed var(--memox-outline-variant)', borderRadius: 999, fontSize: 12, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 4, fontFamily: 'inherit', cursor: 'pointer' }}>
              <Ic name="plus" size={12} color="var(--memox-on-surface-variant)" />
              Add tag
            </button>
          </div>}

        <div style={{ height: 1, background: 'var(--memox-outline-variant)', margin: '8px 6px 22px' }} />

        {/* Danger zone */}
        <div className="ov" style={{ padding: '0 4px 10px', display: 'inline-flex', alignItems: 'center', gap: 6, color: 'var(--memox-error)' }}>
          <Ic name="alert-triangle" size={11} color="var(--memox-error)" />
          <span>Danger zone</span>
        </div>
        <div className="card" style={{ padding: 14, marginBottom: 24, borderColor: 'color-mix(in srgb, var(--memox-danger) 20%, transparent)', background: 'color-mix(in srgb, var(--memox-danger) 3%, transparent)' }}>
          <div style={{ fontSize: 14, fontWeight: 600, marginBottom: 4 }}>Delete this flashcard</div>
          <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5, marginBottom: 12 }}>
            Removes the card and its review history from <strong style={{ color: 'var(--memox-on-surface)', fontWeight: 700 }}>TOPIK II — Vocab</strong>. Other cards in this deck stay.
          </div>
          <button disabled={loading} style={{ height: 'var(--memox-size-button)', padding: '0 16px', background: 'transparent', color: 'var(--memox-error)', border: '1px solid color-mix(in srgb, var(--memox-danger) 40%, transparent)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 7, fontFamily: 'inherit', cursor: 'pointer', opacity: loading ? 0.45 : 1 }}>
            <Ic name="trash-2" size={14} color="var(--memox-error)" />
            Delete flashcard
          </button>
        </div>
      </div>

      {/* Save bar */}
      <div style={{ padding: '10px 14px 16px', borderTop: 'var(--memox-border-ghost)', background: 'var(--memox-surface)', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {saveFailed &&
          <div style={{ padding: '10px 12px', background: 'color-mix(in srgb, var(--memox-danger) 8%, transparent)', border: '1px solid color-mix(in srgb, var(--memox-danger) 22%, transparent)', borderRadius: 'var(--memox-radius-md)', display: 'flex', gap: 8, alignItems: 'flex-start' }}>
            <Ic name="alert-circle" size={14} color="var(--memox-error)" />
            <div style={{ flex: 1, fontSize: 12, lineHeight: 1.45 }}>
              <strong style={{ fontWeight: 700 }}>Couldn't save changes.</strong>{' '}
              <span style={{ color: 'var(--memox-on-surface-variant)' }}>Nothing was lost. Tap Save to try again.</span>
            </div>
          </div>}
        <div style={{ display: 'flex', gap: 10 }}>
          <button className="pill-btn outline" style={{ height: 'var(--memox-size-button)', padding: '0 18px', borderRadius: 12, fontSize: 14, flexShrink: 0 }}>Cancel</button>
          <button className="pill-btn primary" disabled={!valid || saving} style={{ flex: 1, height: 'var(--memox-size-button)', borderRadius: 12, fontSize: 14, gap: 8, opacity: !valid || saving ? 0.45 : 1, pointerEvents: !valid || saving ? 'none' : 'auto' }}>
            {saving ? <><Spinner size={14} /> Saving changes…</> :
              saveFailed ? <><Ic name="refresh-cw" size={15} color="var(--memox-on-primary)" /> Retry save</> :
              <><Ic name="check" size={16} color="var(--memox-on-primary)" /> Save changes</>}
          </button>
        </div>
        <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', textAlign: 'center', opacity: 0.7 }}>
          {loading ? 'Loading card…' :
            validationErr ? 'Add the missing field to enable save.' :
            saving ? 'Saving to this device…' :
            'Changes save to this device only.'}
        </div>
      </div>

      {/* Delete confirm dialog */}
      {delConfirm &&
        <>
          <Scrim />
          <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px 18px', zIndex: 51, pointerEvents: 'none' }}>
            <div style={{ width: '100%', maxWidth: 340, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderRadius: 18, boxShadow: 'var(--memox-shadow-card)', pointerEvents: 'auto', overflow: 'hidden', animation: 'memoxDialogIn 200ms cubic-bezier(0.2,0,0,1)' }}>
              <div style={{ padding: '18px 18px 4px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
                  <div style={{ width: 34, height: 34, borderRadius: 'var(--memox-radius-md)', background: 'color-mix(in srgb, var(--memox-danger) 12%, transparent)', color: 'var(--memox-error)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                    <Ic name="trash-2" size={16} color="var(--memox-error)" />
                  </div>
                  <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px' }}>Delete this flashcard?</div>
                </div>
                <div style={{ padding: '12px 14px', background: 'var(--memox-surface-container-lowest)', borderRadius: 'var(--memox-radius-md)', border: 'var(--memox-border-ghost)', marginTop: 4 }}>
                  <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 3 }}>{FRONT}</div>
                  <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)' }}>Researcher / Nhà nghiên cứu</div>
                </div>
                <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5, marginTop: 12 }}>
                  Removes the card and its <strong style={{ color: 'var(--memox-on-surface)', fontWeight: 700 }}>14 reviews</strong> of history. Other cards in this deck are unaffected.
                </div>
              </div>
              <div style={{ padding: '14px 14px 14px', display: 'flex', gap: 8 }}>
                <button className="pill-btn outline" style={{ flex: 1, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>Cancel</button>
                <button className="pill-btn" style={{ flex: 1.2, height: 'var(--memox-size-button)', borderRadius: 'var(--memox-radius-md)', fontSize: 14, background: 'var(--memox-error-fill)', color: 'var(--memox-on-error-fill)', border: 'none', fontWeight: 600, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
                  <Ic name="trash-2" size={14} color="var(--memox-on-error-fill)" />
                  Delete card
                </button>
              </div>
            </div>
          </div>
        </>}

      <style>{`
        @keyframes memoxBlink     { 0%, 50% { opacity:1; } 50.01%, 100% { opacity:0; } }
        @keyframes memoxSpin      { to { transform: rotate(360deg); } }
        @keyframes memoxScrimIn   { from { opacity: 0; } to { opacity: 1; } }
        @keyframes memoxDialogIn  { from { transform: scale(0.94); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        @keyframes memoxSkelPulse { 0%, 100% { opacity:0.45; } 50% { opacity:0.75; } }
      `}</style>
    </div>);
}

Object.assign(window, { FlashcardEditScreen });
})();
