import 'dart:async';

import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// One column of an [MxBarChart].
class MxBarDatum {
  const MxBarDatum({required this.value, required this.label, this.highlight = false});

  /// Raw magnitude; bars are normalized against the max in the set.
  final double value;
  final String label;

  /// Render in `primary` (e.g. "today"); others use the neutral track color.
  final bool highlight;
}

/// 7-day activity bar chart with a `chartDraw` (600ms) grow-in entrance.
///
/// Section E of the handoff. Lightweight `CustomPaint` — no charting
/// dependency. Highlighted bars use `primary`; the rest use
/// `surfaceContainerHighest`. Honors reduced-motion (skips the entrance).
class MxBarChart extends StatefulWidget {
  const MxBarChart({required this.data, this.height = 80, super.key});

  final List<MxBarDatum> data;
  final double height;

  @override
  State<MxBarChart> createState() => _MxBarChartState();
}

class _MxBarChartState extends State<MxBarChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DurationTokens.chartDraw,
  );
  late final Animation<double> _grow = CurvedAnimation(
    parent: _controller,
    curve: EasingTokens.emphasized,
  );

  @override
  void initState() {
    super.initState();
    _controller.value = 1; // safe default until first frame resolves motion pref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
        return;
      }
      unawaited(_controller.forward(from: 0));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final double maxValue = widget.data.fold<double>(
      0,
      (double m, MxBarDatum d) => d.value > m ? d.value : m,
    );
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _grow,
        builder: (BuildContext context, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (final MxBarDatum datum in widget.data)
                Expanded(
                  child: _Bar(
                    datum: datum,
                    maxValue: maxValue,
                    progress: _grow.value,
                    barColor: datum.highlight
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    labelColor: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.datum,
    required this.maxValue,
    required this.progress,
    required this.barColor,
    required this.labelColor,
  });

  final MxBarDatum datum;
  final double maxValue;
  final double progress;
  final Color barColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final double ratio = maxValue <= 0 ? 0 : datum.value / maxValue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: (ratio * progress).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: RadiusTokens.brXs,
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs + 1),
          Text(
            datum.label,
            style: context.textTheme.labelSmall?.copyWith(color: labelColor),
          ),
        ],
      ),
    );
  }
}
