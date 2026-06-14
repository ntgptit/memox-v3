import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';

void main() {
  testWidgets('MxSearchField renders at the mock height', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: MxSearchField(
                controller: controller,
                hintText: 'Search decks, cards, tags',
              ),
            ),
          ),
        ),
      ),
    );

    final Finder textField = find.byType(TextField);
    expect(tester.getSize(textField).height, SizeTokens.input);
    expect(
      tester.widget<TextField>(textField).decoration!.border,
      isA<OutlineInputBorder>().having(
        (OutlineInputBorder border) => border.borderRadius,
        'borderRadius',
        RadiusTokens.brMd,
      ),
    );
    expect(
      tester.getTopLeft(find.byIcon(Icons.search)).dx,
      greaterThanOrEqualTo(SpacingTokens.form),
    );
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  // Contract: the field owns the trailing inset, so an emptyTrailing widget sits
  // ~14px from the right edge — symmetric with the leading icon — regardless of
  // what the consumer passes. Guards the keycap-hugging-the-border regression.
  testWidgets(
    'MxSearchField insets emptyTrailing symmetric to the leading icon',
    (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: MxSearchField(
                  controller: controller,
                  hintText: 'Search folders',
                  emptyTrailing: const SizedBox(
                    key: ValueKey<String>('mx_trailing_probe'),
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final Rect field = tester.getRect(find.byType(TextField));
      final double leadingInset =
          tester.getRect(find.byIcon(Icons.search)).left - field.left;
      final double trailingInset =
          field.right -
          tester
              .getRect(find.byKey(const ValueKey<String>('mx_trailing_probe')))
              .right;

      expect(trailingInset, closeTo(SpacingTokens.form, 1.5));
      expect(trailingInset, closeTo(leadingInset, 1.5));
    },
  );
}
