/* MemoX Mobile — LibraryOverviewScreen · MAIN
   ────────────────────────────────────────────────────────────────────────
   Folder layout:
     LibraryOverviewScreen/
       LibraryOverviewScreen.jsx  ← shell + shared fragments + dispatch
       states/                    ← one file per state in window.MemoXStates.LibraryOverview

   Several states are OVERLAYS (action sheet, create/rename/move/archive/delete
   dialogs) drawn over the populated folder list. So a state module here returns
     { body, overlay }
   — `body` fills the .scroll area, `overlay` is rendered as an absolute sibling
   over the chrome. Overlay states reuse ctx.FoldersList() as their body, so the
   background list is defined once and each overlay is isolated in its own file.

   ctx: { go, state, Ic, masteryColor, Scrim, FolderCard, FoldersList,
          LoadingList, EmptyCard, ErrorCard, OverflowSheet, Dialog,
          folders, seedSwatches, iconChoices, target } */
(function () {
const { StatusBar, masteryColor, Ic, Breadcrumb, BottomNav, OfflineBanner, StudyTopBar, Fab, SearchField, Badge } = window;

/* The folder these follow-up actions operate on (matches the overflow sheet). */
const target = { name: 'Korean', decks: 8, cards: 412, due: 23, seed: '#5265F5', ic: 'flag' };
const seedSwatches = ['#5265F5', '#A78BFA', '#4DB6AC', '#E57373', '#FFB74D', '#81C784'];
const iconChoices = ['flag', 'book-open', 'sparkles', 'layers', 'copy'];

/* Root folders — each has its own seed color so the eye can find them. */
const folders = [
  { name: 'Korean', decks: 8, cards: 412, due: 23, fresh: 6, mastery: 0.62, lastStudied: '2h ago', ic: 'flag', seed: '#5265F5', sub: 'TOPIK · Hangul · grammar' },
  { name: 'Japanese', decks: 5, cards: 248, due: 0, fresh: 0, mastery: 0.41, lastStudied: 'yesterday', ic: 'flag', seed: '#2BA88B', sub: 'Genki · kana · kanji' },
  { name: 'Mandarin', decks: 3, cards: 180, due: 48, fresh: 12, mastery: 0.18, lastStudied: '4 days ago', ic: 'flag', seed: '#F59E0B', sub: 'HSK 1–3' },
  { name: 'Hanja & roots', decks: 2, cards: 64, due: 6, fresh: 0, mastery: 0.88, lastStudied: 'just now', ic: 'book-open', seed: '#8B6FF5', sub: 'Sino-Korean character roots' }
];

/* ── shared inline widgets ── */
const Scrim = () =>
  <div style={{ position: 'absolute', inset: 0, background: 'rgba(25,28,30,0.45)', zIndex: 50, animation: 'memoxScrimIn 220ms ease' }} />;

/* Centered modal-dialog shell used by create/rename/archive/delete states. */
const Dialog = ({ children }) =>
  <>
    <Scrim />
    <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px 18px', zIndex: 51, pointerEvents: 'none' }}>
      <div style={{ width: '100%', maxWidth: 340, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderRadius: 18, boxShadow: 'var(--memox-shadow-card)', pointerEvents: 'auto', overflow: 'hidden', animation: 'memoxDialogIn 200ms cubic-bezier(0.2,0,0,1)' }}>
        {children}
      </div>
    </div>
  </>;

const FolderCard = ({ f }) =>
  <div className="card" style={{ marginBottom: 10, display: 'grid', gridTemplateColumns: '48px 1fr 24px', gap: 14, alignItems: 'center', padding: '14px 14px', cursor: 'pointer' }}>
    <div style={{ width: 44, height: 44, borderRadius: 12, background: `color-mix(in srgb, ${f.seed} 12%, transparent)`, color: f.seed, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <Ic name={f.ic} size={20} color={f.seed} />
    </div>
    <div style={{ minWidth: 0 }}>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 8 }}>
        <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{f.name}</div>
        {f.due > 0 &&
          <Badge tone="primary">{`${f.due} due`}</Badge>}
      </div>
      <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', marginTop: 2, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{f.sub}</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 8, fontSize: 12, color: 'var(--memox-on-surface-variant)', fontVariantNumeric: 'tabular-nums' }}>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <Ic name="layers" size={11} color="var(--memox-on-surface-variant)" />
          {f.decks} {f.decks === 1 ? 'deck' : 'decks'}
        </span>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
          <Ic name="copy" size={11} color="var(--memox-on-surface-variant)" />
          {f.cards} cards
        </span>
        {f.fresh > 0 &&
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, color: 'var(--memox-mastery)' }}>
            <span className="status-dot" style={{ background: 'var(--memox-mastery)', width: 6, height: 6 }} />
            {f.fresh} new
          </span>}
      </div>
      <div style={{ marginTop: 8, height: 5, background: 'var(--memox-surface-container)', borderRadius: 999, overflow: 'hidden' }}>
        <div style={{ height: '100%', width: `${f.mastery * 100}%`, background: masteryColor(f.mastery), borderRadius: 999 }} />
      </div>
    </div>
    <button className="icon-btn" style={{ width: 28, height: 28 }} title="More" onClick={(e) => e.stopPropagation()}>
      <Ic name="more-vertical" size={16} color="var(--memox-on-surface-variant)" />
    </button>
  </div>;

const FoldersList = () => <>{folders.map((f) => <FolderCard key={f.name} f={f} />)}</>;

const LoadingList = () =>
  <>{[0, 1, 2, 3].map((i) =>
    <div key={i} className="card" style={{ marginBottom: 10, display: 'grid', gridTemplateColumns: '48px 1fr 24px', gap: 14, alignItems: 'center', padding: '14px' }}>
      <span style={{ width: 44, height: 44, borderRadius: 12, background: 'var(--memox-surface-container-high)', opacity: 0.55, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
      <div>
        <span style={{ display: 'inline-block', height: 12, width: 100 + i * 30, borderRadius: 6, background: 'var(--memox-surface-container-high)', opacity: 0.55, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
        <span style={{ display: 'block', height: 10, width: 140, borderRadius: 6, background: 'var(--memox-surface-container-high)', opacity: 0.4, marginTop: 6, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
        <span style={{ display: 'block', height: 5, width: '100%', borderRadius: 999, background: 'var(--memox-surface-container-high)', opacity: 0.35, marginTop: 10, animation: 'memoxSkelPulse 1.4s ease-in-out infinite' }} />
      </div>
      <span />
    </div>
  )}</>;

const EmptyCard = () =>
  <div className="card" style={{ padding: '44px 22px 32px', textAlign: 'center', marginTop: 8 }}>
    <div style={{ width: 64, height: 64, borderRadius: 18, background: 'color-mix(in srgb, var(--memox-primary) 10%, transparent)', color: 'var(--memox-primary)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 16 }}>
      <Ic name="folder-plus" size={28} color="var(--memox-primary)" />
    </div>
    <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: '-0.3px', marginBottom: 8 }}>Start your library</div>
    <div style={{ fontSize: 14, color: 'var(--memox-on-surface-variant)', lineHeight: 1.55, marginBottom: 18, padding: '0 4px' }}>
      Folders keep related decks together — by language, course, or topic. Create your first folder to begin.
    </div>
    <button className="pill-btn primary" style={{ height: 'var(--memox-size-button)', padding: '0 18px', borderRadius: 12, fontSize: 14 }}>
      <Ic name="folder-plus" size={15} color="var(--memox-on-primary)" />
      Create folder
    </button>
    <div style={{ marginTop: 18, padding: '10px 12px', background: 'var(--memox-surface-container-lowest)', borderRadius: 'var(--memox-radius-md)', fontSize: 12, color: 'var(--memox-on-surface-variant)', lineHeight: 1.5, textAlign: 'left', display: 'flex', gap: 8, alignItems: 'flex-start' }}>
      <Ic name="info" size={13} color="var(--memox-on-surface-variant)" />
      <span>You can also import a deck and MemoX will wrap it in a folder for you.</span>
    </div>
  </div>;

const ErrorCard = () =>
  <div className="card" style={{ padding: '40px 22px', textAlign: 'center', marginTop: 8 }}>
    <div style={{ width: 52, height: 52, borderRadius: 14, background: 'color-mix(in srgb, var(--memox-danger) 10%, transparent)', color: 'var(--memox-error)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}>
      <Ic name="cloud-off" size={22} color="var(--memox-error)" />
    </div>
    <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.2px', marginBottom: 6 }}>Couldn't load your library</div>
    <div style={{ fontSize: 14, color: 'var(--memox-on-surface-variant)', lineHeight: 1.55, marginBottom: 16 }}>
      Your data is safe on this device. Try again in a moment.
    </div>
    <button className="pill-btn primary" style={{ height: 'var(--memox-size-button)', padding: '0 18px', borderRadius: 'var(--memox-radius-md)', fontSize: 14 }}>
      <Ic name="refresh-cw" size={14} color="var(--memox-on-primary)" />
      Retry
    </button>
  </div>;

/* Folder overflow action sheet (the 'overflow' state). */
const OverflowSheet = () =>
  <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, background: 'var(--memox-surface-container-high)', color: 'var(--memox-on-surface)', borderTopLeftRadius: 20, borderTopRightRadius: 20, zIndex: 51, animation: 'memoxSheetIn 260ms cubic-bezier(0.2,0,0,1)', boxShadow: 'var(--memox-shadow-chrome)', overflow: 'hidden' }}>
    <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 4px' }}>
      <span style={{ width: 36, height: 4, borderRadius: 999, background: 'var(--memox-outline-variant)' }} />
    </div>
    <div style={{ padding: '6px 16px 4px', display: 'flex', alignItems: 'center', gap: 12 }}>
      <div style={{ width: 36, height: 36, borderRadius: 'var(--memox-radius-md)', background: 'color-mix(in srgb, var(--memox-primary) 12%, transparent)', color: 'var(--memox-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Ic name="flag" size={16} color="var(--memox-primary)" />
      </div>
      <div>
        <div style={{ fontSize: 14, fontWeight: 700 }}>Korean</div>
        <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', marginTop: 1 }}>8 decks · 412 cards</div>
      </div>
    </div>
    <div style={{ padding: '6px 8px 8px' }}>
      {[
        { ic: 'folder-open', label: 'Open folder', sub: null },
        { ic: 'play', label: 'Study due cards', sub: '23 cards waiting' },
        { ic: 'pencil', label: 'Rename folder', sub: null },
        { ic: 'folder-tree', label: 'Move folder', sub: null },
        { ic: 'archive', label: 'Archive folder', sub: 'Hides from Library, keeps cards' }
      ].map((a) =>
        <button key={a.label} style={{ width: '100%', display: 'grid', gridTemplateColumns: '32px 1fr auto', gap: 12, alignItems: 'center', padding: '12px 10px', background: 'transparent', border: 'none', color: 'var(--memox-on-surface)', borderRadius: 'var(--memox-radius-md)', fontFamily: 'inherit', cursor: 'pointer', textAlign: 'left' }}>
          <div style={{ width: 30, height: 30, borderRadius: 9, background: 'color-mix(in srgb, var(--memox-primary) 8%, transparent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Ic name={a.ic} size={14} color="var(--memox-primary)" />
          </div>
          <div>
            <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: '-0.1px' }}>{a.label}</div>
            {a.sub && <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', marginTop: 2 }}>{a.sub}</div>}
          </div>
          <Ic name="chevron-right" size={16} color="var(--memox-on-surface-variant)" />
        </button>
      )}
      <div style={{ height: 1, background: 'var(--memox-outline-variant)', margin: '8px 10px' }} />
      <button style={{ width: '100%', display: 'grid', gridTemplateColumns: '32px 1fr', gap: 12, alignItems: 'center', padding: '12px 10px', background: 'transparent', border: 'none', color: 'var(--memox-on-surface)', borderRadius: 'var(--memox-radius-md)', fontFamily: 'inherit', cursor: 'pointer', textAlign: 'left' }}>
        <div style={{ width: 30, height: 30, borderRadius: 9, background: 'color-mix(in srgb, var(--memox-danger) 10%, transparent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Ic name="trash-2" size={14} color="var(--memox-error)" />
        </div>
        <div>
          <div style={{ fontSize: 14, fontWeight: 600, color: 'var(--memox-error)', letterSpacing: '-0.1px' }}>Delete folder</div>
          <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', marginTop: 2 }}>Keeps all 412 cards</div>
        </div>
      </button>
    </div>
    <div style={{ height: 'env(safe-area-inset-bottom, 12px)' }} />
  </div>;

/* ════════════ SCREEN ════════════ */
function LibraryOverviewScreen({ go, state = 'loaded' }) {
  const searchActive = state === 'search';
  const showSheet = state === 'overflow';
  const overlay = ['createFolder', 'renameFolder', 'moveFolder', 'archiveFolder', 'deleteFolder'].includes(state);
  const bgLoaded = state === 'loaded' || overlay;
  const showFAB = state !== 'empty' && state !== 'error' && !showSheet && !overlay;

  const States = (window.MemoXStates && window.MemoXStates.LibraryOverview) || {};
  const ctx = {
    go, state, Ic, masteryColor, Scrim, Dialog, FolderCard, FoldersList,
    LoadingList, EmptyCard, ErrorCard, OverflowSheet, folders, seedSwatches, iconChoices, target
  };
  const mod = States[state] || States.loaded;
  const out = mod ? mod(ctx) : null;
  const body = out && out.body !== undefined ? out.body : out;
  const overlayNode = out && out.overlay !== undefined ? out.overlay : null;

  return (
    <div className="app" style={{ position: 'relative' }}>
      <StatusBar />

      {/* Large title app bar */}
      <div className="appbar appbar-lg" style={{ justifyContent: 'space-between' }}>
        <div style={{ fontSize: 24, fontWeight: 700, letterSpacing: '-0.5px' }}>Library</div>
        <button className="icon-btn">
          <Ic name="sliders-horizontal" size={18} color="var(--memox-on-surface-variant)" />
        </button>
      </div>

      {/* Search */}
      <div style={{ padding: '0 14px 10px' }}>
        <SearchField placeholder="Search decks, cards, tags" active={searchActive} />
      </div>

      {/* Today summary strip */}
      {bgLoaded &&
        <div style={{ padding: '0 14px 12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', background: 'color-mix(in srgb, var(--memox-primary) 6%, var(--memox-surface-bright))', border: 'none', borderRadius: 'var(--memox-radius-lg)', cursor: 'pointer' }}>
            <div style={{ width: 36, height: 36, borderRadius: 'var(--memox-radius-md)', background: 'var(--memox-primary)', color: 'var(--memox-on-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <Ic name="zap" size={18} color="var(--memox-on-primary)" />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: 700, letterSpacing: '-0.1px' }}>77 cards due today</div>
              <div style={{ fontSize: 12, color: 'var(--memox-on-surface-variant)', marginTop: 1 }}>Across 3 folders · ~14 min</div>
            </div>
            <Ic name="chevron-right" size={18} color="var(--memox-primary)" />
          </div>
        </div>}

      {/* Folders header */}
      {(bgLoaded || state === 'loading' || state === 'overflow') &&
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 18px 8px' }}>
          <span className="ov">{state === 'loading' ? 'Loading folders' : `${folders.length} folders`}</span>
          <button className="pill-btn" style={{ height: 28, padding: '0 10px', borderRadius: 999, fontSize: 12, gap: 5, background: 'transparent', border: 'none', color: 'var(--memox-on-surface-variant)' }}>
            <Ic name="arrow-down-up" size={11} color="var(--memox-on-surface-variant)" />
            Recent
            <Ic name="chevron-down" size={11} color="var(--memox-on-surface-variant)" />
          </button>
        </div>}

      {/* ScreenScroll — FAB floats above the bottom nav, so clear with .scroll-fab-nav */}
      <div className="scroll scroll-fab-nav">
        {body}
      </div>

      {/* FAB — shared pinned chrome, lifted above the bottom nav */}
      {showFAB && <Fab icon="folder-plus" label="New folder" aboveNav />}

      {overlayNode}

      <BottomNav active="library" onChange={go} />

      <style>{`
        @keyframes memoxScrimIn  { from { opacity: 0; } to { opacity: 1; } }
        @keyframes memoxSheetIn  { from { transform: translateY(20%); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        @keyframes memoxDialogIn { from { transform: scale(0.94); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        @keyframes memoxBlink    { 0%, 50% { opacity: 1; } 50.01%, 100% { opacity: 0; } }
      `}</style>
    </div>);
}

Object.assign(window, { LibraryOverviewScreen });
})();
