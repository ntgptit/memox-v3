import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_stroke.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/domain/types/app_theme_mode.dart';

/// A mini theme-preview swatch (kit screen 24 lead): a small rounded panel of
/// accent/surface bars rendered in the option's own palette. [AppThemeMode.system]
/// shows a split light|dark panel.
class ThemeSwatch extends StatelessWidget {
  const ThemeSwatch({required this.mode, super.key});

  final AppThemeMode mode;

  static const double _size = MxSpacing.space12;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      width: _size,
      height: _size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: MxRadius.mdAll,
        border: Border.all(color: colors.border, width: MxStroke.hairline),
      ),
      child: switch (mode) {
        AppThemeMode.light => const _Panel(theme: AppThemeMode.light),
        AppThemeMode.dark => const _Panel(theme: AppThemeMode.dark),
        AppThemeMode.system => const Row(
          children: <Widget>[
            Expanded(child: _Panel(theme: AppThemeMode.light)),
            Expanded(child: _Panel(theme: AppThemeMode.dark)),
          ],
        ),
      },
    );
  }
}

/// A single panel forced into [theme]'s palette: accent + two surface bars.
class _Panel extends StatelessWidget {
  const _Panel({required this.theme});

  final AppThemeMode theme;

  @override
  Widget build(BuildContext context) {
    final ThemeData data = theme == AppThemeMode.dark
        ? MxTheme.dark
        : MxTheme.light;
    return Theme(
      data: data,
      child: Builder(
        builder: (BuildContext context) {
          final MxColors colors = context.mxColors;
          return Container(
            color: colors.bg,
            padding: const EdgeInsets.all(MxSpacing.space1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SwatchBar(color: colors.accent, widthFactor: 0.6),
                const SizedBox(height: MxSpacing.space1),
                _SwatchBar(color: colors.surface),
                const SizedBox(height: MxSpacing.space1),
                _SwatchBar(color: colors.surface, widthFactor: 0.8),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SwatchBar extends StatelessWidget {
  const _SwatchBar({required this.color, this.widthFactor = 1});

  final Color color;
  final double widthFactor;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    alignment: Alignment.centerLeft,
    widthFactor: widthFactor,
    child: Container(
      height: MxSpacing.space2,
      decoration: BoxDecoration(color: color, borderRadius: MxRadius.xsAll),
    ),
  );
}
