/* MemoX Mobile — StudyScreen
   Split from index.html for isolated review/editing. Wrapped in an IIFE so its
   top-level bindings stay local (every screen file shares one global scope when
   loaded as separate <script> tags). Shared chrome (StatusBar, Ic, BottomNav,
   Breadcrumb, OfflineBanner, StudyTopBar, masteryColor) comes from
   screens/_shared.jsx via window; this file publishes StudyScreen back to window. */
(function () {
const { useState, useEffect } = React;
const { StatusBar, masteryColor, Ic, Breadcrumb, BottomNav, OfflineBanner, StudyTopBar } = window;

/* ─────── Screen: Study (term + meaning visible together, swipe to next) ─────── */
function StudyScreen({ go }) {
  const cards = [
  { front: '공부하다', back: 'to study', example: '저는 매일 한국어를 공부해요.', lang: 'Korean' },
  { front: '먹다', back: 'to eat', example: '아침을 먹었어요.', lang: 'Korean' },
  { front: '도서관', back: 'library', example: '저는 도서관에서 책을 읽어요.', lang: 'Korean' }];

  const total = 23;
  const [idx, setIdx] = useState(7);
  const card = cards[idx % cards.length];
  const cardRef = React.useRef(null);
  const [dragX, setDragX] = useState(0);
  const dragRef = React.useRef({ startX: null, captured: false });

  const advance = (dir = 1) => {
    setIdx((prev) => Math.max(0, Math.min(prev + dir, total - 1)));
  };

  React.useEffect(() => {
    const el = cardRef.current;
    if (!el) return;
    const onDown = (e) => {
      dragRef.current.startX = e.touches ? e.touches[0].clientX : e.clientX;
      dragRef.current.captured = true;
    };
    const onMove = (e) => {
      if (!dragRef.current.captured) return;
      const x = e.touches ? e.touches[0].clientX : e.clientX;
      setDragX(x - dragRef.current.startX);
    };
    const onUp = () => {
      if (!dragRef.current.captured) return;
      const dx = dragX;
      dragRef.current.captured = false;
      dragRef.current.startX = null;
      if (Math.abs(dx) > 70) {
        // V1 simplification: Review is a single linear pass, so BOTH swipe
        // directions advance to the next card (no distinct left/right semantics).
        // The card is thrown whichever way it was dragged, but advance(1) is
        // intentional for either direction. Distinct again/good semantics live in
        // the Recall/Guess modes, not here. The visible Next/Previous buttons and
        // the reworded hint below reflect this direction-agnostic behavior.
        setDragX(dx > 0 ? 500 : -500);
        setTimeout(() => {advance(1);setDragX(0);}, 180);
      } else {
        setDragX(0);
      }
    };
    el.addEventListener('mousedown', onDown);
    el.addEventListener('touchstart', onDown, { passive: true });
    window.addEventListener('mousemove', onMove);
    window.addEventListener('touchmove', onMove, { passive: true });
    window.addEventListener('mouseup', onUp);
    window.addEventListener('touchend', onUp);
    return () => {
      el.removeEventListener('mousedown', onDown);
      el.removeEventListener('touchstart', onDown);
      window.removeEventListener('mousemove', onMove);
      window.removeEventListener('touchmove', onMove);
      window.removeEventListener('mouseup', onUp);
      window.removeEventListener('touchend', onUp);
    };
  }, [dragX]);

  const isSwiping = Math.abs(dragX) > 4;
  const transform = `translateX(${dragX}px) rotate(${dragX * 0.025}deg)`;
  const opacity = 1 - Math.min(Math.abs(dragX) / 400, 0.5);

  return (
    <div className="app">
      <StatusBar />
      <div className="appbar" style={{ justifyContent: 'space-between' }}>
        <button className="icon-btn" onClick={() => go('deck')}><Ic name="x" size={22} /></button>
        <div style={{ flex: 1, margin: '0 16px', height: 4, background: 'var(--memox-surface-container)', borderRadius: 999, overflow: 'hidden' }}>
          <div style={{ height: '100%', width: `${(idx + 1) / total * 100}%`, background: 'var(--memox-primary)', transition: 'width 200ms cubic-bezier(0.2,0,0,1)' }} />
        </div>
        <div style={{ fontSize: 14, fontWeight: 600, fontVariantNumeric: 'tabular-nums', color: 'var(--memox-on-surface-variant)' }}>{idx + 1} / {total}</div>
      </div>

      <div style={{ flex: 1, padding: '6px 14px 12px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div
          ref={cardRef}
          className="card"
          style={{
            flex: 1,
            padding: 0,
            display: 'flex', flexDirection: 'column',
            cursor: 'grab',
            userSelect: 'none',
            transform,
            opacity,
            transition: isSwiping ? 'none' : 'transform 220ms cubic-bezier(0.05,0.7,0.1,1), opacity 220ms cubic-bezier(0.2,0,0,1)',
            touchAction: 'pan-y'
          }}>

          {/* Top half — term */}
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '20px 16px 8px', position: 'relative' }}>
            <div className="ov" style={{ position: 'absolute', top: 16, left: 20 }}>{card.lang}</div>
            <div style={{ fontSize: 32, fontWeight: 700, letterSpacing: '-0.5px', textAlign: 'center', lineHeight: 1.15 }}>{card.front}</div>
          </div>

          {/* Divider */}
          <div style={{ height: 1, background: 'var(--memox-outline-variant)', opacity: 0.5, margin: '0 20px' }} />

          {/* Bottom half — meaning + example */}
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '8px 16px 20px', position: 'relative', gap: 14 }}>
            <div className="ov" style={{ position: 'absolute', top: 16, left: 20 }}>Meaning</div>
            <div style={{ fontSize: 24, fontWeight: 600, letterSpacing: '-0.3px', textAlign: 'center' }}>{card.back}</div>
            <div style={{
              padding: '10px 14px',
              background: 'var(--memox-surface-container-low)',
              borderRadius: 'var(--memox-radius-md)',
              fontSize: 14,
              lineHeight: 1.5,
              color: 'var(--memox-on-surface-variant)',
              textAlign: 'center',
              maxWidth: 280
            }}>
              {card.example}
            </div>
          </div>
        </div>

        {/* Bottom controls — keyboard-focusable Previous / Next.
            The swipe gesture above still works; these are an accessible, visible
            alternative built from the brand pill-btn primitive + tokens (C1). */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <button
            className="pill-btn secondary"
            onClick={() => advance(-1)}
            disabled={idx === 0}
            aria-label="Previous card"
            style={{ flex: 1, gap: 6, opacity: idx === 0 ? 'var(--memox-op-disabled)' : 1 }}>
            <Ic name="arrow-left" size={18} />
            Previous
          </button>
          <button
            className="pill-btn primary"
            onClick={() => advance(1)}
            disabled={idx >= total - 1}
            aria-label="Next card"
            style={{ flex: 1, gap: 6, opacity: idx >= total - 1 ? 'var(--memox-op-disabled)' : 1 }}>
            Next
            <Ic name="arrow-right" size={18} />
          </button>
        </div>
        {/* Gesture hint kept, reworded to be direction-agnostic (see C2) */}
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          fontSize: 12, color: 'var(--memox-on-surface-variant)',
          letterSpacing: 0.3
        }}>
          <Ic name="chevrons-right" size={16} color="var(--memox-on-surface-variant)" />
          <span>or swipe the card to continue</span>
        </div>
      </div>
    </div>);

}

Object.assign(window, { StudyScreen });
})();
