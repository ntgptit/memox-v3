import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/widgets/status/mx_card_status.dart';

/// Mastery percentage as a 40×3px arc with the percent in the middle.
///
/// Section E of the handoff. The arc color steps with the percentage via
/// [masteryColor] (`< 34 / < 67 / ≥ 67`).
class MxMasteryRing extends StatelessWidget {
  const MxMasteryRing({
    required this.pct,
    this.size = 40,
    this.strokeWidth = 3,
    this.showLabel = true,
    super.key,
  });

  /// Mastery in `0..1`.
  final double pct;
  final double size;
  final double strokeWidth;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final double value = pct.clamp(0, 1);
    final Color tone = masteryColor(context, value);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MasteryRingPainter(
          value: value,
          color: tone,
          track: context.colorScheme.surfaceContainerHighest,
          strokeWidth: strokeWidth,
        ),
        child: showLabel
            ? Center(
                child: Text(
                  '${(value * 100).round()}',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: tone,
                    fontWeight: TypographyTokens.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _MasteryRingPainter extends CustomPainter {
  _MasteryRingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color track;
  final double strokeWidth;

  static const double _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, base..color = track);
    if (value > 0) {
      canvas.drawArc(rect, _start, 2 * math.pi * value, false, base..color = color);
    }
  }

  @override
  bool shouldRepaint(_MasteryRingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}
