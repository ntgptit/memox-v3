import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// One column of an [MxBarChart]: a [value] with its axis [label].
///
/// [value] is a real count (never "no data"); a zero still renders a thin stub
/// so the day stays on the axis. [semanticsLabel] is the spoken description for
/// the column (e.g. "Monday, 18 cards"); the chart composes them into one image
/// label so the data never depends on bar height or color alone.
@immutable
class MxBarDatum {
  const MxBarDatum({
    required this.label,
    required this.value,
    this.semanticsLabel,
  });

  final String label;
  final int value;
  final String? semanticsLabel;
}

/// A compact vertical column chart — the design-system bar-chart primitive (kit
/// `BarChart`).
///
/// Purpose:
/// One owner for the kit's weekly/period activity chart: a value label above
/// each bar, the bar scaled to the peak, and an axis label below — token sizes
/// and the accent fill — so Stats (screen 18) and Progress (screen 19) share the
/// same chart instead of re-implementing bars.
///
/// Use when:
/// Showing a small fixed set of labelled counts (a week / a period of days).
///
/// Category:
/// feedback
///
/// Public API:
/// - data: the columns, left to right.
/// - max: optional fixed peak for bar scaling; defaults to the largest value
///   (min 1, so an all-zero series renders flat stubs, never NaN).
/// - barColor: optional fill; defaults to the accent token.
class MxBarChart extends StatelessWidget {
  const MxBarChart({required this.data, this.max, this.barColor, super.key});

  final List<MxBarDatum> data;
  final int? max;
  final Color? barColor;

  /// Plot height (kit `--memox-space-12 * 3` = 144px) — the value label + bar +
  /// axis label all fit inside this.
  static const double _chartHeight = MxSpacing.space12 * 3;

  /// Smallest bar height fraction so a zero day still shows a thin stub on the
  /// axis (kit `Math.max(4, …)`).
  static const double _minBarFraction = 0.04;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final int peak = <int>[
      max ?? 0,
      1,
      for (final MxBarDatum d in data) d.value,
    ].reduce((int a, int b) => a > b ? a : b);

    return Semantics(
      image: true,
      label: <String>[
        for (final MxBarDatum d in data)
          d.semanticsLabel ?? '${d.label} ${d.value}',
      ].join(', '),
      child: ExcludeSemantics(
        child: SizedBox(
          height: _chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (int i = 0; i < data.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: MxSpacing.space2),
                Expanded(child: _column(colors, data[i], peak)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _column(MxColors colors, MxBarDatum datum, int peak) {
    final double raw = peak > 0 ? datum.value / peak : 0;
    final double fraction = raw < _minBarFraction
        ? _minBarFraction
        : (raw > 1 ? 1 : raw);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        MxText(
          '${datum.value}',
          role: MxTextRole.labelSmall,
          color: colors.textSecondary,
        ),
        const SizedBox(height: MxSpacing.space1),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: barColor ?? colors.accent,
                  borderRadius: MxRadius.smAll,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: MxSpacing.space1),
        MxText(
          datum.label,
          role: MxTextRole.labelSmall,
          color: colors.textSecondary,
        ),
      ],
    );
  }
}
