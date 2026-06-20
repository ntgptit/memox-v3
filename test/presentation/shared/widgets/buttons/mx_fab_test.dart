import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';

import '../../../../support/golden_harness.dart';

void main() {
  group('MxFab', () {
    testWidgets('icon-only variant renders the glyph and fires onPressed', (
      tester,
    ) async {
      int taps = 0;
      await pumpThemed(
        tester,
        MxFab(
          icon: Icons.create_new_folder_outlined,
          tooltip: 'New folder',
          onPressed: () => taps++,
        ),
      );

      expect(find.byIcon(Icons.create_new_folder_outlined), findsOneWidget);
      await tester.tap(find.byType(MxFab));
      expect(taps, 1);
    });

    testWidgets('extended variant shows the label', (tester) async {
      await pumpThemed(
        tester,
        MxFab.extended(icon: Icons.add, label: 'New folder', onPressed: () {}),
      );

      expect(find.text('New folder'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('falls back to the label as tooltip when none given', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        MxFab.extended(icon: Icons.add, label: 'Create', onPressed: () {}),
      );

      final FloatingActionButton fab = tester.widget(
        find.byType(FloatingActionButton),
      );
      expect(fab.tooltip, 'Create');
    });
  });
}
