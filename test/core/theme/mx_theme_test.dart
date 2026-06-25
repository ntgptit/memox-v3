import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_shadows.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/core/theme/mx_typography.dart';

void main() {
  group('MxTheme', () {
    test('light theme uses Material 3, light brightness, and bg scaffold', () {
      final ThemeData theme = MxTheme.light;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, MxColors.light.bg);
      expect(
        theme.textTheme.bodyMedium?.fontFamily,
        MxTypography.fontFamilySans,
      );
      // CJK fallback chain is applied app-wide so Korean/kanji renders glyphs
      // (ThemeData folds fontFamilyFallback into the textTheme styles).
      expect(
        theme.textTheme.bodyMedium?.fontFamilyFallback,
        MxTypography.fontFamilyFallback,
      );
    });

    test('dark theme uses dark brightness and dark bg scaffold', () {
      final ThemeData theme = MxTheme.dark;

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, MxColors.dark.bg);
    });

    test('color scheme is pinned to tokens, not seed-generated', () {
      final ColorScheme light = MxTheme.light.colorScheme;

      expect(light.primary, MxColors.light.accent);
      expect(light.onPrimary, MxColors.light.accentContrast);
      expect(light.surface, MxColors.light.surface);
      expect(light.onSurface, MxColors.light.text);
      expect(light.error, MxColors.light.danger);
      expect(light.outline, MxColors.light.borderStrong);
      expect(light.outlineVariant, MxColors.light.border);
    });

    test('registers MxColors and MxShadows extensions per brightness', () {
      expect(MxTheme.light.extension<MxColors>(), same(MxColors.light));
      expect(MxTheme.light.extension<MxShadows>(), same(MxShadows.light));
      expect(MxTheme.dark.extension<MxColors>(), same(MxColors.dark));
      expect(MxTheme.dark.extension<MxShadows>(), same(MxShadows.dark));
    });

    testWidgets('context helpers resolve the active extensions', (
      tester,
    ) async {
      late MxColors colors;
      late MxShadows shadows;
      await tester.pumpWidget(
        MaterialApp(
          theme: MxTheme.dark,
          home: Builder(
            builder: (context) {
              colors = context.mxColors;
              shadows = context.mxShadows;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors, same(MxColors.dark));
      expect(shadows, same(MxShadows.dark));
    });
  });

  group('MxColors', () {
    test('light and dark differ for theme-varying tokens', () {
      expect(MxColors.light.accent, isNot(MxColors.dark.accent));
      expect(MxColors.light.bg, isNot(MxColors.dark.bg));
      expect(MxColors.light.text, isNot(MxColors.dark.text));
      expect(MxColors.light.surface, isNot(MxColors.dark.surface));
    });

    test('contract aliases resolve from the base palette', () {
      const MxColors c = MxColors.light;

      expect(c.statusNew, c.info);
      expect(c.statusMastered, c.success);
      expect(c.masteryLow, c.danger);
      expect(c.ratingCorrect, c.success);
      expect(c.ratingWrongSoft, c.dangerSoft);
      expect(c.selfPartial, c.warn);
    });

    test('lerp returns the endpoints at t=0 and t=1', () {
      final MxColors mid = MxColors.light.lerp(MxColors.dark, 0);
      final MxColors end = MxColors.light.lerp(MxColors.dark, 1);

      expect(mid.accent, MxColors.light.accent);
      expect(end.accent, MxColors.dark.accent);
    });

    test('copyWith overrides only the named field', () {
      const Color override = Color(0xFF123456);
      final MxColors c = MxColors.light.copyWith(accent: override);

      expect(c.accent, override);
      expect(c.bg, MxColors.light.bg);
    });
  });

  group('MxShadows', () {
    test('uses neutral (zero-saturation) shadow colors only', () {
      for (final BoxShadow shadow in <BoxShadow>[
        ...MxShadows.light.sm,
        ...MxShadows.light.md,
        ...MxShadows.light.lg,
        ...MxShadows.dark.sm,
        ...MxShadows.dark.md,
        ...MxShadows.dark.lg,
      ]) {
        expect(
          HSLColor.fromColor(shadow.color).saturation,
          lessThan(0.15),
          reason: 'shadows must stay neutral, never colored/glowing',
        );
      }
    });

    test('lerp returns the endpoints at t=0 and t=1', () {
      final MxShadows start = MxShadows.light.lerp(MxShadows.dark, 0);
      final MxShadows end = MxShadows.light.lerp(MxShadows.dark, 1);

      expect(start.sm.first.color, MxShadows.light.sm.first.color);
      expect(end.sm.first.color, MxShadows.dark.sm.first.color);
    });
  });

  group('MxTypography', () {
    test('exposes the full Material text scale with MemoX sizes', () {
      const TextTheme t = MxTypography.textTheme;

      expect(t.displayLarge?.fontSize, 34);
      expect(t.displayLarge?.fontWeight, MxTypography.extrabold);
      expect(t.titleMedium?.fontSize, 16);
      expect(t.bodyMedium?.fontSize, 14);
      expect(t.labelSmall?.fontSize, 11);
    });
  });

  group('MxSpacing / MxRadius', () {
    test('scale follows the 4px base and semantic roles', () {
      expect(MxSpacing.space4, 16);
      expect(MxSpacing.screen, 20);
      expect(MxSpacing.minTouchTarget, 48);
      expect(MxRadius.card, MxRadius.lg);
      expect(MxRadius.button, MxRadius.pill);
    });
  });
}
