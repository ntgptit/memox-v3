import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';

void main() {
  testWidgets(
    'showMxBottomSheet uses the root navigator so it can overlap shell chrome',
    (WidgetTester tester) async {
      const Key buttonKey = ValueKey<String>('open_sheet');
      const Key sheetKey = ValueKey<String>('sheet_body');

      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Navigator(
              onGenerateRoute: (RouteSettings settings) =>
                  MaterialPageRoute<void>(
                    settings: settings,
                    builder: (BuildContext context) => Center(
                      child: TextButton(
                        key: buttonKey,
                        onPressed: () async {
                          await showMxBottomSheet<void>(
                            context,
                            builder: (BuildContext context) => const SizedBox(
                              key: sheetKey,
                              height: 120,
                              width: double.infinity,
                            ),
                          );
                        },
                        child: const Text('Open'),
                      ),
                    ),
                  ),
            ),
            bottomNavigationBar: const SizedBox(height: 80),
          ),
        ),
      );

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(sheetKey), findsOneWidget);
      expect(tester.getBottomLeft(find.byKey(sheetKey)).dy, greaterThan(760));
    },
  );
}
