import * as React from 'react';

export interface SegmentOption {
  value: string;
  label: string;
}

export interface SegmentedControlProps {
  /** Options as plain strings or {value,label} objects. */
  options: Array<string | SegmentOption>;
  /** Currently selected value. */
  value?: string;
  /** Called with the chosen value. */
  onChange?: (value: string) => void;
  style?: React.CSSProperties;
}

/** Pill segmented control for 2–4 short, mutually-exclusive options. */
export function SegmentedControl(props: SegmentedControlProps): JSX.Element;
