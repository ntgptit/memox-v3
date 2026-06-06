import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('locks confirm dialogs and keeps equal-width actions', (
    WidgetTester tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (BuildContext context) => ElevatedButton(
            onPressed: () async {
              result = await showMxConfirmDialog(
                context,
                title: 'Delete card?',
                message: 'This will delete the flashcard.',
                confirmLabel: 'Delete',
                cancelLabel: 'Cancel',
                destructive: true,
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
    expect(find.text('Delete card?'), findsOneWidget);
    expect(find.text('This will delete the flashcard.'), findsOneWidget);

    final Finder cancelButton = find.widgetWithText(OutlinedButton, 'Cancel');
    final Finder confirmButton = find.widgetWithText(FilledButton, 'Delete');
    expect(
      tester.getSize(cancelButton).width,
      closeTo(tester.getSize(confirmButton).width, 0.1),
    );

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('Delete card?'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Delete card?'), findsOneWidget);

    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
