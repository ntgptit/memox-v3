import React from 'react';

/**
 * MemoX Card — generic surface container with token elevation.
 */
export function Card({ children, elevation = 'sm', pad = 16, accent, style, ...rest }) {
  const shadows = {
    none: 'none',
    sm: 'var(--memox-shadow-sm)',
    md: 'var(--memox-shadow-md)',
    lg: 'var(--memox-shadow-lg)',
  };
  return (
    <div
      style={{
        position: 'relative',
        overflow: 'hidden',
        background: 'var(--memox-card)',
        border: '1px solid var(--memox-border)',
        borderRadius: 'var(--memox-radius-lg)',
        boxShadow: shadows[elevation] || shadows.sm,
        padding: pad,
        ...style,
      }}
      {...rest}
    >
      {accent && (
        <span
          style={{
            position: 'absolute',
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            background: accent,
          }}
        ></span>
      )}
      {children}
    </div>
  );
}
