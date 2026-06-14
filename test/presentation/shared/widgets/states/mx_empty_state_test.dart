import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';

void main() {
  testWidgets('MxEmptyState uses the large icon token', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: MxEmptyState(
            icon: Icons.inbox_outlined,
            title: 'No cards yet',
            message: 'Add cards to start reviewing.',
            actionLabel: 'Add cards',
            onAction: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(
      tester.getSize(find.byIcon(Icons.inbox_outlined)).shortestSide,
      SizeTokens.iconXl,
    );
    expect(find.text('Add cards'), findsOneWidget);
  });
}
