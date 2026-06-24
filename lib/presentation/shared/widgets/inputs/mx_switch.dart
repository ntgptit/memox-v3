import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';

/// The design-system on/off toggle — the kit `Toggle` (`.switch`) primitive.
///
/// Purpose:
/// One shared switch surface so settings/feature code never reaches for a raw
/// [Switch] (`memox.design_system.no_raw_switch`). Tracks the accent token when
/// on; a null [onChanged] renders a disabled toggle (the kit's `disabled` state).
///
/// Use when:
/// A single boolean setting toggled in place — a daily-goal toggle, a dark-mode
/// switch, a TTS auto-play toggle.
///
/// Do not use when:
/// The choice is among several options (use a segmented control / radio rows),
/// or the action navigates rather than flips a boolean (use a list row).
///
/// Category:
/// input
///
/// Public API:
/// - value: current on/off state.
/// - onChanged: toggle callback; null disables the switch.
class MxSwitch extends StatelessWidget {
  const MxSwitch({required this.value, this.onChanged, super.key});

  /// Whether the switch is on.
  final bool value;

  /// Toggle callback; null renders a disabled switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? colors.accentContrast
            : colors.surface,
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? colors.accent
            : colors.surfaceMuted,
      ),
      trackOutlineWidth: WidgetStateProperty.all<double>(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
