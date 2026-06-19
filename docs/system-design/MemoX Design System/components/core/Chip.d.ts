import * as React from 'react';

export interface ChipProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Selected (accent-filled) state. */
  selected?: boolean;
  /** Color of a leading dot (e.g. a space/folder color token). */
  dot?: string;
  /** Lucide icon name. */
  icon?: string;
  children?: React.ReactNode;
}

/** Filter / selection pill used in horizontal scrollers. */
export function Chip(props: ChipProps): JSX.Element;
