import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';

Widget _wrap({required ThemeData theme, required bool isError}) => MaterialApp(
  theme: theme,
  home: Scaffold(
    body: Builder(
      builder: (BuildContext context) => TextButton(
        onPressed: () => showMxSnackbar(
          context,
          message: isError ? 'Failed to save changes' : 'Saved changes',
          isError: isError,
        ),
        child: const Text('Show snackbar'),
      ),
    ),
  ),
);

void main() {
  testWidgets('uses the shared snackbar surface for normal messages', (
    WidgetTester tester,
  ) async {
    final ThemeData theme = AppTheme.light();

    await tester.pumpWidget(_wrap(theme: theme, isError: false));
    await tester.tap(find.text('Show snackbar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    final SnackBar snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, theme.colorScheme.surfaceContainerHighest);

    final Text message = tester.widget<Text>(find.text('Saved changes'));
    expect(message.style?.color, theme.colorScheme.onSurface);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  testWidgets('shows error snackbars on the same surface with an accent icon', (
    WidgetTester tester,
  ) async {
    final ThemeData theme = AppTheme.dark();

    await tester.pumpWidget(_wrap(theme: theme, isError: true));
    await tester.tap(find.text('Show snackbar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    final SnackBar snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, theme.colorScheme.surfaceContainerHighest);

    final Text message = tester.widget<Text>(
      find.text('Failed to save changes'),
    );
    expect(message.style?.color, theme.colorScheme.onSurface);

    final Icon icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
    expect(icon.color, theme.colorScheme.error);
  });
}
