import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

void main() {
  test('app bar uses shared horizontal padding tokens', () {
    final ThemeData theme = AppTheme.light();

    expect(theme.appBarTheme.titleSpacing, SpacingTokens.lg);
    expect(
      theme.appBarTheme.actionsPadding,
      const EdgeInsetsDirectional.only(end: SpacingTokens.lg),
    );
  });

  test('slider theme matches the MemoX settings slider contract', () {
    final ThemeData theme = AppTheme.light();

    expect(theme.sliderTheme.trackHeight, SpacingTokens.sm);
    expect(theme.sliderTheme.activeTrackColor, theme.colorScheme.primary);
    expect(
      theme.sliderTheme.inactiveTrackColor,
      theme.colorScheme.surfaceContainerHigh,
    );
    expect(theme.sliderTheme.thumbColor, theme.colorScheme.surface);
    expect(theme.sliderTheme.showValueIndicator, ShowValueIndicator.never);
  });
}
