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
}
