import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';
import 'package:memox/presentation/shared/layouts/mx_list_scaffold.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

import '../../../support/golden_harness.dart';

void main() {
  group('MxScaffold', () {
    testWidgets('renders the body inside the page gutter by default', (
      tester,
    ) async {
      await pumpThemedHome(
        tester,
        const MxScaffold(
          appBar: MxAppBar(title: 'Library'),
          body: Text('content'),
        ),
      );

      expect(find.text('content'), findsOneWidget);
      expect(find.byType(MxContentShell), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
    });

    testWidgets('omits the page gutter when useShell is false', (tester) async {
      await pumpThemedHome(
        tester,
        const MxScaffold(useShell: false, body: Text('full-bleed')),
      );

      expect(find.text('full-bleed'), findsOneWidget);
      expect(find.byType(MxContentShell), findsNothing);
    });

    testWidgets('mounts the FAB and bottom-nav slots', (tester) async {
      await pumpThemedHome(
        tester,
        MxScaffold(
          body: const Text('body'),
          floatingActionButton: MxFab(icon: Icons.add, onPressed: () {}),
          bottomNavigationBar: const SizedBox(
            key: ValueKey<String>('bottom'),
            height: 56,
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('bottom')), findsOneWidget);
    });
  });

  group('MxListScaffold', () {
    testWidgets('builds a separated list and pins the header', (tester) async {
      await pumpThemedHome(
        tester,
        MxListScaffold(
          appBar: const MxAppBar(title: 'Decks'),
          header: const Text('header'),
          itemCount: 3,
          itemBuilder: (context, index) => Text('row $index'),
        ),
      );

      expect(find.text('header'), findsOneWidget);
      expect(find.text('row 0'), findsOneWidget);
      expect(find.text('row 2'), findsOneWidget);
    });
  });
}
