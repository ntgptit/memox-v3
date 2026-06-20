import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// A circular daily-goal ring (the kit `GoalRing`): an arc of `value / total`
/// over a track, with the count in the center.
///
/// Purpose:
/// One owner for the goal ring so Progress (and anywhere a goal lives) shares the
/// same arc + center treatment. The sweep is derived from the value (no magic
/// sweep number); it turns mastered-green when [met] and flattens to the track
/// when [paused].
///
/// Use when:
/// Showing progress toward a countable daily goal.
///
/// Do not use when:
/// You need a linear progress bar (use `MxProgress`) or an indeterminate spinner.
///
/// Category:
/// display
///
/// Public API:
/// - value / total: completed vs target (drive the 0..1 sweep, clamped).
/// - label: caller-localized center copy (e.g. "12/20"); kept as a parameter so
///   the widget owns no hardcoded copy.
/// - met: render the goal-reached (mastered-green) arc.
/// - paused: flatten to the track only (no arc).
class MxGoalRing extends StatelessWidget {
  const MxGoalRing({
    required this.value,
    required this.total,
    required this.label,
    this.met = false,
    this.paused = false,
    super.key,
  });

  final int value;
  final int total;
  final String label;
  final bool met;
  final bool paused;

  /// Ring diameter — the kit `--memox-size-ring` (72). Not on the spacing scale,
  /// so it is named here.
  static const double _diameter = 72;
  static const double _stroke = 8;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final double sweep = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    final Color arc = met ? colors.statusMastered : colors.accent;
    return SizedBox(
      width: _diameter,
      height: _diameter,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: _diameter,
            height: _diameter,
            child: CircularProgressIndicator(
              value: paused ? 0 : sweep,
              strokeWidth: _stroke,
              backgroundColor: colors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(arc),
            ),
          ),
          MxText(label, role: MxTextRole.titleSmall),
        ],
      ),
    );
  }
}
