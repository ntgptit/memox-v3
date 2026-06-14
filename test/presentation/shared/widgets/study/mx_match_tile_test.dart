import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/presentation/shared/widgets/study/mx_match_tile.dart';

void main() {
  testWidgets('MxMatchTile default height uses the touch token', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: MxMatchTile(
            label: 'Card',
            state: MxMatchState.idle,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MxMatchTile)).height, SizeTokens.touch);
  });
}
