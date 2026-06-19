import * as React from 'react';

export interface SwitchProps {
  /** On/off state. */
  checked?: boolean;
  /** Called with the next boolean when toggled. */
  onChange?: (next: boolean) => void;
  disabled?: boolean;
  style?: React.CSSProperties;
}

/** Boolean toggle switch (accent when on). */
export function Switch(props: SwitchProps): JSX.Element;
