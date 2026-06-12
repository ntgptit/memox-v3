import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/types/progress_range.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Minimum distinct study days before trends/charts render
/// (mock: "Trend appears after 3 days of data").
const int kProgressTrendMinDays = 3;

/// "CARDS STUDIED" section: total + per-day bar chart for the range
/// (mock `shots/19-progress--week--*`; data-driven states per
/// `docs/wireframes/03-progress.md`).
class ProgressCardsStudiedCard extends StatelessWidget {
  const ProgressCardsStudiedCard({required this.activity, super.key});

  final ProgressActivity activity;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final bool hasChart = activity.range != ProgressRange.allTime;
    final int distinctDays = activity.distinctStudyDayCount;

    final String caption = switch (activity.range) {
      ProgressRange.week => l10n.progressCardsStudiedCaptionWeek,
      ProgressRange.month => l10n.progressCardsStudiedCaptionMonth,
      ProgressRange.allTime => l10n.progressCardsStudiedCaptionAllTime,
    };

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ProgressOverline(label: l10n.progressCardsStudiedTitle),
          if (distinctDays == 0)
            ProgressHintBox(text: l10n.progressChartEmptyHint)
          else ...<Widget>[
            const SizedBox(height: SpacingTokens.xxs),
            MxText(
              '${activity.totalAttempts}',
              role: MxTextRole.headlineMedium,
              color: scheme.onSurface,
            ),
            MxText(
              caption,
              role: MxTextRole.bodySmall,
              color: scheme.onSurfaceVariant,
            ),
            if (hasChart) ...<Widget>[
              const SizedBox(height: SpacingTokens.md),
              if (distinctDays < kProgressTrendMinDays) ...<Widget>[
                ProgressHintBox(
                  text: l10n.progressChartInsufficientHint(distinctDays),
                ),
                const SizedBox(height: SpacingTokens.sm),
                ProgressInfoBanner(
                  text: l10n.progressTrendBanner(kProgressTrendMinDays),
                ),
              ],
              if (distinctDays >= kProgressTrendMinDays)
                ProgressBarChart(days: activity.days),
            ],
          ],
        ],
      ),
    );
  }
}

/// "ACCURACY" section: range accuracy, delta vs the previous range, and a
/// per-day sparkline.
class ProgressAccuracyCard extends StatelessWidget {
  const ProgressAccuracyCard({required this.activity, super.key});

  final ProgressActivity activity;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;

    final int total = activity.totalAttempts;
    final int accuracy = total == 0
        ? 0
        : ((activity.correctAttempts / total) * 100).round();
    final int? previousAccuracy = activity.previousTotalAttempts == 0
        ? null
        : ((activity.previousCorrectAttempts / activity.previousTotalAttempts) *
                  100)
              .round();

    final String? deltaCaption = switch (activity.range) {
      ProgressRange.week => l10n.progressVsPreviousWeek,
      ProgressRange.month => l10n.progressVsPreviousMonth,
      ProgressRange.allTime => null,
    };

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ProgressOverline(label: l10n.progressAccuracyTitle),
          if (total == 0)
            ProgressHintBox(text: l10n.progressAccuracyEmptyHint)
          else ...<Widget>[
            const SizedBox(height: SpacingTokens.xxs),
            MxText(
              '$accuracy%',
              role: MxTextRole.headlineMedium,
              color: scheme.onSurface,
            ),
            if (previousAccuracy != null && deltaCaption != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.xxs),
              _AccuracyDeltaRow(
                delta: accuracy - previousAccuracy,
                caption: deltaCaption,
              ),
            ],
            if (activity.range != ProgressRange.allTime &&
                activity.distinctStudyDayCount >= 2) ...<Widget>[
              const SizedBox(height: SpacingTokens.md),
              ProgressSparkline(days: activity.days),
            ],
          ],
        ],
      ),
    );
  }
}

class _AccuracyDeltaRow extends StatelessWidget {
  const _AccuracyDeltaRow({required this.delta, required this.caption});

  final int delta;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color deltaColor = delta >= 0
        ? context.customColors.mastery
        : scheme.error;

    return Row(
      children: <Widget>[
        Icon(
          delta >= 0 ? Icons.trending_up : Icons.trending_down,
          size: SizeTokens.iconXs,
          color: deltaColor,
        ),
        const SizedBox(width: SpacingTokens.xxs),
        MxText(
          '${delta >= 0 ? '+' : ''}$delta%',
          role: MxTextRole.labelMedium,
          color: deltaColor,
        ),
        const SizedBox(width: SpacingTokens.xs),
        Expanded(
          child: MxText(
            caption,
            role: MxTextRole.bodySmall,
            color: scheme.onSurfaceVariant.withValues(
              alpha: OpacityTokens.surfaceGlass,
            ),
          ),
        ),
      ],
    );
  }
}

/// Per-day attempt bar chart (7 or 28 bars). Today's bar is full primary;
/// past days use a softened primary; zero days show a thin baseline stub.
class ProgressBarChart extends StatelessWidget {
  const ProgressBarChart({required this.days, super.key});

  final List<ProgressDayActivity> days;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final int maxCount = days.fold(
      0,
      (int max, ProgressDayActivity day) =>
          day.attemptCount > max ? day.attemptCount : max,
    );
    final bool week = days.length <= 7;

    return SizedBox(
      height: SizeTokens.chart,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (int i = 0; i < days.length; i++) ...<Widget>[
                  if (i > 0)
                    SizedBox(
                      width: week ? SpacingTokens.xs : SpacingTokens.xxs,
                    ),
                  Expanded(
                    child: _ChartBar(
                      fraction: maxCount == 0
                          ? 0
                          : days[i].attemptCount / maxCount,
                      isLast: i == days.length - 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xxs),
          Row(
            children: <Widget>[
              for (int i = 0; i < days.length; i++) ...<Widget>[
                if (i > 0)
                  SizedBox(width: week ? SpacingTokens.xs : SpacingTokens.xxs),
                Expanded(
                  child: _BarLabel(
                    day: days[i].day,
                    index: i,
                    week: week,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({required this.fraction, required this.isLast});

  final double fraction;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color color = isLast
        ? scheme.primary
        : scheme.primary.withValues(alpha: OpacityTokens.hint);

    return FractionallySizedBox(
      heightFactor: fraction <= 0 ? null : fraction.clamp(0.04, 1).toDouble(),
      alignment: Alignment.bottomCenter,
      child: Container(
        height: fraction <= 0 ? SizeTokens.dot : null,
        decoration: BoxDecoration(
          color: fraction <= 0 ? scheme.surfaceContainerHigh : color,
          borderRadius: RadiusTokens.brXs,
        ),
      ),
    );
  }
}

class _BarLabel extends StatelessWidget {
  const _BarLabel({
    required this.day,
    required this.index,
    required this.week,
    required this.color,
  });

  final DateTime day;
  final int index;
  final bool week;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    // Week: single-letter weekday under every bar. Month: day-of-month under
    // a sparse subset so 28 labels do not collide.
    final String text = week
        ? StringUtils.uppercased(
            DateFormat.E(locale).format(day).characters.first,
          )
        : (index % 5 == 0 ? '${day.day}' : '');
    return MxText(
      text,
      role: MxTextRole.labelSmall,
      color: color,
      textAlign: TextAlign.center,
    );
  }
}

/// Per-day accuracy sparkline (line chart) for the accuracy card.
class ProgressSparkline extends StatelessWidget {
  const ProgressSparkline({required this.days, super.key});

  final List<ProgressDayActivity> days;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return SizedBox(
      height: SizeTokens.chart,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(
          days: days,
          lineColor: scheme.primary,
          gridColor: scheme.surfaceContainerHigh,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.days,
    required this.lineColor,
    required this.gridColor,
  });

  final List<ProgressDayActivity> days;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final double y = size.height * (i + 1) / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final List<({double x, double y})> points = <({double x, double y})>[];
    for (int i = 0; i < days.length; i++) {
      final ProgressDayActivity day = days[i];
      if (day.attemptCount == 0) continue;
      final double accuracy = day.correctCount / day.attemptCount;
      points.add((
        x: days.length == 1 ? size.width : size.width * i / (days.length - 1),
        y: size.height * (1 - accuracy),
      ));
    }
    if (points.length < 2) return;

    final Paint line = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Path path = Path()..moveTo(points.first.x, points.first.y);
    for (final ({double x, double y}) point in points.skip(1)) {
      path.lineTo(point.x, point.y);
    }
    canvas.drawPath(path, line);

    final Paint dot = Paint()..color = lineColor;
    canvas.drawCircle(
      Offset(points.last.x, points.last.y),
      SpacingTokens.xs,
      Paint()..color = lineColor.withValues(alpha: OpacityTokens.selected),
    );
    canvas.drawCircle(
      Offset(points.last.x, points.last.y),
      SizeTokens.dot,
      dot,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.days != days ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.gridColor != gridColor;
}

/// Section overline label ("CARDS STUDIED" style).
class ProgressOverline extends StatelessWidget {
  const ProgressOverline({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => MxText(
    StringUtils.uppercased(label),
    role: MxTextRole.labelSmall,
    color: context.colorScheme.onSurfaceVariant,
  );
}

/// Centered hint box used by every section's data-empty state
/// (mock empty state: dash-bordered rounded box with muted copy).
class ProgressHintBox extends StatelessWidget {
  const ProgressHintBox({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.sm),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: scheme.outlineVariant,
          radius: RadiusTokens.brMd.topLeft,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: SpacingTokens.lg,
            horizontal: SpacingTokens.md,
          ),
          child: MxText(
            text,
            role: MxTextRole.bodySmall,
            color: scheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Dashed rounded border matching the mock's hint-box style; no dashed-border
/// primitive exists in the design system yet.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  static const double _dashLength = 4;
  static const double _gapLength = 3;
  static const double _strokeWidth = 1;

  final Color color;
  final Radius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;
    final Path border = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));
    for (final PathMetric metric in border.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashLength),
          paint,
        );
        distance += _dashLength + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Informational banner ("Trend appears after 3 days of data").
class ProgressInfoBanner extends StatelessWidget {
  const ProgressInfoBanner({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.xs,
        horizontal: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: OpacityTokens.softTint),
        borderRadius: RadiusTokens.brMd,
        border: Border.all(
          color: scheme.primary.withValues(alpha: OpacityTokens.borderSubtle),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: SizeTokens.iconXs,
            color: scheme.primary,
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: MxText(
              text,
              role: MxTextRole.bodySmall,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
