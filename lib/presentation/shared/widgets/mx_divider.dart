import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_stroke.dart';

/// A hairline divider — the shared 1px separator drawn in the theme divider
/// color.
///
/// Purpose:
/// One hairline primitive (mirrors the kit `.hr`) so every separator shares the
/// same 1px weight and divider color, instead of raw Material `Divider`s with
/// ad-hoc height/thickness (guard `memox.design_system.no_raw_divider`).
///
/// Use when:
/// Separating rows inside a card or list section, or a sheet header from its
/// actions.
///
/// Do not use when:
/// You need vertical separation between inline elements (compose a sized gap).
///
/// Category:
/// display
///
/// Public API:
/// - indent: left inset of the hairline (e.g. under a row's text, past the
///   leading tile — the `.hr.inset` variant). Defaults to 0.
class MxDivider extends StatelessWidget {
  const MxDivider({this.indent = 0, super.key});

  /// Left inset of the hairline.
  final double indent;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        height: MxStroke.hairline,
        width: double.infinity,
        color: colors.divider,
      ),
    );
  }
}
