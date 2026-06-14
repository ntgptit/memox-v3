import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/presentation/shared/widgets/status/mx_bar_chart.dart';

void main() {
  testWidgets('MxBarChart default height uses the chart token', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: MxBarChart(
            data: <MxBarDatum>[
              MxBarDatum(value: 3, label: 'Mon'),
              MxBarDatum(value: 5, label: 'Tue'),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MxBarChart)).height, SizeTokens.chart);
  });
}
