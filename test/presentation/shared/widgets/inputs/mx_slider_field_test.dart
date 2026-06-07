import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_slider_field.dart';

Widget _appShell(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('renders the labeled slider field layout', (tester) async {
    await tester.pumpWidget(
      _appShell(
        MxSliderField(
          label: 'Speech rate',
          valueLabel: '0.50x',
          value: 0.5,
          min: 0.3,
          max: 0.7,
          sublabels: const <String>['0.3x', 'Default', '0.7x'],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Speech rate'), findsOneWidget);
    expect(find.text('0.50x'), findsOneWidget);
    expect(find.text('0.3x'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('0.7x'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });
}
