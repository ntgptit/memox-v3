import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('locks the dialog and keeps equal-width actions in one row', (
    WidgetTester tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (BuildContext context) => ElevatedButton(
            onPressed: () async {
              result = await showMxNameDialog(
                context,
                title: 'Add tag',
                fieldLabel: 'Tags',
                confirmLabel: 'Add',
                cancelLabel: 'Cancel',
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text('Add tag'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    final Finder cancelButton = find.widgetWithText(OutlinedButton, 'Cancel');
    final Finder confirmButton = find.widgetWithText(FilledButton, 'Add');
    expect(
      tester.getSize(cancelButton).width,
      closeTo(tester.getSize(confirmButton).width, 0.1),
    );
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNull);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('Add tag'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Add tag'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  TOPIK II  ');
    await tester.pump();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(result, 'TOPIK II');
  });
}
