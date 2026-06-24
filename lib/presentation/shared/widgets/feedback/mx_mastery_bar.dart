import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_linear_progress.dart';

/// A per-deck mastery bar — the design-system mastery-bar primitive (kit
/// `MasteryBar`).
///
/// Purpose:
/// One owner of the mastery threshold → tint rule so weak decks read low and
/// strong decks read high consistently: fill width is [fraction] and the tint
/// steps through the mastery scale — `low` (< 50%), `mid` (50–79%), `high`
/// (≥ 80%) — matching the kit's `MASTERY_TINT`. Wraps [MxLinearProgress] so the
/// track/fill recipe stays in one place.
///
/// Use when:
/// Showing a deck's (or any item's) mastery as a single bounded bar tinted by
/// strength.
///
/// Category:
/// feedback
///
/// Public API:
/// - fraction: mastery in 0..1 (clamped).
class MxMasteryBar extends StatelessWidget {
  const MxMasteryBar({required this.fraction, super.key});

  /// Mastery in 0..1 (clamped).
  final double fraction;

  /// Mid-band lower bound (50%) — below this reads "low".
  static const double _midBand = 0.5;

  /// High-band lower bound (80%) — at/above this reads "high".
  static const double _highBand = 0.8;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final double value = fraction.clamp(0.0, 1.0);
    final Color tint = value >= _highBand
        ? colors.masteryHigh
        : value >= _midBand
        ? colors.masteryMid
        : colors.masteryLow;
    return MxLinearProgress(value: value, color: tint);
  }
}
