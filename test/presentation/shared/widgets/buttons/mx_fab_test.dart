import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('renders a minimal icon-only FAB', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(
        MxFab.extended(icon: Icons.add, label: 'New card', onPressed: () {}),
      ),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('New card'), findsNothing);
    expect(find.byTooltip('New card'), findsOneWidget);
  });

  testWidgets('regular FAB also stays icon-only', (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(MxFab(icon: Icons.add, onPressed: () {}, tooltip: 'Create')),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byTooltip('Create'), findsOneWidget);
  });
}
