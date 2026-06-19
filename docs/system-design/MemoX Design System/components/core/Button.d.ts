import * as React from 'react';

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Visual style. @default "primary" */
  variant?: 'primary' | 'secondary' | 'ghost' | 'soft' | 'danger';
  /** Size. @default "md" */
  size?: 'sm' | 'md' | 'lg';
  /** Lucide icon name shown before the label. */
  icon?: string;
  /** Lucide icon name shown after the label. */
  iconRight?: string;
  /** Disabled state. */
  disabled?: boolean;
  /** Stretch to fill container width. */
  full?: boolean;
  children?: React.ReactNode;
}

/**
 * Primary tappable action for MemoX. Pill-shaped, token-driven.
 * @startingPoint section="Core" subtitle="Buttons — primary, secondary, ghost, soft, danger" viewport="700x150"
 */
export function Button(props: ButtonProps): JSX.Element;
