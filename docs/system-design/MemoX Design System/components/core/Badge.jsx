import React from 'react';

/**
 * MemoX Badge — compact status/label pill. Tones map to semantic tokens.
 */
export function Badge({ children, tone = 'neutral', icon, solid = false, style, ...rest }) {
  const tones = {
    neutral: ['var(--memox-surface-2)', 'var(--memox-text-2)'],
    accent: ['var(--memox-accent-soft)', 'var(--memox-text-accent)'],
    success: ['var(--memox-success-soft)', 'var(--memox-success)'],
    warn: ['var(--memox-warn-soft)', 'var(--memox-warn)'],
    danger: ['var(--memox-danger-soft)', 'var(--memox-danger)'],
    info: ['var(--memox-info-soft)', 'var(--memox-info)'],
  };
  const [bg, fg] = tones[tone] || tones.neutral;

  return (
    <span
      style={{
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
        ...style,
      }}
      {...rest}
    >
      {icon && <i data-lucide={icon} style={{ width: 13, height: 13 }}></i>}
      {children}
    </span>
  );
}
