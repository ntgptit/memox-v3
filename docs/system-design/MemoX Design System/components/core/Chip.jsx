import React from 'react';

/**
 * MemoX Chip — filter / selection pill. Selected state uses accent fill.
 */
export function Chip({ children, selected = false, dot, icon, onClick, style, ...rest }) {
  return (
    <button
      type="button"
      onClick={onClick}
      style={{
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
        ...style,
      }}
      {...rest}
    >
      {dot && <span style={{ width: 9, height: 9, borderRadius: 3, background: dot }}></span>}
      {icon && <i data-lucide={icon} style={{ width: 15, height: 15 }}></i>}
      {children}
    </button>
  );
}
