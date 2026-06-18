/* MemoX Mobile — TagManagementScreen · MAIN
   ────────────────────────────────────────────────────────────────────────
   Folder layout:
     TagManagementScreen/
       TagManagementScreen.jsx  ← shell + shared sheet/dialog/row widgets + dispatch
       states/                  ← one file per state in window.MemoXStates.TagManagement

   Many states are overlays (action sheet, rename/renameMerge dialogs, merge sheet,
   delete dialog) over the tag list; `busy` shows a spinner on one row; `opError`
   floats a toast. So a state module returns { body, overlay, toast } — overlay
   states reuse ctx.TagList() behind the scrim. Each overlay/dialog lives in its
   own file; the shared list, widgets and search/count chrome stay in MAIN.

   ctx: { go, state, Ic, Scrim, Sheet, Dialog, TagPill, TagRow, TagList,
          tags, selectedTag, totalTags } */
(function () {
const { StatusBar, masteryColor, Ic, Breadcrumb, BottomNav, OfflineBanner, StudyTopBar } = window;

const selectedTag = { name: 'people', count: 46 };
const totalTags = 14;
const baseTags = [
  { name: 'TOPIK II', count: 142, hot: true },
  { name: 'noun', count: 88 },
  { name: 'verb', count: 71 },
  { name: 'people', count: 46 },
  { name: 'food', count: 34 },
  { name: 'adjective', count: 28 },
  { name: 'business', count: 22 },
  { name: 'travel', count: 18 },
  { name: 'idioms', count: 11 },
  { name: 'numbers', count: 6 },
  { name: 'archive 2023', count: 3 }
];

const Scrim = () =>
  <div style={{ position: 'absolute', inset: 0, background: 'rgba(25,28,30,0.45)', zIndex: 50, animation: 'memoxScrimIn 220ms ease' }} />;

const Sheet = ({ children }) =>
  <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderTopLeftRadius: 20, borderTopRightRadius: 20, zIndex: 51, animation: 'memoxSheetIn 260ms cubic-bezier(0.2,0,0,1)', boxShadow: 'var(--memox-shadow-chrome)', maxHeight: '85%', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
    <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 4px' }}>
      <span style={{ width: 36, height: 4, borderRadius: 999, background: 'var(--memox-outline-variant)' }} />
    </div>
    {children}
  </div>;

const Dialog = ({ children }) =>
  <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px 18px', zIndex: 51, pointerEvents: 'none' }}>
    <div style={{ width: '100%', maxWidth: 340, background: 'var(--memox-surface)', borderRadius: 18, boxShadow: 'var(--memox-shadow-card)', animation: 'memoxDialogIn 200ms cubic-bezier(0.2,0,0,1)', pointerEvents: 'auto', overflow: 'hidden' }}>
      {children}
    </div>
  </div>;

const TagPill = ({ name, count, tone = 'indigo' }) => {
  const tones = {
    indigo: { bg: 'color-mix(in srgb, var(--memox-primary) 10%, transparent)', col: 'var(--memox-primary)' },
    neutral: { bg: 'var(--memox-surface-container)', col: 'var(--memox-on-surface)' },
    red: { bg: 'color-mix(in srgb, var(--memox-danger) 10%, transparent)', col: 'var(--memox-error)' }
  }[tone];
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, height: 26, padding: '0 10px', background: tones.bg, color: tones.col, borderRadius: 999, fontSize: 12, fontWeight: 600 }}>
      <Ic name="tag" size={11} color={tones.col} />
      {name}
      {count != null && <span style={{ fontSize: 12, fontWeight: 700, opacity: 0.7, fontVariantNumeric: 'tabular-nums' }}>· {count}</span>}
    </span>);
};

const TagRow = ({ tag, last }) =>
  <div role="button" tabIndex={0} style={{ display: 'grid', gridTemplateColumns: '32px 1fr auto auto', gap: 12, alignItems: 'center', padding: '12px 14px', borderBottom: last ? 'none' : 'var(--memox-border-ghost)' }}>
    <div style={{ width: 28, height: 28, borderRadius: 8, background: 'color-mix(in srgb, var(--memox-primary) 8%, transparent)', color: 'var(--memox-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <Ic name="tag" size={13} color="var(--memox-primary)" />
    </div>
    <div style={{ minWidth: 0 }}>
      <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: '-0.1px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{tag.name}</div>
      <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', marginTop: 1, fontVariantNumeric: 'tabular-nums' }}>{tag.count} card{tag.count === 1 ? '' : 's'}</div>
    </div>
    {tag.hot ?
      <span style={{ height: 20, padding: '0 7px', borderRadius: 999, background: 'color-mix(in srgb, var(--memox-streak) 12%, transparent)', color: 'var(--memox-streak)', fontSize: 12, fontWeight: 700, display: 'inline-flex', alignItems: 'center', gap: 4 }}>
        <Ic name="flame" size={10} color="var(--memox-streak)" />
        Most used
      </span> : <span />}
    {tag.busy ?
      <span style={{ width: 14, height: 14, borderRadius: 999, border: '2px solid var(--memox-primary)', borderTopColor: 'transparent', animation: 'memoxSpin 0.8s linear infinite' }} /> :
      <button className="icon-btn" style={{ width: 30, height: 30 }} title="More">
        <Ic name="more-vertical" size={16} color="var(--memox-on-surface-variant)" />
      </button>}
  </div>;

/* Tag list card. busy=true marks the "business" row with a spinner. */
const TagList = (busy) => {
  const tags = baseTags.map((t) => t.name === 'business' ? { ...t, busy } : t);
  return (
    <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
      {tags.map((t, i, a) => <TagRow key={t.name} tag={t} last={i === a.length - 1} />)}
    </div>);
};

/* ════════════ SCREEN ════════════ */
function TagManagementScreen({ go, state = 'loaded' }) {
  const searchActive = state === 'searchEmpty';

  const States = (window.MemoXStates && window.MemoXStates.TagManagement) || {};
  const ctx = { go, state, Ic, Scrim, Sheet, Dialog, TagPill, TagRow, TagList, tags: baseTags, selectedTag, totalTags };
  const mod = States[state] || States.loaded;
  const out = mod ? mod(ctx) : null;
  const body = out && out.body !== undefined ? out.body : out;
  const overlayNode = out && out.overlay !== undefined ? out.overlay : null;
  const toastNode = out && out.toast !== undefined ? out.toast : null;

  return (
    <div className="app" style={{ position: 'relative' }}>
      <StatusBar />
      <div className="appbar">
        <button className="icon-btn" onClick={() => go('settings')}>
          <Ic name="arrow-left" size={20} />
        </button>
        <div className="title" style={{ fontSize: 16, fontWeight: 700 }}>Manage tags</div>
      </div>

      <div className="scroll">

        {/* Search input */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, height: 44, padding: '0 14px', background: 'var(--memox-surface-container-lowest)', border: 'var(--memox-border-ghost)', borderRadius: 12, marginBottom: 14 }}>
          <Ic name="search" size={16} color="var(--memox-on-surface-variant)" />
          <span style={{ flex: 1, fontSize: 14, color: searchActive ? 'var(--memox-on-surface)' : 'var(--memox-on-surface-variant)', opacity: searchActive ? 1 : 0.7, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {searchActive ? 'phras' : 'Search tags'}
          </span>
          {searchActive &&
            <button className="icon-btn" style={{ width: 26, height: 26 }} title="Clear">
              <Ic name="x" size={14} color="var(--memox-on-surface-variant)" />
            </button>}
        </div>

        {/* Count + sort row */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '0 4px 10px' }}>
          <span className="ov">{state === 'empty' ? 'No tags' : searchActive ? 'No matches' : `${totalTags} tags`}</span>
          <button className="pill-btn" style={{ height: 30, padding: '0 12px', borderRadius: 999, fontSize: 12, gap: 6, background: 'var(--memox-surface-container-lowest)', border: 'var(--memox-border-ghost)', color: 'var(--memox-on-surface)' }}>
            <Ic name="arrow-down-up" size={12} color="var(--memox-on-surface-variant)" />
            Most used
            <Ic name="chevron-down" size={12} color="var(--memox-on-surface-variant)" />
          </button>
        </div>

        {body}

        <div style={{ height: 20 }} />
      </div>

      {toastNode}
      {overlayNode}

      <style>{`
        @keyframes memoxScrimIn  { from { opacity: 0; } to { opacity: 1; } }
        @keyframes memoxSheetIn  { from { transform: translateY(20%); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        @keyframes memoxDialogIn { from { transform: scale(0.94); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        @keyframes memoxBlink    { 0%,50% { opacity: 1; } 50.01%,100% { opacity: 0; } }
        @keyframes memoxSpin     { to { transform: rotate(360deg); } }
        @keyframes memoxSkelPulse { 0%, 100% { opacity:0.45; } 50% { opacity:0.75; } }
      `}</style>
    </div>);
}

Object.assign(window, { TagManagementScreen });
})();
