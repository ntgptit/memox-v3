import * as React from 'react';

export interface NoteCardProps extends React.HTMLAttributes<HTMLDivElement> {
  title?: string;
  /** Preview text (clamped to 2 lines). */
  body?: string;
  /** Folder / space name (shown uppercased). */
  folder?: string;
  /** Relative time label. */
  time?: string;
  /** Left tint-bar color (a --memox-note-* token). */
  color?: string;
  pinned?: boolean;
  /** Tag labels (rendered as # badges). */
  tags?: string[];
}

/**
 * The signature MemoX memo tile.
 * @startingPoint section="Mobile" subtitle="Note tile with tint bar, folder, preview & tags" viewport="360x180"
 */
export function NoteCard(props: NoteCardProps): JSX.Element;
