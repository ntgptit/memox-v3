import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/responsive/breakpoints.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';

void main() {
  testWidgets('MxContentShell default padding uses screen padding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MxContentShell(child: SizedBox(width: 120, height: 40)),
        ),
      ),
    );

    final Padding padding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(MxContentShell),
        matching: find.byType(Padding),
      ),
    );
    expect(
      padding.padding,
      isA<EdgeInsets>()
          .having(
            (EdgeInsets value) => value.left,
            'left',
            SpacingTokens.screenPadding,
          )
          .having(
            (EdgeInsets value) => value.right,
            'right',
            SpacingTokens.screenPadding,
          ),
    );

    final ConstrainedBox constrainedBox = tester.widget<ConstrainedBox>(
      find.descendant(
        of: find.byType(MxContentShell),
        matching: find.byType(ConstrainedBox),
      ),
    );
    expect(constrainedBox.constraints.maxWidth, Breakpoints.maxBodyWidth);
  });
}
