import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// A thin, rounded determinate progress bar — the design-system linear-progress
/// primitive.
///
/// Purpose:
/// One shared linear-progress surface so feature code never reaches for a raw
/// [LinearProgressIndicator] (`memox.design_system.no_raw_progress_indicator`).
/// Fills with the accent token by default; pass [color] for a family variant
/// (e.g. the green production-mode family in study).
///
/// Use when:
/// Showing bounded progress through a known total — a study session's
/// answered/total, an import's processed rows, etc.
///
/// Category:
/// feedback
///
/// Public API:
/// - value: 0..1 progress (clamped).
/// - color: optional fill color; defaults to the accent token.
class MxLinearProgress extends StatelessWidget {
  const MxLinearProgress({required this.value, this.color, super.key});

  /// Progress in 0..1 (clamped).
  final double value;

  /// Fill color; defaults to the accent token.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return ClipRRect(
      borderRadius: MxRadius.pillAll,
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: MxSpacing.space2,
        color: color ?? colors.accent,
        backgroundColor: colors.surfaceMuted,
      ),
    );
  }
}
