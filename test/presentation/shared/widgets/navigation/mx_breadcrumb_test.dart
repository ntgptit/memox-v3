import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: SizedBox(width: 400, child: child)),
);

void main() {
  testWidgets('aligns breadcrumb content to the left edge', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const MxBreadcrumb(
          segments: <MxBreadcrumbSegment>[
            MxBreadcrumbSegment(label: 'Library'),
            MxBreadcrumbSegment(label: 'Korean'),
            MxBreadcrumbSegment(label: 'fdf'),
          ],
        ),
      ),
    );

    final double left = tester.getTopLeft(find.text('Library')).dx;

    expect(left, lessThan(40));
  });
}
