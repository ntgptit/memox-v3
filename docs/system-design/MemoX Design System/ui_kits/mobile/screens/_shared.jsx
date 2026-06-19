/* MemoX UI kit — shared screen primitives. Single source of truth for the thin
   JSX wrappers over the .memox-components.css contract classes. Loaded before
   any screen; every screen reads helpers from window.MX so there is ONE copy to
   maintain (avoids per-screen drift / future refactors). */
(function () {
  const Icon = ({ name, style }) => <i data-lucide={name} style={style}></i>;

  // spacing token helper: S(4) -> "var(--memox-space-4)"
  const S = (k) => `var(--memox-space-${k})`;

  const PillBtn = ({ variant = 'primary', icon, iconRight, sm, full, disabled, children, ...rest }) => (
    <button className={`pill-btn ${variant}${sm ? ' sm' : ''}`} disabled={disabled}
      style={full ? { width: '100%' } : undefined} {...rest}>
      {icon && <Icon name={icon} />}{children}{iconRight && <Icon name={iconRight} />}
    </button>
  );

  const IconBtn = ({ icon, label, ...rest }) => (
    <button className="icon-btn" aria-label={label} {...rest}><Icon name={icon} /></button>
  );

  const IconTile = ({ icon, color, solid, style }) => (
    <span className={`icon-tile${solid ? ' solid' : ''}`} style={{ '--tile': color, ...style }}><Icon name={icon} /></span>
  );

  // Large hero/resume tile. tonal by default, solid when `solid`.
  const TileLg = ({ icon, tint, solid, style }) => (
    <span className={`tile-lg ${solid ? 'solid' : 'tonal'}`} style={{ '--tile': tint, ...style }}><Icon name={icon} /></span>
  );

  const Chip = ({ status, solid, icon, children }) => (
    <span className={`chip${status ? ' ' + status : ''}${solid ? ' solid' : ''}`}>
      {icon && <Icon name={icon} />}{children}
    </span>
  );

  const Overline = ({ dot, icon, color, children }) => (
    <div className="ov" style={color ? { color } : undefined}>
      {dot && <span className="status-dot" style={{ '--dot': dot }}></span>}
      {icon && <Icon name={icon} />}{children}
    </div>
  );

  const Progress = ({ value }) => (
    <div className="progress"><div className="progress-fill" style={{ width: value + '%' }}></div></div>
  );

  const SectionHead = ({ title, action }) => (
    <div className="section-head"><span className="section-head-title">{title}</span>{action}</div>
  );

  // Strong, scannable list row. Trailing affordance is consistent everywhere:
  // an optional due badge (solid when the count is high, soft when low) followed
  // by a chevron, so every row reads as tappable. `trail` is an escape hatch for
  // a custom trailing element; `chevron={false}` drops the chevron.
  const DUE_STRONG = 15; // at/above this many cards due, the badge goes solid
  const ListRow = ({ icon, color, title, meta, due, trail, chevron = true }) => (
    <div className="list-row">
      <IconTile icon={icon} color={color} />
      <div className="list-row-main">
        <div className="list-row-title">{title}</div>
        {meta != null && <div className="list-row-meta">{meta}</div>}
      </div>
      <span className="list-row-trail">
        {due != null && due > 0 && (
          <span className={`chip due${due >= DUE_STRONG ? ' solid' : ''}`}>{due} due</span>
        )}
        {trail}
        {chevron && <Icon name="chevron-right" />}
      </span>
    </div>
  );

  // Centered hero / empty-state / error card: tile + title + desc + actions.
  // One place owns the spacing so screens never hand-roll it.
  const HeroCard = ({ icon, tint, solid, title, desc, children }) => (
    <div className="card" style={{ textAlign: 'center', padding: S(6) }}>
      <TileLg icon={icon} tint={tint} solid={solid} style={{ margin: `0 auto ${S(4)}` }} />
      <div style={{ fontSize: 'var(--memox-size-h1)', fontWeight: 'var(--memox-weight-extrabold)', letterSpacing: 'var(--memox-tracking-tight)', color: 'var(--memox-text-primary)', marginBottom: S(1) }}>{title}</div>
      {desc && <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', lineHeight: 1.5, maxWidth: '280px', margin: `${S(1)} auto 0` }}>{desc}</div>}
      {children && <div style={{ display: 'flex', flexDirection: 'column', gap: S(2), marginTop: S(5) }}>{children}</div>}
    </div>
  );

  // Centered empty / no-results state that is NOT wrapped in a card (the bare
  // tile + title + desc used by search-empty and empty list screens). One owner
  // so every empty screen reads identically. Pass actions as children.
  const EmptyState = ({ icon, tint = 'var(--memox-text-secondary)', title, desc, pad = 8, children }) => (
    <div style={{ flex: 1, display: 'grid', placeItems: 'center', padding: `${S(pad)} 0` }}>
      <div style={{ textAlign: 'center' }}>
        <TileLg icon={icon} tint={tint} style={{ margin: '0 auto' }} />
        <div className="title" style={{ marginTop: S(4) }}>{title}</div>
        {desc && <div className="muted" style={{ fontSize: 'var(--memox-fs-label-large)', marginTop: S(1), maxWidth: '260px', marginInline: 'auto' }}>{desc}</div>}
        {children && <div style={{ marginTop: S(5) }}>{children}</div>}
      </div>
    </div>
  );

  // Non-blocking notice strip (.banner). `tone`: warn | danger | info (drives the
  // color via the contract class); `tint` overrides it with any token. Optional
  // `action` renders a solid tone-matched button on the right. One owner so every
  // banner — and its retry/CTA button — looks identical across screens.
  const Banner = ({ tone, icon, tint, action, style, children }) => (
    <div className={`banner${tone ? ' ' + tone : ''}`} style={{ ...(tint ? { '--bn': tint } : null), ...style }}>
      {icon && <Icon name={icon} />}
      <span style={{ flex: 1 }}>{children}</span>
      {action && <button className="pill-btn sm solid" style={{ '--btn': 'var(--bn)' }}>{action}</button>}
    </div>
  );

  // Horizontal info card: tile + title + sub, optional trailing element.
  const InfoRow = ({ icon, tint, title, desc, trail }) => (
    <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3), padding: S(4) }}>
      <IconTile icon={icon} color={tint} />
      <div style={{ flex: 1 }}>
        <div className="title">{title}</div>
        <div className="muted" style={{ fontSize: 'var(--memox-fs-body-small)' }}>{desc}</div>
      </div>
      {trail}
    </div>
  );

  // Flat, tappable selector row (a shadow-less .card): icon tile + label +
  // trailing chevron. The "choose a deck / value" picker dropped inside a form
  // field. One owner so every picker reads identically (was hand-rolled per
  // screen in create/edit).
  const PickerRow = ({ icon, tint = 'var(--memox-primary)', title, ...rest }) => (
    <div className="card" style={{ display: 'flex', alignItems: 'center', gap: S(3), padding: S(3), boxShadow: 'none', cursor: 'pointer' }} {...rest}>
      <IconTile icon={icon} color={tint} />
      <span className="title" style={{ flex: 1, fontSize: 'var(--memox-fs-label-large)' }}>{title}</span>
      <Icon name="chevron-right" style={{ width: 'var(--memox-icon-md)', height: 'var(--memox-icon-md)', color: 'var(--memox-text-secondary)' }} />
    </div>
  );

  // Lightweight, mobile-native stat row (NOT a desktop dashboard widget): evenly
  // spaced centered metrics, sentence-case labels, no table dividers. Pass each
  // stat as [value, label, accent?]; the `accent` one sits in a soft tinted
  // column so the action metric (e.g. "Due") reads as the most important number.
  const StatSummary = ({ stats }) => (
    <div className="card" style={{ display: 'flex', alignItems: 'stretch', padding: S(2), gap: S(1) }}>
      {stats.map(([value, label, accent]) => (
        <div key={label} style={{
          flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center',
          justifyContent: 'center', gap: S(1), padding: `${S(2)} ${S(1)}`,
          borderRadius: 'var(--memox-radius-md)',
          background: accent ? 'color-mix(in srgb, var(--memox-primary) calc(var(--memox-op-selected) * 100%), transparent)' : 'transparent',
        }}>
          <div style={{ fontSize: 'var(--memox-size-title)', fontWeight: 'var(--memox-weight-extrabold)', lineHeight: 1, letterSpacing: 'var(--memox-tracking-tight)', fontVariantNumeric: 'tabular-nums', color: accent ? 'var(--memox-primary)' : 'var(--memox-text-primary)' }}>{value}</div>
          <div style={{ fontSize: 'var(--memox-fs-body-small)', fontWeight: 'var(--memox-weight-semibold)', color: accent ? 'var(--memox-primary)' : 'var(--memox-text-secondary)' }}>{label}</div>
        </div>
      ))}
    </div>
  );

  // Native grouped list: an optional overline header (+ count) sits ABOVE the
  // rounded card (iOS-style section grouping), with inset hairlines between rows,
  // so a floating list card reads as a labelled group, not a stray web container.
  const ListGroup = ({ heading, items, kind }) => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
      {heading && (
        <div className="ov" style={{ paddingLeft: S(1) }}>
          {heading}<span style={{ marginLeft: S(1), color: 'var(--memox-text-3)' }}>{items.length}</span>
        </div>
      )}
      <div className="list-card">
        {items.map((it, i) => (
          <div key={it.name}>
            {i > 0 && <div className="hr inset"></div>}
            <ListRow icon={it.icon} color={it.tint} title={it.name} meta={it.meta}
              due={kind === 'deck' ? it.due : undefined} />
          </div>
        ))}
      </div>
    </div>
  );

  // Bottom tab bar. `active` = label of the current tab. One source of truth so
  // every screen ships the same four destinations in the same order.
  const NAV_ITEMS = [['Home', 'house'], ['Library', 'library'], ['Stats', 'bar-chart-3'], ['Settings', 'settings']];
  const BottomNav = ({ active = 'Home' }) => (
    <div className="bottom-nav">
      {NAV_ITEMS.map(([label, icon]) => (
        <button key={label} className={`bottom-nav-item${label === active ? ' active' : ''}`}>
          <span className="nav-ind"><Icon name={icon} /></span>{label}
        </button>
      ))}
    </div>
  );

  // Floating action button. Screens own positioning via `style` (absolute over
  // the bottom nav); the component only owns the look + hit target.
  const Fab = ({ icon = 'plus', label = 'Create', style, ...rest }) => (
    <button className="fab" aria-label={label} style={style} {...rest}><Icon name={icon} /></button>
  );

  // Skeleton block — the one shimmer shape every loading state composes from.
  const Sk = ({ h, w, r }) => (
    <div className="skeleton" style={{ height: h, width: w || '100%', borderRadius: r || 'var(--memox-radius-sm)' }}></div>
  );

  // ---- Forms ---------------------------------------------------------------
  // Labelled form group: an overline label (optional "Optional"/right slot) above
  // a control, with a red field-error message below when `error` is set. One owner
  // of the label/spacing/error treatment so every form field reads identically.
  const FormField = ({ label, right, error, children }) => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: S(2) }}>
      {label && (
        <div className="ov" style={{ justifyContent: 'space-between' }}>
          <span>{label}</span>{right && <span style={{ color: 'var(--memox-text-3)' }}>{right}</span>}
        </div>
      )}
      {children}
      {error && (
        <div style={{ display: 'flex', alignItems: 'center', gap: S(1), color: 'var(--memox-danger)', fontSize: 'var(--memox-fs-body-small)', fontWeight: 'var(--memox-weight-bold)' }}>
          <Icon name="alert-circle" style={{ width: 'var(--memox-icon-sm)', height: 'var(--memox-icon-sm)' }} />{error}
        </div>
      )}
    </div>
  );

  // Multiline text control matching the .field look (single-line uses .field).
  // `invalid` swaps the border to danger for validation states.
  const TextArea = ({ invalid, style, ...rest }) => (
    <textarea {...rest} style={{
      width: '100%', minHeight: '96px', resize: 'none',
      padding: 'var(--memox-space-3) var(--memox-space-4)',
      background: 'var(--memox-surface)',
      border: `1px solid ${invalid ? 'var(--memox-danger)' : 'var(--memox-outline-variant)'}`,
      borderRadius: 'var(--memox-radius-md)', fontFamily: 'var(--memox-font-sans)',
      fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-medium)', lineHeight: 1.5,
      color: 'var(--memox-text-primary)', ...style,
    }} />
  );

  // ---- Overlays ------------------------------------------------------------
  // Centered modal: scrim + .dialog. Children are the dialog body. One owner of
  // the scrim + centering + width so every confirm/rename dialog is consistent.
  const Modal = ({ children }) => (
    <div style={{ position: 'absolute', inset: 0, zIndex: 20, display: 'grid', placeItems: 'center', padding: S(6) }}>
      <div className="scrim"></div>
      <div className="dialog" style={{ position: 'relative', width: '100%' }}>{children}</div>
    </div>
  );

  // Bottom sheet: scrim + docked .sheet with grabber and optional title row.
  const Sheet = ({ title, children }) => (
    <div style={{ position: 'absolute', inset: 0, zIndex: 20, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
      <div className="scrim"></div>
      <div className="sheet" style={{ position: 'relative' }}>
        <div className="sheet-grabber"></div>
        {title && <div className="section-head" style={{ marginBottom: S(3) }}><span className="section-head-title">{title}</span></div>}
        {children}
      </div>
    </div>
  );

  // Loading/working overlay: scrim + centered spinner with a label. Use for a
  // blocking in-flight operation (busy state) over existing content.
  const BusyOverlay = ({ label = 'Working\u2026' }) => (
    <div style={{ position: 'absolute', inset: 0, zIndex: 20, display: 'grid', placeItems: 'center', padding: S(6) }}>
      <div className="scrim"></div>
      <div className="dialog" style={{ position: 'relative', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: S(3), width: 'auto', padding: S(6) }}>
        <div className="spinner"></div>
        <div className="title" style={{ fontSize: 'var(--memox-fs-label-large)' }}>{label}</div>
      </div>
    </div>
  );

  // ---- Study --------------------------------------------------------------
  // Top bar for every in-session study screen: exit × · progress bar · "x / N"
  // card counter. One owner so all five study modes share identical chrome.
  const StudyTopBar = ({ index, total }) => (
    <div className="appbar" style={{ gap: S(3) }}>
      <button className="icon-btn" aria-label="Exit study"><Icon name="x" /></button>
      <div style={{ flex: 1 }}><Progress value={total ? Math.min(100, (index / total) * 100) : 0} /></div>
      <span style={{ flex: 'none', fontSize: 'var(--memox-fs-label-large)', fontWeight: 'var(--memox-weight-bold)', color: 'var(--memox-text-secondary)', fontVariantNumeric: 'tabular-nums' }}>
        {index}<span style={{ color: 'var(--memox-text-3)' }}>{' / '}{total}</span>
      </span>
    </div>
  );

  // Study session frame: top progress bar + scrollable body + a fixed footer
  // action area (the place every mode puts Next / Check / self-rate buttons).
  // `center` vertically balances short content (e.g. Match's pair grid) so the
  // slack is shared above and below instead of pooling into one dead gap over
  // the footer — taller modes leave it off and stay top-aligned.
  const StudyShell = ({ index, total, children, footer, bodyStyle, center }) => (
    <div className="app" style={{ position: 'relative' }}>
      <StudyTopBar index={index} total={total} />
      <div style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: `${S(4)} var(--memox-space-screen)`, display: 'flex', flexDirection: 'column', ...(center ? { justifyContent: 'center' } : null), ...bodyStyle }}>
        {children}
      </div>
      {footer && (
        <div style={{ flex: 'none', padding: `${S(3)} var(--memox-space-screen) calc(${S(5)} + var(--memox-safe-bottom))`, display: 'flex', flexDirection: 'column', gap: S(2), borderTop: '1px solid var(--memox-border-ghost)' }}>
          {footer}
        </div>
      )}
    </div>
  );

  // One selectable answer cell. `state`: 'selected' | 'correct' | 'wrong'.
  // `k` = leading key badge (A–E); `mark` = trailing state icon. `more` shows the
  // corner "tap to read" hint on a card whose meaning is still truncated after
  // clamping (the card opens a full-text sheet). (.choice classes)
  const StudyOption = ({ state, k, mark, dim, clamp, more, children, ...rest }) => (
    <button className={`choice${state ? ' ' + state : ''}${dim ? ' dim' : ''}${clamp ? ' clamp' : ''}`} {...rest}>
      {k != null && <span className="choice-key">{k}</span>}
      <span className="choice-text">{children}</span>
      {mark && <span className="choice-mark"><Icon name={mark} /></span>}
      {more && <span className="choice-more"><Icon name="ellipsis" /></span>}
    </button>
  );

  // Self-rate button (Recall). `tone` selects a self-* token.
  const SELF_TINT = { missed: 'var(--memox-self-missed)', partial: 'var(--memox-self-partial)', got: 'var(--memox-self-got)' };
  const RateBtn = ({ tone = 'got', icon, children, ...rest }) => (
    <button className="rate-btn" style={{ '--rt': SELF_TINT[tone] }} {...rest}>
      <Icon name={icon} />{children}
    </button>
  );

  // Correct-answer reveal panel. `tone`: 'correct' (default) | 'wrong'.
  const AnswerReveal = ({ label = 'Answer', tone = 'correct', children }) => (
    <div className="answer-box" style={{ '--ab': tone === 'wrong' ? 'var(--memox-rating-wrong)' : 'var(--memox-rating-correct)' }}>
      <div className="ov" style={{ color: tone === 'wrong' ? 'var(--memox-rating-wrong)' : 'var(--memox-rating-correct)', marginBottom: S(1) }}>{label}</div>
      <div style={{ fontSize: 'var(--memox-size-h2)', fontWeight: 'var(--memox-weight-bold)', color: 'var(--memox-text-primary)', letterSpacing: 'var(--memox-tracking-tight)' }}>{children}</div>
    </div>
  );

  // ---- Settings -----------------------------------------------------------
  // Round avatar. `initials` for text, `icon` for a glyph (e.g. signed-out).
  // `lg` for the 56px account-header size; `tint` selects the color.
  const Avatar = ({ initials, icon, tint = 'var(--memox-primary)', lg }) => (
    <span className={`avatar${lg ? ' lg' : ''}`} style={{ '--av': tint }}>
      {icon ? <Icon name={icon} /> : initials}
    </span>
  );

  // On/off switch (.switch). Presentational — the kit shows fixed states.
  const Toggle = ({ on, disabled }) => (
    <button className={`switch${on ? ' on' : ''}`} disabled={disabled} aria-label="Toggle" aria-pressed={!!on}></button>
  );

  // Value slider (.slider). `value` within [min,max] positions fill + thumb.
  const Slider = ({ value, min = 0, max = 100 }) => {
    const pct = Math.max(0, Math.min(100, ((value - min) / (max - min)) * 100));
    return (
      <div className="slider">
        <div className="slider-track">
          <div className="slider-fill" style={{ width: pct + '%' }}></div>
          <div className="slider-thumb" style={{ left: pct + '%' }}></div>
        </div>
      </div>
    );
  };

  // Single-select row: icon-tile + label/desc + radio indicator (.radio). For
  // theme / language / voice pickers. `icon` optional (text-only radio lists).
  const RadioRow = ({ icon, tint, title, desc, selected, lead }) => (
    <div className="list-row">
      {lead}
      {icon && <IconTile icon={icon} color={tint} />}
      <div className="list-row-main">
        <div className="list-row-title">{title}</div>
        {desc != null && <div className="list-row-meta">{desc}</div>}
      </div>
      <span className={`radio${selected ? ' on' : ''}`}></span>
    </div>
  );

  // ---- Stats / progress ---------------------------------------------------
  // Segmented range/mode toggle (e.g. Week | Month). `value` = the active option
  // label; `options` = the labels in order. Presentational — the kit shows fixed
  // states. One owner so every range/mode switch reads identically (.segmented).
  const Segmented = ({ options, value }) => (
    <div className="segmented" role="tablist">
      {options.map((o) => (
        <button key={o} role="tab" aria-selected={o === value}
          className={`segmented-item${o === value ? ' active' : ''}`}>{o}</button>
      ))}
    </div>
  );

  // Column chart for study activity. `data` = [{ label, value }]; a null/undefined
  // value renders a dashed "no data" column (for partial ranges). Bars use the
  // primary accent and scale to `max` (or the data peak). `dim` softens the whole
  // chart for low-confidence ranges (insufficient data). One owner so weekly and
  // ranged charts share the same bars, gaps and day labels.
  const BarChart = ({ data, max, dim }) => {
    const peak = max || Math.max(1, ...data.map((d) => d.value || 0));
    return (
      <div style={{ display: 'flex', alignItems: 'flex-end', gap: S(2), height: 'calc(var(--memox-space-12) * 3)', opacity: dim ? 'var(--memox-op-disabled)' : 1 }}>
        {data.map((d, i) => {
          const has = d.value != null;
          const h = has ? Math.max(4, Math.round((d.value / peak) * 100)) : 0;
          return (
            <div key={i} style={{ flex: 1, minWidth: 0, height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: S(2) }}>
              <div style={{ flex: 1, width: '100%', display: 'flex', alignItems: 'flex-end', justifyContent: 'center' }}>
                {has ? (
                  <div style={{ width: '100%', height: h + '%', borderRadius: 'var(--memox-radius-sm)', background: 'var(--memox-primary)' }}></div>
                ) : (
                  <div style={{ width: '100%', height: '100%', borderRadius: 'var(--memox-radius-sm)', border: '1px dashed var(--memox-border-strong)' }}></div>
                )}
              </div>
              <span style={{ fontSize: 'var(--memox-fs-label-small)', fontWeight: 'var(--memox-weight-semibold)', color: 'var(--memox-text-secondary)' }}>{d.label}</span>
            </div>
          );
        })}
      </div>
    );
  };

  // Per-deck mastery bar. Fill width = `value`%; the tint steps through the
  // mastery scale (low < 50 ≤ mid < 80 ≤ high) so weak decks read low, strong
  // decks read high at a glance. One owner of the threshold logic + bar look.
  const MASTERY_TINT = (v) => (v >= 80 ? 'var(--memox-mastery-high)' : v >= 50 ? 'var(--memox-mastery-mid)' : 'var(--memox-mastery-low)');
  const MasteryBar = ({ value }) => (
    <div style={{ height: S(2), borderRadius: 'var(--memox-radius-full)', background: 'var(--memox-progress-track)', overflow: 'hidden' }}>
      <div style={{ height: '100%', width: value + '%', borderRadius: 'var(--memox-radius-full)', background: MASTERY_TINT(value) }}></div>
    </div>
  );

  window.MX = { Icon, S, PillBtn, IconBtn, IconTile, TileLg, Chip, Overline, Progress, SectionHead, ListRow, StatSummary, ListGroup, HeroCard, InfoRow, PickerRow, EmptyState, Banner, BottomNav, Fab, Sk, FormField, TextArea, Modal, Sheet, BusyOverlay, StudyTopBar, StudyShell, StudyOption, RateBtn, AnswerReveal, Avatar, Toggle, Slider, RadioRow, Segmented, BarChart, MasteryBar };
})();
