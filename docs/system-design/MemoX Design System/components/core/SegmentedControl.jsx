import React from 'react';

/**
 * MemoX SegmentedControl — single-select among 2–4 short options.
 */
export function SegmentedControl({ options = [], value, onChange, style, ...rest }) {
  return (
    <div
      style={{
        display: 'flex',
        gap: 4,
        padding: 4,
        borderRadius: 'var(--memox-radius-pill)',
        background: 'var(--memox-surface-2)',
        border: '1px solid var(--memox-border)',
        ...style,
      }}
      {...rest}
    >
      {options.map((opt) => {
        const val = typeof opt === 'string' ? opt : opt.value;
        const label = typeof opt === 'string' ? opt : opt.label;
        const on = val === value;
        return (
          <button
            key={val}
            type="button"
            onClick={() => onChange && onChange(val)}
            style={{
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
              transition: 'background .14s ease, color .14s ease',
            }}
          >
            {label}
          </button>
        );
      })}
    </div>
  );
}
