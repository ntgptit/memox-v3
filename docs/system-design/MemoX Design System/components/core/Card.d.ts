import * as React from 'react';

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Shadow depth. @default "sm" */
  elevation?: 'none' | 'sm' | 'md' | 'lg';
  /** Inner padding (px). @default 16 */
  pad?: number;
  /** Optional left accent-bar color (e.g. a note tint token). */
  accent?: string;
  children?: React.ReactNode;
}

/** Generic surface container with token-driven elevation and optional accent bar. */
export function Card(props: CardProps): JSX.Element;
