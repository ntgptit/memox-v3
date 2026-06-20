/* @ds-bundle: {"format":3,"namespace":"DesignSystem_48ad9c","components":[{"name":"Avatar","sourcePath":"components/core/Avatar.jsx"},{"name":"Badge","sourcePath":"components/core/Badge.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Card","sourcePath":"components/core/Card.jsx"},{"name":"Chip","sourcePath":"components/core/Chip.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"SegmentedControl","sourcePath":"components/core/SegmentedControl.jsx"},{"name":"Switch","sourcePath":"components/core/Switch.jsx"},{"name":"NoteCard","sourcePath":"components/mobile/NoteCard.jsx"}],"sourceHashes":{"components/core/Avatar.jsx":"6fb896786b20","components/core/Badge.jsx":"5c2c0e0189ba","components/core/Button.jsx":"db60dd3ede0f","components/core/Card.jsx":"47a7a56a082b","components/core/Chip.jsx":"25f83cc08614","components/core/IconButton.jsx":"9c68965eb8c0","components/core/SegmentedControl.jsx":"f0b9c15222b6","components/core/Switch.jsx":"6b0cd9388d4e","components/mobile/NoteCard.jsx":"e780eea25703","tools/check-ui-kit.js":"be8d53e53c4f","ui_kits/mobile/screens/00-components.jsx":"77cd197a3b0f","ui_kits/mobile/screens/01-onboarding.jsx":"c205e46e14a9","ui_kits/mobile/screens/02-dashboard.jsx":"6bb9080ab361","ui_kits/mobile/screens/03-library.jsx":"00eb90fdb7a5","ui_kits/mobile/screens/04-folder.jsx":"55f2abc4c48a","ui_kits/mobile/screens/05-search.jsx":"67bfc5c0cb26","ui_kits/mobile/screens/06-flashcard-list.jsx":"a897998227e9","ui_kits/mobile/screens/07-flashcard-create.jsx":"62fe8f747708","ui_kits/mobile/screens/08-flashcard-edit.jsx":"3c11bf729981","ui_kits/mobile/screens/09-flashcard-history.jsx":"b6601af6bdb2","ui_kits/mobile/screens/10-deck-import.jsx":"3c52746489f8","ui_kits/mobile/screens/11-tag-management.jsx":"5391e163ee62","ui_kits/mobile/screens/12-study-review.jsx":"f96858d16542","ui_kits/mobile/screens/13-study-match.jsx":"389897a11003","ui_kits/mobile/screens/14-study-guess.jsx":"409ed128d205","ui_kits/mobile/screens/15-study-recall.jsx":"4cb7b102a64d","ui_kits/mobile/screens/16-study-fill.jsx":"e20517af9cd8","ui_kits/mobile/screens/17-study-result.jsx":"742b91ebb7e0","ui_kits/mobile/screens/18-stats.jsx":"c34f6912532e","ui_kits/mobile/screens/19-progress.jsx":"b8eceb4cfd96","ui_kits/mobile/screens/20-settings.jsx":"e6a2b2256ca9","ui_kits/mobile/screens/21-account-sync.jsx":"29f6cc815c78","ui_kits/mobile/screens/22-learning-settings.jsx":"d6d02915ea47","ui_kits/mobile/screens/23-audio-speech.jsx":"75277876f8e4","ui_kits/mobile/screens/24-appearance.jsx":"3d3a2141bc40","ui_kits/mobile/screens/25-language.jsx":"efe935022f7b"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.DesignSystem_48ad9c = window.DesignSystem_48ad9c || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/core/Avatar.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const NOTE_TINTS = ['var(--memox-note-violet)', 'var(--memox-note-blue)', 'var(--memox-note-teal)', 'var(--memox-note-green)', 'var(--memox-note-amber)', 'var(--memox-note-clay)'];

/**
 * MemoX Avatar — initials or image. Color derives from name when not given.
 */
function Avatar({
  name = '',
  src,
  size = 40,
  color,
  style,
  ...rest
}) {
  const initials = name.split(/\s+/).filter(Boolean).slice(0, 2).map(w => w[0]).join('').toUpperCase();
  let hash = 0;
  for (let i = 0; i < name.length; i++) hash = hash * 31 + name.charCodeAt(i) >>> 0;
  const bg = color || NOTE_TINTS[hash % NOTE_TINTS.length];
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      width: size,
      height: size,
      borderRadius: 'var(--memox-radius-pill)',
      display: 'grid',
      placeItems: 'center',
      overflow: 'hidden',
      flex: 'none',
      background: bg,
      color: 'var(--memox-true-white)',
      fontFamily: 'var(--memox-font-sans)',
      fontWeight: 800,
      fontSize: Math.round(size * 0.38),
      letterSpacing: '0.01em',
      ...style
    }
  }, rest), src ? /*#__PURE__*/React.createElement("img", {
    src: src,
    alt: name,
    style: {
      width: '100%',
      height: '100%',
      objectFit: 'cover'
    }
  }) : initials || '?');
}
Object.assign(__ds_scope, { Avatar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Avatar.jsx", error: String((e && e.message) || e) }); }

// components/core/Badge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * MemoX Badge — compact status/label pill. Tones map to semantic tokens.
 */
function Badge({
  children,
  tone = 'neutral',
  icon,
  solid = false,
  style,
  ...rest
}) {
  const tones = {
    neutral: ['var(--memox-surface-2)', 'var(--memox-text-2)'],
    accent: ['var(--memox-accent-soft)', 'var(--memox-text-accent)'],
    success: ['var(--memox-success-soft)', 'var(--memox-success)'],
    warn: ['var(--memox-warn-soft)', 'var(--memox-warn)'],
    danger: ['var(--memox-danger-soft)', 'var(--memox-danger)'],
    info: ['var(--memox-info-soft)', 'var(--memox-info)']
  };
  const [bg, fg] = tones[tone] || tones.neutral;
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 5,
      padding: '4px 10px',
      borderRadius: 'var(--memox-radius-pill)',
      background: solid ? fg : bg,
      color: solid ? 'var(--memox-true-white)' : fg,
      fontFamily: 'var(--memox-font-sans)',
      fontSize: 12,
      fontWeight: 700,
      letterSpacing: '0.01em',
      lineHeight: 1.3,
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement("i", {
    "data-lucide": icon,
    style: {
      width: 13,
      height: 13
    }
  }), children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Badge.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * MemoX Button — primary action control.
 * Variants read entirely from --memox-* tokens; never hardcode colors.
 */
function Button({
  children,
  variant = 'primary',
  size = 'md',
  icon,
  iconRight,
  disabled = false,
  full = false,
  onClick,
  style,
  ...rest
}) {
  const sizes = {
    sm: {
      padding: '8px 14px',
      fontSize: 13,
      height: 36,
      gap: 6,
      icon: 16
    },
    md: {
      padding: '11px 18px',
      fontSize: 15,
      height: 44,
      gap: 8,
      icon: 18
    },
    lg: {
      padding: '14px 22px',
      fontSize: 16,
      height: 52,
      gap: 9,
      icon: 20
    }
  };
  const s = sizes[size] || sizes.md;
  const variants = {
    primary: {
      background: 'var(--memox-accent)',
      color: 'var(--memox-accent-contrast)',
      border: '1px solid transparent',
      boxShadow: 'none'
    },
    secondary: {
      background: 'var(--memox-surface)',
      color: 'var(--memox-text)',
      border: '1px solid var(--memox-border-strong)',
      boxShadow: 'var(--memox-shadow-sm)'
    },
    ghost: {
      background: 'transparent',
      color: 'var(--memox-text-2)',
      border: '1px solid transparent',
      boxShadow: 'none'
    },
    soft: {
      background: 'var(--memox-accent-soft)',
      color: 'var(--memox-text-accent)',
      border: '1px solid transparent',
      boxShadow: 'none'
    },
    danger: {
      background: 'var(--memox-danger)',
      color: 'var(--memox-true-white)',
      border: '1px solid transparent',
      boxShadow: 'none'
    }
  };
  const v = variants[variant] || variants.primary;
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    onClick: disabled ? undefined : onClick,
    disabled: disabled,
    style: {
      display: full ? 'flex' : 'inline-flex',
      width: full ? '100%' : undefined,
      alignItems: 'center',
      justifyContent: 'center',
      gap: s.gap,
      height: s.height,
      padding: s.padding,
      fontFamily: 'var(--memox-font-sans)',
      fontSize: s.fontSize,
      fontWeight: 700,
      lineHeight: 1,
      letterSpacing: '-0.01em',
      borderRadius: 'var(--memox-radius-pill)',
      cursor: disabled ? 'not-allowed' : 'pointer',
      opacity: disabled ? 0.45 : 1,
      transition: 'transform .12s ease, filter .15s ease',
      ...v,
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement("i", {
    "data-lucide": icon,
    style: {
      width: s.icon,
      height: s.icon
    }
  }), children, iconRight && /*#__PURE__*/React.createElement("i", {
    "data-lucide": iconRight,
    style: {
      width: s.icon,
      height: s.icon
    }
  }));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * MemoX Card — generic surface container with token elevation.
 */
function Card({
  children,
  elevation = 'sm',
  pad = 16,
  accent,
  style,
  ...rest
}) {
  const shadows = {
    none: 'none',
    sm: 'var(--memox-shadow-sm)',
    md: 'var(--memox-shadow-md)',
    lg: 'var(--memox-shadow-lg)'
  };
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      position: 'relative',
      overflow: 'hidden',
      background: 'var(--memox-card)',
      border: '1px solid var(--memox-border)',
      borderRadius: 'var(--memox-radius-lg)',
      boxShadow: shadows[elevation] || shadows.sm,
      padding: pad,
      ...style
    }
  }, rest), accent && /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      left: 0,
      top: 0,
      bottom: 0,
      width: 5,
      background: accent
    }
  }), children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Card.jsx", error: String((e && e.message) || e) }); }

// components/core/Chip.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * MemoX Chip — filter / selection pill. Selected state uses accent fill.
 */
function Chip({
  children,
  selected = false,
  dot,
  icon,
  onClick,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    onClick: onClick,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 7,
      padding: '7px 14px',
      borderRadius: 'var(--memox-radius-pill)',
      fontFamily: 'var(--memox-font-sans)',
      fontSize: 13,
      fontWeight: 700,
      lineHeight: 1.2,
      cursor: 'pointer',
      transition: 'background .12s ease, color .12s ease, border-color .12s ease',
      background: selected ? 'var(--memox-accent)' : 'var(--memox-surface)',
      color: selected ? 'var(--memox-accent-contrast)' : 'var(--memox-text-2)',
      border: selected ? '1px solid transparent' : '1px solid var(--memox-border)',
      ...style
    }
  }, rest), dot && /*#__PURE__*/React.createElement("span", {
    style: {
      width: 9,
      height: 9,
      borderRadius: 3,
      background: dot
    }
  }), icon && /*#__PURE__*/React.createElement("i", {
    "data-lucide": icon,
    style: {
      width: 15,
      height: 15
    }
  }), children);
}
Object.assign(__ds_scope, { Chip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Chip.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * MemoX IconButton — square, icon-only control. Good for toolbars & headers.
 */
function IconButton({
  icon,
  variant = 'ghost',
  size = 'md',
  active = false,
  disabled = false,
  label,
  onClick,
  style,
  ...rest
}) {
  const sizes = {
    sm: 34,
    md: 40,
    lg: 48
  };
  const iconSizes = {
    sm: 18,
    md: 20,
    lg: 22
  };
  const dim = sizes[size] || sizes.md;
  const variants = {
    ghost: {
      background: 'transparent',
      color: 'var(--memox-text-2)',
      border: '1px solid transparent'
    },
    surface: {
      background: 'var(--memox-surface)',
      color: 'var(--memox-text)',
      border: '1px solid var(--memox-border)'
    },
    accent: {
      background: 'var(--memox-accent)',
      color: 'var(--memox-accent-contrast)',
      border: '1px solid transparent',
      boxShadow: 'var(--memox-shadow-md)'
    }
  };
  const v = active ? {
    background: 'var(--memox-accent-soft)',
    color: 'var(--memox-text-accent)',
    border: '1px solid transparent'
  } : variants[variant] || variants.ghost;
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    "aria-label": label,
    onClick: disabled ? undefined : onClick,
    disabled: disabled,
    style: {
      width: dim,
      height: dim,
      display: 'grid',
      placeItems: 'center',
      borderRadius: variant === 'accent' ? 'var(--memox-radius-pill)' : 'var(--memox-radius-sm)',
      cursor: disabled ? 'not-allowed' : 'pointer',
      opacity: disabled ? 0.45 : 1,
      transition: 'background .12s ease, transform .12s ease',
      ...v,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("i", {
    "data-lucide": icon,
    style: {
      width: iconSizes[size] || 20,
      height: iconSizes[size] || 20
    }
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/core/SegmentedControl.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * MemoX SegmentedControl — single-select among 2–4 short options.
 */
function SegmentedControl({
  options = [],
  value,
  onChange,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      gap: 4,
      padding: 4,
      borderRadius: 'var(--memox-radius-pill)',
      background: 'var(--memox-surface-2)',
      border: '1px solid var(--memox-border)',
      ...style
    }
  }, rest), options.map(opt => {
    const val = typeof opt === 'string' ? opt : opt.value;
    const label = typeof opt === 'string' ? opt : opt.label;
    const on = val === value;
    return /*#__PURE__*/React.createElement("button", {
      key: val,
      type: "button",
      onClick: () => onChange && onChange(val),
      style: {
        flex: 1,
        textAlign: 'center',
        padding: '8px 12px',
        fontFamily: 'var(--memox-font-sans)',
        fontSize: 13.5,
        fontWeight: 700,
        lineHeight: 1.2,
        border: 'none',
        cursor: 'pointer',
        borderRadius: 'var(--memox-radius-pill)',
        background: on ? 'var(--memox-surface)' : 'transparent',
        color: on ? 'var(--memox-text)' : 'var(--memox-text-3)',
        boxShadow: on ? 'var(--memox-shadow-sm)' : 'none',
        transition: 'background .14s ease, color .14s ease'
      }
    }, label);
  }));
}
Object.assign(__ds_scope, { SegmentedControl });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/SegmentedControl.jsx", error: String((e && e.message) || e) }); }

// components/core/Switch.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * MemoX Switch — boolean toggle. Controlled via `checked` + `onChange`.
 */
function Switch({
  checked = false,
  onChange,
  disabled = false,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    role: "switch",
    "aria-checked": checked,
    disabled: disabled,
    onClick: disabled ? undefined : () => onChange && onChange(!checked),
    style: {
      width: 50,
      height: 30,
      flex: 'none',
      borderRadius: 'var(--memox-radius-pill)',
      border: 'none',
      cursor: disabled ? 'not-allowed' : 'pointer',
      opacity: disabled ? 0.5 : 1,
      padding: 3,
      display: 'flex',
      justifyContent: checked ? 'flex-end' : 'flex-start',
      alignItems: 'center',
      background: checked ? 'var(--memox-accent)' : 'var(--memox-border-strong)',
      transition: 'background .18s ease',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 24,
      height: 24,
      borderRadius: 'var(--memox-radius-pill)',
      background: 'var(--memox-true-white)',
      boxShadow: 'var(--memox-shadow-sm)',
      transition: 'transform .18s ease'
    }
  }));
}
Object.assign(__ds_scope, { Switch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Switch.jsx", error: String((e && e.message) || e) }); }

// components/mobile/NoteCard.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/**
 * MemoX NoteCard — the signature memo tile: tint bar, folder, title, preview, tags.
 */
function NoteCard({
  title,
  body,
  folder,
  time,
  color = 'var(--memox-note-amber)',
  pinned = false,
  tags = [],
  onClick,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    onClick: onClick,
    style: {
      position: 'relative',
      overflow: 'hidden',
      background: 'var(--memox-card)',
      border: '1px solid var(--memox-border)',
      borderRadius: 'var(--memox-radius-lg)',
      boxShadow: 'var(--memox-shadow-sm)',
      padding: 16,
      cursor: onClick ? 'pointer' : 'default',
      fontFamily: 'var(--memox-font-sans)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      left: 0,
      top: 0,
      bottom: 0,
      width: 5,
      background: color
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      marginBottom: 7
    }
  }, folder && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 11,
      fontWeight: 700,
      color: 'var(--memox-text-3)',
      textTransform: 'uppercase',
      letterSpacing: '0.05em'
    }
  }, folder), pinned && /*#__PURE__*/React.createElement("i", {
    "data-lucide": "pin",
    style: {
      width: 13,
      height: 13,
      color: 'var(--memox-accent)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }), time && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 11.5,
      color: 'var(--memox-text-3)',
      fontWeight: 600
    }
  }, time)), title && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 16,
      fontWeight: 700,
      marginBottom: 4,
      color: 'var(--memox-text)'
    }
  }, title), body && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13.5,
      lineHeight: 1.5,
      color: 'var(--memox-text-2)',
      display: '-webkit-box',
      WebkitLineClamp: 2,
      WebkitBoxOrient: 'vertical',
      overflow: 'hidden'
    }
  }, body), tags.length > 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      marginTop: 11,
      flexWrap: 'wrap'
    }
  }, tags.map(t => /*#__PURE__*/React.createElement(__ds_scope.Badge, {
    key: t,
    tone: "neutral"
  }, "#", t))));
}
Object.assign(__ds_scope, { NoteCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/mobile/NoteCard.jsx", error: String((e && e.message) || e) }); }

// tools/check-ui-kit.js
try { (() => {
/* ============================================================================
 * MemoX — UI-kit adherence checker
 * ----------------------------------------------------------------------------
 * Zero-dependency. Verifies that ui_kits screens stick to the shared system so
 * you don't have to eyeball-review (or pay an agent to):
 *   • no hardcoded colors  (#hex / rgb / rgba)            -> ERROR
 *   • no undefined --memox-* token references              -> ERROR
 *   • each screen has the bundle guard (no __errors)       -> ERROR
 *   • no raw px for spacing/size/radius/font               -> WARN
 *   • screens consume the shared primitives (window.MX)    -> WARN
 *   • screens don't re-declare a shared primitive locally  -> WARN
 *
 * Usage:   node tools/check-ui-kit.js
 * Exit:    0 = clean (no errors), 1 = at least one ERROR.
 *
 * NOTE: the whole body is wrapped in a Node-only guard so that when the design
 * system compiler bundles this file for the browser it simply no-ops (no
 * require/process there) — keeping _ds_bundle.js clean.
 * ========================================================================== */
'use strict';

(function () {
  if (typeof process === 'undefined' || !process.versions || !process.versions.node) return; // browser/bundle: no-op

  const fs = require('fs');
  const path = require('path');
  const ROOT = path.resolve(__dirname, '..');
  const read = p => fs.readFileSync(p, 'utf8');
  const exists = p => fs.existsSync(p);
  function walk(dir, out = []) {
    if (!exists(dir)) return out;
    for (const name of fs.readdirSync(dir)) {
      const fp = path.join(dir, name);
      if (fs.statSync(fp).isDirectory()) walk(fp, out);else out.push(fp);
    }
    return out;
  }
  const stripComments = s => s.replace(/\/\*[\s\S]*?\*\//g, '').replace(/(^|[^:])\/\/.*$/gm, '$1');
  const rel = p => path.relative(ROOT, p).split(path.sep).join('/');

  // 1. defined --memox-* tokens (every root CSS file, skipping _generated)
  const cssFiles = walk(ROOT).filter(f => f.endsWith('.css') && !f.includes(path.sep + '_'));
  const definedTokens = new Set();
  for (const f of cssFiles) {
    for (const m of read(f).matchAll(/(--memox-[\w-]+)\s*:/g)) definedTokens.add(m[1]);
  }

  // shared primitives exposed on window.MX
  const sharedPath = path.join(ROOT, 'ui_kits/mobile/screens/_shared.jsx');
  const sharedNames = new Set();
  if (exists(sharedPath)) {
    const m = read(sharedPath).match(/window\.MX\s*=\s*\{([^}]*)\}/);
    if (m) m[1].split(',').map(s => s.trim()).filter(Boolean).forEach(n => sharedNames.add(n));
  }

  // 2. screen files
  const screens = walk(ROOT).filter(f => /ui_kits\/.+\/screens\/.+\.jsx$/.test(f.split(path.sep).join('/'))).filter(f => !/_shared\.jsx$/.test(f));

  // 3. checks
  let errors = 0,
    warns = 0;
  const report = (level, file, msg) => {
    if (level === 'ERROR') errors++;else warns++;
    console.log(`  [${level === 'ERROR' ? 'ERROR' : 'warn '}] ${rel(file)}: ${msg}`);
  };
  if (!sharedNames.size) console.log('! could not read window.MX from _shared.jsx — shared-usage checks skipped\n');
  for (const file of screens) {
    const src = stripComments(read(file));

    // 3a. hardcoded colors
    const colorHits = new Set();
    for (const m of src.matchAll(/#[0-9a-fA-F]{3,8}\b/g)) colorHits.add(m[0]);
    for (const m of src.matchAll(/\brgba?\([^)]*\)/g)) colorHits.add(m[0]);
    colorHits.forEach(c => report('ERROR', file, `hardcoded color "${c}" — use a var(--memox-*) token`));

    // 3b. undefined token references
    const badTokens = new Set();
    for (const m of src.matchAll(/var\((--memox-[\w-]+)/g)) if (!definedTokens.has(m[1])) badTokens.add(m[1]);
    badTokens.forEach(t => report('ERROR', file, `references undefined token ${t}`));

    // 3c. bundle guard present
    if (!/if\s*\(\s*!window\.MX[\s\S]{0,80}?return/.test(src)) {
      report('ERROR', file, 'missing bundle guard `if (!window.MX || !window.MEMOX_KIT...) return;` at IIFE top');
    }

    // 3d. consumes shared primitives
    if (sharedNames.size && !/window\.MX/.test(src)) {
      report('warn', file, 'does not read from window.MX — is it using the shared primitives?');
    }

    // 3e. re-declares a shared primitive locally
    for (const name of sharedNames) {
      if (new RegExp(`\\b(?:const|let|function)\\s+${name}\\b\\s*[=(]`).test(src)) {
        report('warn', file, `re-declares shared primitive "${name}" locally — import it from window.MX instead`);
      }
    }

    // 3f. raw px / bare size literals (skeleton px is acceptable)
    const pxHits = [];
    for (const m of src.matchAll(/\b(\d+)px\b/g)) if (m[1] !== '0' && m[1] !== '1') pxHits.push(m[0]);
    for (const m of src.matchAll(/\b(gap|padding[A-Za-z]*|margin[A-Za-z]*|fontSize|borderRadius)\s*:\s*(\d+)\b/g)) {
      if (m[2] !== '0') pxHits.push(`${m[1]}: ${m[2]}`);
    }
    if (pxHits.length) {
      const uniq = [...new Set(pxHits)].slice(0, 8).join(', ');
      report('warn', file, `raw px/size literal(s): ${uniq}${pxHits.length > 8 ? ' …' : ''} — prefer S(n)/--memox-* (skeleton px is ok)`);
    }
  }

  // 4. summary
  console.log('');
  console.log(`Checked ${screens.length} screen file(s) · ${definedTokens.size} tokens · ${sharedNames.size} shared primitives`);
  console.log(`Result: ${errors} error(s), ${warns} warning(s)`);
  if (errors === 0) console.log('\u2713 UI kit adheres to the shared theme / tokens / components.');
  process.exit(errors ? 1 : 0);
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "tools/check-ui-kit.js", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/00-components.jsx
try { (() => {
/* MemoX screen — 00 Components. Storybook of the token-driven contract layer.
   Every element uses the .memox-components.css classes; the gallery renders it
   in light AND dark frames automatically. JSX helpers wrap each class. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  // Shared primitives — single source of truth (screens/_shared.jsx).
  const {
    Icon,
    PillBtn,
    IconBtn,
    IconTile,
    Chip,
    Overline,
    Progress,
    SectionHead,
    ListRow
  } = window.MX;
  const Group = ({
    label,
    children,
    cols
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-space-3)'
    }
  }, /*#__PURE__*/React.createElement(Overline, null, label), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: 'var(--memox-space-2)',
      alignItems: 'center'
    }
  }, children));
  function Components() {
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement("div", {
      className: "appbar-lg"
    }, /*#__PURE__*/React.createElement("div", {
      className: "appbar-subtitle"
    }, "MemoX UI Kit"), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        width: '100%',
        alignItems: 'flex-end'
      }
    }, /*#__PURE__*/React.createElement("span", {
      className: "appbar-title"
    }, "Components"), /*#__PURE__*/React.createElement("span", {
      className: "spacer"
    }), /*#__PURE__*/React.createElement(IconBtn, {
      icon: "sliders-horizontal",
      label: "Filter"
    }))), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        overflowY: 'auto',
        padding: 'var(--memox-space-1) var(--memox-space-screen) var(--memox-space-8)',
        display: 'flex',
        flexDirection: 'column',
        gap: 'var(--memox-space-6)'
      }
    }, /*#__PURE__*/React.createElement(Group, {
      label: "Pill buttons"
    }, /*#__PURE__*/React.createElement(PillBtn, {
      variant: "primary",
      icon: "play"
    }, "Study"), /*#__PURE__*/React.createElement(PillBtn, {
      variant: "secondary",
      icon: "plus"
    }, "Add"), /*#__PURE__*/React.createElement(PillBtn, {
      variant: "outline"
    }, "Skip"), /*#__PURE__*/React.createElement(PillBtn, {
      variant: "primary",
      disabled: true
    }, "Done")), /*#__PURE__*/React.createElement(Group, {
      label: "Icon buttons"
    }, /*#__PURE__*/React.createElement(IconBtn, {
      icon: "search",
      label: "Search"
    }), /*#__PURE__*/React.createElement(IconBtn, {
      icon: "star",
      label: "Star"
    }), /*#__PURE__*/React.createElement(IconBtn, {
      icon: "share-2",
      label: "Share"
    }), /*#__PURE__*/React.createElement(IconBtn, {
      icon: "more-vertical",
      label: "More"
    })), /*#__PURE__*/React.createElement(Group, {
      label: "Icon tiles \u2014 tonal & solid"
    }, /*#__PURE__*/React.createElement(IconTile, {
      icon: "sparkles",
      color: "var(--memox-status-new)"
    }), /*#__PURE__*/React.createElement(IconTile, {
      icon: "brain",
      color: "var(--memox-status-learning)"
    }), /*#__PURE__*/React.createElement(IconTile, {
      icon: "repeat",
      color: "var(--memox-status-reviewing)"
    }), /*#__PURE__*/React.createElement(IconTile, {
      icon: "check",
      color: "var(--memox-status-mastered)",
      solid: true
    }), /*#__PURE__*/React.createElement(IconTile, {
      icon: "folder",
      color: "var(--memox-note-clay)",
      solid: true
    })), /*#__PURE__*/React.createElement("div", {
      className: "card accent"
    }, /*#__PURE__*/React.createElement(Overline, {
      dot: "var(--memox-primary)"
    }, "DUE TODAY"), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        alignItems: 'baseline',
        gap: 'var(--memox-space-2)',
        margin: 'var(--memox-space-1) 0 var(--memox-space-2)'
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 'var(--memox-fs-headline-medium)',
        fontWeight: 'var(--memox-weight-extrabold)',
        color: 'var(--memox-text-primary)'
      }
    }, "12 cards"), /*#__PURE__*/React.createElement(Chip, {
      status: "due"
    }, "in 3 decks")), /*#__PURE__*/React.createElement(Progress, {
      value: 64
    })), /*#__PURE__*/React.createElement(Group, {
      label: "Status chips"
    }, /*#__PURE__*/React.createElement(Chip, {
      status: "new"
    }, "New"), /*#__PURE__*/React.createElement(Chip, {
      status: "learning"
    }, "Learning"), /*#__PURE__*/React.createElement(Chip, {
      status: "reviewing"
    }, "Reviewing"), /*#__PURE__*/React.createElement(Chip, {
      status: "mastered",
      icon: "check"
    }, "Mastered"), /*#__PURE__*/React.createElement(Chip, {
      status: "due",
      solid: true
    }, "12 due")), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: 'var(--memox-space-3)'
      }
    }, /*#__PURE__*/React.createElement(SectionHead, {
      title: "Your decks",
      action: /*#__PURE__*/React.createElement(PillBtn, {
        variant: "secondary",
        sm: true,
        iconRight: "chevron-right"
      }, "All")
    }), /*#__PURE__*/React.createElement("div", {
      className: "card",
      style: {
        padding: 'var(--memox-space-1) var(--memox-space-card)'
      }
    }, /*#__PURE__*/React.createElement(ListRow, {
      icon: "languages",
      color: "var(--memox-status-new)",
      title: "Japanese \xB7 N5",
      meta: "48 cards \xB7 6 due"
    }), /*#__PURE__*/React.createElement("div", {
      className: "hr"
    }), /*#__PURE__*/React.createElement(ListRow, {
      icon: "flask-conical",
      color: "var(--memox-status-learning)",
      title: "Organic chemistry",
      meta: "120 cards \xB7 4 due"
    }), /*#__PURE__*/React.createElement("div", {
      className: "hr"
    }), /*#__PURE__*/React.createElement(ListRow, {
      icon: "landmark",
      color: "var(--memox-status-reviewing)",
      title: "World capitals",
      meta: "195 cards \xB7 2 due"
    }))), /*#__PURE__*/React.createElement(Group, {
      label: "Bottom sheet"
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        position: 'relative',
        width: '100%',
        borderRadius: 'var(--memox-radius-card)',
        overflow: 'hidden',
        border: '1px solid var(--memox-border-ghost)'
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        height: 60,
        background: 'var(--memox-bg)'
      }
    }), /*#__PURE__*/React.createElement("div", {
      className: "scrim",
      style: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        height: 'var(--memox-space-12)'
      }
    }), /*#__PURE__*/React.createElement("div", {
      className: "sheet",
      style: {
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "sheet-grabber"
    }), /*#__PURE__*/React.createElement("div", {
      className: "section-head-title",
      style: {
        marginBottom: 'var(--memox-space-1)'
      }
    }, "Add to deck"), /*#__PURE__*/React.createElement("div", {
      className: "list-row-meta",
      style: {
        marginBottom: 'var(--memox-space-3)'
      }
    }, "Pick a deck for this card."), /*#__PURE__*/React.createElement(PillBtn, {
      variant: "primary",
      icon: "plus"
    }, "New deck"))))), /*#__PURE__*/React.createElement("div", {
      style: {
        position: 'absolute',
        right: 'var(--memox-space-4)',
        bottom: 'calc(var(--memox-size-bottom-nav) + var(--memox-space-4))'
      }
    }, /*#__PURE__*/React.createElement("button", {
      className: "fab",
      "aria-label": "New card"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "plus"
    }))), /*#__PURE__*/React.createElement("div", {
      className: "bottom-nav"
    }, /*#__PURE__*/React.createElement("div", {
      className: "bottom-nav-item active"
    }, /*#__PURE__*/React.createElement("span", {
      className: "nav-ind"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "layers"
    })), "Decks"), /*#__PURE__*/React.createElement("div", {
      className: "bottom-nav-item"
    }, /*#__PURE__*/React.createElement("span", {
      className: "nav-ind"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "graduation-cap"
    })), "Study"), /*#__PURE__*/React.createElement("div", {
      className: "bottom-nav-item"
    }, /*#__PURE__*/React.createElement("span", {
      className: "nav-ind"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "bar-chart-3"
    })), "Stats"), /*#__PURE__*/React.createElement("div", {
      className: "bottom-nav-item"
    }, /*#__PURE__*/React.createElement("span", {
      className: "nav-ind"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "user"
    })), "You")));
  }
  if (!window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  window.MEMOX_KIT.register({
    num: '00',
    title: 'Components',
    states: [{
      label: 'Showcase',
      render: () => /*#__PURE__*/React.createElement(Components, null)
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/00-components.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/01-onboarding.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* MemoX screen — 01 Onboarding (9 states). Welcomes a new user and routes to
   creating/importing a first deck, plus the sign-in + restore branch.
   Token-driven; composes the contract component classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  // Shared primitives — single source of truth (screens/_shared.jsx).
  const {
    Icon,
    S,
    PillBtn,
    HeroCard,
    InfoRow
  } = window.MX;
  const AppBar = ({
    title,
    subtitle
  }) => /*#__PURE__*/React.createElement("div", {
    className: "appbar-lg"
  }, subtitle && /*#__PURE__*/React.createElement("div", {
    className: "appbar-subtitle"
  }, subtitle), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title"
  }, title));
  const REASSURE = [{
    icon: 'shield-check',
    tint: 'var(--memox-status-mastered)',
    title: 'Local-first',
    desc: 'Your cards live on your device.'
  }, {
    icon: 'calendar-check',
    tint: 'var(--memox-status-new)',
    title: 'A gentle daily rhythm',
    desc: 'Small reviews, every day.'
  }, {
    icon: 'feather',
    tint: 'var(--memox-status-reviewing)',
    title: 'No streak pressure',
    desc: 'Miss a day — nothing breaks.'
  }];
  function Body({
    children
  }) {
    return /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        overflowY: 'auto',
        padding: `${S(2)} var(--memox-space-screen) var(--memox-space-8)`,
        display: 'flex',
        flexDirection: 'column',
        gap: S(3)
      }
    }, children);
  }
  function Onboarding({
    variant
  }) {
    let bar = {
      title: 'Welcome',
      subtitle: 'MemoX'
    };
    let body;
    if (variant === 'welcome') {
      body = /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        solid: true,
        icon: "graduation-cap",
        tint: "var(--memox-primary)",
        title: "Welcome to MemoX",
        desc: "Make a deck, study a little each day, and let spaced repetition do the rest."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "plus",
        full: true
      }, "Create first deck"), /*#__PURE__*/React.createElement(PillBtn, {
        variant: "secondary",
        icon: "download",
        full: true
      }, "Import a deck")), REASSURE.map(r => /*#__PURE__*/React.createElement(InfoRow, _extends({
        key: r.title
      }, r))));
    } else if (variant === 'zero') {
      bar = {
        title: 'MemoX',
        subtitle: 'No decks yet'
      };
      body = /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        solid: true,
        icon: "layers",
        tint: "var(--memox-primary)",
        title: "No decks yet",
        desc: "Your library is empty. Create your first deck to start studying."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "plus",
        full: true
      }, "Create first deck"), /*#__PURE__*/React.createElement(PillBtn, {
        variant: "outline",
        icon: "download",
        full: true
      }, "Import a deck")));
    } else if (variant === 'create') {
      bar = {
        title: 'New deck',
        subtitle: 'Step 1 of 2'
      };
      body = /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: S(6)
        }
      }, /*#__PURE__*/React.createElement("span", {
        className: "tile-lg tonal",
        style: {
          '--tile': 'var(--memox-primary)',
          margin: `0 auto ${S(4)}`
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "folder-plus"
      })), /*#__PURE__*/React.createElement("div", {
        style: {
          textAlign: 'center',
          fontSize: 'var(--memox-size-h1)',
          fontWeight: 'var(--memox-weight-extrabold)',
          color: 'var(--memox-text-primary)',
          marginBottom: S(5)
        }
      }, "Name your deck"), /*#__PURE__*/React.createElement("div", {
        className: "ov",
        style: {
          marginBottom: S(2)
        }
      }, "DECK NAME"), /*#__PURE__*/React.createElement("input", {
        className: "field",
        defaultValue: "Japanese \xB7 N5",
        placeholder: "e.g. Spanish verbs"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          marginTop: S(5),
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "check",
        full: true
      }, "Create deck"), /*#__PURE__*/React.createElement(PillBtn, {
        variant: "outline",
        full: true
      }, "Cancel"))));
    } else if (variant === 'import') {
      bar = {
        title: 'Import a deck',
        subtitle: 'Choose a source'
      };
      body = /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        solid: true,
        icon: "download",
        tint: "var(--memox-status-new)",
        title: "Import a deck",
        desc: "Bring cards in from a file or straight from your clipboard."
      }), [{
        icon: 'file-up',
        tint: 'var(--memox-status-new)',
        title: 'From a file',
        desc: 'CSV, TSV or .apkg'
      }, {
        icon: 'clipboard-paste',
        tint: 'var(--memox-status-reviewing)',
        title: 'From clipboard',
        desc: 'Paste tab-separated rows'
      }].map(o => /*#__PURE__*/React.createElement(InfoRow, _extends({
        key: o.title
      }, o, {
        trail: /*#__PURE__*/React.createElement("span", {
          className: "list-row-trail"
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "chevron-right"
        }))
      }))));
    } else if (variant === 'signing') {
      bar = {
        title: 'Sign in',
        subtitle: 'MemoX'
      };
      body = /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: S(8),
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: S(4)
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "spinner"
      }), /*#__PURE__*/React.createElement("div", {
        className: "title",
        style: {
          fontSize: 'var(--memox-size-h2)'
        }
      }, "Signing in\u2026"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-label-large)',
          textAlign: 'center'
        }
      }, "Connecting to your Google account")));
    } else if (variant === 'restore-prompt') {
      bar = {
        title: 'Backup found',
        subtitle: 'Google Drive'
      };
      body = /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "cloud-download",
        tint: "var(--memox-status-new)",
        title: "Restore your decks?",
        desc: /*#__PURE__*/React.createElement("span", null, "We found a backup from ", /*#__PURE__*/React.createElement("b", {
          style: {
            color: 'var(--memox-text-primary)'
          }
        }, "2 days ago"), " \xB7 4 decks \xB7 405 cards.")
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "cloud-download",
        full: true
      }, "Restore backup"), /*#__PURE__*/React.createElement(PillBtn, {
        variant: "outline",
        full: true
      }, "Start fresh")));
    } else if (variant === 'restoring') {
      bar = {
        title: 'Restoring',
        subtitle: 'Google Drive'
      };
      body = /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: S(6)
        }
      }, /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3),
          marginBottom: S(4)
        }
      }, /*#__PURE__*/React.createElement("span", {
        className: "tile-lg tonal",
        style: {
          '--tile': 'var(--memox-status-new)'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "cloud-download"
      })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
        className: "title",
        style: {
          fontSize: 'var(--memox-size-h2)'
        }
      }, "Restoring backup"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-body-small)'
        }
      }, "142 / 405 cards"))), /*#__PURE__*/React.createElement("div", {
        className: "progress"
      }, /*#__PURE__*/React.createElement("div", {
        className: "progress-fill",
        style: {
          width: '35%'
        }
      })), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-body-small)',
          marginTop: S(2),
          textAlign: 'right'
        }
      }, "35%")));
    } else if (variant === 'restore-failed') {
      bar = {
        title: 'Restore failed',
        subtitle: 'Google Drive'
      };
      body = /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "cloud-off",
        tint: "var(--memox-danger)",
        title: "Couldn't restore",
        desc: "The connection dropped at 35%. You can try again or skip for now."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "rotate-ccw",
        full: true
      }, "Try again"), /*#__PURE__*/React.createElement(PillBtn, {
        variant: "outline",
        full: true
      }, "Skip")));
    } else {
      // import-handoff
      bar = {
        title: 'Import a deck',
        subtitle: 'Handing off'
      };
      body = /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        solid: true,
        icon: "arrow-right-left",
        tint: "var(--memox-status-reviewing)",
        title: "Open the importer",
        desc: "We'll take you to the import flow to map fields and pick a deck."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        iconRight: "arrow-right",
        full: true
      }, "Continue to import"), /*#__PURE__*/React.createElement(PillBtn, {
        variant: "outline",
        full: true
      }, "Back")));
    }
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(AppBar, {
      title: bar.title,
      subtitle: bar.subtitle
    }), body);
  }
  if (!window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  window.MEMOX_KIT.register({
    num: '01',
    title: 'Onboarding',
    states: [{
      label: 'Welcome',
      render: () => /*#__PURE__*/React.createElement(Onboarding, {
        variant: "welcome"
      })
    }, {
      label: 'Zero state',
      render: () => /*#__PURE__*/React.createElement(Onboarding, {
        variant: "zero"
      })
    }, {
      label: 'Create deck',
      render: () => /*#__PURE__*/React.createElement(Onboarding, {
        variant: "create"
      })
    }, {
      label: 'Deck for import',
      render: () => /*#__PURE__*/React.createElement(Onboarding, {
        variant: "import"
      })
    }, {
      label: 'Signing in',
      render: () => /*#__PURE__*/React.createElement(Onboarding, {
        variant: "signing"
      })
    }, {
      label: 'Restore prompt',
      render: () => /*#__PURE__*/React.createElement(Onboarding, {
        variant: "restore-prompt"
      })
    }, {
      label: 'Restoring',
      render: () => /*#__PURE__*/React.createElement(Onboarding, {
        variant: "restoring"
      })
    }, {
      label: 'Restore failed',
      render: () => /*#__PURE__*/React.createElement(Onboarding, {
        variant: "restore-failed"
      })
    }, {
      label: 'Import handoff',
      render: () => /*#__PURE__*/React.createElement(Onboarding, {
        variant: "import-handoff"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/01-onboarding.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/02-dashboard.jsx
try { (() => {
/* MemoX screen — 02 Dashboard (8 states). A QUIET overview hub — not the study
   nag screen. It answers "how am I doing today, what's active, anything worth a
   look?" with a neutral stat strip + a light due snapshot + recent decks + a
   shortcut into Progress. The heavy lifting (goal ring, streak pressure, study
   insights, trends) lives on Progress/Stats — the dashboard only refers to work,
   it never pressures the user to study now. Token-driven; composes shared
   primitives (single source of truth in screens/_shared.jsx). */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    TileLg,
    Progress,
    ListRow,
    StatSummary,
    DueSummary,
    ShortcutRow,
    HeroCard,
    Banner,
    BottomNav,
    Sk
  } = window.MX;

  // ---- Header --------------------------------------------------------------
  const Header = () => /*#__PURE__*/React.createElement("div", {
    className: "appbar-lg"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      width: '100%',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "appbar-titles"
  }, /*#__PURE__*/React.createElement("div", {
    className: "appbar-subtitle"
  }, "Thursday, 19 June"), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title"
  }, "Good evening, An")), /*#__PURE__*/React.createElement("span", {
    className: "spacer"
  }), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Settings"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "settings"
  }))));

  // ---- Continue studying (only when a session is paused) -------------------
  const ResumeCard = ({
    multi
  }) => /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      marginBottom: S(2)
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "status-dot",
    style: {
      '--dot': 'var(--memox-primary)'
    }
  }), "CONTINUE STUDYING"), /*#__PURE__*/React.createElement("div", {
    className: "card"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(3),
      marginBottom: S(3)
    }
  }, /*#__PURE__*/React.createElement(TileLg, {
    icon: "pause",
    tint: "var(--memox-primary)",
    solid: true
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "title",
    style: {
      fontSize: 'var(--memox-size-h2)'
    }
  }, "Japanese \xB7 N5"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)'
    }
  }, "Recall \xB7 7/20 cards \xB7 paused 32m ago"))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: S(4)
    }
  }, /*#__PURE__*/React.createElement(Progress, {
    value: 35
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "pill-btn secondary",
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "play"
  }), "Resume"), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn outline"
  }, "Discard")), multi && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'center',
      marginTop: S(3)
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "chip"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "pause"
  }), "+2 sessions paused"))));

  // ---- Recent decks --------------------------------------------------------
  const DECKS = [{
    icon: 'languages',
    tint: 'var(--memox-status-new)',
    name: 'Japanese · N5',
    meta: '142 cards · last 2h ago',
    due: 23
  }, {
    icon: 'flask-conical',
    tint: 'var(--memox-status-learning)',
    name: 'Organic chemistry',
    meta: '120 cards · last 1d ago',
    due: 8
  }, {
    icon: 'landmark',
    tint: 'var(--memox-status-reviewing)',
    name: 'World capitals',
    meta: '195 cards · last 3d ago',
    due: 2
  }];
  const DeckList = () => /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "section-head",
    style: {
      marginBottom: S(2)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "ov"
  }, "RECENT DECKS"), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn ghost sm"
  }, "Library", /*#__PURE__*/React.createElement(Icon, {
    name: "chevron-right"
  }))), /*#__PURE__*/React.createElement("div", {
    className: "list-card"
  }, DECKS.map((d, i) => /*#__PURE__*/React.createElement("div", {
    key: d.name
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr inset"
  }), /*#__PURE__*/React.createElement(ListRow, {
    icon: d.icon,
    color: d.tint,
    title: d.name,
    meta: d.meta,
    due: d.due
  })))));

  // Quiet shortcut into the analysis hub.
  const ProgressShortcut = () => /*#__PURE__*/React.createElement(ShortcutRow, {
    icon: "trending-up",
    label: "See learning stats",
    sub: "Goal, streak, trends & weak decks"
  });

  // ---- Assembled screen ----------------------------------------------------
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${S(2)} var(--memox-space-screen) var(--memox-space-6)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);
  function Dashboard({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Header, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          gap: S(2)
        }
      }, [0, 1, 2, 3].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: S(2),
          padding: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "22px",
        w: "60%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "70%"
      })))), /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "45%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "65%"
      }))), /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: `${S(2)} var(--memox-space-card)`,
          display: 'flex',
          flexDirection: 'column',
          gap: S(4)
        }
      }, [0, 1, 2].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "55%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "40%"
      })))))), /*#__PURE__*/React.createElement(BottomNav, null));
    }
    if (variant === 'onboarding') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Header, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        solid: true,
        icon: "graduation-cap",
        tint: "var(--memox-primary)",
        title: "Nothing here yet",
        desc: "Create your first deck and your overview fills up here."
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "plus"
      }), "Create first deck"), /*#__PURE__*/React.createElement("button", {
        className: "pill-btn outline",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "download"
      }), "Import a deck"))), /*#__PURE__*/React.createElement(BottomNav, null));
    }
    if (variant === 'error') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Header, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "alert-triangle",
        tint: "var(--memox-danger)",
        title: "Couldn't load today",
        desc: "Something went wrong fetching your overview."
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "rotate-ccw"
      }), "Retry"))), /*#__PURE__*/React.createElement(BottomNav, null));
    }

    // Data states: loaded / no-session / caught-up / multi-resume / offline
    const caughtUp = variant === 'caught-up';
    const hasSession = variant === 'loaded' || variant === 'multi-resume' || variant === 'offline';
    const multi = variant === 'multi-resume';

    // Overview stat strip — neutral snapshot, not a goal/streak nag. "Due" is the
    // one accented metric so it reads as the notable number without pressure.
    const stats = caughtUp ? [['0', 'Due'], ['9', 'Decks'], ['86%', 'Accuracy'], ['11', 'Streak']] : [['23', 'Due', true], ['9', 'Decks'], ['86%', 'Accuracy'], ['11', 'Streak']];
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(Header, null), /*#__PURE__*/React.createElement(Body, null, variant === 'offline' && /*#__PURE__*/React.createElement(Banner, {
      tone: "info",
      icon: "cloud-off"
    }, "You're offline \u2014 showing cached cards."), /*#__PURE__*/React.createElement(StatSummary, {
      stats: stats
    }), hasSession && /*#__PURE__*/React.createElement(ResumeCard, {
      multi: multi
    }), /*#__PURE__*/React.createElement(DueSummary, {
      count: 23,
      decks: 3,
      minutes: 14,
      caughtUp: caughtUp
    }), /*#__PURE__*/React.createElement(DeckList, null), /*#__PURE__*/React.createElement(ProgressShortcut, null)), /*#__PURE__*/React.createElement(BottomNav, null));
  }
  window.MEMOX_KIT.register({
    num: '02',
    title: 'Dashboard',
    states: [{
      label: 'Loaded',
      render: () => /*#__PURE__*/React.createElement(Dashboard, {
        variant: "loaded"
      })
    }, {
      label: 'No session',
      render: () => /*#__PURE__*/React.createElement(Dashboard, {
        variant: "no-session"
      })
    }, {
      label: 'Caught up',
      render: () => /*#__PURE__*/React.createElement(Dashboard, {
        variant: "caught-up"
      })
    }, {
      label: 'Multi resume',
      render: () => /*#__PURE__*/React.createElement(Dashboard, {
        variant: "multi-resume"
      })
    }, {
      label: 'Onboarding',
      render: () => /*#__PURE__*/React.createElement(Dashboard, {
        variant: "onboarding"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Dashboard, {
        variant: "loading"
      })
    }, {
      label: 'Offline',
      render: () => /*#__PURE__*/React.createElement(Dashboard, {
        variant: "offline"
      })
    }, {
      label: 'Error',
      render: () => /*#__PURE__*/React.createElement(Dashboard, {
        variant: "error"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/02-dashboard.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/03-library.jsx
try { (() => {
/* MemoX screen — 03 Library overview (6 states). Top-level browser: shows the
   high-level FOLDER list (never raw decks). Token-driven; composes contract
   classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    ListRow,
    HeroCard,
    SearchDock,
    BottomNav,
    Fab,
    Sk
  } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const FOLDERS = [{
    icon: 'languages',
    tint: 'var(--memox-status-new)',
    name: 'Languages',
    meta: '4 decks · 412 cards'
  }, {
    icon: 'flask-conical',
    tint: 'var(--memox-status-learning)',
    name: 'Sciences',
    meta: '3 decks · 286 cards'
  }, {
    icon: 'landmark',
    tint: 'var(--memox-status-reviewing)',
    name: 'History & Geography',
    meta: '2 decks · 195 cards'
  }, {
    icon: 'briefcase',
    tint: 'var(--memox-status-mastered)',
    name: 'Work',
    meta: '5 decks · 320 cards'
  }, {
    icon: 'book-open',
    tint: 'var(--memox-primary)',
    name: 'Literature',
    meta: '1 deck · 64 cards'
  }];

  // ---- App bars ------------------------------------------------------------
  const TitleBar = () => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("span", {
    className: "appbar-title"
  }, "Library"), /*#__PURE__*/React.createElement("span", {
    className: "spacer"
  }), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Sort"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-up-down"
  })));
  const SearchBar = ({
    query
  }) => /*#__PURE__*/React.createElement(SearchDock, {
    query: query,
    placeholder: "Search folders"
  });

  // ---- List card -----------------------------------------------------------
  const FolderCard = ({
    items
  }) => /*#__PURE__*/React.createElement("div", {
    className: "list-card"
  }, items.map((f, i) => /*#__PURE__*/React.createElement("div", {
    key: f.name
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr inset"
  }), /*#__PURE__*/React.createElement(ListRow, {
    icon: f.icon,
    color: f.tint,
    title: f.name,
    meta: f.meta
  }))));

  // ---- Bottom sheet (overflow actions for one folder) ----------------------
  const SheetRow = ({
    icon,
    label,
    danger
  }) => /*#__PURE__*/React.createElement("button", {
    className: "list-row",
    style: {
      width: '100%',
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      padding: `${S(3)} 0`,
      textAlign: 'left'
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "icon-tile",
    style: {
      '--tile': danger ? 'var(--memox-danger)' : 'var(--memox-text-secondary)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: icon
  })), /*#__PURE__*/React.createElement("span", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("span", {
    className: "list-row-title",
    style: danger ? {
      color: 'var(--memox-danger)'
    } : undefined
  }, label)));
  const OverflowSheet = () => /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      zIndex: 20,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'flex-end'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "scrim"
  }), /*#__PURE__*/React.createElement("div", {
    className: "sheet",
    style: {
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "sheet-grabber"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row",
    style: {
      padding: `0 0 ${S(2)}`
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "icon-tile",
    style: {
      '--tile': 'var(--memox-status-new)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "languages"
  })), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title"
  }, "Languages"), /*#__PURE__*/React.createElement("div", {
    className: "list-row-meta"
  }, "4 decks \xB7 412 cards"))), /*#__PURE__*/React.createElement("div", {
    className: "hr",
    style: {
      margin: `${S(2)} 0`
    }
  }), /*#__PURE__*/React.createElement(SheetRow, {
    icon: "pencil",
    label: "Rename"
  }), /*#__PURE__*/React.createElement(SheetRow, {
    icon: "folder-input",
    label: "Move to\u2026"
  }), /*#__PURE__*/React.createElement(SheetRow, {
    icon: "trash-2",
    label: "Delete folder",
    danger: true
  })));

  // ---- Assembled screen ----------------------------------------------------
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${S(3)} var(--memox-space-screen) var(--memox-space-10)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);
  const FabSlot = () => /*#__PURE__*/React.createElement(Fab, {
    icon: "folder-plus",
    label: "New folder",
    style: {
      position: 'absolute',
      right: S(5),
      bottom: `calc(var(--memox-size-bottom-nav) + ${S(4)})`,
      zIndex: 5
    }
  });
  function Library({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(TitleBar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: `${S(2)} var(--memox-space-card)`,
          display: 'flex',
          flexDirection: 'column',
          gap: S(4)
        }
      }, [0, 1, 2, 3].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "55%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "38%"
      })))))), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }));
    }
    if (variant === 'empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(TitleBar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        solid: true,
        icon: "folder-open",
        tint: "var(--memox-primary)",
        title: "No folders yet",
        desc: "Folders keep your decks tidy by subject. Create your first to get started."
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "folder-plus"
      }), "Create folder"))), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }));
    }
    if (variant === 'error') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(TitleBar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "alert-triangle",
        tint: "var(--memox-danger)",
        title: "Couldn't load library",
        desc: "We couldn't reach your folders. Check your connection and try again."
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "rotate-ccw"
      }), "Retry"))), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }));
    }
    if (variant === 'search') {
      const results = FOLDERS.filter(f => /lang|sci/i.test(f.name));
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(TitleBar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        className: "ov"
      }, "2 folders"), /*#__PURE__*/React.createElement(FolderCard, {
        items: results
      })), /*#__PURE__*/React.createElement(SearchBar, {
        query: "la"
      }), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }));
    }
    if (variant === 'overflow') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(TitleBar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(FolderCard, {
        items: FOLDERS
      })), /*#__PURE__*/React.createElement(FabSlot, null), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }), /*#__PURE__*/React.createElement(OverflowSheet, null));
    }

    // loaded
    return /*#__PURE__*/React.createElement("div", {
      className: "app",
      style: {
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement(TitleBar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(FolderCard, {
      items: FOLDERS
    })), /*#__PURE__*/React.createElement(FabSlot, null), /*#__PURE__*/React.createElement(BottomNav, {
      active: "Library"
    }));
  }
  window.MEMOX_KIT.register({
    num: '03',
    title: 'Library overview',
    states: [{
      label: 'Loaded',
      render: () => /*#__PURE__*/React.createElement(Library, {
        variant: "loaded"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Library, {
        variant: "loading"
      })
    }, {
      label: 'Empty',
      render: () => /*#__PURE__*/React.createElement(Library, {
        variant: "empty"
      })
    }, {
      label: 'Search',
      render: () => /*#__PURE__*/React.createElement(Library, {
        variant: "search"
      })
    }, {
      label: 'Overflow sheet',
      render: () => /*#__PURE__*/React.createElement(Library, {
        variant: "overflow"
      })
    }, {
      label: 'Error',
      render: () => /*#__PURE__*/React.createElement(Library, {
        variant: "error"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/03-library.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/04-folder.jsx
try { (() => {
/* MemoX screen — 04 Folder detail (8 states). The children of one folder —
   EITHER subfolders OR decks (never mixed) — with a scope summary, create FAB
   and overflow. Token-driven; composes contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    Breadcrumb,
    TileLg,
    ListRow,
    StatSummary,
    ListGroup,
    HeroCard,
    EmptyState,
    SearchDock,
    BottomNav,
    Fab,
    Sk
  } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const DECKS = [{
    icon: 'languages',
    tint: 'var(--memox-status-new)',
    name: 'Japanese · N5',
    meta: '142 cards · last 2h ago',
    due: 23
  }, {
    icon: 'book-marked',
    tint: 'var(--memox-status-reviewing)',
    name: 'Spanish verbs',
    meta: '96 cards · last 1d ago',
    due: 8
  }, {
    icon: 'book-open-text',
    tint: 'var(--memox-status-learning)',
    name: 'French basics',
    meta: '74 cards · last 4d ago',
    due: 0
  }];
  const SUBFOLDERS = [{
    icon: 'folder',
    tint: 'var(--memox-status-new)',
    name: 'East Asian',
    meta: '2 decks · 238 cards'
  }, {
    icon: 'folder',
    tint: 'var(--memox-status-reviewing)',
    name: 'Romance',
    meta: '3 decks · 174 cards'
  }];
  const MOVE_TARGETS = [{
    icon: 'languages',
    name: 'Languages',
    sel: false
  }, {
    icon: 'flask-conical',
    name: 'Sciences',
    sel: true
  }, {
    icon: 'landmark',
    name: 'History & Geography',
    sel: false
  }, {
    icon: 'briefcase',
    name: 'Work',
    sel: false
  }];

  // ---- App bar -------------------------------------------------------------
  const Bar = ({
    title
  }) => /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      minWidth: 0,
      marginLeft: S(2),
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, title), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "More"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "more-vertical"
  }))), /*#__PURE__*/React.createElement(Breadcrumb, {
    items: [{
      label: 'Library',
      icon: 'library'
    }, {
      label: title,
      current: true
    }]
  }));
  const SearchBar = ({
    query
  }) => /*#__PURE__*/React.createElement(SearchDock, {
    query: query,
    placeholder: "Search this folder"
  });

  // ---- Delete confirm dialog ----------------------------------------------
  const DeleteDialog = () => /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      zIndex: 20,
      display: 'grid',
      placeItems: 'center',
      padding: 'var(--memox-space-6)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "scrim"
  }), /*#__PURE__*/React.createElement("div", {
    className: "dialog",
    style: {
      position: 'relative',
      width: '100%'
    }
  }, /*#__PURE__*/React.createElement(TileLg, {
    icon: "trash-2",
    tint: "var(--memox-danger)",
    style: {
      margin: `0 0 ${S(4)}`
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--memox-size-h1)',
      fontWeight: 'var(--memox-weight-extrabold)',
      color: 'var(--memox-text-primary)',
      letterSpacing: 'var(--memox-tracking-tight)'
    }
  }, "Delete \u201CLanguages\u201D?"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      lineHeight: 1.5,
      marginTop: S(2)
    }
  }, "This removes the folder and its ", /*#__PURE__*/React.createElement("b", {
    style: {
      color: 'var(--memox-text-primary)'
    }
  }, "4 decks \xB7 412 cards"), ". This can't be undone."), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: S(2),
      marginTop: S(5)
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "pill-btn outline",
    style: {
      flex: 1
    }
  }, "Cancel"), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn danger",
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "trash-2"
  }), "Delete"))));

  // ---- Move bottom sheet ---------------------------------------------------
  const MoveSheet = () => /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      zIndex: 20,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'flex-end'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "scrim"
  }), /*#__PURE__*/React.createElement("div", {
    className: "sheet",
    style: {
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "sheet-grabber"
  }), /*#__PURE__*/React.createElement("div", {
    className: "section-head",
    style: {
      marginBottom: S(3)
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "section-head-title"
  }, "Move to folder")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column'
    }
  }, MOVE_TARGETS.map((t, i) => /*#__PURE__*/React.createElement("div", {
    key: t.name
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row"
  }, /*#__PURE__*/React.createElement("span", {
    className: "icon-tile",
    style: {
      '--tile': 'var(--memox-text-secondary)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: t.icon
  })), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title"
  }, t.name)), /*#__PURE__*/React.createElement("span", {
    className: "list-row-trail",
    style: t.sel ? {
      color: 'var(--memox-primary)'
    } : {
      color: 'var(--memox-outline-variant)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: t.sel ? 'check-circle-2' : 'circle'
  })))))), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn primary",
    style: {
      width: '100%',
      marginTop: S(5)
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "folder-input"
  }), "Move here")));

  // ---- Assembled screen ----------------------------------------------------
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${S(3)} var(--memox-space-screen) var(--memox-space-10)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);
  const FabSlot = ({
    icon = 'plus'
  }) => /*#__PURE__*/React.createElement(Fab, {
    icon: icon,
    label: "Create",
    style: {
      position: 'absolute',
      right: S(5),
      bottom: `calc(var(--memox-size-bottom-nav) + ${S(4)})`,
      zIndex: 5
    }
  });
  function Folder({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Languages"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(Sk, {
        h: "64px",
        r: "var(--memox-radius-card)"
      }), /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: `${S(2)} var(--memox-space-card)`,
          display: 'flex',
          flexDirection: 'column',
          gap: S(4)
        }
      }, [0, 1, 2].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "55%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "40%"
      })))))), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }));
    }
    if (variant === 'error') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Folder"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "folder-x",
        tint: "var(--memox-danger)",
        title: "Folder not found",
        desc: "This folder may have been moved or deleted."
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "arrow-left"
      }), "Back to library"))), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }));
    }
    if (variant === 'unlocked') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Languages"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        solid: true,
        icon: "folder-open",
        tint: "var(--memox-primary)",
        title: "Empty folder",
        desc: "Add a deck of cards, or nest a subfolder to keep things organized."
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "layers"
      }), "Create deck"), /*#__PURE__*/React.createElement("button", {
        className: "pill-btn outline",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "folder-plus"
      }), "Create subfolder"))), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }));
    }
    if (variant === 'search-empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Languages"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(EmptyState, {
        icon: "search-x",
        pad: 10,
        title: "No matches in this folder",
        desc: 'Nothing here matches “kanji”.'
      })), /*#__PURE__*/React.createElement(SearchBar, {
        query: "kanji"
      }), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }));
    }
    if (variant === 'subfolders') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Languages"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(StatSummary, {
        stats: [['2', 'Subfolders'], ['5', 'Decks'], ['31', 'Due', true]]
      }), /*#__PURE__*/React.createElement(ListGroup, {
        heading: "Folders",
        items: SUBFOLDERS,
        kind: "folder"
      })), /*#__PURE__*/React.createElement(FabSlot, {
        icon: "folder-plus"
      }), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }));
    }
    if (variant === 'delete' || variant === 'move') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Languages"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(StatSummary, {
        stats: [['3', 'Decks'], ['312', 'Cards'], ['31', 'Due', true]]
      }), /*#__PURE__*/React.createElement(ListGroup, {
        heading: "Decks",
        items: DECKS,
        kind: "deck"
      })), /*#__PURE__*/React.createElement(FabSlot, {
        icon: "layers"
      }), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Library"
      }), variant === 'delete' ? /*#__PURE__*/React.createElement(DeleteDialog, null) : /*#__PURE__*/React.createElement(MoveSheet, null));
    }

    // decks
    return /*#__PURE__*/React.createElement("div", {
      className: "app",
      style: {
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement(Bar, {
      title: "Languages"
    }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(StatSummary, {
      stats: [['3', 'Decks'], ['312', 'Cards'], ['31', 'Due', true]]
    }), /*#__PURE__*/React.createElement(ListGroup, {
      heading: "Decks",
      items: DECKS,
      kind: "deck"
    })), /*#__PURE__*/React.createElement(FabSlot, {
      icon: "layers"
    }), /*#__PURE__*/React.createElement(BottomNav, {
      active: "Library"
    }));
  }
  window.MEMOX_KIT.register({
    num: '04',
    title: 'Folder detail',
    states: [{
      label: 'Decks',
      render: () => /*#__PURE__*/React.createElement(Folder, {
        variant: "decks"
      })
    }, {
      label: 'Subfolders',
      render: () => /*#__PURE__*/React.createElement(Folder, {
        variant: "subfolders"
      })
    }, {
      label: 'Empty / unlocked',
      render: () => /*#__PURE__*/React.createElement(Folder, {
        variant: "unlocked"
      })
    }, {
      label: 'Search empty',
      render: () => /*#__PURE__*/React.createElement(Folder, {
        variant: "search-empty"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Folder, {
        variant: "loading"
      })
    }, {
      label: 'Error',
      render: () => /*#__PURE__*/React.createElement(Folder, {
        variant: "error"
      })
    }, {
      label: 'Delete confirm',
      render: () => /*#__PURE__*/React.createElement(Folder, {
        variant: "delete"
      })
    }, {
      label: 'Move sheet',
      render: () => /*#__PURE__*/React.createElement(Folder, {
        variant: "move"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/04-folder.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/05-search.jsx
try { (() => {
/* MemoX screen — 05 Library search (5 states). Global search across folders,
   decks and flashcards; results grouped by type. Token-driven; composes
   contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    PillBtn,
    ListRow,
    SectionHead,
    HeroCard,
    EmptyState,
    SearchDock,
    BottomNav,
    Sk
  } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const FOLDER_HITS = [{
    icon: 'languages',
    tint: 'var(--memox-status-new)',
    name: 'Languages',
    meta: '4 decks · 412 cards'
  }];
  const DECK_HITS = [{
    icon: 'languages',
    tint: 'var(--memox-status-new)',
    name: 'Japanese · N5',
    meta: 'Languages · 142 cards',
    due: 23
  }, {
    icon: 'languages',
    tint: 'var(--memox-status-reviewing)',
    name: 'Japanese · N4',
    meta: 'Languages · 88 cards',
    due: 5
  }];
  const CARD_HITS = [{
    icon: 'square-stack',
    tint: 'var(--memox-status-learning)',
    front: '日本 — Japan',
    meta: 'Japanese · N5'
  }, {
    icon: 'square-stack',
    tint: 'var(--memox-status-learning)',
    front: '日曜日 — Sunday',
    meta: 'Japanese · N5'
  }, {
    icon: 'square-stack',
    tint: 'var(--memox-status-reviewing)',
    front: '本 — book',
    meta: 'Japanese · N4'
  }];
  const RECENT = ['Japanese', 'verbs', 'capitals', 'N5 kanji'];
  const POPULAR = [{
    icon: 'flame',
    tint: 'var(--memox-status-learning)',
    name: 'Due today',
    meta: 'Across all decks'
  }, {
    icon: 'sparkles',
    tint: 'var(--memox-status-new)',
    name: 'Recently added',
    meta: 'New cards this week'
  }];

  // ---- Result group --------------------------------------------------------
  const Group = ({
    title,
    count,
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement(SectionHead, {
    title: title,
    action: /*#__PURE__*/React.createElement("span", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-label-medium)',
        fontWeight: 'var(--memox-weight-bold)'
      }
    }, count)
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-card"
  }, children));
  const Rows = ({
    items,
    render
  }) => /*#__PURE__*/React.createElement(React.Fragment, null, items.map((it, i) => /*#__PURE__*/React.createElement("div", {
    key: i
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr inset"
  }), render(it))));

  // ---- Assembled screen ----------------------------------------------------
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-10)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);

  // Search is a primary bottom-nav destination, so every state renders the SAME
  // shell — search field + BottomNav with `Search` active — and only the body
  // content changes per variant. One source of truth keeps the tab's active
  // state in sync no matter which state is shown. `query` seeds the field.
  function Search({
    variant
  }) {
    let query = 'japan';
    let content;
    if (variant === 'empty') {
      query = '';
      content = /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "ov"
      }, "Recent searches"), /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          flexWrap: 'wrap',
          gap: S(2)
        }
      }, RECENT.map(r => /*#__PURE__*/React.createElement("span", {
        key: r,
        className: "chip",
        style: {
          cursor: 'pointer'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "clock"
      }), r)))), /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "ov"
      }, "Jump to"), /*#__PURE__*/React.createElement("div", {
        className: "list-card"
      }, /*#__PURE__*/React.createElement(Rows, {
        items: POPULAR,
        render: p => /*#__PURE__*/React.createElement(ListRow, {
          icon: p.icon,
          color: p.tint,
          title: p.name,
          meta: p.meta
        })
      }))));
    } else if (variant === 'loading') {
      content = /*#__PURE__*/React.createElement(React.Fragment, null, [0, 1].map(g => /*#__PURE__*/React.createElement("div", {
        key: g,
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "13px",
        w: "30%"
      }), /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: `${S(2)} var(--memox-space-card)`,
          display: 'flex',
          flexDirection: 'column',
          gap: S(4)
        }
      }, [0, 1].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "60%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "42%"
      }))))))));
    } else if (variant === 'no-results') {
      query = 'zxqv';
      content = /*#__PURE__*/React.createElement(EmptyState, {
        icon: "search-x",
        pad: 12,
        title: "No results",
        desc: 'Nothing matches “zxqv”. Try a different word or check the spelling.'
      });
    } else if (variant === 'error') {
      content = /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'grid',
          placeItems: 'center'
        }
      }, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "alert-triangle",
        tint: "var(--memox-danger)",
        title: "Search failed",
        desc: "We couldn't run that search just now."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "rotate-ccw",
        full: true
      }, "Try again")));
    } else {
      // results
      content = /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Group, {
        title: "Folders",
        count: "1"
      }, /*#__PURE__*/React.createElement(Rows, {
        items: FOLDER_HITS,
        render: f => /*#__PURE__*/React.createElement(ListRow, {
          icon: f.icon,
          color: f.tint,
          title: f.name,
          meta: f.meta
        })
      })), /*#__PURE__*/React.createElement(Group, {
        title: "Decks",
        count: "2"
      }, /*#__PURE__*/React.createElement(Rows, {
        items: DECK_HITS,
        render: d => /*#__PURE__*/React.createElement(ListRow, {
          icon: d.icon,
          color: d.tint,
          title: d.name,
          meta: d.meta,
          due: d.due
        })
      })), /*#__PURE__*/React.createElement(Group, {
        title: "Flashcards",
        count: "3"
      }, /*#__PURE__*/React.createElement(Rows, {
        items: CARD_HITS,
        render: c => /*#__PURE__*/React.createElement(ListRow, {
          icon: c.icon,
          color: c.tint,
          title: c.front,
          meta: c.meta
        })
      })));
    }
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement("div", {
      className: "appbar"
    }, /*#__PURE__*/React.createElement("span", {
      className: "appbar-title"
    }, "Search")), /*#__PURE__*/React.createElement(Body, null, content), /*#__PURE__*/React.createElement(SearchDock, {
      query: query,
      placeholder: "Search everything"
    }), /*#__PURE__*/React.createElement(BottomNav, {
      active: "Search"
    }));
  }
  window.MEMOX_KIT.register({
    num: '05',
    title: 'Library search',
    states: [{
      label: 'Results',
      render: () => /*#__PURE__*/React.createElement(Search, {
        variant: "results"
      })
    }, {
      label: 'Empty',
      render: () => /*#__PURE__*/React.createElement(Search, {
        variant: "empty"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Search, {
        variant: "loading"
      })
    }, {
      label: 'No results',
      render: () => /*#__PURE__*/React.createElement(Search, {
        variant: "no-results"
      })
    }, {
      label: 'Error',
      render: () => /*#__PURE__*/React.createElement(Search, {
        variant: "error"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/05-search.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/06-flashcard-list.jsx
try { (() => {
/* MemoX screen — 06 Flashcard list (8 states). The cards inside one deck:
   create / edit / delete / reorder. App bar (deck name + back + search + deck
   overflow) · list of card rows (front + SRS box/status meta + chevron) · FAB
   add card. Bottom nav hidden (sub-screen). Token-driven; composes contract
   classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    PillBtn,
    Chip,
    IconTile,
    TileLg,
    ListRow,
    HeroCard,
    EmptyState,
    Breadcrumb,
    SearchDock,
    Fab,
    Sk,
    Modal,
    Sheet
  } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const STATUS_TINT = {
    new: 'var(--memox-status-new)',
    learning: 'var(--memox-status-learning)',
    reviewing: 'var(--memox-status-reviewing)',
    mastered: 'var(--memox-status-mastered)'
  };
  const CARDS = [{
    front: '日本 — Japan',
    meta: 'Box 4 · due in 3d',
    status: 'reviewing'
  }, {
    front: '日曜日 — Sunday',
    meta: 'Box 2 · due today',
    status: 'learning'
  }, {
    front: '本 — book',
    meta: 'New · not studied',
    status: 'new'
  }, {
    front: '水 — water',
    meta: 'Box 6 · mastered',
    status: 'mastered'
  }, {
    front: '火曜日 — Tuesday',
    meta: 'Box 3 · due in 1d',
    status: 'reviewing'
  }, {
    front: '山 — mountain',
    meta: 'Box 1 · due today',
    status: 'learning'
  }];
  const STATUS_LABEL = {
    new: 'New',
    learning: 'Learning',
    reviewing: 'Review',
    mastered: 'Mastered'
  };

  // ---- App bars ------------------------------------------------------------
  const Bar = ({
    title
  }) => /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      minWidth: 0,
      marginLeft: S(2),
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, title), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Deck options"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "more-vertical"
  }))), /*#__PURE__*/React.createElement(Breadcrumb, {
    items: [{
      label: 'Library',
      icon: 'library'
    }, {
      label: 'Languages'
    }, {
      label: title,
      current: true
    }]
  }));
  const ReorderBar = ({
    title
  }) => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Cancel"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "x"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      minWidth: 0,
      marginLeft: S(2),
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, "Reorder \xB7 ", title), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn primary sm"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "check"
  }), "Done"));
  const SearchBar = ({
    query
  }) => /*#__PURE__*/React.createElement(SearchDock, {
    query: query,
    placeholder: "Search cards"
  });

  // ---- Card row ------------------------------------------------------------
  const CardRow = ({
    c
  }) => /*#__PURE__*/React.createElement(ListRow, {
    icon: "square-stack",
    color: STATUS_TINT[c.status],
    title: c.front,
    meta: c.meta,
    trail: /*#__PURE__*/React.createElement(Chip, {
      status: c.status
    }, STATUS_LABEL[c.status])
  });
  const Body = ({
    children,
    pad
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${pad || S(3)} var(--memox-space-screen) var(--memox-space-12)`,
      display: 'flex',
      flexDirection: 'column',
      gap: S(3)
    }
  }, children);
  const FabSlot = () => /*#__PURE__*/React.createElement(Fab, {
    icon: "plus",
    label: "Add card",
    style: {
      position: 'absolute',
      right: S(5),
      bottom: `calc(var(--memox-size-search-dock) + ${S(4)})`,
      zIndex: 5
    }
  });

  // count summary strip above the list
  const CountStrip = ({
    total,
    due
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: `0 ${S(1)}`
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "ov"
  }, total, " cards"), /*#__PURE__*/React.createElement("span", {
    className: "chip due solid"
  }, due, " due"));
  function Screen({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Japanese \xB7 N5"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: `${S(2)} var(--memox-space-card)`,
          display: 'flex',
          flexDirection: 'column',
          gap: S(4)
        }
      }, [0, 1, 2, 3, 4].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "58%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "38%"
      })), /*#__PURE__*/React.createElement(Sk, {
        h: "22px",
        w: "56px",
        r: "var(--memox-radius-full)"
      }))))));
    }
    if (variant === 'error') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Japanese \xB7 N5"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'grid',
          placeItems: 'center'
        }
      }, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "cloud-off",
        tint: "var(--memox-danger)",
        title: "Couldn't load cards",
        desc: "Check your connection and try again."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "rotate-ccw",
        full: true
      }, "Retry")))));
    }
    if (variant === 'empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Japanese \xB7 N5"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'grid',
          placeItems: 'center'
        }
      }, /*#__PURE__*/React.createElement(HeroCard, {
        solid: true,
        icon: "square-stack",
        tint: "var(--memox-primary)",
        title: "No cards yet",
        desc: "Add your first flashcard, or import a set from a file."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "plus",
        full: true
      }, "Add card"), /*#__PURE__*/React.createElement(PillBtn, {
        variant: "outline",
        icon: "upload",
        full: true
      }, "Import cards")))));
    }
    if (variant === 'search-empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Japanese \xB7 N5"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(EmptyState, {
        icon: "search-x",
        pad: 10,
        title: "No cards match",
        desc: 'Nothing here matches “kanji”.'
      })), /*#__PURE__*/React.createElement(SearchBar, {
        query: "kanji"
      }));
    }
    if (variant === 'reorder') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app",
        style: {
          position: 'relative'
        }
      }, /*#__PURE__*/React.createElement(ReorderBar, {
        title: "Japanese \xB7 N5"
      }), /*#__PURE__*/React.createElement(Body, {
        pad: S(3)
      }, /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-body-small)',
          padding: `0 ${S(1)}`
        }
      }, "Drag the handles to reorder cards."), /*#__PURE__*/React.createElement("div", {
        className: "list-card"
      }, CARDS.slice(0, 5).map((c, i) => /*#__PURE__*/React.createElement("div", {
        key: i
      }, i > 0 && /*#__PURE__*/React.createElement("div", {
        className: "hr inset"
      }), /*#__PURE__*/React.createElement("div", {
        className: "list-row",
        style: i === 1 ? {
          background: 'color-mix(in srgb, var(--memox-primary) calc(var(--memox-op-selected) * 100%), transparent)'
        } : undefined
      }, /*#__PURE__*/React.createElement("span", {
        className: "icon-tile",
        style: {
          '--tile': STATUS_TINT[c.status]
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "square-stack"
      })), /*#__PURE__*/React.createElement("div", {
        className: "list-row-main"
      }, /*#__PURE__*/React.createElement("div", {
        className: "list-row-title"
      }, c.front), /*#__PURE__*/React.createElement("div", {
        className: "list-row-meta"
      }, c.meta)), /*#__PURE__*/React.createElement("span", {
        className: "list-row-trail",
        style: {
          color: 'var(--memox-text-3)',
          cursor: 'grab'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "grip-vertical"
      }))))))));
    }

    // loaded (+ delete-card / delete-deck overlays)
    const overlay = variant === 'delete-card' ? /*#__PURE__*/React.createElement(Modal, null, /*#__PURE__*/React.createElement(TileLg, {
      icon: "trash-2",
      tint: "var(--memox-danger)",
      style: {
        margin: `0 0 ${S(4)}`
      }
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-size-h1)',
        fontWeight: 'var(--memox-weight-extrabold)',
        color: 'var(--memox-text-primary)',
        letterSpacing: 'var(--memox-tracking-tight)'
      }
    }, "Delete this card?"), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-label-large)',
        lineHeight: 1.5,
        marginTop: S(2)
      }
    }, /*#__PURE__*/React.createElement("b", {
      style: {
        color: 'var(--memox-text-primary)'
      }
    }, "\u201C\u65E5\u672C \u2014 Japan\u201D"), " and its review history will be removed. This can't be undone."), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: S(2),
        marginTop: S(5)
      }
    }, /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline",
      style: {
        flex: 1
      }
    }, "Cancel"), /*#__PURE__*/React.createElement("button", {
      className: "pill-btn danger",
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "trash-2"
    }), "Delete"))) : variant === 'delete-deck' ? /*#__PURE__*/React.createElement(Modal, null, /*#__PURE__*/React.createElement(TileLg, {
      icon: "layers",
      tint: "var(--memox-danger)",
      style: {
        margin: `0 0 ${S(4)}`
      }
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-size-h1)',
        fontWeight: 'var(--memox-weight-extrabold)',
        color: 'var(--memox-text-primary)',
        letterSpacing: 'var(--memox-tracking-tight)'
      }
    }, "Delete \u201CJapanese \xB7 N5\u201D?"), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-label-large)',
        lineHeight: 1.5,
        marginTop: S(2)
      }
    }, "This deletes the whole deck and all ", /*#__PURE__*/React.createElement("b", {
      style: {
        color: 'var(--memox-text-primary)'
      }
    }, "142 cards"), " inside it. This can't be undone."), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: S(2),
        marginTop: S(5)
      }
    }, /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline",
      style: {
        flex: 1
      }
    }, "Cancel"), /*#__PURE__*/React.createElement("button", {
      className: "pill-btn danger",
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "trash-2"
    }), "Delete deck"))) : null;
    return /*#__PURE__*/React.createElement("div", {
      className: "app",
      style: {
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement(Bar, {
      title: "Japanese \xB7 N5"
    }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(CountStrip, {
      total: "142",
      due: "23"
    }), /*#__PURE__*/React.createElement("div", {
      className: "list-card"
    }, CARDS.map((c, i) => /*#__PURE__*/React.createElement("div", {
      key: i
    }, i > 0 && /*#__PURE__*/React.createElement("div", {
      className: "hr inset"
    }), /*#__PURE__*/React.createElement(CardRow, {
      c: c
    }))))), !overlay && /*#__PURE__*/React.createElement(FabSlot, null), /*#__PURE__*/React.createElement(SearchBar, {
      query: ""
    }), overlay);
  }
  window.MEMOX_KIT.register({
    num: '06',
    title: 'Flashcard list',
    states: [{
      label: 'Loaded',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loaded"
      })
    }, {
      label: 'Empty',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "empty"
      })
    }, {
      label: 'Search empty',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "search-empty"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loading"
      })
    }, {
      label: 'Error',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "error"
      })
    }, {
      label: 'Delete card',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "delete-card"
      })
    }, {
      label: 'Delete deck',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "delete-deck"
      })
    }, {
      label: 'Reorder',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "reorder"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/06-flashcard-list.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/07-flashcard-create.jsx
try { (() => {
/* MemoX screen — 07 Flashcard create (6 states). Create a new card: Front / Back
   faces plus an optional, collapsible Details area (deck, tags, note). App bar
   (title "New card" + back + Save). Token-driven; composes contract classes +
   shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    PillBtn,
    FormField,
    TextArea,
    Chip,
    Banner,
    PickerRow,
    Breadcrumb
  } = window.MX;

  // ---- App bar (back + title + Save) ---------------------------------------
  const Bar = ({
    canSave,
    saving
  }) => /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "x"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      minWidth: 0,
      marginLeft: S(2)
    }
  }, "New card"), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn primary sm",
    disabled: !canSave || saving,
    style: {
      minWidth: '76px'
    }
  }, saving ? /*#__PURE__*/React.createElement("span", {
    className: "spinner",
    style: {
      width: 'var(--memox-icon-sm)',
      height: 'var(--memox-icon-sm)',
      borderWidth: '2px'
    }
  }) : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Icon, {
    name: "check"
  }), "Save"))), /*#__PURE__*/React.createElement(Breadcrumb, {
    items: [{
      label: 'Library',
      icon: 'library'
    }, {
      label: 'Languages'
    }, {
      label: 'Japanese \u00B7 N5'
    }, {
      label: 'New card',
      current: true
    }]
  }));
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-12)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);

  // Collapsible "Details" disclosure header
  const DetailsHeader = ({
    open
  }) => /*#__PURE__*/React.createElement("button", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(2),
      width: '100%',
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      padding: `0 ${S(1)}`,
      fontFamily: 'var(--memox-font-sans)',
      color: 'var(--memox-text-secondary)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: open ? 'chevron-down' : 'chevron-right',
    style: {
      width: 'var(--memox-icon-md)',
      height: 'var(--memox-icon-md)'
    }
  }), /*#__PURE__*/React.createElement("span", {
    className: "section-head-title",
    style: {
      fontSize: 'var(--memox-fs-title-small)'
    }
  }, "Details"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement("span", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)',
      fontWeight: 'var(--memox-weight-semibold)'
    }
  }, open ? 'tags · note' : 'Optional'));
  const DetailsBody = () => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(4),
      paddingTop: S(2)
    }
  }, /*#__PURE__*/React.createElement(FormField, {
    label: "Deck"
  }, /*#__PURE__*/React.createElement(PickerRow, {
    icon: "languages",
    tint: "var(--memox-status-new)",
    title: "Japanese \xB7 N5"
  })), /*#__PURE__*/React.createElement(FormField, {
    label: "Tags"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement(Chip, {
    icon: "hash"
  }, "kanji"), /*#__PURE__*/React.createElement(Chip, {
    icon: "hash"
  }, "n5"), /*#__PURE__*/React.createElement("span", {
    className: "chip",
    style: {
      borderRadius: 'var(--memox-radius-full)',
      border: '1px dashed var(--memox-outline-variant)',
      background: 'transparent',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "plus"
  }), "Add tag"))), /*#__PURE__*/React.createElement(FormField, {
    label: "Note",
    right: "Optional"
  }, /*#__PURE__*/React.createElement(TextArea, {
    placeholder: "Add a hint, mnemonic or example sentence\u2026",
    defaultValue: "",
    style: {
      minHeight: '72px'
    }
  })));
  function Screen({
    variant
  }) {
    const filled = variant !== 'empty' && variant !== 'validation';
    const open = variant === 'details';
    const front = variant === 'validation' ? '' : filled ? '日本' : '';
    const back = filled ? 'Japan / にほん' : '';
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(Bar, {
      canSave: filled,
      saving: variant === 'saving'
    }), variant === 'save-failed' && /*#__PURE__*/React.createElement("div", {
      style: {
        padding: `0 var(--memox-space-screen) ${S(3)}`
      }
    }, /*#__PURE__*/React.createElement(Banner, {
      tone: "danger",
      icon: "alert-triangle",
      action: "Retry"
    }, "Couldn't save \u2014 your card is kept here.")), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(FormField, {
      label: "Front",
      error: variant === 'validation' ? 'The front of the card is required.' : undefined
    }, /*#__PURE__*/React.createElement(TextArea, {
      invalid: variant === 'validation',
      placeholder: "Term, question or prompt",
      defaultValue: front
    })), /*#__PURE__*/React.createElement(FormField, {
      label: "Back"
    }, /*#__PURE__*/React.createElement(TextArea, {
      placeholder: "Answer or definition",
      defaultValue: back
    })), /*#__PURE__*/React.createElement("div", {
      className: "hr"
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: open ? S(4) : 0
      }
    }, /*#__PURE__*/React.createElement(DetailsHeader, {
      open: open
    }), open && /*#__PURE__*/React.createElement(DetailsBody, null))));
  }
  window.MEMOX_KIT.register({
    num: '07',
    title: 'Flashcard create',
    states: [{
      label: 'Empty',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "empty"
      })
    }, {
      label: 'Valid',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "valid"
      })
    }, {
      label: 'Details open',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "details"
      })
    }, {
      label: 'Validation',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "validation"
      })
    }, {
      label: 'Saving',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "saving"
      })
    }, {
      label: 'Save failed',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "save-failed"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/07-flashcard-create.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/08-flashcard-edit.jsx
try { (() => {
/* MemoX screen — 08 Flashcard edit (7 states). Edit an existing card: prefilled
   Front / Back / Details, plus loading + load-error states and a delete action.
   App bar (title "Edit card" + back + Save + delete). Token-driven; composes
   contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    PillBtn,
    FormField,
    TextArea,
    Chip,
    TileLg,
    HeroCard,
    Banner,
    Sk,
    Modal,
    PickerRow,
    Breadcrumb
  } = window.MX;

  // ---- App bar (back + title + delete + Save) ------------------------------
  const Bar = ({
    saving,
    showActions = true
  }) => /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      minWidth: 0,
      marginLeft: S(2)
    }
  }, "Edit card"), showActions && /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Delete card",
    style: {
      color: 'var(--memox-danger)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "trash-2"
  })), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn primary sm",
    disabled: saving,
    style: {
      minWidth: '76px'
    }
  }, saving ? /*#__PURE__*/React.createElement("span", {
    className: "spinner",
    style: {
      width: 'var(--memox-icon-sm)',
      height: 'var(--memox-icon-sm)',
      borderWidth: '2px'
    }
  }) : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Icon, {
    name: "check"
  }), "Save")))), /*#__PURE__*/React.createElement(Breadcrumb, {
    items: [{
      label: 'Library',
      icon: 'library'
    }, {
      label: 'Languages'
    }, {
      label: 'Japanese \u00B7 N5'
    }, {
      label: 'Edit card',
      current: true
    }]
  }));
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-12)`,
      display: 'flex',
      flexDirection: 'column',
      gap: S(5)
    }
  }, children);
  const DetailsBlock = () => /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "hr"
  }), /*#__PURE__*/React.createElement(FormField, {
    label: "Deck"
  }, /*#__PURE__*/React.createElement(PickerRow, {
    icon: "languages",
    tint: "var(--memox-status-new)",
    title: "Japanese \xB7 N5"
  })), /*#__PURE__*/React.createElement(FormField, {
    label: "Tags"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement(Chip, {
    icon: "hash"
  }, "kanji"), /*#__PURE__*/React.createElement(Chip, {
    icon: "hash"
  }, "n5"), /*#__PURE__*/React.createElement(Chip, {
    icon: "hash"
  }, "vocab"), /*#__PURE__*/React.createElement("span", {
    className: "chip",
    style: {
      border: '1px dashed var(--memox-outline-variant)',
      background: 'transparent',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "plus"
  }), "Add tag"))));
  function Screen({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, {
        showActions: false
      }), /*#__PURE__*/React.createElement(Body, null, [0, 1].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "12px",
        w: "22%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "96px",
        r: "var(--memox-radius-md)"
      }))), /*#__PURE__*/React.createElement(Sk, {
        h: "1px"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "24px",
        w: "64px",
        r: "var(--memox-radius-full)"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "24px",
        w: "52px",
        r: "var(--memox-radius-full)"
      }))));
    }
    if (variant === 'load-error') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, {
        showActions: false
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'grid',
          placeItems: 'center'
        }
      }, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "cloud-off",
        tint: "var(--memox-danger)",
        title: "Couldn't load card",
        desc: "We couldn't fetch this card to edit."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "rotate-ccw",
        full: true
      }, "Retry")))));
    }
    const invalid = variant === 'validation';
    const overlay = variant === 'delete' ? /*#__PURE__*/React.createElement(Modal, null, /*#__PURE__*/React.createElement(TileLg, {
      icon: "trash-2",
      tint: "var(--memox-danger)",
      style: {
        margin: `0 0 ${S(4)}`
      }
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-size-h1)',
        fontWeight: 'var(--memox-weight-extrabold)',
        color: 'var(--memox-text-primary)',
        letterSpacing: 'var(--memox-tracking-tight)'
      }
    }, "Delete this card?"), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-label-large)',
        lineHeight: 1.5,
        marginTop: S(2)
      }
    }, /*#__PURE__*/React.createElement("b", {
      style: {
        color: 'var(--memox-text-primary)'
      }
    }, "\u201C\u65E5\u672C \u2014 Japan\u201D"), " and its review history will be removed. This can't be undone."), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: S(2),
        marginTop: S(5)
      }
    }, /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline",
      style: {
        flex: 1
      }
    }, "Cancel"), /*#__PURE__*/React.createElement("button", {
      className: "pill-btn danger",
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "trash-2"
    }), "Delete"))) : null;
    return /*#__PURE__*/React.createElement("div", {
      className: "app",
      style: {
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement(Bar, {
      saving: variant === 'saving'
    }), variant === 'save-failed' && /*#__PURE__*/React.createElement("div", {
      style: {
        padding: `0 var(--memox-space-screen) ${S(3)}`
      }
    }, /*#__PURE__*/React.createElement(Banner, {
      tone: "danger",
      icon: "alert-triangle",
      action: "Retry"
    }, "Changes couldn't be saved.")), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(FormField, {
      label: "Front",
      error: invalid ? 'The front of the card is required.' : undefined
    }, /*#__PURE__*/React.createElement(TextArea, {
      invalid: invalid,
      defaultValue: invalid ? '' : '日本',
      placeholder: "Term, question or prompt"
    })), /*#__PURE__*/React.createElement(FormField, {
      label: "Back"
    }, /*#__PURE__*/React.createElement(TextArea, {
      defaultValue: "Japan / \u306B\u307B\u3093"
    })), /*#__PURE__*/React.createElement(DetailsBlock, null)), overlay);
  }
  window.MEMOX_KIT.register({
    num: '08',
    title: 'Flashcard edit',
    states: [{
      label: 'Loaded',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loaded"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loading"
      })
    }, {
      label: 'Load error',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "load-error"
      })
    }, {
      label: 'Validation',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "validation"
      })
    }, {
      label: 'Saving',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "saving"
      })
    }, {
      label: 'Save failed',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "save-failed"
      })
    }, {
      label: 'Delete',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "delete"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/08-flashcard-edit.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/09-flashcard-history.jsx
try { (() => {
/* MemoX screen — 09 Flashcard history (5 states). Activity timeline for one
   card: study events with result + timestamp + duration, under a card summary
   header. App bar (title "History" + back). Token-driven; composes contract
   classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    PillBtn,
    Chip,
    HeroCard,
    EmptyState,
    Banner,
    Sk,
    Breadcrumb
  } = window.MX;

  // ---- Data ----------------------------------------------------------------
  // grade -> { icon, tint } maps each review outcome to a calm status color.
  const GRADE = {
    Easy: {
      icon: 'check-check',
      tint: 'var(--memox-status-mastered)'
    },
    Good: {
      icon: 'check',
      tint: 'var(--memox-status-reviewing)'
    },
    Hard: {
      icon: 'alert-circle',
      tint: 'var(--memox-status-learning)'
    },
    Again: {
      icon: 'rotate-ccw',
      tint: 'var(--memox-danger)'
    },
    Created: {
      icon: 'plus',
      tint: 'var(--memox-status-new)'
    }
  };
  const EVENTS = [{
    grade: 'Good',
    when: 'Today · 9:41',
    dur: '4.2s'
  }, {
    grade: 'Easy',
    when: 'Yesterday · 8:05',
    dur: '2.8s'
  }, {
    grade: 'Again',
    when: '3 days ago · 21:10',
    dur: '11.0s'
  }, {
    grade: 'Hard',
    when: '5 days ago · 7:58',
    dur: '8.4s'
  }, {
    grade: 'Good',
    when: 'Mar 2 · 9:30',
    dur: '5.1s'
  }, {
    grade: 'Created',
    when: 'Feb 24 · 14:02',
    dur: null
  }];

  // ---- App bar -------------------------------------------------------------
  const Bar = () => /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      minWidth: 0,
      marginLeft: S(2)
    }
  }, "History")), /*#__PURE__*/React.createElement(Breadcrumb, {
    items: [{
      label: 'Library',
      icon: 'library'
    }, {
      label: 'Languages'
    }, {
      label: 'Japanese \u00B7 N5'
    }, {
      label: 'History',
      current: true
    }]
  }));

  // ---- Card summary header -------------------------------------------------
  const SummaryHead = () => /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      padding: 'var(--memox-space-5)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(3)
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "icon-tile",
    style: {
      '--tile': 'var(--memox-status-reviewing)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "square-stack"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "title",
    style: {
      fontSize: 'var(--memox-size-h1)'
    }
  }, "\u65E5\u672C \u2014 Japan"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)'
    }
  }, "Japanese \xB7 N5")), /*#__PURE__*/React.createElement(Chip, {
    status: "reviewing"
  }, "Box 4")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      marginTop: S(4),
      gap: S(1)
    }
  }, [['18', 'Reviews'], ['92%', 'Retention'], ['5.4s', 'Avg time']].map(([v, l]) => /*#__PURE__*/React.createElement("div", {
    key: l,
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--memox-size-h2)',
      fontWeight: 'var(--memox-weight-extrabold)',
      color: 'var(--memox-text-primary)',
      fontVariantNumeric: 'tabular-nums'
    }
  }, v), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)',
      fontWeight: 'var(--memox-weight-semibold)'
    }
  }, l)))));

  // ---- Event row -----------------------------------------------------------
  const EventRow = ({
    e
  }) => {
    const g = GRADE[e.grade];
    return /*#__PURE__*/React.createElement("div", {
      className: "list-row",
      style: {
        cursor: 'default'
      }
    }, /*#__PURE__*/React.createElement("span", {
      className: "icon-tile",
      style: {
        '--tile': g.tint
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: g.icon
    })), /*#__PURE__*/React.createElement("div", {
      className: "list-row-main"
    }, /*#__PURE__*/React.createElement("div", {
      className: "list-row-title",
      style: {
        fontWeight: 'var(--memox-weight-bold)'
      }
    }, e.grade === 'Created' ? 'Card created' : `Reviewed · ${e.grade}`), /*#__PURE__*/React.createElement("div", {
      className: "list-row-meta"
    }, e.when)), e.dur && /*#__PURE__*/React.createElement("span", {
      className: "list-row-trail",
      style: {
        fontSize: 'var(--memox-fs-body-small)',
        fontWeight: 'var(--memox-weight-semibold)',
        color: 'var(--memox-text-secondary)',
        fontVariantNumeric: 'tabular-nums'
      }
    }, e.dur));
  };
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-12)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);
  const Feed = ({
    events
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      paddingLeft: S(1)
    }
  }, "Activity"), /*#__PURE__*/React.createElement("div", {
    className: "list-card"
  }, events.map((e, i) => /*#__PURE__*/React.createElement("div", {
    key: i
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr inset"
  }), /*#__PURE__*/React.createElement(EventRow, {
    e: e
  })))));
  function Screen({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(Sk, {
        h: "148px",
        r: "var(--memox-radius-card)"
      }), /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: `${S(2)} var(--memox-space-card)`,
          display: 'flex',
          flexDirection: 'column',
          gap: S(4)
        }
      }, [0, 1, 2, 3].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "50%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "34%"
      })), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "32px"
      }))))));
    }
    if (variant === 'error') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'grid',
          placeItems: 'center'
        }
      }, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "cloud-off",
        tint: "var(--memox-danger)",
        title: "Couldn't load history",
        desc: "We couldn't fetch this card's activity."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "rotate-ccw",
        full: true
      }, "Retry")))));
    }
    if (variant === 'empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(SummaryHead, null), /*#__PURE__*/React.createElement(EmptyState, {
        icon: "history",
        pad: 6,
        title: "No history yet",
        desc: "Study this card and your reviews will show up here."
      })));
    }
    if (variant === 'partial') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(SummaryHead, null), /*#__PURE__*/React.createElement(Feed, {
        events: EVENTS.slice(0, 3)
      }), /*#__PURE__*/React.createElement(Banner, {
        tone: "info",
        icon: "info",
        action: "Retry"
      }, "Older events couldn't be loaded.")));
    }

    // loaded
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(SummaryHead, null), /*#__PURE__*/React.createElement(Feed, {
      events: EVENTS
    })));
  }
  window.MEMOX_KIT.register({
    num: '09',
    title: 'Flashcard history',
    states: [{
      label: 'Loaded',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loaded"
      })
    }, {
      label: 'Empty',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "empty"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loading"
      })
    }, {
      label: 'Error',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "error"
      })
    }, {
      label: 'Partial',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "partial"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/09-flashcard-history.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/10-deck-import.jsx
try { (() => {
/* MemoX screen — 10 Deck import (9 states). Import cards from a file: choose →
   parse → preview (valid / invalid rows) → import. App bar (title "Import" +
   back). Token-driven; composes contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    Progress,
    IconTile,
    TileLg,
    HeroCard,
    Banner
  } = window.MX;

  // ---- Data (parsed rows) --------------------------------------------------
  const ROWS = [{
    front: '日本 — Japan',
    ok: true
  }, {
    front: '日曜日 — Sunday',
    ok: true
  }, {
    front: '本 — book',
    ok: true
  }, {
    front: '水 — water',
    ok: true
  }, {
    front: '火曜日 — Tuesday',
    ok: true
  }];
  const ROWS_MIXED = [{
    front: '日本 — Japan',
    ok: true
  }, {
    front: '日曜日 — Sunday',
    ok: true
  }, {
    front: '(empty front)',
    ok: false,
    why: 'Missing front'
  }, {
    front: '水 — water',
    ok: true
  }, {
    front: 'dup: 本 — book',
    ok: false,
    why: 'Duplicate card'
  }];

  // ---- App bar -------------------------------------------------------------
  const Bar = ({
    action
  }) => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      minWidth: 0,
      marginLeft: S(2)
    }
  }, "Import"), action);
  const Body = ({
    children,
    center
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-12)`,
      display: 'flex',
      flexDirection: 'column',
      gap: S(4),
      ...(center ? {
        justifyContent: 'center'
      } : null)
    }
  }, children);

  // file chip card
  const FileCard = ({
    status
  }) => /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(3),
      padding: S(4)
    }
  }, /*#__PURE__*/React.createElement(IconTile, {
    icon: "file-text",
    color: "var(--memox-status-new)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "title",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, "japanese-n5.csv"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)'
    }
  }, status || '24.6 KB · CSV')), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Remove file"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "x"
  })));

  // parsed-rows preview list
  const PreviewList = ({
    rows
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      paddingLeft: S(1)
    }
  }, "Preview", /*#__PURE__*/React.createElement("span", {
    style: {
      marginLeft: S(1),
      color: 'var(--memox-text-3)'
    }
  }, rows.length)), /*#__PURE__*/React.createElement("div", {
    className: "list-card"
  }, rows.map((r, i) => /*#__PURE__*/React.createElement("div", {
    key: i
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr inset"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row",
    style: {
      cursor: 'default'
    }
  }, /*#__PURE__*/React.createElement(IconTile, {
    icon: r.ok ? 'check' : 'alert-triangle',
    color: r.ok ? 'var(--memox-status-mastered)' : 'var(--memox-danger)'
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title",
    style: r.ok ? undefined : {
      color: 'var(--memox-text-secondary)'
    }
  }, r.front), !r.ok && /*#__PURE__*/React.createElement("div", {
    className: "list-row-meta",
    style: {
      color: 'var(--memox-danger)'
    }
  }, r.why)), !r.ok && /*#__PURE__*/React.createElement("span", {
    className: "chip",
    style: {
      '--chip': 'var(--memox-danger)'
    }
  }, "Skip"))))));

  // result hero (success / partial / failed)
  const ResultHero = ({
    icon,
    tint,
    solid,
    title,
    desc,
    primary,
    secondary
  }) => /*#__PURE__*/React.createElement(HeroCard, {
    icon: icon,
    tint: tint,
    solid: solid,
    title: title,
    desc: desc
  }, primary, secondary);
  function Screen({
    variant
  }) {
    // ----- empty: choose a file (mobile-first) -----
    if (variant === 'empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "file-up",
        tint: "var(--memox-primary)",
        title: "Import cards from a file",
        desc: "Pick a CSV, TSV or Anki (.apkg) file from your device to bring its cards into MemoX."
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "folder-open"
      }), "Choose file")), /*#__PURE__*/React.createElement(Banner, {
        tone: "info",
        icon: "info"
      }, "Supports CSV, TSV and Anki (.apkg) files. On the web you can also drag a file onto this screen.")));
    }

    // ----- file selected: file card + parse action -----
    if (variant === 'selected') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(FileCard, {
        status: "24.6 KB \xB7 CSV \xB7 ready to parse"
      }), /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "scan-line"
      }), "Parse file"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-body-small)',
          textAlign: 'center'
        }
      }, "We'll show a preview before anything is imported.")));
    }

    // ----- parsing -----
    if (variant === 'parsing') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, {
        center: true
      }, /*#__PURE__*/React.createElement("div", {
        style: {
          textAlign: 'center',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: S(4)
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "spinner"
      }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
        className: "title"
      }, "Parsing file\u2026"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-label-large)',
          marginTop: S(1)
        }
      }, "Reading japanese-n5.csv")))));
    }

    // ----- preview (all valid) -----
    if (variant === 'preview-all') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(FileCard, {
        status: "142 cards found \xB7 all valid"
      }), /*#__PURE__*/React.createElement(Banner, {
        tint: "var(--memox-status-mastered)",
        icon: "check-circle-2"
      }, "All 142 cards look good."), /*#__PURE__*/React.createElement(PreviewList, {
        rows: ROWS
      }), /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "download"
      }), "Import 142 cards")));
    }

    // ----- preview (mixed valid/invalid) -----
    if (variant === 'preview-mixed') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(FileCard, {
        status: "142 found \xB7 118 valid \xB7 24 to skip"
      }), /*#__PURE__*/React.createElement(Banner, {
        tone: "warn",
        icon: "alert-triangle"
      }, "24 cards have problems and will be skipped."), /*#__PURE__*/React.createElement(PreviewList, {
        rows: ROWS_MIXED
      }), /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "download"
      }), "Import 118 valid cards")));
    }

    // ----- importing -----
    if (variant === 'importing') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, {
        center: true
      }, /*#__PURE__*/React.createElement("div", {
        style: {
          width: '100%',
          textAlign: 'center',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: S(4)
        }
      }, /*#__PURE__*/React.createElement("span", {
        className: "tile-lg solid",
        style: {
          '--tile': 'var(--memox-primary)'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "download"
      })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
        className: "title"
      }, "Importing cards\u2026"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-label-large)',
          marginTop: S(1)
        }
      }, "96 of 142 imported")), /*#__PURE__*/React.createElement("div", {
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Progress, {
        value: 68
      })))));
    }

    // ----- success -----
    if (variant === 'success') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, {
        center: true
      }, /*#__PURE__*/React.createElement(ResultHero, {
        icon: "check",
        tint: "var(--memox-status-mastered)",
        title: "142 cards imported",
        desc: "They're now in your \u201CJapanese \xB7 N5\u201D deck, ready to study.",
        primary: /*#__PURE__*/React.createElement("button", {
          className: "pill-btn primary",
          style: {
            width: '100%'
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "layers"
        }), "Open deck"),
        secondary: /*#__PURE__*/React.createElement("button", {
          className: "pill-btn outline",
          style: {
            width: '100%'
          }
        }, "Done")
      })));
    }

    // ----- partial -----
    if (variant === 'partial') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, {
        center: true
      }, /*#__PURE__*/React.createElement(ResultHero, {
        icon: "check-check",
        tint: "var(--memox-status-learning)",
        title: "118 imported \xB7 24 skipped",
        desc: "Some rows were invalid or duplicates and were left out.",
        primary: /*#__PURE__*/React.createElement("button", {
          className: "pill-btn primary",
          style: {
            width: '100%'
          }
        }, /*#__PURE__*/React.createElement(Icon, {
          name: "download"
        }), "Review skipped"),
        secondary: /*#__PURE__*/React.createElement("button", {
          className: "pill-btn outline",
          style: {
            width: '100%'
          }
        }, "Done")
      })));
    }

    // ----- failed -----
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, {
      center: true
    }, /*#__PURE__*/React.createElement(ResultHero, {
      icon: "x",
      tint: "var(--memox-danger)",
      title: "Import failed",
      desc: "Nothing was imported. The file may be corrupt or in an unsupported format.",
      primary: /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "rotate-ccw"
      }), "Try again"),
      secondary: /*#__PURE__*/React.createElement("button", {
        className: "pill-btn outline",
        style: {
          width: '100%'
        }
      }, "Choose another file")
    })));
  }
  window.MEMOX_KIT.register({
    num: '10',
    title: 'Deck import',
    states: [{
      label: 'Empty',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "empty"
      })
    }, {
      label: 'File selected',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "selected"
      })
    }, {
      label: 'Parsing',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "parsing"
      })
    }, {
      label: 'Preview · all valid',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "preview-all"
      })
    }, {
      label: 'Preview · mixed',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "preview-mixed"
      })
    }, {
      label: 'Importing',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "importing"
      })
    }, {
      label: 'Success',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "success"
      })
    }, {
      label: 'Partial',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "partial"
      })
    }, {
      label: 'Failed',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "failed"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/10-deck-import.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/11-tag-management.jsx
try { (() => {
/* MemoX screen — 11 Tag management (11 states). Manage tags: rename, merge,
   delete. App bar (title "Tags" + search) · list of tag rows (tag + cards-used
   count + overflow). Token-driven; composes contract classes + shared
   primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    TileLg,
    EmptyState,
    Banner,
    SearchDock,
    Sk,
    Modal,
    Sheet,
    BusyOverlay
  } = window.MX;

  // ---- Data ----------------------------------------------------------------
  const TAGS = [{
    name: 'kanji',
    count: 142
  }, {
    name: 'vocab',
    count: 210
  }, {
    name: 'verbs',
    count: 88
  }, {
    name: 'n5',
    count: 64
  }, {
    name: 'grammar',
    count: 52
  }, {
    name: 'particles',
    count: 31
  }];
  const MERGE_TARGETS = [{
    name: 'vocab',
    count: 210,
    sel: true
  }, {
    name: 'verbs',
    count: 88,
    sel: false
  }, {
    name: 'n5',
    count: 64,
    sel: false
  }, {
    name: 'grammar',
    count: 52,
    sel: false
  }];

  // ---- App bars ------------------------------------------------------------
  const Bar = () => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      minWidth: 0,
      marginLeft: S(2)
    }
  }, "Tags"));
  const SearchBar = ({
    query
  }) => /*#__PURE__*/React.createElement(SearchDock, {
    query: query,
    placeholder: "Search tags"
  });

  // ---- Tag row -------------------------------------------------------------
  const TagRow = ({
    t
  }) => /*#__PURE__*/React.createElement("div", {
    className: "list-row"
  }, /*#__PURE__*/React.createElement("span", {
    className: "icon-tile",
    style: {
      '--tile': 'var(--memox-text-secondary)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "hash"
  })), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title"
  }, t.name), /*#__PURE__*/React.createElement("div", {
    className: "list-row-meta"
  }, t.count, " cards")), /*#__PURE__*/React.createElement("span", {
    className: "list-row-trail"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Tag options"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "more-vertical"
  }))));
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: `${S(3)} var(--memox-space-screen) var(--memox-space-12)`,
      display: 'flex',
      flexDirection: 'column',
      gap: S(3)
    }
  }, children);
  const TagList = ({
    tags
  }) => /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      paddingLeft: S(1)
    }
  }, tags.length, " tags"), /*#__PURE__*/React.createElement("div", {
    className: "list-card"
  }, tags.map((t, i) => /*#__PURE__*/React.createElement("div", {
    key: t.name
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr inset"
  }), /*#__PURE__*/React.createElement(TagRow, {
    t: t
  })))));

  // ---- Overlays ------------------------------------------------------------
  const ActionSheet = () => /*#__PURE__*/React.createElement(Sheet, {
    title: "kanji \xB7 142 cards"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column'
    }
  }, [{
    icon: 'pencil',
    label: 'Rename'
  }, {
    icon: 'git-merge',
    label: 'Merge into…'
  }, {
    icon: 'trash-2',
    label: 'Delete',
    danger: true
  }].map((a, i) => /*#__PURE__*/React.createElement("div", {
    key: a.label
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row",
    style: a.danger ? {
      color: 'var(--memox-danger)'
    } : undefined
  }, /*#__PURE__*/React.createElement("span", {
    className: "icon-tile",
    style: {
      '--tile': a.danger ? 'var(--memox-danger)' : 'var(--memox-text-secondary)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: a.icon
  })), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title",
    style: a.danger ? {
      color: 'var(--memox-danger)'
    } : undefined
  }, a.label)))))));
  const RenameDialog = ({
    conflict
  }) => /*#__PURE__*/React.createElement(Modal, null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--memox-size-h1)',
      fontWeight: 'var(--memox-weight-extrabold)',
      color: 'var(--memox-text-primary)',
      letterSpacing: 'var(--memox-tracking-tight)'
    }
  }, "Rename tag"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: S(4)
    }
  }, /*#__PURE__*/React.createElement("input", {
    className: "field",
    defaultValue: conflict ? 'vocab' : 'kanji',
    autoFocus: true,
    style: conflict ? {
      borderColor: 'var(--memox-danger)'
    } : undefined
  })), conflict ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Banner, {
    tone: "warn",
    icon: "git-merge",
    style: {
      marginTop: S(3)
    }
  }, "A tag \u201Cvocab\u201D already exists. Merge them?"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: S(2),
      marginTop: S(5)
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "pill-btn outline",
    style: {
      flex: 1
    }
  }, "Cancel"), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn primary",
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "git-merge"
  }), "Merge tags"))) : /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: S(2),
      marginTop: S(5)
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "pill-btn outline",
    style: {
      flex: 1
    }
  }, "Cancel"), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn primary",
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "check"
  }), "Save")));
  const MergeSheet = () => /*#__PURE__*/React.createElement(Sheet, {
    title: "Merge \u201Ckanji\u201D into"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column'
    }
  }, MERGE_TARGETS.map((t, i) => /*#__PURE__*/React.createElement("div", {
    key: t.name
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row"
  }, /*#__PURE__*/React.createElement("span", {
    className: "icon-tile",
    style: {
      '--tile': 'var(--memox-text-secondary)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "hash"
  })), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title"
  }, t.name), /*#__PURE__*/React.createElement("div", {
    className: "list-row-meta"
  }, t.count, " cards")), /*#__PURE__*/React.createElement("span", {
    className: "list-row-trail",
    style: t.sel ? {
      color: 'var(--memox-primary)'
    } : {
      color: 'var(--memox-outline-variant)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: t.sel ? 'check-circle-2' : 'circle'
  })))))), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn primary",
    style: {
      width: '100%',
      marginTop: S(5)
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "git-merge"
  }), "Merge into \u201Cvocab\u201D"));
  const DeleteDialog = () => /*#__PURE__*/React.createElement(Modal, null, /*#__PURE__*/React.createElement(TileLg, {
    icon: "trash-2",
    tint: "var(--memox-danger)",
    style: {
      margin: `0 0 ${S(4)}`
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--memox-size-h1)',
      fontWeight: 'var(--memox-weight-extrabold)',
      color: 'var(--memox-text-primary)',
      letterSpacing: 'var(--memox-tracking-tight)'
    }
  }, "Delete tag \u201Ckanji\u201D?"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      lineHeight: 1.5,
      marginTop: S(2)
    }
  }, "The tag is removed from ", /*#__PURE__*/React.createElement("b", {
    style: {
      color: 'var(--memox-text-primary)'
    }
  }, "142 cards"), ". The cards themselves stay. This can't be undone."), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: S(2),
      marginTop: S(5)
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "pill-btn outline",
    style: {
      flex: 1
    }
  }, "Cancel"), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn danger",
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "trash-2"
  }), "Delete")));
  const ErrorDialog = () => /*#__PURE__*/React.createElement(Modal, null, /*#__PURE__*/React.createElement(TileLg, {
    icon: "alert-triangle",
    tint: "var(--memox-danger)",
    style: {
      margin: `0 0 ${S(4)}`
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--memox-size-h1)',
      fontWeight: 'var(--memox-weight-extrabold)',
      color: 'var(--memox-text-primary)',
      letterSpacing: 'var(--memox-tracking-tight)'
    }
  }, "Couldn't rename tag"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      lineHeight: 1.5,
      marginTop: S(2)
    }
  }, "Something went wrong updating this tag. Your tags are unchanged."), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: S(2),
      marginTop: S(5)
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "pill-btn outline",
    style: {
      flex: 1
    }
  }, "Dismiss"), /*#__PURE__*/React.createElement("button", {
    className: "pill-btn primary",
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "rotate-ccw"
  }), "Try again")));
  function Screen({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(Sk, {
        h: "12px",
        w: "22%"
      }), /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          padding: `${S(2)} var(--memox-space-card)`,
          display: 'flex',
          flexDirection: 'column',
          gap: S(4)
        }
      }, [0, 1, 2, 3, 4].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "40%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "26%"
      })))))));
    }
    if (variant === 'empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(EmptyState, {
        icon: "hash",
        pad: 8,
        title: "No tags yet",
        desc: "Add tags to your cards and they'll appear here to manage."
      })));
    }
    if (variant === 'search-empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(EmptyState, {
        icon: "search-x",
        pad: 10,
        title: "No tags match",
        desc: 'Nothing here matches “xyz”.'
      })), /*#__PURE__*/React.createElement(SearchBar, {
        query: "xyz"
      }));
    }
    const overlay = {
      'action-sheet': /*#__PURE__*/React.createElement(ActionSheet, null),
      rename: /*#__PURE__*/React.createElement(RenameDialog, null),
      'rename-merge': /*#__PURE__*/React.createElement(RenameDialog, {
        conflict: true
      }),
      'merge-sheet': /*#__PURE__*/React.createElement(MergeSheet, null),
      delete: /*#__PURE__*/React.createElement(DeleteDialog, null),
      busy: /*#__PURE__*/React.createElement(BusyOverlay, {
        label: "Merging tags\u2026"
      }),
      'op-error': /*#__PURE__*/React.createElement(ErrorDialog, null)
    }[variant];
    return /*#__PURE__*/React.createElement("div", {
      className: "app",
      style: {
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(TagList, {
      tags: TAGS
    })), /*#__PURE__*/React.createElement(SearchBar, {
      query: ""
    }), overlay);
  }
  window.MEMOX_KIT.register({
    num: '11',
    title: 'Tag management',
    states: [{
      label: 'Loaded',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loaded"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loading"
      })
    }, {
      label: 'Empty',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "empty"
      })
    }, {
      label: 'Search empty',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "search-empty"
      })
    }, {
      label: 'Action sheet',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "action-sheet"
      })
    }, {
      label: 'Rename',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "rename"
      })
    }, {
      label: 'Rename → merge',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "rename-merge"
      })
    }, {
      label: 'Merge sheet',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "merge-sheet"
      })
    }, {
      label: 'Delete',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "delete"
      })
    }, {
      label: 'Busy',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "busy"
      })
    }, {
      label: 'Op error',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "op-error"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/11-tag-management.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/12-study-review.jsx
try { (() => {
/* MemoX screen — 12 Study · Review (1 state). The classic flip card: the front
   shows the term; tapping the card flips to the meaning; "Next" advances. Study
   chrome (progress x/N + exit) comes from the shared StudyShell. The front face
   is shown here with a tap-to-flip affordance. Token-driven; composes contract
   classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    StudyShell
  } = window.MX;

  // The big flip card. Front = term + reading; a quiet hint invites the flip.
  const FlipCard = () => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: S(4),
      padding: S(6),
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      color: 'var(--memox-text-3)'
    }
  }, "Term"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'calc(var(--memox-size-display) * 1.9)',
      fontWeight: 'var(--memox-weight-extrabold)',
      lineHeight: 1.05,
      color: 'var(--memox-text-primary)',
      letterSpacing: 'var(--memox-tracking-tight)'
    }
  }, "\u65E5\u672C"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-size-h2)',
      fontWeight: 'var(--memox-weight-medium)',
      fontFamily: 'var(--memox-font-serif)'
    }
  }, "\u306B\u307B\u3093 \xB7 nihon"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(2),
      marginTop: S(4),
      color: 'var(--memox-text-3)',
      fontSize: 'var(--memox-fs-label-medium)',
      fontWeight: 'var(--memox-weight-bold)',
      letterSpacing: 'var(--memox-ls-section)',
      textTransform: 'uppercase'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "rotate-cw",
    style: {
      width: 'var(--memox-icon-sm)',
      height: 'var(--memox-icon-sm)'
    }
  }), "Tap to flip")));
  function Screen() {
    return /*#__PURE__*/React.createElement(StudyShell, {
      index: 8,
      total: 20,
      footer: /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn outline"
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "rotate-cw"
      }), "Flip"), /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          flex: 1
        }
      }, "Next", /*#__PURE__*/React.createElement(Icon, {
        name: "arrow-right"
      })))
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        marginBottom: S(3),
        display: 'flex',
        justifyContent: 'center'
      }
    }, /*#__PURE__*/React.createElement("span", {
      className: "chip reviewing"
    }, "Japanese \xB7 N5")), /*#__PURE__*/React.createElement(FlipCard, null));
  }
  window.MEMOX_KIT.register({
    num: '12',
    title: 'Study · Review',
    states: [{
      label: 'Front',
      render: () => /*#__PURE__*/React.createElement(Screen, null)
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/12-study-review.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/13-study-match.jsx
try { (() => {
/* MemoX screen — 13 Study · Match (3 states). Two columns — terms on the left,
   meanings on the right (shuffled). Tap a term, then its match: a correct pair
   locks green, a wrong attempt flashes red, the current pick shows primary.
   Cards are the shared StudyOption (.choice.clamp) inside the .match-grid:
     • Standard — meanings up to 2 lines (default).
     • Long meanings — the grid opts into .match-grid.long-text so every card
       gets the taller floor + 3-line clamp at once (stays uniform).
     • Read full meaning — a meaning longer than 3 lines clamps with a "tap to
       read" hint and opens the full text in the shared bottom Sheet, so a
       truncated meaning never leaves the user guessing.
   All height/padding/clamp logic lives in the match-card tokens + common
   component — the screen only picks the strategy. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    StudyShell,
    StudyOption,
    Sheet,
    PillBtn
  } = window.MX;

  // ---- Standard grid: short / medium meanings, 2-line cards. ----
  const STD_LEFT = [{
    t: '水',
    state: 'correct',
    mark: 'check'
  }, {
    t: '火',
    state: 'wrong',
    mark: 'x'
  }, {
    t: '日本',
    state: 'selected'
  }, {
    t: '山'
  }, {
    t: '本'
  }];
  const STD_RIGHT = [{
    t: 'fire',
    state: 'wrong',
    mark: 'x'
  }, {
    t: 'water',
    state: 'correct',
    mark: 'check'
  }, {
    t: 'book'
  }, {
    t: 'a tall landform rising above its surroundings'
  }, {
    t: 'Japan'
  }];

  // ---- Long-text grid: one 3-line definition + one meaning too long for the
  // card, which clamps with the "tap to read" hint (more). ----
  const LONG_FULL = 'a very long definition that requires three or more lines to read fully, with extra clauses and examples the learner needs before choosing the right pair';
  const LONG_LEFT = [{
    t: '山'
  }, {
    t: '勉強'
  }, {
    t: '図書館'
  }];
  const LONG_RIGHT = [{
    t: 'a tall landform rising high above the surrounding land'
  }, {
    t: 'the act of studying or learning something with focused effort over time'
  }, {
    t: LONG_FULL,
    more: true
  }];
  const StdGrid = () => /*#__PURE__*/React.createElement("div", {
    className: "match-grid"
  }, STD_LEFT.map((l, i) => /*#__PURE__*/React.createElement(React.Fragment, {
    key: i
  }, /*#__PURE__*/React.createElement(StudyOption, {
    clamp: true,
    state: l.state,
    mark: l.mark,
    dim: l.state === 'correct'
  }, l.t), /*#__PURE__*/React.createElement(StudyOption, {
    clamp: true,
    state: STD_RIGHT[i].state,
    mark: STD_RIGHT[i].mark,
    dim: STD_RIGHT[i].state === 'correct'
  }, STD_RIGHT[i].t))));
  const LongGrid = () => /*#__PURE__*/React.createElement("div", {
    className: "match-grid long-text"
  }, LONG_LEFT.map((l, i) => /*#__PURE__*/React.createElement(React.Fragment, {
    key: i
  }, /*#__PURE__*/React.createElement(StudyOption, {
    clamp: true,
    state: l.state,
    mark: l.mark
  }, l.t), /*#__PURE__*/React.createElement(StudyOption, {
    clamp: true,
    state: LONG_RIGHT[i].state,
    mark: LONG_RIGHT[i].mark,
    more: LONG_RIGHT[i].more
  }, LONG_RIGHT[i].t))));
  const Head = ({
    sub
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      marginBottom: S(5)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "title",
    style: {
      fontSize: 'var(--memox-size-h1)'
    }
  }, "Match the pairs"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      marginTop: S(1)
    }
  }, sub));
  const Legend = ({
    matched,
    left
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'center',
      gap: S(4),
      marginTop: S(5),
      color: 'var(--memox-text-secondary)',
      fontSize: 'var(--memox-fs-body-small)',
      fontWeight: 'var(--memox-weight-bold)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: S(1)
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "status-dot",
    style: {
      '--dot': 'var(--memox-rating-correct)'
    }
  }), matched, " matched"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: S(1)
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "status-dot",
    style: {
      '--dot': 'var(--memox-text-3)'
    }
  }), left, " left"));
  const ShuffleFooter = /*#__PURE__*/React.createElement("button", {
    className: "pill-btn outline",
    style: {
      width: '100%'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "rotate-ccw"
  }), "Shuffle & restart");

  // State 1 — standard short/medium meanings.
  function Standard() {
    return /*#__PURE__*/React.createElement(StudyShell, {
      index: 1,
      total: 5,
      center: true,
      footer: ShuffleFooter
    }, /*#__PURE__*/React.createElement(Head, {
      sub: "Tap a term, then its meaning."
    }), /*#__PURE__*/React.createElement(StdGrid, null), /*#__PURE__*/React.createElement(Legend, {
      matched: 1,
      left: 4
    }));
  }

  // State 2 — a grid that holds a long definition: the whole grid uses the
  // long-text strategy (taller floor + 3 lines), still uniform.
  function LongMeanings() {
    return /*#__PURE__*/React.createElement(StudyShell, {
      index: 2,
      total: 5,
      center: true,
      footer: ShuffleFooter
    }, /*#__PURE__*/React.createElement(Head, {
      sub: "Longer meanings show up to three lines."
    }), /*#__PURE__*/React.createElement(LongGrid, null), /*#__PURE__*/React.createElement(Legend, {
      matched: 0,
      left: 3
    }));
  }

  // State 3 — a meaning too long for the card: tapping it opens the full text in
  // the shared bottom sheet so the learner can read it all before matching.
  function ReadFull() {
    return /*#__PURE__*/React.createElement(StudyShell, {
      index: 2,
      total: 5,
      center: true,
      footer: ShuffleFooter
    }, /*#__PURE__*/React.createElement(Head, {
      sub: "Tap a clipped meaning to read it in full."
    }), /*#__PURE__*/React.createElement(LongGrid, null), /*#__PURE__*/React.createElement(Legend, {
      matched: 0,
      left: 3
    }), /*#__PURE__*/React.createElement(Sheet, {
      title: "Full meaning"
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: S(2),
        color: 'var(--memox-text-secondary)',
        fontSize: 'var(--memox-fs-label-medium)',
        fontWeight: 'var(--memox-weight-bold)',
        textTransform: 'uppercase',
        letterSpacing: 'var(--memox-ls-section)',
        marginBottom: S(2)
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "book-open",
      style: {
        width: 'var(--memox-icon-sm)',
        height: 'var(--memox-icon-sm)'
      }
    }), "Meaning"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-fs-title-small)',
        fontWeight: 'var(--memox-weight-semibold)',
        lineHeight: 'var(--memox-leading-normal)',
        color: 'var(--memox-text-primary)'
      }
    }, LONG_FULL), /*#__PURE__*/React.createElement("div", {
      style: {
        marginTop: S(5)
      }
    }, /*#__PURE__*/React.createElement(PillBtn, {
      variant: "primary",
      full: true
    }, "Got it"))));
  }
  window.MEMOX_KIT.register({
    num: '13',
    title: 'Study · Match',
    states: [{
      label: 'Matching',
      render: () => /*#__PURE__*/React.createElement(Standard, null)
    }, {
      label: 'Long meanings',
      render: () => /*#__PURE__*/React.createElement(LongMeanings, null)
    }, {
      label: 'Read full meaning',
      render: () => /*#__PURE__*/React.createElement(ReadFull, null)
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/13-study-match.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/14-study-guess.jsx
try { (() => {
/* MemoX screen — 14 Study · Guess (1 state). A prompt plus five A–E options
   (pick one). Shown here AFTER answering: the chosen option was wrong (red), the
   correct one is revealed (green), the rest dim. Study chrome from StudyShell;
   options are the shared StudyOption (.choice). Token-driven. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    StudyShell,
    StudyOption
  } = window.MX;

  // answered snapshot: picked C (wrong), B is correct.
  const OPTIONS = [{
    k: 'A',
    t: 'Sunday',
    state: null,
    dim: true
  }, {
    k: 'B',
    t: 'Tuesday',
    state: 'correct',
    mark: 'check'
  }, {
    k: 'C',
    t: 'Thursday',
    state: 'wrong',
    mark: 'x'
  }, {
    k: 'D',
    t: 'Saturday',
    state: null,
    dim: true
  }, {
    k: 'E',
    t: 'Monday',
    state: null,
    dim: true
  }];
  function Screen() {
    return /*#__PURE__*/React.createElement(StudyShell, {
      index: 5,
      total: 20,
      footer: /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, "Next", /*#__PURE__*/React.createElement(Icon, {
        name: "arrow-right"
      }))
    }, /*#__PURE__*/React.createElement("div", {
      className: "card",
      style: {
        marginBottom: S(5),
        padding: S(5)
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "ov",
      style: {
        color: 'var(--memox-text-3)',
        marginBottom: S(2)
      }
    }, "What does this mean?"), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'calc(var(--memox-size-display) * 1.1)',
        fontWeight: 'var(--memox-weight-extrabold)',
        color: 'var(--memox-text-primary)',
        letterSpacing: 'var(--memox-tracking-tight)',
        lineHeight: 1.1
      }
    }, "\u706B\u66DC\u65E5"), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-size-h2)',
        fontWeight: 'var(--memox-weight-medium)',
        fontFamily: 'var(--memox-font-serif)',
        marginTop: S(1)
      }
    }, "\u304B\u3088\u3046\u3073 \xB7 kayoubi")), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: S(2)
      }
    }, OPTIONS.map(o => /*#__PURE__*/React.createElement(StudyOption, {
      key: o.k,
      k: o.k,
      state: o.state,
      mark: o.mark,
      dim: o.dim
    }, o.t))));
  }
  window.MEMOX_KIT.register({
    num: '14',
    title: 'Study · Guess',
    states: [{
      label: 'Answered',
      render: () => /*#__PURE__*/React.createElement(Screen, null)
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/14-study-guess.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/15-study-recall.jsx
try { (() => {
/* MemoX screen — 15 Study · Recall (2 states). Active recall: hidden shows only
   the prompt + "Show answer"; revealed surfaces the answer and three self-rate
   buttons (Missed / Partial / Got it) coloured from the self-* tokens. Study
   chrome from StudyShell; reveal + rate buttons are shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    StudyShell,
    AnswerReveal,
    RateBtn
  } = window.MX;
  const Prompt = () => /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      padding: S(5)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      color: 'var(--memox-text-3)',
      marginBottom: S(2)
    }
  }, "Recall the meaning"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'calc(var(--memox-size-display) * 1.1)',
      fontWeight: 'var(--memox-weight-extrabold)',
      color: 'var(--memox-text-primary)',
      letterSpacing: 'var(--memox-tracking-tight)',
      lineHeight: 1.1
    }
  }, "\u6C34\u66DC\u65E5"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-size-h2)',
      fontWeight: 'var(--memox-weight-medium)',
      fontFamily: 'var(--memox-font-serif)',
      marginTop: S(1)
    }
  }, "\u3059\u3044\u3088\u3046\u3073 \xB7 suiyoubi"));
  function Screen({
    revealed
  }) {
    const footer = revealed ? /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
      className: "ov",
      style: {
        justifyContent: 'center',
        color: 'var(--memox-text-3)',
        marginBottom: S(2)
      }
    }, "How well did you know it?"), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement(RateBtn, {
      tone: "missed",
      icon: "x"
    }, "Missed"), /*#__PURE__*/React.createElement(RateBtn, {
      tone: "partial",
      icon: "minus"
    }, "Partial"), /*#__PURE__*/React.createElement(RateBtn, {
      tone: "got",
      icon: "check"
    }, "Got it"))) : /*#__PURE__*/React.createElement("button", {
      className: "pill-btn primary",
      style: {
        width: '100%'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "eye"
    }), "Show answer");
    return /*#__PURE__*/React.createElement(StudyShell, {
      index: revealed ? 12 : 11,
      total: 20,
      footer: footer
    }, /*#__PURE__*/React.createElement(Prompt, null), revealed ? /*#__PURE__*/React.createElement("div", {
      style: {
        marginTop: S(4)
      }
    }, /*#__PURE__*/React.createElement(AnswerReveal, {
      label: "Answer"
    }, "Wednesday")) : /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        display: 'grid',
        placeItems: 'center',
        color: 'var(--memox-text-3)',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        textAlign: 'center'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "brain",
      style: {
        width: 'var(--memox-icon-lg)',
        height: 'var(--memox-icon-lg)'
      }
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-fs-label-large)',
        fontWeight: 'var(--memox-weight-semibold)',
        marginTop: S(2)
      }
    }, "Say it in your head, then reveal."))));
  }
  window.MEMOX_KIT.register({
    num: '15',
    title: 'Study · Recall',
    states: [{
      label: 'Hidden',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        revealed: false
      })
    }, {
      label: 'Revealed',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        revealed: true
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/15-study-recall.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/16-study-fill.jsx
try { (() => {
/* MemoX screen — 16 Study · Fill (2 states). Type-the-answer: input shows an
   empty field + Check; wrong shows the field in error (red border, the typed
   answer) with the correct answer revealed below. Study chrome from StudyShell;
   field uses the .field.invalid contract state + shared AnswerReveal. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    StudyShell,
    FormField,
    AnswerReveal
  } = window.MX;
  const Prompt = () => /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      padding: S(5)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      color: 'var(--memox-text-3)',
      marginBottom: S(2)
    }
  }, "Type the reading"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'calc(var(--memox-size-display) * 1.1)',
      fontWeight: 'var(--memox-weight-extrabold)',
      color: 'var(--memox-text-primary)',
      letterSpacing: 'var(--memox-tracking-tight)',
      lineHeight: 1.1
    }
  }, "\u5C71"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      marginTop: S(1)
    }
  }, "English: mountain"));
  function Screen({
    wrong
  }) {
    const footer = wrong ? /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "rotate-ccw"
    }), "Retry"), /*#__PURE__*/React.createElement("button", {
      className: "pill-btn primary",
      style: {
        flex: 1
      }
    }, "Next", /*#__PURE__*/React.createElement(Icon, {
      name: "arrow-right"
    }))) : /*#__PURE__*/React.createElement("button", {
      className: "pill-btn primary",
      style: {
        width: '100%'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "check"
    }), "Check answer");
    return /*#__PURE__*/React.createElement(StudyShell, {
      index: wrong ? 14 : 13,
      total: 20,
      footer: footer
    }, /*#__PURE__*/React.createElement(Prompt, null), /*#__PURE__*/React.createElement("div", {
      style: {
        marginTop: S(5)
      }
    }, /*#__PURE__*/React.createElement(FormField, {
      label: "Your answer",
      error: wrong ? 'Not quite — see the answer below.' : undefined
    }, wrong ? /*#__PURE__*/React.createElement("input", {
      className: "field invalid",
      defaultValue: "yamma",
      readOnly: true
    }) : /*#__PURE__*/React.createElement("input", {
      className: "field",
      placeholder: "Romaji reading\u2026",
      autoFocus: true
    }))), wrong && /*#__PURE__*/React.createElement("div", {
      style: {
        marginTop: S(4)
      }
    }, /*#__PURE__*/React.createElement(AnswerReveal, {
      label: "Correct answer"
    }, "yama")));
  }
  window.MEMOX_KIT.register({
    num: '16',
    title: 'Study · Fill',
    states: [{
      label: 'Input',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        wrong: false
      })
    }, {
      label: 'Wrong',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        wrong: true
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/16-study-fill.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/17-study-result.jsx
try { (() => {
/* MemoX screen — 17 Study result (6 states). End-of-session summary: an accuracy
   ring hero · a stat strip (correct / wrong / next due) · a goal + streak update
   · Done / Keep studying. States: loaded · loading (saving) · goal off · save
   failed (banner + retry) · defensive (missing data fallback) · tough empty
   (no cards studied). Composes contract classes + shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    IconTile,
    StatSummary,
    HeroCard,
    Banner
  } = window.MX;
  const Bar = ({
    title
  }) => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1
    }
  }, title), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Close"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "x"
  })));
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);
  const Footer = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 'none',
      padding: `${S(3)} var(--memox-space-screen) ${S(5)}`,
      display: 'flex',
      flexDirection: 'column',
      gap: S(2),
      borderTop: '1px solid var(--memox-border-ghost)'
    }
  }, children);

  // Accuracy ring hero. `pct` null → unknown ("—"), draws an empty track.
  const ResultHero = ({
    pct,
    title,
    sub
  }) => {
    const deg = pct == null ? 0 : Math.round(pct / 100 * 360);
    const ring = pct == null ? 'var(--memox-progress-track)' : `conic-gradient(var(--memox-rating-correct) ${deg}deg, var(--memox-progress-track) 0)`;
    return /*#__PURE__*/React.createElement("div", {
      className: "card",
      style: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        textAlign: 'center',
        padding: S(6),
        gap: S(4)
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "goal-ring",
      style: {
        width: 'calc(var(--memox-size-ring) * 1.6)',
        height: 'calc(var(--memox-size-ring) * 1.6)',
        background: ring
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "goal-ring-inner",
      style: {
        width: 'calc(var(--memox-size-ring) * 1.6 - var(--memox-space-4))',
        height: 'calc(var(--memox-size-ring) * 1.6 - var(--memox-space-4))'
      }
    }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-size-display)',
        fontWeight: 'var(--memox-weight-extrabold)',
        lineHeight: 1,
        color: 'var(--memox-text-primary)',
        letterSpacing: 'var(--memox-tracking-tight)'
      }
    }, pct == null ? '—' : pct + '%'), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-label-medium)',
        fontWeight: 'var(--memox-weight-bold)',
        marginTop: S(1)
      }
    }, "accuracy")))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-size-h1)',
        fontWeight: 'var(--memox-weight-extrabold)',
        color: 'var(--memox-text-primary)',
        letterSpacing: 'var(--memox-tracking-tight)'
      }
    }, title), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-label-large)',
        marginTop: S(1)
      }
    }, sub)));
  };

  // Goal + streak update card (omitted when goal is off).
  const GoalUpdate = () => /*#__PURE__*/React.createElement("div", {
    className: "card accent"
  }, /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      color: 'var(--memox-primary)',
      marginBottom: S(3)
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "target"
  }), "Goal & streak"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(3),
      marginBottom: S(3)
    }
  }, /*#__PURE__*/React.createElement(IconTile, {
    icon: "check",
    color: "var(--memox-primary)",
    solid: true
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "title"
  }, "Daily goal reached"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)'
    }
  }, "20 / 20 cards today"))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(3)
    }
  }, /*#__PURE__*/React.createElement(IconTile, {
    icon: "flame",
    color: "var(--memox-status-learning)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "title"
  }, "12-day streak"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)'
    }
  }, "+1 from today \xB7 keep it going")), /*#__PURE__*/React.createElement("span", {
    className: "chip got"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-up"
  }), "+1")));
  function Screen({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Session complete"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'grid',
          placeItems: 'center',
          padding: S(6)
        }
      }, /*#__PURE__*/React.createElement("div", {
        style: {
          textAlign: 'center',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: S(4)
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "spinner",
        style: {
          width: 'var(--memox-size-fab)',
          height: 'var(--memox-size-fab)'
        }
      }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
        className: "title",
        style: {
          fontSize: 'var(--memox-size-h2)'
        }
      }, "Saving your session\u2026"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-label-large)',
          marginTop: S(1)
        }
      }, "Updating spaced-repetition schedule")))));
    }
    if (variant === 'tough-empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, {
        title: "Session ended"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'grid',
          placeItems: 'center',
          padding: `${S(6)} 0`
        }
      }, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "inbox",
        tint: "var(--memox-text-secondary)",
        title: "No cards studied",
        desc: "This session ended before any cards were reviewed, so nothing was scored."
      }))), /*#__PURE__*/React.createElement(Footer, null, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, "Back to deck")));
    }
    const goalOff = variant === 'goal-off';
    const failed = variant === 'save-failed';
    const defensive = variant === 'defensive';
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(Bar, {
      title: "Session complete"
    }), /*#__PURE__*/React.createElement(Body, null, failed && /*#__PURE__*/React.createElement(Banner, {
      tone: "danger",
      icon: "cloud-off"
    }, "Couldn't save your results. Your progress is kept locally."), defensive && /*#__PURE__*/React.createElement(Banner, {
      tone: "warn",
      icon: "alert-triangle"
    }, "Some stats couldn't be calculated for this session."), defensive ? /*#__PURE__*/React.createElement(ResultHero, {
      pct: null,
      title: "Session saved",
      sub: "Reviewed cards were recorded."
    }) : /*#__PURE__*/React.createElement(ResultHero, {
      pct: 85,
      title: "Nice work!",
      sub: "20 cards \xB7 Recall \xB7 Japanese \xB7 N5"
    }), /*#__PURE__*/React.createElement(StatSummary, {
      stats: defensive ? [['—', 'Correct'], ['—', 'Wrong'], ['9', 'Due next', true]] : [['17', 'Correct'], ['3', 'Wrong'], ['9', 'Due next', true]]
    }), !goalOff && !defensive && /*#__PURE__*/React.createElement(GoalUpdate, null)), /*#__PURE__*/React.createElement(Footer, null, failed ? /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "rotate-ccw"
    }), "Retry save"), /*#__PURE__*/React.createElement("button", {
      className: "pill-btn primary",
      style: {
        flex: 1
      }
    }, "Done")) : /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "play"
    }), "Keep studying"), /*#__PURE__*/React.createElement("button", {
      className: "pill-btn primary",
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "check"
    }), "Done"))));
  }
  window.MEMOX_KIT.register({
    num: '17',
    title: 'Study result',
    states: [{
      label: 'Loaded',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loaded"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loading"
      })
    }, {
      label: 'Goal off',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "goal-off"
      })
    }, {
      label: 'Save failed',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "save-failed"
      })
    }, {
      label: 'Defensive',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "defensive"
      })
    }, {
      label: 'Tough empty',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "tough-empty"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/17-study-result.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/18-stats.jsx
try { (() => {
/* MemoX screen — 18 Stats (1 state). The "Stats" tab: a weekly activity column
   chart + a per-deck mastery list (each deck's mastery bar tinted by the
   low/mid/high scale). Token-driven; composes the shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    IconTile,
    SectionHead,
    BarChart,
    MasteryBar,
    BottomNav
  } = window.MX;

  // Cards reviewed per day this week.
  const WEEK = [{
    label: 'M',
    value: 18
  }, {
    label: 'T',
    value: 24
  }, {
    label: 'W',
    value: 12
  }, {
    label: 'T',
    value: 31
  }, {
    label: 'F',
    value: 22
  }, {
    label: 'S',
    value: 9
  }, {
    label: 'S',
    value: 16
  }];

  // Per-deck mastery (% of cards at the "mastered" stage).
  const DECKS = [{
    icon: 'languages',
    tint: 'var(--memox-status-new)',
    name: 'Japanese · N5',
    value: 72
  }, {
    icon: 'flask-conical',
    tint: 'var(--memox-status-learning)',
    name: 'Organic chemistry',
    value: 38
  }, {
    icon: 'landmark',
    tint: 'var(--memox-status-reviewing)',
    name: 'World capitals',
    value: 91
  }, {
    icon: 'book-open',
    tint: 'var(--memox-status-mastered)',
    name: 'SAT vocabulary',
    value: 56
  }];
  const MasteryRow = ({
    d
  }) => /*#__PURE__*/React.createElement("div", {
    className: "list-row",
    style: {
      cursor: 'default'
    }
  }, /*#__PURE__*/React.createElement(IconTile, {
    icon: d.icon,
    color: d.tint
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title"
  }, d.name), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: S(2)
    }
  }, /*#__PURE__*/React.createElement(MasteryBar, {
    value: d.value
  }))), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 'none',
      minWidth: 'calc(var(--memox-space-10) + var(--memox-space-1))',
      textAlign: 'right',
      fontSize: 'var(--memox-fs-label-large)',
      fontWeight: 'var(--memox-weight-extrabold)',
      color: 'var(--memox-text-primary)',
      fontVariantNumeric: 'tabular-nums'
    }
  }, d.value, "%"));
  function StatsScreen() {
    const total = WEEK.reduce((s, d) => s + (d.value || 0), 0);
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement("div", {
      className: "appbar"
    }, /*#__PURE__*/React.createElement("span", {
      className: "appbar-title",
      style: {
        flex: 1
      }
    }, "Stats")), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        overflowY: 'auto',
        padding: `${S(2)} var(--memox-space-screen) var(--memox-space-6)`,
        display: 'flex',
        flexDirection: 'column',
        gap: 'var(--memox-gap-section)'
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "card"
    }, /*#__PURE__*/React.createElement("div", {
      className: "section-head",
      style: {
        marginBottom: S(4)
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "ov"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "calendar-days"
    }), "Cards this week"), /*#__PURE__*/React.createElement("span", {
      className: "title",
      style: {
        fontSize: 'var(--memox-fs-label-large)',
        fontVariantNumeric: 'tabular-nums'
      }
    }, total)), /*#__PURE__*/React.createElement(BarChart, {
      data: WEEK
    })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(SectionHead, {
      title: "Per-deck mastery"
    }), /*#__PURE__*/React.createElement("div", {
      className: "list-card",
      style: {
        marginTop: S(2)
      }
    }, DECKS.map((d, i) => /*#__PURE__*/React.createElement("div", {
      key: d.name
    }, i > 0 && /*#__PURE__*/React.createElement("div", {
      className: "hr inset"
    }), /*#__PURE__*/React.createElement(MasteryRow, {
      d: d
    })))))), /*#__PURE__*/React.createElement(BottomNav, {
      active: "Stats"
    }));
  }
  window.MEMOX_KIT.register({
    num: '18',
    title: 'Stats',
    states: [{
      label: 'Loaded',
      render: () => /*#__PURE__*/React.createElement(StatsScreen, null)
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/18-stats.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/19-progress.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* MemoX screen — 19 Progress (9 states). The analysis + gentle-nudge HOME: this
   is where goal, streak, trend, accuracy, due load, weak decks and "what to study
   next" live — the things the Dashboard deliberately keeps light. Layout:
   Today status (goal ring + streak) · ranged activity chart (Week | Month) · KPI
   strip (accuracy / time / cards) · Insights (analytic nudges). States: week ·
   month · goal met · streak lost · loading · empty · insufficient · partial ·
   error. Token-driven; composes the shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    Segmented,
    BarChart,
    StatSummary,
    GoalRing,
    Insight,
    SectionHead,
    Banner,
    EmptyState,
    HeroCard,
    Sk
  } = window.MX;
  const WEEK = [{
    label: 'M',
    value: 18
  }, {
    label: 'T',
    value: 24
  }, {
    label: 'W',
    value: 12
  }, {
    label: 'T',
    value: 31
  }, {
    label: 'F',
    value: 22
  }, {
    label: 'S',
    value: 9
  }, {
    label: 'S',
    value: 16
  }];
  const MONTH = [{
    label: 'Wk1',
    value: 96
  }, {
    label: 'Wk2',
    value: 132
  }, {
    label: 'Wk3',
    value: 88
  }, {
    label: 'Wk4',
    value: 121
  }];
  const PARTIAL = [{
    label: 'M',
    value: 18
  }, {
    label: 'T',
    value: null
  }, {
    label: 'W',
    value: 12
  }, {
    label: 'T',
    value: null
  }, {
    label: 'F',
    value: 22
  }, {
    label: 'S',
    value: 9
  }, {
    label: 'S',
    value: 14
  }];
  // KPI strip — accuracy / time / cards (streak shown in the Today card above).
  const KPI_WEEK = [['86%', 'Accuracy'], ['3.3h', 'Time'], ['132', 'Cards']];
  const KPI_MONTH = [['84%', 'Accuracy'], ['14h', 'Time'], ['437', 'Cards']];
  const SK_BARS = [1.4, 2.2, 1, 2.7, 1.8, 0.8, 2];

  // ---- Insight library (analytic nudges live HERE, not on the Dashboard) ----
  const INS = {
    closeToGoal: {
      tone: 'good',
      icon: 'target',
      title: "You're close to today's goal",
      desc: '8 more cards to reach 20.',
      action: 'Review 8 cards'
    },
    goalMet: {
      tone: 'good',
      icon: 'check-check',
      title: 'Daily goal reached',
      desc: '20/20 cards today — keep the streak going.'
    },
    streakReset: {
      tone: 'warn',
      icon: 'flame',
      title: 'Your 11-day streak reset',
      desc: 'Study today to start a new one.',
      action: 'Review 12 cards'
    },
    mostDue: {
      tone: 'warn',
      icon: 'layers',
      title: 'Japanese · N5 has the most due',
      desc: '23 of your 33 due cards are in this deck.',
      action: 'Open deck'
    },
    accuracyUp: {
      tone: 'good',
      icon: 'trending-up',
      title: 'Accuracy is up this week',
      desc: '86% correct, up 4% from last week.'
    },
    accuracyDown: {
      tone: 'down',
      icon: 'trending-down',
      title: 'Accuracy dropped this week',
      desc: '80% correct, down 6% from last week.',
      action: 'Review missed cards'
    },
    weakDeck: {
      tone: 'warn',
      icon: 'flask-conical',
      title: 'Organic chemistry is your weakest deck',
      desc: '38% mastered — the lowest of your decks.',
      action: 'Study it'
    },
    needData: {
      tone: 'info',
      icon: 'info',
      title: 'A few more sessions needed',
      desc: 'Study a couple more days to unlock trends and insights.'
    }
  };
  const Bar = ({
    range
  }) => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1
    }
  }, "Progress"), /*#__PURE__*/React.createElement(Segmented, {
    options: ['Week', 'Month'],
    value: range === 'month' ? 'Month' : 'Week'
  }));
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);

  // Today status — goal ring + streak. The goal/streak that USED to pressure the
  // Dashboard now reports here as status.
  const TodayCard = ({
    goalValue = 12,
    goalTotal = 20,
    goalMet,
    streak = 11,
    streakLost
  }) => /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(4)
    }
  }, /*#__PURE__*/React.createElement(GoalRing, {
    value: goalMet ? goalTotal : goalValue,
    total: goalTotal,
    met: goalMet
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "title",
    style: {
      fontSize: 'var(--memox-fs-label-large)'
    }
  }, "Today's goal"), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)'
    }
  }, goalMet ? 'Goal reached — nice work' : `${goalTotal - goalValue} cards to go`), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: S(2),
      display: 'flex'
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: `chip${streakLost ? '' : ' learning'}`
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "flame"
  }), streakLost ? 'Streak reset' : `${streak}-day streak`))));
  const ChartCard = ({
    heading,
    total,
    data,
    dim
  }) => /*#__PURE__*/React.createElement("div", {
    className: "card"
  }, /*#__PURE__*/React.createElement("div", {
    className: "section-head",
    style: {
      marginBottom: S(4)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "ov"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "bar-chart-3"
  }), heading), /*#__PURE__*/React.createElement("span", {
    className: "title",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      fontVariantNumeric: 'tabular-nums'
    }
  }, total)), /*#__PURE__*/React.createElement(BarChart, {
    data: data,
    dim: dim
  }));
  const Insights = ({
    items
  }) => /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(SectionHead, {
    title: "Insights"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(3),
      marginTop: S(2)
    }
  }, items.map((k, i) => /*#__PURE__*/React.createElement(Insight, _extends({
    key: i
  }, INS[k])))));
  function ProgressScreen({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, {
        range: "week"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(4)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "72px",
        w: "72px",
        r: "var(--memox-radius-full)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "45%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "60%"
      }))), /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: S(4)
        }
      }, /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          justifyContent: 'space-between'
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "42%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "18%"
      })), /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          alignItems: 'flex-end',
          gap: S(2),
          height: 'calc(var(--memox-space-12) * 3)'
        }
      }, SK_BARS.map((m, i) => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          flex: 1,
          display: 'flex',
          alignItems: 'flex-end',
          justifyContent: 'center'
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: `calc(var(--memox-space-12) * ${m})`,
        w: "100%",
        r: "var(--memox-radius-sm)"
      }))))), /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          gap: S(2)
        }
      }, [0, 1, 2].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: S(2),
          padding: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "22px",
        w: "58%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "46%"
      }))))));
    }
    if (variant === 'empty') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, {
        range: "week"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(EmptyState, {
        icon: "bar-chart-3",
        title: "Not enough data",
        desc: "Not enough data to show progress yet. Study a few sessions to start seeing your trends."
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary"
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "play"
      }), "Start studying"))));
    }
    if (variant === 'error') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, {
        range: "week"
      }), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'grid',
          placeItems: 'center'
        }
      }, /*#__PURE__*/React.createElement(HeroCard, {
        icon: "alert-triangle",
        tint: "var(--memox-danger)",
        title: "Couldn't load progress",
        desc: "Something went wrong fetching your stats."
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "rotate-ccw"
      }), "Retry")))));
    }

    // ---- Data states ----
    const range = variant === 'month' ? 'month' : 'week';
    const data = variant === 'partial' ? PARTIAL : range === 'month' ? MONTH : WEEK;
    const heading = range === 'month' ? 'This month' : 'This week';
    const total = range === 'month' ? '437 cards' : '132 cards';
    const dim = variant === 'insufficient';
    const goalMet = variant === 'goal-met';
    const streakLost = variant === 'streak-lost';
    const insights = variant === 'goal-met' ? ['goalMet', 'weakDeck', 'accuracyUp'] : variant === 'streak-lost' ? ['streakReset', 'mostDue', 'accuracyDown'] : variant === 'insufficient' ? ['needData'] : variant === 'partial' ? ['mostDue', 'accuracyDown'] : variant === 'month' ? ['accuracyUp', 'weakDeck', 'mostDue'] : ['closeToGoal', 'mostDue', 'accuracyUp']; // week

    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(Bar, {
      range: range
    }), /*#__PURE__*/React.createElement(Body, null, variant === 'insufficient' && /*#__PURE__*/React.createElement(Banner, {
      tone: "info",
      icon: "info"
    }, "A few more days of study are needed to show a trend."), variant === 'partial' && /*#__PURE__*/React.createElement(Banner, {
      tone: "warn",
      icon: "alert-triangle"
    }, "Study data is missing for some days in this range."), /*#__PURE__*/React.createElement(TodayCard, {
      goalMet: goalMet,
      streakLost: streakLost
    }), /*#__PURE__*/React.createElement(ChartCard, {
      heading: heading,
      total: dim ? '\u2014' : total,
      data: data,
      dim: dim
    }), /*#__PURE__*/React.createElement(StatSummary, {
      stats: range === 'month' ? KPI_MONTH : KPI_WEEK
    }), /*#__PURE__*/React.createElement(Insights, {
      items: insights
    })));
  }
  window.MEMOX_KIT.register({
    num: '19',
    title: 'Progress',
    states: [{
      label: 'Week',
      render: () => /*#__PURE__*/React.createElement(ProgressScreen, {
        variant: "week"
      })
    }, {
      label: 'Month',
      render: () => /*#__PURE__*/React.createElement(ProgressScreen, {
        variant: "month"
      })
    }, {
      label: 'Goal met',
      render: () => /*#__PURE__*/React.createElement(ProgressScreen, {
        variant: "goal-met"
      })
    }, {
      label: 'Streak lost',
      render: () => /*#__PURE__*/React.createElement(ProgressScreen, {
        variant: "streak-lost"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(ProgressScreen, {
        variant: "loading"
      })
    }, {
      label: 'Empty',
      render: () => /*#__PURE__*/React.createElement(ProgressScreen, {
        variant: "empty"
      })
    }, {
      label: 'Insufficient',
      render: () => /*#__PURE__*/React.createElement(ProgressScreen, {
        variant: "insufficient"
      })
    }, {
      label: 'Partial',
      render: () => /*#__PURE__*/React.createElement(ProgressScreen, {
        variant: "partial"
      })
    }, {
      label: 'Error',
      render: () => /*#__PURE__*/React.createElement(ProgressScreen, {
        variant: "error"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/19-progress.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/20-settings.jsx
try { (() => {
/* MemoX screen — 20 Settings (5 states). The settings hub: an account header
   block (avatar + email + sync status) followed by grouped category rows that
   lead to sub-screens. States: populated · loading · signed out · signing in ·
   sync error. App bar + bottom-nav; token-driven, composes shared primitives. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    Avatar,
    ListRow,
    Banner,
    BottomNav,
    Sk
  } = window.MX;
  const Header = () => /*#__PURE__*/React.createElement("div", {
    className: "appbar-lg"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      width: '100%'
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "appbar-title"
  }, "Settings")));
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      overflowY: 'auto',
      padding: `${S(2)} var(--memox-space-screen) var(--memox-space-6)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);

  // Account header block — its body switches per variant.
  const AccountBlock = ({
    variant
  }) => {
    if (variant === 'signing-in') {
      return /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "spinner"
      }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
        className: "title"
      }, "Signing in\u2026"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-body-small)'
        }
      }, "Connecting to your Google account")));
    }
    if (variant === 'signed-out') {
      return /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Avatar, {
        lg: true,
        icon: "user",
        tint: "var(--memox-text-secondary)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          minWidth: 0
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "title"
      }, "Not signed in"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-body-small)'
        }
      }, "Sign in to back up your decks")), /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary sm"
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "log-in"
      }), "Sign in"));
    }
    const synced = variant !== 'sync-error';
    return /*#__PURE__*/React.createElement("div", {
      className: "card",
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: S(3)
      }
    }, /*#__PURE__*/React.createElement(Avatar, {
      lg: true,
      initials: "AN"
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        minWidth: 0
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "title"
    }, "An Nguyen"), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-body-small)',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap'
      }
    }, "an.nguyen@gmail.com")), synced ? /*#__PURE__*/React.createElement("span", {
      className: "chip got"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "cloud"
    }), "Synced") : /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline sm",
      style: {
        color: 'var(--memox-danger)',
        borderColor: 'color-mix(in srgb, var(--memox-danger) calc(var(--memox-op-border-subtle) * 100%), transparent)'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "rotate-ccw"
    }), "Retry"));
  };
  const GROUP_1 = [{
    icon: 'target',
    tint: 'var(--memox-status-new)',
    title: 'Learning',
    meta: 'Daily goal, reminders',
    value: '20/day'
  }, {
    icon: 'volume-2',
    tint: 'var(--memox-status-reviewing)',
    title: 'Audio & speech',
    meta: 'Text-to-speech voices',
    value: 'English'
  }, {
    icon: 'palette',
    tint: 'var(--memox-status-learning)',
    title: 'Appearance',
    meta: 'Theme',
    value: 'System'
  }, {
    icon: 'languages',
    tint: 'var(--memox-status-mastered)',
    title: 'Language',
    meta: 'App language',
    value: 'English'
  }];
  const GROUP_2 = [{
    icon: 'cloud',
    tint: 'var(--memox-status-new)',
    title: 'Account & sync',
    meta: 'Backup and restore'
  }, {
    icon: 'info',
    tint: 'var(--memox-text-secondary)',
    title: 'About',
    meta: 'Version, licenses',
    value: 'v2.4.0'
  }];
  const Group = ({
    items
  }) => /*#__PURE__*/React.createElement("div", {
    className: "list-card"
  }, items.map((it, i) => /*#__PURE__*/React.createElement("div", {
    key: it.title
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr inset"
  }), /*#__PURE__*/React.createElement(ListRow, {
    icon: it.icon,
    color: it.tint,
    title: it.title,
    meta: it.meta,
    trail: it.value != null ? /*#__PURE__*/React.createElement("span", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-label-large)',
        fontWeight: 'var(--memox-weight-semibold)'
      }
    }, it.value) : undefined
  }))));
  function Screen({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Header, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "56px",
        w: "56px",
        r: "var(--memox-radius-full)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "16px",
        w: "50%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "12px",
        w: "70%"
      }))), [0, 1].map(g => /*#__PURE__*/React.createElement("div", {
        key: g,
        className: "card",
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: S(4),
          padding: `${S(2)} var(--memox-space-card)`
        }
      }, [0, 1, 2].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "45%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "62%"
      }))))))), /*#__PURE__*/React.createElement(BottomNav, {
        active: "Settings"
      }));
    }
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(Header, null), /*#__PURE__*/React.createElement(Body, null, variant === 'sync-error' && /*#__PURE__*/React.createElement(Banner, {
      tone: "danger",
      icon: "cloud-off"
    }, "Last sync failed. Your latest changes aren't backed up."), /*#__PURE__*/React.createElement(AccountBlock, {
      variant: variant
    }), /*#__PURE__*/React.createElement(Group, {
      items: GROUP_1
    }), /*#__PURE__*/React.createElement(Group, {
      items: GROUP_2
    })), /*#__PURE__*/React.createElement(BottomNav, {
      active: "Settings"
    }));
  }
  window.MEMOX_KIT.register({
    num: '20',
    title: 'Settings',
    states: [{
      label: 'Populated',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "populated"
      })
    }, {
      label: 'Signed out',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "signed-out"
      })
    }, {
      label: 'Signing in',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "signing-in"
      })
    }, {
      label: 'Sync error',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "sync-error"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loading"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/20-settings.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/21-account-sync.jsx
try { (() => {
/* MemoX screen — 21 Account sync (9 states). Google sign-in + Drive backup /
   restore. App bar · account block · backup block (status + Backup/Restore) ·
   recent-sync log. States: signed out · signing in · failed · no backup ·
   ready · uploading · restore warn (dialog) · restoring · token expired.
   Token-driven; composes shared primitives + contract classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    PillBtn,
    Avatar,
    IconTile,
    TileLg,
    HeroCard,
    Banner,
    Progress,
    Modal
  } = window.MX;
  const Bar = () => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      marginLeft: S(2)
    }
  }, "Account"));
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);
  const SectionLabel = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      paddingLeft: S(1)
    }
  }, children);

  // Account identity block.
  const AccountBlock = ({
    variant
  }) => {
    if (variant === 'signing-in') {
      return /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "spinner"
      }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
        className: "title"
      }, "Signing in\u2026"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-body-small)'
        }
      }, "Authorizing with Google")));
    }
    if (variant === 'signed-out' || variant === 'failed') {
      return /*#__PURE__*/React.createElement(HeroCard, {
        icon: "cloud",
        tint: "var(--memox-primary)",
        title: "Sign in to sync",
        desc: "Back up your decks to Google Drive and restore them on any device."
      }, /*#__PURE__*/React.createElement(PillBtn, {
        variant: "primary",
        icon: "log-in",
        full: true
      }, "Continue with Google"));
    }
    return /*#__PURE__*/React.createElement("div", {
      className: "card",
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: S(3)
      }
    }, /*#__PURE__*/React.createElement(Avatar, {
      lg: true,
      initials: "AN"
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        minWidth: 0
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "title"
    }, "An Nguyen"), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-body-small)',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap'
      }
    }, "an.nguyen@gmail.com")), /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline sm"
    }, "Sign out"));
  };

  // Backup block per variant.
  const BackupBlock = ({
    variant
  }) => {
    if (variant === 'uploading' || variant === 'restoring') {
      const up = variant === 'uploading';
      return /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(IconTile, {
        icon: up ? 'upload' : 'download',
        color: "var(--memox-primary)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "title"
      }, up ? 'Backing up…' : 'Restoring…'), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-body-small)'
        }
      }, up ? '3 decks · 412 cards' : 'Replacing local data')), /*#__PURE__*/React.createElement("span", {
        style: {
          fontSize: 'var(--memox-fs-label-large)',
          fontWeight: 'var(--memox-weight-extrabold)',
          color: 'var(--memox-primary)',
          fontVariantNumeric: 'tabular-nums'
        }
      }, up ? '60%' : '40%')), /*#__PURE__*/React.createElement(Progress, {
        value: up ? 60 : 40
      }));
    }
    if (variant === 'no-backup') {
      return /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: S(4)
        }
      }, /*#__PURE__*/React.createElement("div", {
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(IconTile, {
        icon: "cloud-off",
        color: "var(--memox-status-learning)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1
        }
      }, /*#__PURE__*/React.createElement("div", {
        className: "title"
      }, "No backup yet"), /*#__PURE__*/React.createElement("div", {
        className: "muted",
        style: {
          fontSize: 'var(--memox-fs-body-small)'
        }
      }, "Your decks aren't on Drive yet"))), /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "upload"
      }), "Back up now"));
    }
    // ready / restore-warn underlying
    return /*#__PURE__*/React.createElement("div", {
      className: "card",
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: S(4)
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: S(3)
      }
    }, /*#__PURE__*/React.createElement(IconTile, {
      icon: "check",
      color: "var(--memox-status-mastered)"
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "title"
    }, "Backup ready"), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-body-small)'
      }
    }, "3 decks \xB7 412 cards \xB7 1.2 MB"))), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement("button", {
      className: "pill-btn primary",
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "upload"
    }), "Back up"), /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline",
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "download"
    }), "Restore")));
  };
  const LOG = [{
    icon: 'upload',
    tint: 'var(--memox-status-mastered)',
    t: 'Backed up',
    meta: '412 cards',
    when: '2h ago'
  }, {
    icon: 'download',
    tint: 'var(--memox-status-new)',
    t: 'Restored',
    meta: '398 cards',
    when: 'Jun 14'
  }, {
    icon: 'upload',
    tint: 'var(--memox-status-mastered)',
    t: 'Backed up',
    meta: '398 cards',
    when: 'Jun 12'
  }];
  const SyncLog = () => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement(SectionLabel, null, "Recent sync"), /*#__PURE__*/React.createElement("div", {
    className: "list-card"
  }, LOG.map((l, i) => /*#__PURE__*/React.createElement("div", {
    key: i
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    className: "hr inset"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row",
    style: {
      cursor: 'default'
    }
  }, /*#__PURE__*/React.createElement(IconTile, {
    icon: l.icon,
    color: l.tint
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title"
  }, l.t), /*#__PURE__*/React.createElement("div", {
    className: "list-row-meta"
  }, l.meta)), /*#__PURE__*/React.createElement("span", {
    className: "list-row-trail muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)',
      fontWeight: 'var(--memox-weight-semibold)'
    }
  }, l.when))))));
  function Screen({
    variant
  }) {
    const showBackup = ['no-backup', 'ready', 'uploading', 'restoring', 'restore-warn'].includes(variant);
    const showLog = ['ready', 'uploading', 'restoring', 'restore-warn'].includes(variant);
    const overlay = variant === 'restore-warn' ? /*#__PURE__*/React.createElement(Modal, null, /*#__PURE__*/React.createElement(TileLg, {
      icon: "alert-triangle",
      tint: "var(--memox-status-learning)",
      style: {
        margin: `0 0 ${S(4)}`
      }
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 'var(--memox-size-h1)',
        fontWeight: 'var(--memox-weight-extrabold)',
        color: 'var(--memox-text-primary)',
        letterSpacing: 'var(--memox-tracking-tight)'
      }
    }, "Restore from backup?"), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-label-large)',
        lineHeight: 1.5,
        marginTop: S(2)
      }
    }, "This ", /*#__PURE__*/React.createElement("b", {
      style: {
        color: 'var(--memox-text-primary)'
      }
    }, "replaces all local decks"), " with the backup from 2h ago. Anything not backed up will be lost."), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: S(2),
        marginTop: S(5)
      }
    }, /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline",
      style: {
        flex: 1
      }
    }, "Cancel"), /*#__PURE__*/React.createElement("button", {
      className: "pill-btn primary",
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "download"
    }), "Restore"))) : null;
    return /*#__PURE__*/React.createElement("div", {
      className: "app",
      style: {
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, variant === 'failed' && /*#__PURE__*/React.createElement(Banner, {
      tone: "danger",
      icon: "alert-circle"
    }, "Sign-in failed. Please try again."), variant === 'token-expired' && /*#__PURE__*/React.createElement(Banner, {
      tone: "warn",
      icon: "clock"
    }, "Your session expired. Sign in again to keep syncing."), /*#__PURE__*/React.createElement(AccountBlock, {
      variant: variant
    }), showBackup && /*#__PURE__*/React.createElement(BackupBlock, {
      variant: variant
    }), showLog && /*#__PURE__*/React.createElement(SyncLog, null)), overlay);
  }
  window.MEMOX_KIT.register({
    num: '21',
    title: 'Account sync',
    states: [{
      label: 'Signed out',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "signed-out"
      })
    }, {
      label: 'Signing in',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "signing-in"
      })
    }, {
      label: 'Failed',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "failed"
      })
    }, {
      label: 'No backup',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "no-backup"
      })
    }, {
      label: 'Ready',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "ready"
      })
    }, {
      label: 'Uploading',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "uploading"
      })
    }, {
      label: 'Restore warn',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "restore-warn"
      })
    }, {
      label: 'Restoring',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "restoring"
      })
    }, {
      label: 'Token expired',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "token-expired"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/21-account-sync.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/22-learning-settings.jsx
try { (() => {
/* MemoX screen — 22 Learning settings (5 states). Daily goal + reminders.
   App bar · Daily goal card (toggle + slider/stepper of cards) · Reminder card
   (toggle + time). States: goal on · goal off · reminder on · perm denied
   (notification permission refused → banner) · saving. Token-driven; composes
   shared primitives + contract classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    IconTile,
    Toggle,
    Slider,
    Banner,
    BusyOverlay
  } = window.MX;
  const Bar = () => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      marginLeft: S(2)
    }
  }, "Learning"));
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);
  const RowHead = ({
    icon,
    tint,
    title,
    desc,
    on,
    disabled
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(3)
    }
  }, /*#__PURE__*/React.createElement(IconTile, {
    icon: icon,
    color: tint
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "title"
  }, title), /*#__PURE__*/React.createElement("div", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-body-small)'
    }
  }, desc)), /*#__PURE__*/React.createElement(Toggle, {
    on: on,
    disabled: disabled
  }));
  const PRESETS = [10, 20, 30, 50];
  const GoalCard = ({
    on
  }) => /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(4)
    }
  }, /*#__PURE__*/React.createElement(RowHead, {
    icon: "target",
    tint: "var(--memox-status-new)",
    title: "Daily goal",
    desc: on ? 'Cards to study each day' : 'Turned off — study freely',
    on: on
  }), on && /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "hr"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--memox-size-display)',
      fontWeight: 'var(--memox-weight-extrabold)',
      color: 'var(--memox-text-primary)',
      letterSpacing: 'var(--memox-tracking-tight)',
      lineHeight: 1
    }
  }, "20"), /*#__PURE__*/React.createElement("span", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      fontWeight: 'var(--memox-weight-semibold)'
    }
  }, "cards / day")), /*#__PURE__*/React.createElement(Slider, {
    value: 20,
    min: 5,
    max: 60
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: S(2)
    }
  }, PRESETS.map(p => /*#__PURE__*/React.createElement("span", {
    key: p,
    className: `chip${p === 20 ? ' due solid' : ''}`,
    style: {
      flex: 1,
      justifyContent: 'center',
      cursor: 'pointer'
    }
  }, p)))));
  const ReminderCard = ({
    on,
    disabled
  }) => /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(4),
      opacity: disabled ? 'var(--memox-op-disabled)' : 1
    }
  }, /*#__PURE__*/React.createElement(RowHead, {
    icon: "bell",
    tint: "var(--memox-status-learning)",
    title: "Daily reminder",
    desc: on ? 'A nudge to keep your streak' : 'No reminder set',
    on: on,
    disabled: disabled
  }), on && !disabled && /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "hr"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row",
    style: {
      margin: 0,
      padding: `${S(2)} 0`
    }
  }, /*#__PURE__*/React.createElement(IconTile, {
    icon: "clock",
    color: "var(--memox-text-secondary)"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title"
  }, "Time")), /*#__PURE__*/React.createElement("span", {
    className: "list-row-trail"
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      fontWeight: 'var(--memox-weight-bold)',
      color: 'var(--memox-text-primary)'
    }
  }, "8:00 PM"), /*#__PURE__*/React.createElement(Icon, {
    name: "chevron-right"
  }))), /*#__PURE__*/React.createElement("div", {
    className: "hr inset"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row",
    style: {
      margin: 0,
      padding: `${S(2)} 0`
    }
  }, /*#__PURE__*/React.createElement(IconTile, {
    icon: "repeat",
    color: "var(--memox-text-secondary)"
  }), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title"
  }, "Repeat")), /*#__PURE__*/React.createElement("span", {
    className: "list-row-trail"
  }, /*#__PURE__*/React.createElement("span", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      fontWeight: 'var(--memox-weight-semibold)'
    }
  }, "Every day"), /*#__PURE__*/React.createElement(Icon, {
    name: "chevron-right"
  })))));
  function Screen({
    variant
  }) {
    const goalOn = variant !== 'goal-off';
    const reminderOn = variant === 'reminder-on';
    const permDenied = variant === 'perm-denied';
    return /*#__PURE__*/React.createElement("div", {
      className: "app",
      style: {
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, permDenied && /*#__PURE__*/React.createElement(Banner, {
      tone: "warn",
      icon: "bell-off"
    }, "Notifications are blocked. Enable them in system settings to get reminders."), /*#__PURE__*/React.createElement(GoalCard, {
      on: goalOn
    }), /*#__PURE__*/React.createElement(ReminderCard, {
      on: permDenied ? true : reminderOn,
      disabled: permDenied
    }), permDenied && /*#__PURE__*/React.createElement("button", {
      className: "pill-btn outline",
      style: {
        width: '100%'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "settings"
    }), "Open system settings")), variant === 'saving' && /*#__PURE__*/React.createElement(BusyOverlay, {
      label: "Saving\u2026"
    }));
  }
  window.MEMOX_KIT.register({
    num: '22',
    title: 'Learning settings',
    states: [{
      label: 'Goal on',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "goal-on"
      })
    }, {
      label: 'Goal off',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "goal-off"
      })
    }, {
      label: 'Reminder on',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "reminder-on"
      })
    }, {
      label: 'Perm denied',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "perm-denied"
      })
    }, {
      label: 'Saving',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "saving"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/22-learning-settings.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/23-audio-speech.jsx
try { (() => {
/* MemoX screen — 23 Audio & speech (7 states). Text-to-speech: voice language,
   voice list (radio), a preview, and speed/pitch. States: Korean · English ·
   loading · no voices (empty) · engine error · playing (stop + waveform) ·
   saving. Token-driven; composes shared primitives + contract classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    RadioRow,
    Slider,
    HeroCard,
    BusyOverlay,
    Sk
  } = window.MX;
  const Bar = () => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      marginLeft: S(2)
    }
  }, "Audio & speech"));
  const Body = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      overflowY: 'auto',
      padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`,
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-gap-section)'
    }
  }, children);
  const SectionLabel = ({
    children
  }) => /*#__PURE__*/React.createElement("div", {
    className: "ov",
    style: {
      paddingLeft: S(1)
    }
  }, children);
  const VOICES = {
    Korean: {
      sample: '안녕하세요, 오늘도 공부해요.',
      list: [{
        name: 'Yuna',
        desc: 'Female · Neural',
        sel: true
      }, {
        name: 'Minho',
        desc: 'Male · Neural'
      }, {
        name: 'Sora',
        desc: 'Female · Standard'
      }]
    },
    English: {
      sample: 'The quick brown fox jumps over the lazy dog.',
      list: [{
        name: 'Ava',
        desc: 'Female · US · Neural',
        sel: true
      }, {
        name: 'James',
        desc: 'Male · UK'
      }, {
        name: 'Emma',
        desc: 'Female · UK'
      }]
    }
  };
  const LangRow = ({
    lang
  }) => /*#__PURE__*/React.createElement("div", {
    className: "list-card"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row"
  }, /*#__PURE__*/React.createElement("span", {
    className: "icon-tile",
    style: {
      '--tile': 'var(--memox-status-reviewing)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "languages"
  })), /*#__PURE__*/React.createElement("div", {
    className: "list-row-main"
  }, /*#__PURE__*/React.createElement("div", {
    className: "list-row-title"
  }, "Voice language")), /*#__PURE__*/React.createElement("span", {
    className: "list-row-trail"
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      fontWeight: 'var(--memox-weight-bold)',
      color: 'var(--memox-text-primary)'
    }
  }, lang), /*#__PURE__*/React.createElement(Icon, {
    name: "chevron-right"
  }))));
  const PreviewCard = ({
    sample,
    playing
  }) => /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(3)
    }
  }, /*#__PURE__*/React.createElement(SectionLabel, null, "Preview"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 'var(--memox-size-h2)',
      fontWeight: 'var(--memox-weight-semibold)',
      color: 'var(--memox-text-primary)',
      fontFamily: 'var(--memox-font-serif)',
      lineHeight: 1.4
    }
  }, sample), playing ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: S(3)
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "pill-btn primary",
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "square"
  }), "Stop"), /*#__PURE__*/React.createElement("div", {
    className: "waveform"
  }, /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("span", null), /*#__PURE__*/React.createElement("span", null))) : /*#__PURE__*/React.createElement("button", {
    className: "pill-btn secondary",
    style: {
      width: '100%'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "play"
  }), "Play sample"));
  const Tuning = () => /*#__PURE__*/React.createElement("div", {
    className: "card",
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(5)
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "section-head"
  }, /*#__PURE__*/React.createElement("span", {
    className: "title"
  }, "Speed"), /*#__PURE__*/React.createElement("span", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      fontWeight: 'var(--memox-weight-bold)'
    }
  }, "1.0\xD7")), /*#__PURE__*/React.createElement(Slider, {
    value: 1,
    min: 0.5,
    max: 2
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: S(2)
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "section-head"
  }, /*#__PURE__*/React.createElement("span", {
    className: "title"
  }, "Pitch"), /*#__PURE__*/React.createElement("span", {
    className: "muted",
    style: {
      fontSize: 'var(--memox-fs-label-large)',
      fontWeight: 'var(--memox-weight-bold)'
    }
  }, "Normal")), /*#__PURE__*/React.createElement(Slider, {
    value: 50,
    min: 0,
    max: 100
  })));
  function Screen({
    variant
  }) {
    if (variant === 'loading') {
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement(Sk, {
        h: "64px",
        r: "var(--memox-radius-card)"
      }), /*#__PURE__*/React.createElement("div", {
        className: "card",
        style: {
          display: 'flex',
          flexDirection: 'column',
          gap: S(4),
          padding: `${S(2)} var(--memox-space-card)`
        }
      }, [0, 1, 2].map(i => /*#__PURE__*/React.createElement("div", {
        key: i,
        style: {
          display: 'flex',
          alignItems: 'center',
          gap: S(3)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "40px",
        w: "40px",
        r: "var(--memox-radius-md)"
      }), /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          gap: S(2)
        }
      }, /*#__PURE__*/React.createElement(Sk, {
        h: "14px",
        w: "40%"
      }), /*#__PURE__*/React.createElement(Sk, {
        h: "11px",
        w: "55%"
      })), /*#__PURE__*/React.createElement(Sk, {
        h: "22px",
        w: "22px",
        r: "var(--memox-radius-full)"
      }))))));
    }
    if (variant === 'no-voices' || variant === 'engine-error') {
      const err = variant === 'engine-error';
      return /*#__PURE__*/React.createElement("div", {
        className: "app"
      }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
        style: {
          flex: 1,
          display: 'grid',
          placeItems: 'center',
          padding: `${S(6)} 0`
        }
      }, /*#__PURE__*/React.createElement(HeroCard, {
        icon: err ? 'alert-triangle' : 'volume-x',
        tint: err ? 'var(--memox-danger)' : 'var(--memox-text-secondary)',
        title: err ? 'Speech engine unavailable' : 'No voices installed',
        desc: err ? "MemoX couldn't reach the device's text-to-speech engine." : 'Your device has no text-to-speech voices for this language yet.'
      }, /*#__PURE__*/React.createElement("button", {
        className: "pill-btn primary",
        style: {
          width: '100%'
        }
      }, /*#__PURE__*/React.createElement(Icon, {
        name: err ? 'rotate-ccw' : 'settings'
      }), err ? 'Try again' : 'Install voices')))));
    }
    const lang = variant === 'English' ? 'English' : 'Korean';
    const data = VOICES[lang];
    const playing = variant === 'playing';
    return /*#__PURE__*/React.createElement("div", {
      className: "app",
      style: {
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(Body, null, /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement(SectionLabel, null, "Language"), /*#__PURE__*/React.createElement(LangRow, {
      lang: lang
    })), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        flexDirection: 'column',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement(SectionLabel, null, "Voice"), /*#__PURE__*/React.createElement("div", {
      className: "list-card"
    }, data.list.map((v, i) => /*#__PURE__*/React.createElement("div", {
      key: v.name
    }, i > 0 && /*#__PURE__*/React.createElement("div", {
      className: "hr inset"
    }), /*#__PURE__*/React.createElement(RadioRow, {
      icon: "mic",
      tint: "var(--memox-status-new)",
      title: v.name,
      desc: v.desc,
      selected: v.sel
    }))))), /*#__PURE__*/React.createElement(PreviewCard, {
      sample: data.sample,
      playing: playing
    }), /*#__PURE__*/React.createElement(Tuning, null)), variant === 'saving' && /*#__PURE__*/React.createElement(BusyOverlay, {
      label: "Saving\u2026"
    }));
  }
  window.MEMOX_KIT.register({
    num: '23',
    title: 'Audio & speech',
    states: [{
      label: 'Korean',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "Korean"
      })
    }, {
      label: 'English',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "English"
      })
    }, {
      label: 'Playing',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "playing"
      })
    }, {
      label: 'Loading',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "loading"
      })
    }, {
      label: 'No voices',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "no-voices"
      })
    }, {
      label: 'Engine error',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "engine-error"
      })
    }, {
      label: 'Saving',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        variant: "saving"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/23-audio-speech.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/24-appearance.jsx
try { (() => {
/* MemoX screen — 24 Appearance (3 states). Theme picker: Light · Dark · System,
   as a radio list with a live mini-preview swatch per option. The swatches force
   their palette via the .memox-light / .memox-dark token scopes, so each renders
   in its own theme regardless of the current one. Token-driven. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    RadioRow
  } = window.MX;
  const Bar = () => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      marginLeft: S(2)
    }
  }, "Appearance"));

  // Mini screen preview, forced into `theme` palette.
  const Swatch = ({
    theme
  }) => /*#__PURE__*/React.createElement("div", {
    className: theme,
    style: {
      width: 'var(--memox-size-fab)',
      height: 'var(--memox-size-fab)',
      flex: 'none',
      borderRadius: 'var(--memox-radius-md)',
      overflow: 'hidden',
      border: '1px solid var(--memox-border)',
      background: 'var(--memox-bg)',
      padding: 'var(--memox-space-2)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-space-1)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      height: 'var(--memox-space-2)',
      width: '55%',
      borderRadius: 'var(--memox-radius-xs)',
      background: 'var(--memox-accent)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 'var(--memox-space-2)',
      borderRadius: 'var(--memox-radius-xs)',
      background: 'var(--memox-surface)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 'var(--memox-space-2)',
      width: '80%',
      borderRadius: 'var(--memox-radius-xs)',
      background: 'var(--memox-surface)'
    }
  }));
  const SystemSwatch = () => /*#__PURE__*/React.createElement("div", {
    style: {
      width: 'var(--memox-size-fab)',
      height: 'var(--memox-size-fab)',
      flex: 'none',
      borderRadius: 'var(--memox-radius-md)',
      overflow: 'hidden',
      border: '1px solid var(--memox-border)',
      display: 'flex'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "memox-light",
    style: {
      flex: 1,
      background: 'var(--memox-bg)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-space-1)',
      padding: 'var(--memox-space-1)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      height: 'var(--memox-space-2)',
      borderRadius: 'var(--memox-radius-xs)',
      background: 'var(--memox-accent)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 'var(--memox-space-2)',
      borderRadius: 'var(--memox-radius-xs)',
      background: 'var(--memox-surface)'
    }
  })), /*#__PURE__*/React.createElement("div", {
    className: "memox-dark",
    style: {
      flex: 1,
      background: 'var(--memox-bg)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--memox-space-1)',
      padding: 'var(--memox-space-1)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      height: 'var(--memox-space-2)',
      borderRadius: 'var(--memox-radius-xs)',
      background: 'var(--memox-accent)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 'var(--memox-space-2)',
      borderRadius: 'var(--memox-radius-xs)',
      background: 'var(--memox-surface)'
    }
  })));
  const OPTIONS = [{
    key: 'light',
    title: 'Light',
    desc: 'Always light',
    swatch: /*#__PURE__*/React.createElement(Swatch, {
      theme: "memox-light"
    })
  }, {
    key: 'dark',
    title: 'Dark',
    desc: 'Always dark',
    swatch: /*#__PURE__*/React.createElement(Swatch, {
      theme: "memox-dark"
    })
  }, {
    key: 'system',
    title: 'System',
    desc: 'Match device setting',
    swatch: /*#__PURE__*/React.createElement(SystemSwatch, null)
  }];
  function Screen({
    selected
  }) {
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        minHeight: 0,
        overflowY: 'auto',
        padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`,
        display: 'flex',
        flexDirection: 'column',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "ov",
      style: {
        paddingLeft: S(1)
      }
    }, "Theme"), /*#__PURE__*/React.createElement("div", {
      className: "list-card"
    }, OPTIONS.map((o, i) => /*#__PURE__*/React.createElement("div", {
      key: o.key
    }, i > 0 && /*#__PURE__*/React.createElement("div", {
      className: "hr"
    }), /*#__PURE__*/React.createElement(RadioRow, {
      lead: o.swatch,
      title: o.title,
      desc: o.desc,
      selected: o.key === selected
    })))), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-body-small)',
        padding: `${S(2)} ${S(1)} 0`,
        display: 'flex',
        alignItems: 'center',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "info",
      style: {
        width: 'var(--memox-icon-sm)',
        height: 'var(--memox-icon-sm)'
      }
    }), "System follows your device's light/dark schedule.")));
  }
  window.MEMOX_KIT.register({
    num: '24',
    title: 'Appearance',
    states: [{
      label: 'System',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        selected: "system"
      })
    }, {
      label: 'Light',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        selected: "light"
      })
    }, {
      label: 'Dark',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        selected: "dark"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/24-appearance.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/screens/25-language.jsx
try { (() => {
/* MemoX screen — 25 Language (3 states). App-language picker: System default ·
   English · Tiếng Việt, as a simple radio list. Token-driven; composes shared
   primitives + contract classes. */
(function () {
  if (!window.MX || !window.MEMOX_KIT || !window.MEMOX_KIT.register) return;
  const {
    Icon,
    S,
    RadioRow
  } = window.MX;
  const Bar = () => /*#__PURE__*/React.createElement("div", {
    className: "appbar"
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow-left"
  })), /*#__PURE__*/React.createElement("span", {
    className: "appbar-title",
    style: {
      flex: 1,
      marginLeft: S(2)
    }
  }, "Language"));
  const OPTIONS = [{
    key: 'system',
    icon: 'smartphone',
    tint: 'var(--memox-text-secondary)',
    title: 'System default',
    desc: 'English (United States)'
  }, {
    key: 'en',
    icon: 'globe',
    tint: 'var(--memox-status-new)',
    title: 'English',
    desc: 'English'
  }, {
    key: 'vi',
    icon: 'globe',
    tint: 'var(--memox-status-mastered)',
    title: 'Tiếng Việt',
    desc: 'Vietnamese'
  }];
  function Screen({
    selected
  }) {
    return /*#__PURE__*/React.createElement("div", {
      className: "app"
    }, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        minHeight: 0,
        overflowY: 'auto',
        padding: `${S(4)} var(--memox-space-screen) var(--memox-space-6)`,
        display: 'flex',
        flexDirection: 'column',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "ov",
      style: {
        paddingLeft: S(1)
      }
    }, "App language"), /*#__PURE__*/React.createElement("div", {
      className: "list-card"
    }, OPTIONS.map((o, i) => /*#__PURE__*/React.createElement("div", {
      key: o.key
    }, i > 0 && /*#__PURE__*/React.createElement("div", {
      className: "hr inset"
    }), /*#__PURE__*/React.createElement(RadioRow, {
      icon: o.icon,
      tint: o.tint,
      title: o.title,
      desc: o.desc,
      selected: o.key === selected
    })))), /*#__PURE__*/React.createElement("div", {
      className: "muted",
      style: {
        fontSize: 'var(--memox-fs-body-small)',
        padding: `${S(2)} ${S(1)} 0`,
        display: 'flex',
        alignItems: 'center',
        gap: S(2)
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "info",
      style: {
        width: 'var(--memox-icon-sm)',
        height: 'var(--memox-icon-sm)'
      }
    }), "Changing the language restarts the app.")));
  }
  window.MEMOX_KIT.register({
    num: '25',
    title: 'Language',
    states: [{
      label: 'System',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        selected: "system"
      })
    }, {
      label: 'English',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        selected: "en"
      })
    }, {
      label: 'Vietnamese',
      render: () => /*#__PURE__*/React.createElement(Screen, {
        selected: "vi"
      })
    }]
  });
})();
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/screens/25-language.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Avatar = __ds_scope.Avatar;

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.Chip = __ds_scope.Chip;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.SegmentedControl = __ds_scope.SegmentedControl;

__ds_ns.Switch = __ds_scope.Switch;

__ds_ns.NoteCard = __ds_scope.NoteCard;

})();
