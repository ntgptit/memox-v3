import * as React from 'react';

export interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** @default "neutral" */
  tone?: 'neutral' | 'accent' | 'success' | 'warn' | 'danger' | 'info';
  /** Lucide icon name shown before the label. */
  icon?: string;
  /** Filled (solid) rather than soft-tinted. */
  solid?: boolean;
  children?: React.ReactNode;
}

/** Compact status/label pill with semantic tones. */
export function Badge(props: BadgeProps): JSX.Element;
