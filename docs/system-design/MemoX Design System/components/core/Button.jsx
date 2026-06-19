import React from 'react';

/**
 * MemoX Button — primary action control.
 * Variants read entirely from --memox-* tokens; never hardcode colors.
 */
export function Button({
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
    sm: { padding: '8px 14px', fontSize: 13, height: 36, gap: 6, icon: 16 },
    md: { padding: '11px 18px', fontSize: 15, height: 44, gap: 8, icon: 18 },
    lg: { padding: '14px 22px', fontSize: 16, height: 52, gap: 9, icon: 20 },
  };
  const s = sizes[size] || sizes.md;

  const variants = {
    primary: {
      background: 'var(--memox-accent)',
      color: 'var(--memox-accent-contrast)',
      border: '1px solid transparent',
      boxShadow: 'none',
    },
    secondary: {
      background: 'var(--memox-surface)',
      color: 'var(--memox-text)',
      border: '1px solid var(--memox-border-strong)',
      boxShadow: 'var(--memox-shadow-sm)',
    },
    ghost: {
      background: 'transparent',
      color: 'var(--memox-text-2)',
      border: '1px solid transparent',
      boxShadow: 'none',
    },
    soft: {
      background: 'var(--memox-accent-soft)',
      color: 'var(--memox-text-accent)',
      border: '1px solid transparent',
      boxShadow: 'none',
    },
    danger: {
      background: 'var(--memox-danger)',
      color: 'var(--memox-true-white)',
      border: '1px solid transparent',
      boxShadow: 'none',
    },
  };
  const v = variants[variant] || variants.primary;

  return (
    <button
      type="button"
      onClick={disabled ? undefined : onClick}
      disabled={disabled}
      style={{
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
        ...style,
      }}
      {...rest}
    >
      {icon && <i data-lucide={icon} style={{ width: s.icon, height: s.icon }}></i>}
      {children}
      {iconRight && <i data-lucide={iconRight} style={{ width: s.icon, height: s.icon }}></i>}
    </button>
  );
}
