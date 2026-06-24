import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';

/// The design-system value slider — the kit `Slider` (`.slider`) primitive.
///
/// Purpose:
/// One shared slider surface so feature code never reaches for a raw [Slider]
/// (`memox.design_system.no_raw_slider`). Accent fill + thumb over a muted
/// track; a null [onChanged] renders a disabled slider.
///
/// Use when:
/// Picking a value on a bounded numeric range — a daily-goal card count, a TTS
/// speech rate.
///
/// Do not use when:
/// The value is unbounded or free-form (use a text field), or there are only a
/// few discrete choices better shown as chips / a segmented control.
///
/// Category:
/// input
///
/// Public API:
/// - value/min/max: current value and inclusive bounds (value is clamped).
/// - divisions: discrete stops (e.g. step 5 over 5..60 → 11).
/// - onChanged: value callback; null disables the slider.
class MxSlider extends StatelessWidget {
  const MxSlider({
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
    super.key,
  });

  /// Current value (clamped to [min]..[max]).
  final double value;

  /// Inclusive lower bound.
  final double min;

  /// Inclusive upper bound.
  final double max;

  /// Discrete stops; null for a continuous slider.
  final int? divisions;

  /// Value callback; null renders a disabled slider.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.surfaceMuted,
        thumbColor: colors.accent,
        overlayColor: colors.accentSoft,
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
