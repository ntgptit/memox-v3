import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';

/// The design-system radio indicator — the kit `.radio` primitive.
///
/// Purpose:
/// One shared single-select indicator so settings/picker code never reaches for
/// a raw [Radio] (`memox.design_system.no_raw_radio`). An accent ring + filled
/// dot when [selected]; a muted ring otherwise. Selection is driven by the
/// enclosing row's `onTap` (this is a presentational indicator, not a control).
///
/// Use when:
/// Showing the selected option in a single-select list — a theme picker, a
/// language/voice picker.
///
/// Do not use when:
/// The choice is a boolean (use [MxSwitch]) or multiple options can be selected
/// (use checkboxes / chips).
///
/// Category:
/// input
///
/// Public API:
/// - selected: whether this option is the chosen one.
class MxRadio extends StatelessWidget {
  const MxRadio({required this.selected, super.key});

  /// Whether this option is currently selected.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return SizedBox(
      width: MxSpacing.space5,
      height: MxSpacing.space5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? colors.accent : colors.borderStrong,
            width: MxStroke.emphasis,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: MxSpacing.space2,
                  height: MxSpacing.space2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.accent,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
