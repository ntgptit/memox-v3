import * as React from 'react';

export interface IconButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Lucide icon name. */
  icon: string;
  /** @default "ghost" */
  variant?: 'ghost' | 'surface' | 'accent';
  /** @default "md" */
  size?: 'sm' | 'md' | 'lg';
  /** Toggled/selected state (accent-soft tint). */
  active?: boolean;
  disabled?: boolean;
  /** Accessible label (aria-label). */
  label?: string;
}

/** Square icon-only button for toolbars and headers. */
export function IconButton(props: IconButtonProps): JSX.Element;
