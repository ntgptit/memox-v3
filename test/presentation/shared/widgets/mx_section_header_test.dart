import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/mx_theme.dart';
import 'package:memox/presentation/shared/widgets/mx_section_header.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MxTheme.light,
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('renders the section title', (tester) async {
    await pump(tester, const MxSectionHeader(title: 'Per-deck mastery'));
    expect(find.text('Per-deck mastery'), findsOneWidget);
  });

  testWidgets('renders an optional trailing widget', (tester) async {
    await pump(
      tester,
      const MxSectionHeader(
        title: 'Recent decks',
        trailing: Icon(Icons.chevron_right),
      ),
    );
    expect(find.text('Recent decks'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
