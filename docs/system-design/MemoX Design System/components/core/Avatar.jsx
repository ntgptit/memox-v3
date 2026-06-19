import React from 'react';

const NOTE_TINTS = [
  'var(--memox-note-violet)', 'var(--memox-note-blue)', 'var(--memox-note-teal)',
  'var(--memox-note-green)', 'var(--memox-note-amber)', 'var(--memox-note-clay)',
];

/**
 * MemoX Avatar — initials or image. Color derives from name when not given.
 */
export function Avatar({ name = '', src, size = 40, color, style, ...rest }) {
  const initials = name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0])
    .join('')
    .toUpperCase();
  let hash = 0;
  for (let i = 0; i < name.length; i++) hash = (hash * 31 + name.charCodeAt(i)) >>> 0;
  const bg = color || NOTE_TINTS[hash % NOTE_TINTS.length];

  return (
    <span
      style={{
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
        ...style,
      }}
      {...rest}
    >
      {src ? (
        <img src={src} alt={name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      ) : (
        initials || '?'
      )}
    </span>
  );
}
