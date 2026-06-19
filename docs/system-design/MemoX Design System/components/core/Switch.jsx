import React from 'react';

/**
 * MemoX Switch — boolean toggle. Controlled via `checked` + `onChange`.
 */
export function Switch({ checked = false, onChange, disabled = false, style, ...rest }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      disabled={disabled}
      onClick={disabled ? undefined : () => onChange && onChange(!checked)}
      style={{
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
        ...style,
      }}
      {...rest}
    >
      <span
        style={{
          width: 24,
          height: 24,
          borderRadius: 'var(--memox-radius-pill)',
          background: 'var(--memox-true-white)',
          boxShadow: 'var(--memox-shadow-sm)',
          transition: 'transform .18s ease',
        }}
      ></span>
    </button>
  );
}
