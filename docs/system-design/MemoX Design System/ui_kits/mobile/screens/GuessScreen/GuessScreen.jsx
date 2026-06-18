/* MemoX Mobile — GuessScreen
   Split from index.html for isolated review/editing. Wrapped in an IIFE so its
   top-level bindings stay local (every screen file shares one global scope when
   loaded as separate <script> tags). Shared chrome (StatusBar, Ic, BottomNav,
   Breadcrumb, OfflineBanner, StudyTopBar, masteryColor) comes from
   screens/_shared.jsx via window; this file publishes GuessScreen back to window. */
(function () {
const { useState, useEffect } = React;
const { StatusBar, masteryColor, Ic, Breadcrumb, BottomNav, OfflineBanner, StudyTopBar } = window;

/* ─────── Screen: Guess (multiple choice A/B/C/D/E, auto-advance) ─────── */
function GuessScreen({ go }) {
  const prompt = '도서관';
  const options = [
  { l: 'A', text: 'kitchen', state: 'fade' },
  { l: 'B', text: 'library — public building or room with a collection of books for reading or borrowing', state: 'correct' },
  { l: 'C', text: 'school — institution for educating children', state: 'wrong' },
  { l: 'D', text: 'office', state: 'fade' },
  { l: 'E', text: 'classroom', state: 'fade' }];

  return (
    <div className="app">
      <StatusBar />
      <StudyTopBar mode="Guess" current={5} total={20} onClose={() => go('deck')} />

      {/* Outer scroller — content centers when it fits, scrolls when long answers push past. */}
      <div className="hide-scroll" style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', display: 'flex', flexDirection: 'column', minHeight: 0 }}>
        <div style={{ margin: 'auto 0', padding: '8px 14px 0', display: 'flex', flexDirection: 'column', gap: 14 }}>
          {/* Prompt */}
          <div className="card" style={{ padding: '34px 14px 32px', textAlign: 'center', flexShrink: 0, minHeight: 180, display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 10 }}>
            <div className="ov">What is this?</div>
            <div style={{ fontSize: 32, fontWeight: 700, letterSpacing: '-0.5px', lineHeight: 1.15 }}>{prompt}</div>
          </div>

          {/* Options — split term + explanation, vertical-centered prefix */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8, flexShrink: 0 }}>
            {options.map((o, i) => {
              const styles = {
                idle: {
                  bg: 'var(--memox-surface-container-lowest)',
                  fg: 'var(--memox-on-surface)',
                  border: 'var(--memox-border-ghost)'
                },
                correct: {
                  bg: 'color-mix(in srgb, var(--memox-mastery) 14%, transparent)',
                  fg: 'var(--memox-mastery)',
                  border: '1px solid color-mix(in srgb, var(--memox-mastery) 40%, transparent)'
                },
                wrong: {
                  bg: 'color-mix(in srgb, var(--memox-danger) 10%, transparent)',
                  fg: 'var(--memox-error)',
                  border: '1px solid color-mix(in srgb, var(--memox-danger) 35%, transparent)'
                },
                fade: {
                  bg: 'var(--memox-surface-container-lowest)',
                  fg: 'var(--memox-on-surface-variant)',
                  border: 'var(--memox-border-ghost)',
                  opacity: 0.36
                }
              }[o.state];
              // Split "term — explanation" into separate parts
              const split = o.text.split(' — ');
              const term = split[0];
              const def = split.length > 1 ? split.slice(1).join(' — ') : null;
              return (
                <div key={i} style={{
                  minHeight: 60,
                  background: styles.bg,
                  color: styles.fg,
                  border: styles.border,
                  borderRadius: 12,
                  padding: '12px 14px',
                  display: 'flex', alignItems: 'center', gap: 12,
                  opacity: styles.opacity ?? 1,
                  transition: 'all 200ms cubic-bezier(0.2,0,0,1)'
                }}>
                  <span style={{
                    width: 28, height: 28, borderRadius: 999,
                    border: '1.5px solid currentColor',
                    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                    fontSize: 12, fontWeight: 700,
                    opacity: 0.85, flexShrink: 0
                  }}>{o.l}</span>
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2, minWidth: 0 }}>
                    <div style={{ fontSize: 16, fontWeight: 700, letterSpacing: '-0.1px', lineHeight: 1.25 }}>{term}</div>
                    {def &&
                    <div style={{
                      fontSize: 12, fontWeight: 400, lineHeight: 1.4,
                      opacity: 0.72,
                      textWrap: 'pretty'
                    }}>{def}</div>
                    }
                  </div>
                  {o.state === 'correct' && <Ic name="check" size={18} color="var(--memox-mastery)" />}
                  {o.state === 'wrong' && <Ic name="x" size={18} color="var(--memox-error)" />}
                </div>);

            })}
          </div>
        </div>
      </div>

      {/* Auto-advance footer — static snapshot of the countdown (not looping) */}
      <div style={{ padding: '10px 14px 14px', display: 'flex', flexDirection: 'column', gap: 6, flexShrink: 0 }}>
        <div style={{
          fontSize: 12, fontWeight: 600, letterSpacing: 1.2, textTransform: 'uppercase',
          color: 'var(--memox-on-surface-variant)',
          textAlign: 'center'
        }}>
          Next card in 0.8s
        </div>
        <div style={{ height: 3, background: 'var(--memox-surface-container)', borderRadius: 999, overflow: 'hidden' }}>
          <div style={{ height: '100%', width: '46%', background: 'var(--memox-mastery)' }} />
        </div>
      </div>
    </div>);

}

Object.assign(window, { GuessScreen });
})();
