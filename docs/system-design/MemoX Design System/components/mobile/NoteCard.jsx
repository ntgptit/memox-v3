import React from 'react';
import { Badge } from '../core/Badge.jsx';

/**
 * MemoX NoteCard — the signature memo tile: tint bar, folder, title, preview, tags.
 */
export function NoteCard({
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
  return (
    <div
      onClick={onClick}
      style={{
        position: 'relative',
        overflow: 'hidden',
        background: 'var(--memox-card)',
        border: '1px solid var(--memox-border)',
        borderRadius: 'var(--memox-radius-lg)',
        boxShadow: 'var(--memox-shadow-sm)',
        padding: 16,
        cursor: onClick ? 'pointer' : 'default',
        fontFamily: 'var(--memox-font-sans)',
        ...style,
      }}
      {...rest}
    >
      <span style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 5, background: color }}></span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 7 }}>
        {folder && (
          <span
            style={{
              fontSize: 11,
              fontWeight: 700,
              color: 'var(--memox-text-3)',
              textTransform: 'uppercase',
              letterSpacing: '0.05em',
            }}
          >
            {folder}
          </span>
        )}
        {pinned && <i data-lucide="pin" style={{ width: 13, height: 13, color: 'var(--memox-accent)' }}></i>}
        <div style={{ flex: 1 }}></div>
        {time && <span style={{ fontSize: 11.5, color: 'var(--memox-text-3)', fontWeight: 600 }}>{time}</span>}
      </div>
      {title && (
        <div style={{ fontSize: 16, fontWeight: 700, marginBottom: 4, color: 'var(--memox-text)' }}>{title}</div>
      )}
      {body && (
        <div
          style={{
            fontSize: 13.5,
            lineHeight: 1.5,
            color: 'var(--memox-text-2)',
            display: '-webkit-box',
            WebkitLineClamp: 2,
            WebkitBoxOrient: 'vertical',
            overflow: 'hidden',
          }}
        >
          {body}
        </div>
      )}
      {tags.length > 0 && (
        <div style={{ display: 'flex', gap: 6, marginTop: 11, flexWrap: 'wrap' }}>
          {tags.map((t) => (
            <Badge key={t} tone="neutral">#{t}</Badge>
          ))}
        </div>
      )}
    </div>
  );
}
