import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
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
    expect(tester.getSize(textField).height, 52);
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
      greaterThanOrEqualTo(14),
    );
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });
}
