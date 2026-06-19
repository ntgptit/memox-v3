import React from 'react';

/**
 * MemoX IconButton — square, icon-only control. Good for toolbars & headers.
 */
export function IconButton({
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
  const sizes = { sm: 34, md: 40, lg: 48 };
  const iconSizes = { sm: 18, md: 20, lg: 22 };
  const dim = sizes[size] || sizes.md;

  const variants = {
    ghost: { background: 'transparent', color: 'var(--memox-text-2)', border: '1px solid transparent' },
    surface: { background: 'var(--memox-surface)', color: 'var(--memox-text)', border: '1px solid var(--memox-border)' },
    accent: { background: 'var(--memox-accent)', color: 'var(--memox-accent-contrast)', border: '1px solid transparent', boxShadow: 'var(--memox-shadow-md)' },
  };
  const v = active
    ? { background: 'var(--memox-accent-soft)', color: 'var(--memox-text-accent)', border: '1px solid transparent' }
    : (variants[variant] || variants.ghost);

  return (
    <button
      type="button"
      aria-label={label}
      onClick={disabled ? undefined : onClick}
      disabled={disabled}
      style={{
        width: dim,
        height: dim,
        display: 'grid',
        placeItems: 'center',
        borderRadius: variant === 'accent' ? 'var(--memox-radius-pill)' : 'var(--memox-radius-sm)',
        cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.45 : 1,
        transition: 'background .12s ease, transform .12s ease',
        ...v,
        ...style,
      }}
      {...rest}
    >
      <i data-lucide={icon} style={{ width: iconSizes[size] || 20, height: iconSizes[size] || 20 }}></i>
    </button>
  );
}
