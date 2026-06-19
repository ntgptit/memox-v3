import * as React from 'react';

export interface AvatarProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** Full name; initials are derived and seed the fallback color. */
  name?: string;
  /** Optional image URL. */
  src?: string;
  /** Pixel diameter. @default 40 */
  size?: number;
  /** Override background color token. */
  color?: string;
}

/** Circular initials/image avatar with deterministic color from name. */
export function Avatar(props: AvatarProps): JSX.Element;
