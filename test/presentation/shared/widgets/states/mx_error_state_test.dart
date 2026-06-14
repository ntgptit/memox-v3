import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

void main() {
  testWidgets('MxErrorState uses the large icon token', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: MxErrorState(
            title: 'Could not load',
            message: 'Tap to retry.',
            retryLabel: 'Retry',
            onRetry: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(
      tester.getSize(find.byIcon(Icons.error_outline)).shortestSide,
      SizeTokens.iconXl,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
